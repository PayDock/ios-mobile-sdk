//
//  ActiveTelemetry.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG
import Foundation

/// Bound when activation passes. `report` hands the event to the dispatcher and returns; the reducer, the effect
/// handler and every port run only on the dispatcher's queue, never the caller's thread (R_14).
///
/// `dispatch(intent)` works through a first-in, first-out list inside one queue task: reduce with the clock, the
/// monotonic clock and the session's sequence, run the effects, append their follow-ups, until the list is empty. No
/// follow-up goes back through the dispatcher. Reports use the bounded `post`; every module signal (the flush timer,
/// the runner's retry, the background callback, the test record's flush, a delivered diagnostic) uses `postDelayed`,
/// which never drops.
///
/// Crashes (R_03, R_09, R_11): start installs the exception handler chain on the calling thread, then, on the queue,
/// builds the frame classifier from the SDK's image and the saved ranges before it subscribes to the diagnostics.
package final class ActiveTelemetry: Telemetry, TelemetryRuntime, @unchecked Sendable {
    package struct Ports: Sendable {
        package let store: any DurableStore
        package let exporter: any Exporter
        package let lifecycle: any AppLifecycle
        package let connection: any ConnectionMonitor
        package let clockOffset: ClockOffset
        package let retryPolicy: RetryPolicy
        package let stateStore: any TelemetryStateStore
        package let imageReader: any SdkImageReading
        package let diagnostics: any DiagnosticSource
        /// Nil: no handler is installed.
        package let exceptionHandlers: ExceptionHandlerChain?
        package let resolver: any AddressResolving

        package init(store: any DurableStore = NoOpDurableStore(), exporter: any Exporter = NoOpExporter(),
                     lifecycle: any AppLifecycle = NoOpAppLifecycle(),
                     connection: any ConnectionMonitor = NoOpConnectionMonitor(),
                     clockOffset: ClockOffset = ClockOffset(clock: SystemClock()), retryPolicy: RetryPolicy = RetryPolicy(),
                     stateStore: any TelemetryStateStore = NoOpTelemetryStateStore(),
                     imageReader: any SdkImageReading = NoOpSdkImageReader(),
                     diagnostics: any DiagnosticSource = NoOpDiagnosticSource(),
                     exceptionHandlers: ExceptionHandlerChain? = nil,
                     resolver: any AddressResolving = NoOpAddressResolver()) {
            self.store = store
            self.exporter = exporter
            self.lifecycle = lifecycle
            self.connection = connection
            self.clockOffset = clockOffset
            self.retryPolicy = retryPolicy
            self.stateStore = stateStore
            self.imageReader = imageReader
            self.diagnostics = diagnostics
            self.exceptionHandlers = exceptionHandlers
            self.resolver = resolver
        }
    }

    /// Runs a task on the main queue after a delay in milliseconds.
    package typealias MainScheduler = @Sendable (_ milliseconds: Int64, _ task: @escaping @Sendable () -> Void) -> Void

    /// `DispatchQueue.main.asyncAfter`.
    package static let mainQueue: MainScheduler = { milliseconds, task in
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(milliseconds)), execute: task)
    }

    /// The SDK's image once start has read it; nil before, or when it can't be read.
    private final class ImageBox: @unchecked Sendable {
        private let lock = NSLock()
        private var image: SdkImage?

        var current: SdkImage? {
            get {
                lock.lock()
                defer { lock.unlock() }
                return image
            }
            set {
                lock.lock()
                defer { lock.unlock() }
                image = newValue
            }
        }
    }

    /// Builds the device context once, on first use, then gives the same attributes.
    private final class DeviceContextCache: DeviceContextProvider, @unchecked Sendable {
        private let provider: any DeviceContextProvider
        private let lock = NSLock()
        private var attributes: ResourceAttributes?

        init(provider: any DeviceContextProvider) {
            self.provider = provider
        }

        var built: ResourceAttributes? {
            lock.lock()
            defer { lock.unlock() }
            return attributes
        }

        func current() -> ResourceAttributes {
            if let built {
                return built
            }
            let fresh = provider.current()
            lock.lock()
            defer { lock.unlock() }
            if let attributes {
                return attributes
            }
            attributes = fresh
            return fresh
        }
    }

    /// The test record's `paydock.error.code` (R_16).
    package static let testRecordCode = "TelemetryTestRecord"
    /// The test record's `exception.type`.
    package static let testRecordType = "PaydockTelemetry.TelemetryTestRecord"
    /// The debug test crash's exception name (R_13).
    package static let testCrashName = "PaydockTelemetryTestCrash"

    package let credentials: TelemetryCredentials
    package let level: TelemetryLevel
    /// `idGenerator.newId()`, once, at init.
    package let sessionId: String
    /// This session's record IDs.
    package let sequence: RecordSequence
    package var isActive: Bool { true }

    /// Nil until `start()` has run on the queue.
    package var resourceAttributes: ResourceAttributes? { deviceContext.built }

    private let deviceContext: DeviceContextCache
    private let clock: any Clock
    private let monotonic: any MonotonicClock
    private let dispatcher: any TelemetryDispatcher
    private let ports: Ports
    private let scheduleOnMain: MainScheduler
    private let image = ImageBox()
    private let classifier = FrameClassifierBox()
    private let lock = NSLock()
    private var state: TelemetryState
    private var started = false
    private var handler: TelemetryEffectHandler?

    package init(
        credentials: TelemetryCredentials,
        level: TelemetryLevel,
        deviceContextProvider: any DeviceContextProvider,
        clock: any Clock = SystemClock(),
        monotonic: any MonotonicClock = SystemMonotonicClock(),
        idGenerator: any IdGenerator = RandomIdGenerator(),
        dispatcher: any TelemetryDispatcher = SerialTelemetryDispatcher(),
        ports: Ports = Ports(),
        scheduleOnMain: @escaping MainScheduler = ActiveTelemetry.mainQueue
    ) {
        self.credentials = credentials
        self.level = level
        self.deviceContext = DeviceContextCache(provider: deviceContextProvider)
        self.clock = clock
        self.monotonic = monotonic
        self.dispatcher = dispatcher
        self.ports = ports
        self.scheduleOnMain = scheduleOnMain
        self.sequence = RecordSequence()
        let sessionId = idGenerator.newId()
        self.sessionId = sessionId
        self.state = TelemetryState(level: level, enabled: true, sessionId: sessionId)
        let runner = ExportRunner(
            store: ports.store,
            exporter: ports.exporter,
            deviceContext: deviceContext,
            clockOffset: ports.clockOffset,
            monotonic: monotonic,
            retryPolicy: ports.retryPolicy,
            scheduleRetry: { [weak self] delay in self?.post(.flush(.retry), after: delay) }
        )
        self.handler = TelemetryEffectHandler(
            store: ports.store,
            runner: runner,
            deviceContext: deviceContext,
            connection: ports.connection,
            clock: clock,
            scheduleFlush: { [weak self] delay in self?.post(.flush(.timer), after: delay) }
        )
    }

    /// Production wiring; no I/O on the calling thread: the file store resolves its directory on first use, the
    /// transport builds its client on the first send, and the lifecycle and the monitor register only at start.
    package static func create(credentials: TelemetryCredentials, level: TelemetryLevel, sdkVersion: String,
                               environmentName: String) -> ActiveTelemetry {
        let provider = DefaultDeviceContextProvider(
            platform: ApplePlatformInfo(),
            installationIds: InstallationIdStore(store: UserDefaultsKeyValueStore(), idGenerator: RandomIdGenerator()),
            sdkVersion: sdkVersion,
            environmentName: environmentName
        )
        let clockOffset = ClockOffset(clock: SystemClock())
        let transport = OtlpHttpTransport(endpoint: credentials.endpoint, clockOffset: clockOffset)
        let ports = Ports(
            store: FileDurableStore(directory: { FileDurableStore.defaultDirectory() }),
            exporter: OtlpExporter(transport: transport, credentials: credentials),
            lifecycle: platformLifecycle(),
            connection: platformConnectionMonitor(),
            clockOffset: clockOffset,
            stateStore: FileStateStore(directory: { FileDurableStore.defaultDirectory() }),
            imageReader: DyldSdkImageReader(),
            diagnostics: platformDiagnostics(),
            exceptionHandlers: ExceptionHandlerChain.shared,
            resolver: DladdrAddressResolver()
        )
        return ActiveTelemetry(credentials: credentials, level: level, deviceContextProvider: provider, ports: ports)
    }

    package func report(_ event: TelemetryEvent) {
        dispatcher.post { [self] in dispatch(.reported(event)) }
    }

    /// R_03: the site is described and classified here, on the queue, never on the caller's thread.
    package func report(_ event: TelemetryEvent, site: ReportSite) {
        dispatcher.post { [self] in
            dispatch(.reported(ReportSiteResolver.resolve(event, site: site, resolver: ports.resolver,
                                                          image: image.current, classifier: classifier.current)))
        }
    }

    /// Runs once: installs the exception handler chain on the calling thread; then, on the queue, builds the frame
    /// classifier and subscribes to the diagnostics, builds the device context, starts the connection monitor,
    /// registers the background flush, counts the stored records and flushes, so records from earlier runs go first.
    package func start() {
        lock.lock()
        let isFirst = !started
        started = true
        lock.unlock()
        guard isFirst else {
            return
        }
        ports.exceptionHandlers?.install(CrashRecorder(
            sessionId: sessionId, sequence: sequence, store: ports.store, stateStore: ports.stateStore,
            image: { [image] in image.current }, classifier: classifier, resolver: ports.resolver,
            connection: ports.connection, clock: clock
        ))
        dispatcher.post { [self] in
            buildClassifier()
            ports.diagnostics.start { [weak self] diagnostics in
                self?.dispatcher.postDelayed(milliseconds: 0) { [weak self] in self?.handle(diagnostics) }
            }
            _ = deviceContext.current()
            ports.connection.start()
            ports.lifecycle.register { [weak self] finished in
                guard let self else {
                    finished()
                    return
                }
                dispatcher.postDelayed(milliseconds: 0) { [weak self] in
                    self?.dispatch(.appBackgrounded)
                    finished()
                }
            }
            dispatch(.pendingCounted(ports.store.count()))
            dispatch(.flush(.start))
        }
    }

    /// Stores and sends one test record, an SDK error with the test code (R_16).
    package func sendTestRecord() {
        let event = TelemetryEvent.sdkError(error: TelemetryEvent.ErrorInfo(type: Self.testRecordType, frames: []),
                                            errorCode: Self.testRecordCode)
        dispatcher.post { [self] in dispatch(.reported(event)) }
        post(.flush(.debugSend), after: 0)
    }

    /// R_13: raises a test Objective-C exception from SDK code on the main thread after testCrashDelayMilliseconds.
    package func raiseTestCrash() {
        scheduleOnMain(TelemetryLimits.testCrashDelayMilliseconds) { Self.raiseTestException() }
    }

    /// For tests.
    package func currentState() -> TelemetryState {
        lock.lock()
        defer { lock.unlock() }
        return state
    }

    /// A module signal: never dropped.
    private func post(_ intent: TelemetryIntent, after milliseconds: Int64) {
        dispatcher.postDelayed(milliseconds: milliseconds) { [weak self] in self?.dispatch(intent) }
    }

    /// Runs only on the dispatcher's queue: reads the SDK's image, saves its ranges with the current build first when
    /// they differ from the saved ones, and sets the classifier. Without an image, the saved builds classify alone.
    private func buildClassifier() {
        let read = ports.imageReader.read()
        image.current = read?.image
        let saved = ports.stateStore.loadFramePoints()
        var builds = saved
        if let read, let current = FramePoints(imageName: read.image.name, uuid: read.image.uuid, points: read.points) {
            builds = FrameClassifier.merging(current: current, saved: saved)
            if builds != saved {
                ports.stateStore.saveFramePoints(builds)
            }
        }
        classifier.current = builds.isEmpty ? nil : FrameClassifier(builds: builds)
    }

    /// Runs only on the dispatcher's queue: the diagnostics of earlier launches become events through the reducer.
    private func handle(_ diagnostics: [MetricKitDiagnostic]) {
        let result = DiagnosticReader.events(diagnostics, marker: ports.stateStore.loadCrashMarker(),
                                             classifier: classifier.current, now: clock.now())
        if result.clearMarker {
            ports.stateStore.clearCrashMarker()
        }
        for event in result.events {
            dispatch(.reported(event))
        }
    }

    /// Runs only on the dispatcher's queue.
    private func dispatch(_ intent: TelemetryIntent) {
        var intents = [intent]
        while !intents.isEmpty {
            let next = intents.removeFirst()
            let now = clock.now()
            let elapsed = monotonic.elapsed()
            lock.lock()
            let result = TelemetryReducer.reduce(state, next, now: now, elapsed: elapsed, sequence: sequence)
            state = result.state
            lock.unlock()
            intents.append(contentsOf: handler?.run(result.effects) ?? [])
        }
    }

    /// A non-nil reason: CoreFoundation crashes on a nil one before any handler runs.
    private static func raiseTestException() {
        NSException(name: NSExceptionName(testCrashName), reason: "test", userInfo: nil).raise()
    }

    private static func platformDiagnostics() -> any DiagnosticSource {
        #if os(iOS) && canImport(MetricKit)
        MetricKitDiagnosticSource()
        #else
        NoOpDiagnosticSource()
        #endif
    }

    private static func platformLifecycle() -> any AppLifecycle {
        #if canImport(UIKit)
        UIKitAppLifecycle()
        #else
        NoOpAppLifecycle()
        #endif
    }

    private static func platformConnectionMonitor() -> any ConnectionMonitor {
        #if canImport(Network)
        PathConnectionMonitor()
        #else
        NoOpConnectionMonitor()
        #endif
    }
}
#endif
