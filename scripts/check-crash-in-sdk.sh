#!/usr/bin/env bash

# Crash-in-SDK check (spec § 7.2, R_14): in a stripped, optimised debug build of the example app, a crash from SDK code
# is recorded with paydock.exception.in_sdk true and a crash from app code with false. The classifier never reads
# symbols, so the build is stripped first and the check fails while any MobileSDK symbol is left in the executable.
#
#   build  ExampleApp, scheme "ExampleApp Sandbox", configuration "Debug (Sandbox)", built like a release (-O, whole
#          module, no testability, no exported global symbols, no debug dylib), derived data under
#          .build/DerivedData-crash-check (900 s limit). A debug configuration enables testability and exports global
#          symbols, which strip must keep; these settings turn both off, as a release does
#   strip  build settings on the command line strip nothing (the target sets STRIP_INSTALLED_PRODUCT = NO for its debug
#          configurations), so the script strips the built executable of every symbol itself (`xcrun strip`, Xcode's
#          "all symbols" style for an app) and re-signs the app ad hoc (`codesign --force --sign -`), 120 s each
#   sdk    PAYDOCK_TELEMETRY_TEST_CRASH=true: the runtime raises an exception from SDK code 3 s after start
#   app    EXAMPLE_APP_TEST_CRASH=true: the example app raises an exception from app code 3 s after launch
#
# For each case: uninstall, install, launch with telemetry active (a gateway that never answers, so the record stays on
# disk) and the case's variable, wait at most 60 s for the process to end, then read
# <data container>/Library/Application Support/paydock_telemetry/*.json and expect exactly one record with event.name
# paydock.crash and paydock.crash.source nsexception, with paydock.exception.in_sdk true (sdk) or false (app).
#
# Every step runs under a hard time limit (perl alarm: macOS has no timeout). Never collects diagnostics or logs.
#
# Usage: scripts/check-crash-in-sdk.sh [<simulator udid>]
#   Without a UDID, the first booted iPhone simulator is used. A given simulator is booted with a bounded wait.
# Exit codes: 0 both cases PASS; 1 on any FAIL or when the build, the strip check or the simulator fails.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT="$PROJECT_ROOT/ExampleApp/ExampleApp.xcodeproj"
SCHEME="ExampleApp Sandbox"
CONFIGURATION="Debug (Sandbox)"
DERIVED_DATA="$PROJECT_ROOT/.build/DerivedData-crash-check"
APP="$DERIVED_DATA/Build/Products/$CONFIGURATION-iphonesimulator/ExampleApp.app"
EXECUTABLE="$APP/ExampleApp"
BUNDLE_ID="com.paydock.multitenant.sandbox"
STORE_RELATIVE="Library/Application Support/paydock_telemetry"

BUILD_LIMIT=900
STRIP_LIMIT=120
BOOT_LIMIT=120
LAUNCH_LIMIT=60
STEP_LIMIT=60

# Runs a command under a hard limit in seconds (SIGALRM at the limit).
limit() {
    local seconds="$1"
    shift
    perl -e 'alarm shift @ARGV; exec @ARGV' "$seconds" "$@"
}

fail() {
    echo "ERROR: $*" >&2
    exit 1
}

# The simulator: the given UDID, booted with a bounded wait, or the first booted iPhone.
UDID="${1:-}"
if [[ -n "$UDID" ]]; then
    limit "$BOOT_LIMIT" xcrun simctl bootstatus "$UDID" -b >/dev/null 2>&1 ||
        fail "simulator $UDID did not boot within ${BOOT_LIMIT} s"
else
    UDID="$(limit "$STEP_LIMIT" xcrun simctl list devices booted 2>/dev/null |
        sed -n -E 's/^[[:space:]]*iPhone[^(]*\(([0-9A-F-]{36})\) \(Booted\).*/\1/p' | head -n 1)"
    [[ -n "$UDID" ]] || fail "no booted iPhone simulator: boot one or pass its UDID"
fi

echo "Building ExampleApp ($CONFIGURATION, built like a release) ..."
limit "$BUILD_LIMIT" xcodebuild build \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$DERIVED_DATA" \
    -skipPackagePluginValidation \
    -skipMacroValidation \
    SWIFT_OPTIMIZATION_LEVEL=-O \
    SWIFT_COMPILATION_MODE=wholemodule \
    ENABLE_TESTABILITY=NO \
    LD_EXPORT_GLOBAL_SYMBOLS=NO \
    ENABLE_DEBUG_DYLIB=NO >/dev/null 2>&1 ||
    fail "the build failed or took longer than ${BUILD_LIMIT} s (rerun the xcodebuild command above to see why)"
[[ -x "$EXECUTABLE" ]] || fail "no executable at $EXECUTABLE"

# Build settings strip nothing here: the target sets STRIP_INSTALLED_PRODUCT = NO for its debug configurations. Strip
# every symbol from the executable, as Xcode's "all symbols" style does for an app, then re-sign the app ad hoc: the
# simulator refuses an app whose executable no longer matches its signature.
echo "Stripping and re-signing ExampleApp ..."
limit "$STRIP_LIMIT" xcrun strip "$EXECUTABLE" >/dev/null 2>&1 ||
    fail "strip failed or took longer than ${STRIP_LIMIT} s"
limit "$STRIP_LIMIT" codesign --force --sign - "$APP" >/dev/null 2>&1 ||
    fail "the ad hoc re-sign failed or took longer than ${STRIP_LIMIT} s"

# The classifier must work without symbols: the build counts only when nothing of MobileSDK is left to read.
SYMBOLS="$(limit "$STEP_LIMIT" nm "$EXECUTABLE" 2>/dev/null)" || fail "nm could not read $EXECUTABLE"
SDK_SYMBOLS="$(grep -c '9MobileSDK' <<<"$SYMBOLS")"
[[ "$SDK_SYMBOLS" == "0" ]] || fail "the executable is not stripped: nm finds $SDK_SYMBOLS 9MobileSDK symbols"

# Prints the in_sdk value of the one nsexception crash record in the store directory given as its argument ("true",
# "false" or "absent"), or why there is not exactly one (exit 1).
READ_CRASH="$(cat <<'PYTHON'
import glob, json, os, sys

def attributes(record):
    values = {}
    for attribute in record.get("attributes", []):
        value = attribute.get("value", {})
        for kind in ("stringValue", "boolValue", "intValue", "doubleValue"):
            if kind in value:
                values[attribute.get("key")] = value[kind]
    return values

crashes = []
for path in sorted(glob.glob(os.path.join(sys.argv[1], "*.json"))):
    try:
        with open(path, encoding="utf-8") as handle:
            values = attributes(json.load(handle))
    except (OSError, ValueError):
        continue
    if values.get("event.name") == "paydock.crash" and values.get("paydock.crash.source") == "nsexception":
        crashes.append(values)

if len(crashes) != 1:
    print(f"{len(crashes)} nsexception crash records")
    sys.exit(1)
in_sdk = crashes[0].get("paydock.exception.in_sdk")
print("absent" if in_sdk is None else ("true" if in_sdk is True else "false" if in_sdk is False else repr(in_sdk)))
PYTHON
)"

# Runs one case: its name, the variable that raises its crash, and the expected in_sdk. Prints one PASS or FAIL line.
run_case() {
    local name="$1" variable="$2" expected="$3"
    limit "$STEP_LIMIT" xcrun simctl terminate "$UDID" "$BUNDLE_ID" >/dev/null 2>&1
    limit "$STEP_LIMIT" xcrun simctl uninstall "$UDID" "$BUNDLE_ID" >/dev/null 2>&1
    if ! limit "$STEP_LIMIT" xcrun simctl install "$UDID" "$APP" >/dev/null 2>&1; then
        echo "FAIL $name: the app did not install"
        return 1
    fi

    # --console-pty keeps simctl attached until the process ends; its output is discarded, never collected. At the
    # limit simctl ends the app and exits 0, so the time taken, not the status, says whether the process ended.
    local started=$SECONDS
    env SIMCTL_CHILD_PAYDOCK_TELEMETRY_OTLP_ENDPOINT="https://telemetry.invalid/otlp/v1/logs" \
        SIMCTL_CHILD_PAYDOCK_TELEMETRY_OTLP_AUTH="check" \
        "SIMCTL_CHILD_$variable=true" \
        perl -e 'alarm shift @ARGV; exec @ARGV' "$LAUNCH_LIMIT" \
        xcrun simctl launch --console-pty --terminate-running-process "$UDID" "$BUNDLE_ID" >/dev/null 2>&1
    if (( SECONDS - started >= LAUNCH_LIMIT )); then
        limit "$STEP_LIMIT" xcrun simctl terminate "$UDID" "$BUNDLE_ID" >/dev/null 2>&1
        echo "FAIL $name: the app did not end within ${LAUNCH_LIMIT} s"
        return 1
    fi

    local container
    container="$(limit "$STEP_LIMIT" xcrun simctl get_app_container "$UDID" "$BUNDLE_ID" data 2>/dev/null)"
    if [[ -z "$container" ]]; then
        echo "FAIL $name: no data container"
        return 1
    fi
    local found
    if ! found="$(limit "$STEP_LIMIT" /usr/bin/python3 -I -c "$READ_CRASH" "$container/$STORE_RELATIVE")"; then
        echo "FAIL $name: $found"
        return 1
    fi
    if [[ "$found" != "$expected" ]]; then
        echo "FAIL $name: in_sdk $found, expected $expected"
        return 1
    fi
    echo "PASS $name: one nsexception crash record, in_sdk $found"
}

failures=0
run_case "sdk" "PAYDOCK_TELEMETRY_TEST_CRASH" "true" || failures=$((failures + 1))
run_case "app" "EXAMPLE_APP_TEST_CRASH" "false" || failures=$((failures + 1))

[[ $failures -eq 0 ]] || exit 1
