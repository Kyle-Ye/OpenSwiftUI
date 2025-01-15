//
//  Signpost.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 34756F646CF7AC3DBE2A8E0B344C962F (SwiftUI)
//  ID: 59349949219F590F26B6A55CEC9D59A2 (SwiftUICore)

import OpenSwiftUI_SPI
import OpenGraphShims
#if canImport(os)
package import os.signpost
#endif

extension Signpost {
    package static let render = Signpost.kdebug(0, "Render")
    package static let postUpdateActions = Signpost.kdebug(2, "PostUpdateActions")
    package static let renderUpdate = Signpost.kdebug(3, "RenderUpdate")
    package static let renderFlattened = Signpost.kdebug(4, "RenderFlattened")
    package static let bodyInvoke = Signpost.kdebug(5, "BodyInvoke")
    package static let linkCreate = Signpost.os_log(6, "LinkCreate")
    package static let linkUpdate = Signpost.os_log(7, "LinkUpdate")
    package static let linkDestroy = Signpost.os_log(8, "LinkDestroy")
    package static let viewHost = Signpost.kdebug(9, "ViewHost")
    package static let platformView = Signpost.os_log(10, "ViewMapping")
    package static let platformUpdate = Signpost.os_log(11, "PlatformViewUpdate")
    package static let animationState = Signpost.os_log(12, "AnimationState")
    package static let eventHandling = Signpost.os_log(13, "EventHandling")
}

#if canImport(Darwin)
private let _signpostLog = OSLog(subsystem: Log.subsystem, category: "OpenSwiftUI")
#endif

package struct Signpost {
    #if canImport(Darwin)
    package static let archiving = OSSignposter(logger: Log.archiving)
    package static let metaExtraction = OSSignposter(logger: Log.metadataExtraction)
    #endif
    
    package static let moduleName: String = Tracing.libraryName(defining: Signpost.self)
    
    @inlinable
    package static func os_log(_: UInt8, _ name: StaticString) -> Signpost {
        Signpost(style: .os_log(name), stability: .debug)
    }
    
    @inlinable
    package static func kdebug(_ code: UInt8, _: StaticString?) -> Signpost {
        Signpost(style: .kdebug(code), stability: .debug)
    }

    package static func kdebug(_ code: UInt8) -> Signpost {
        Signpost(style: .kdebug(code), stability: .debug)
    }
    
    private enum Style {
        case kdebug(UInt8)
        case os_log(StaticString)
    }
    
    private enum Stability: Hashable {
        case disabled
        case verbose
        case debug
        case published
        
        @inline(__always)
        static var valid: [Stability] {
            #if DEBUG
            [.debug, .published]
            #else
            [.published]
            #endif
        }
    }
    
    private let style: Style
    private let stability: Stability
    
    @inlinable
    package var disabled: Signpost {
        Signpost(style: style, stability: .disabled)
    }
    
    @inlinable
    package var verbose: Signpost {
        Signpost(style: style, stability: .verbose)
    }
    
    @inlinable
    package var published: Signpost {
        Signpost(style: style, stability: .published)
    }
    
    package var isEnabled: Bool {
        guard Stability.valid.contains(stability) else {
            return false
        }
        #if canImport(Darwin)
        switch style {
            case let .kdebug(code):
                return kdebug_is_enabled(MISC_INSTRUMENTS_DGB_CODE(type: .event, code: code))
            case .os_log:
                guard kdebug_is_enabled(MISC_INSTRUMENTS_DGB_CODE(type: .event)) else {
                    return false
                }
                return _signpostLog.signpostsEnabled
            }
        #else
        return false
        #endif
    }
    
    @_transparent
    package func traceInterval<T>(
        object: AnyObject?,
        _ message: StaticString?,
        closure: () -> T
    ) -> T {
        guard isEnabled else {
            return closure()
        }
        #if canImport(Darwin)
        let id = OSSignpostID.makeExclusiveID(object)
        switch style {
            case let .kdebug(code):
                let code = MISC_INSTRUMENTS_DGB_CODE(type: .begin, code: code)
                kdebug_trace(code, id.rawValue, 0, 0, 0)
                defer { kdebug_trace(code, id.rawValue, 0, 0, 0) }
                return closure()
            case let .os_log(name):
                if let message {
                    os_signpost(.begin, log: _signpostLog, name: name, signpostID: id, message, [])
                } else {
                    os_signpost(.begin, log: _signpostLog, name: name, signpostID: id)
                }
                defer { os_signpost(.end, log: _signpostLog, name: name, signpostID: id) }
                return closure()
            }
        #else
        return closure()
        #endif
    }
    
    @_transparent
    package func traceInterval<T>(
        object: AnyObject?,
        _ message: StaticString,
        _ args: @autoclosure () -> [any CVarArg],
        closure: () -> T
    ) -> T {
        guard isEnabled else {
            return closure()
        }
        #if canImport(Darwin)
        let id = OSSignpostID.makeExclusiveID(object)
        switch style {
            case let .kdebug(code):
                // FIXME: _primitive
                // continuation
                // _primitive
                // withKDebugValues
                _primitive(.end, log: _signpostLog, signpostID: id, message, args()) // FIXME
                
                return closure()
            case let .os_log(name):
                os_signpost(.begin, log: _signpostLog, name: name, signpostID: id, message, args())
                defer { os_signpost(.end, log: _signpostLog, name: name, signpostID: id) }
                return closure()
        }
        #else
        return closure()
        #endif
    }
    
    #if canImport(Darwin)
    @_transparent
    package func traceEvent(
        type: OSSignpostType,
        object: AnyObject?,
        _ message: StaticString,
        _ args: @autoclosure () -> [any CVarArg]
    ) {
        guard isEnabled else {
            return
        }
        let id = OSSignpostID.makeExclusiveID(object)
        let args = args()

        switch style {
            case let .kdebug(code):
                // FIXME: _primitive
                print(code)
                return
            case let .os_log(name):
                os_signpost(type, log: _signpostLog, name: name, signpostID: id, message, args)
        }
    }
    #endif
    
    #if canImport(Darwin)
    private func _primitive(
        _ type: OSSignpostType,
        log: OSLog,
        signpostID: OSSignpostID,
        _ message: StaticString?,
        _ arguments: [any CVarArg]?
    ) {
        // TODO
        
//        let closure: ([UInt64]) -> () = { args in
//            kdebug_trace(code, signpostID.rawValue, args[0], args[1], args[2])
//        }
        withKDebugValues(8, arguments ?? []) { args in
            kdebug_trace(9, signpostID.rawValue, args[0], args[1], args[2])
        }
    }
    #endif
}

#if canImport(os)
extension OSSignpostID {
    private static let continuation = OSSignpostID(0x0ea89ce2)
    
    @inline(__always)
    static func makeExclusiveID(_ object: AnyObject?) -> OSSignpostID {
        if let object {
            OSSignpostID(log: _signpostLog, object: object)
        } else {
            .exclusive
        }
    }
}
#endif

#if canImport(Darwin)

// MARK: - kdebug

private func withKDebugValues(_ code: UInt32, _ args: [(any CVarArg)?], closure: (([UInt64]) -> Void)) {
    let values = args.map { $0?.kdebugValue(code) }
    closure(values.map { $0?.arg ?? 0 })
    values.forEach { $0?.destructor?() }
}

private protocol KDebuggableCVarArg: CVarArg {
    
}

extension CVarArg {
    fileprivate func kdebugValue(_ code: UInt32) -> (arg: UInt64, destructor: (() -> Void)?) {
        if let value = self as? KDebuggableCVarArg {
            preconditionFailure("TODO")
        } else {
            let encoding = _cVarArgEncoding
            if encoding.count == 1 {
                return (UInt64(bitPattern: Int64(encoding[0])), nil)
            } else {
                let description = String(describing: self)
                let moduleName = Signpost.moduleName
                if description == moduleName {
                    return (0, nil)
                } else {
                    // let id = kdebug_trace_string(<#T##debugid: UInt32##UInt32#>, <#T##str_id: UInt64##UInt64#>, <#T##str: UnsafePointer<CChar>!##UnsafePointer<CChar>!#>)
                    preconditionFailure("TODO")
                }
                
            }
        }
    }
}

// MARK: - kdebug macro helper

@_transparent
func KDBG_EVENTID(_ class: UInt32, _ subclass: UInt32, _ code: UInt32) -> UInt32 {
    ((`class` & 0xff) << KDBG_CLASS_OFFSET) |
    ((subclass & 0xff) << KDBG_SUBCLASS_OFFSET) |
    ((code & 0x3fff) << KDBG_CODE_OFFSET)
}

@_transparent
func KDBG_EXTRACT_CLASS(_ debugid: UInt32) -> UInt32 {
    (debugid & KDBG_CLASS_MASK) >> KDBG_CLASS_OFFSET
}

@_transparent
func KDBG_EXTRACT_SUBCLASS(_ debugid: UInt32) -> UInt32 {
    (debugid & UInt32(bitPattern: KDBG_SUBCLASS_MASK)) >> KDBG_SUBCLASS_OFFSET
}

@_transparent
func KDBG_EXTRACT_CODE(_ debugid: UInt32) -> UInt32 {
    (debugid & UInt32(bitPattern: KDBG_CODE_MASK)) >> KDBG_CODE_OFFSET
}

@_transparent
func KDBG_CLASS_ENCODE(_ class: UInt32, _ subclass: UInt32) -> UInt32 {
    KDBG_EVENTID(`class`, subclass, 0)
}

@_transparent
func KDBG_CLASS_DECODE(_ debugid: UInt32) -> UInt32 {
    debugid & KDBG_CSC_MASK
}

@_transparent
func MISCDGB_CODE(_ subclass: UInt32, _ code: UInt32) -> UInt32 {
    KDBG_EVENTID(UInt32(bitPattern: DBG_MISC), subclass, code)
}

@_transparent
func MISC_INSTRUMENTS_DGB_CODE(_ code: UInt32) -> UInt32 {
    MISCDGB_CODE(UInt32(bitPattern: DBG_MISC_INSTRUMENTS), code)
}

@_transparent
func MISC_INSTRUMENTS_DGB_CODE(type: OSSignpostType) -> UInt32 {
    MISC_INSTRUMENTS_DGB_CODE(UInt32(type.rawValue))
}

@_transparent
func MISC_INSTRUMENTS_DGB_CODE(type: OSSignpostType, code: UInt8) -> UInt32 {
    MISC_INSTRUMENTS_DGB_CODE(UInt32(type.rawValue | code << 2))
}


#endif
