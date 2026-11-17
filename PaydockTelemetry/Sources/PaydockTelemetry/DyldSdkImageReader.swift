//
//  DyldSdkImageReader.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG
import Foundation
import MachO

/// `#dsohandle` → the dyld image with that header (`_dyld_image_count`, `_dyld_get_image_header`,
/// `_dyld_get_image_name`); its `LC_UUID`; `__TEXT,__text` bounds via `getsectiondata`; `__TEXT,__swift5_types`
/// records: each a relative pointer (low 2 bits: 0 direct, 1 indirect) to a type context descriptor; the module is the
/// name of the first ancestor with kind 0 (flags & 0x1F) following the parent's relative indirectable pointer (low bit
/// indirect); the accessor is the relative pointer at descriptor + 12. Skips modules `__C` and `__C_Synthesized`, a zero
/// accessor and an accessor outside `__text`. Unaligned loads only.
package struct DyldSdkImageReader: SdkImageReading {
    private static let skippedModules: Set<String> = ["__C", "__C_Synthesized"]
    /// Bounds the walk up a descriptor's parents, so a malformed chain ends.
    private static let maxAncestors = 32
    private static let headerSize = MemoryLayout<mach_header_64>.size
    private static let recordSize = 4
    private static let accessorField = 12
    private static let parentField = 4
    private static let nameField = 8
    private static let moduleKind: UInt32 = 0
    private static let kindMask: UInt32 = 0x1F

    package init() {}

    package func read() -> (image: SdkImage, points: [TypePoint])? {
        let own = UnsafeRawPointer(#dsohandle)
        for index in 0..<_dyld_image_count() {
            guard let header = _dyld_get_image_header(index), UnsafeRawPointer(header) == own else {
                continue
            }
            guard let name = _dyld_get_image_name(index) else {
                return nil
            }
            return Self.read(header: own, path: String(cString: name))
        }
        return nil
    }

    private static func read(header: UnsafeRawPointer, path: String) -> (image: SdkImage, points: [TypePoint])? {
        guard header.loadUnaligned(as: UInt32.self) == MH_MAGIC_64, let uuid = uuid(header) else {
            return nil
        }
        let macho = header.assumingMemoryBound(to: mach_header_64.self)
        var textSize: UInt = 0
        guard let text = getsectiondata(macho, "__TEXT", "__text", &textSize) else {
            return nil
        }
        let loadAddress = UInt(bitPattern: header)
        let textStart = UInt(bitPattern: text)
        let textBounds = textStart..<(textStart + textSize)
        let image = SdkImage(name: (path as NSString).lastPathComponent, uuid: uuid, loadAddress: loadAddress)
        var typesSize: UInt = 0
        guard let types = getsectiondata(macho, "__TEXT", "__swift5_types", &typesSize) else {
            return (image, [])
        }
        var points: [TypePoint] = []
        let base = UnsafeRawPointer(types)
        for index in 0..<(Int(typesSize) / recordSize) {
            guard let descriptor = target(of: base + index * recordSize) else {
                continue
            }
            let accessorRelative = descriptor.loadUnaligned(fromByteOffset: accessorField, as: Int32.self)
            guard accessorRelative != 0 else {
                continue
            }
            let accessor = UInt(bitPattern: descriptor + accessorField + Int(accessorRelative))
            guard textBounds.contains(accessor), let module = moduleName(descriptor), !skippedModules.contains(module) else {
                continue
            }
            points.append(TypePoint(offset: UInt64(accessor - loadAddress), module: module))
        }
        return (image, points)
    }

    /// The `LC_UUID` of a 64-bit image, uppercase with dashes.
    private static func uuid(_ header: UnsafeRawPointer) -> String? {
        let commands = header.loadUnaligned(fromByteOffset: 16, as: UInt32.self) // mach_header_64.ncmds
        var command = header + headerSize
        for _ in 0..<commands {
            let kind = command.loadUnaligned(as: UInt32.self)
            let size = command.loadUnaligned(fromByteOffset: 4, as: UInt32.self)
            if kind == UInt32(LC_UUID) {
                return UUID(uuid: command.loadUnaligned(fromByteOffset: 8, as: uuid_t.self)).uuidString
            }
            guard size > 0 else {
                return nil
            }
            command += Int(size)
        }
        return nil
    }

    /// A `__swift5_types` record's type context descriptor: low 2 bits 0 direct, 1 indirect; nil otherwise.
    private static func target(of record: UnsafeRawPointer) -> UnsafeRawPointer? {
        let value = record.loadUnaligned(as: Int32.self)
        let pointer = record + Int(value & ~3)
        switch value & 3 {
        case 0:
            return pointer
        case 1:
            return UnsafeRawPointer(bitPattern: pointer.loadUnaligned(as: UInt.self))
        default:
            return nil
        }
    }

    /// The name of the descriptor's first ancestor of kind module, following the parents' relative indirectable
    /// pointers (low bit indirect); nil when the chain ends without one.
    private static func moduleName(_ descriptor: UnsafeRawPointer) -> String? {
        var current = descriptor
        for _ in 0..<maxAncestors {
            if current.loadUnaligned(as: UInt32.self) & kindMask == moduleKind {
                let nameRelative = current.loadUnaligned(fromByteOffset: nameField, as: Int32.self)
                guard nameRelative != 0 else {
                    return nil
                }
                return String(cString: (current + nameField + Int(nameRelative)).assumingMemoryBound(to: CChar.self))
            }
            let parentRelative = current.loadUnaligned(fromByteOffset: parentField, as: Int32.self)
            guard parentRelative != 0 else {
                return nil
            }
            let parent = current + parentField + Int(parentRelative & ~1)
            if parentRelative & 1 == 1 {
                guard let resolved = UnsafeRawPointer(bitPattern: parent.loadUnaligned(as: UInt.self)) else {
                    return nil
                }
                current = resolved
            } else {
                current = parent
            }
        }
        return nil
    }
}
#endif
