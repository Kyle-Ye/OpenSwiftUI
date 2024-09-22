//
//  Logging.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2024
//  Status: Complete

import Foundation
#if OPENSWIFTUI_SWIFT_LOG
import Logging
extension Logger {
    package init(subsystem: String, category: String) {
        var logger = Logger(label: subsystem)
        logger[metadataKey: "category"] = MetadataValue.string(category)
        self = logger
    }
}
#else
import os.log

#if DEBUG
package let dso = { () -> UnsafeMutableRawPointer in
    let count = _dyld_image_count()
    for i in 0 ..< count {
        if let name = _dyld_get_image_name(i) {
            let swiftString = String(cString: name)
            if swiftString.hasSuffix("/SwiftUI") {
                if let header = _dyld_get_image_header(i) {
                    return UnsafeMutableRawPointer(mutating: UnsafeRawPointer(header))
                }
            }
        }
    }
    return UnsafeMutableRawPointer(mutating: #dsohandle)
}()
#endif

#endif

@usableFromInline
package enum Log {
    package static let subsystem: String = "org.OpenSwiftUIProject.OpenSwiftUI"
    
    @inline(__always)
    package static func log(_ message: @autoclosure () -> String, unless condition: @autoclosure () -> Bool, file: StaticString, line: UInt) {
        guard !condition() else { return }
        #if OPENSWIFTUI_SWIFT_LOG
        internalErrorsLog.debug("\(message()) \(file) \(line)")
        #else
        #if DEBUG
        os_log(.default, log: internalErrorsLog, "%s %s: %s", message(), file.description, line.description)
        #endif
        #endif
    }
    
    @inline(__always)
    package static func log(_ message: @autoclosure () -> String, unless condition: @autoclosure () -> Bool, file: StaticString = #fileID) {
        log(message(), unless: condition(), file: file, line: #line)
    }
    
    @inline(__always)
    package static func log(_ message: @autoclosure () -> String, unless condition: @autoclosure () -> Bool) {
        log(message(), unless: condition(), file: #fileID)
    }
    
    @inline(__always)
    package static func log(_ message: @autoclosure () -> String) {
        log(message(), unless: false)
    }

    package static func internalWarning(_ message: @autoclosure () -> String, file: StaticString, line: UInt) {
        print("\(message()) - \(file): - please file a bug report")
    }
    
    package static func internalWarning(_ message: @autoclosure () -> String) {
        internalWarning(message(), file: #fileID, line: #line)
    }
    
    package static func internalError(_ message: @autoclosure () -> String, file: StaticString = #fileID, line: UInt = #line) {
        #if OPENSWIFTUI_SWIFT_LOG
        internalErrorsLog.log(level: .error, "\(message()) - \(file): - please file a bug report")
        #else
        #if OPENSWIFTUI_SUPPORT_2022_API
        os_log(.fault, log: internalErrorsLog, "%s %s: %s", message(), file.description, line.description)
        print("\(message()) - \(file): - please file a bug report")
        #endif
        #endif
    }
    
    package static func internalError(_ message: @autoclosure () -> String) {
        internalError(message(), file: #fileID, line: #line)
    }
        
    package static func externalWarning(_ message: String) {
        #if OPENSWIFTUI_SWIFT_LOG
        unlocatedIssuesLog.log(level: .critical, "\(message)")
        #else
        unlocatedIssuesLog.fault("\(message)")
        #endif
    }

    package static func eventDebug(_ message: String) {
        #if !OPENSWIFTUI_SWIFT_LOG
        os_log(log: eventDebuggingLog, "\(message)")
        #endif
    }
    
    #if OPENSWIFTUI_SWIFT_LOG
    @usableFromInline
    package static var runtimeIssuesLog = Logger(subsystem: "com.apple.runtime-issues", category: "OpenSwiftUI")
    
    @_transparent
    package static func runtimeIssues(
        _ message: @autoclosure () -> StaticString,
        _ args: @autoclosure () -> [CVarArg] = []
    ) {
        runtimeIssuesLog.log(level: .critical, "\(message())")
    }
    #else
    @usableFromInline
    package static var runtimeIssuesLog: OSLog = OSLog(subsystem: "com.apple.runtime-issues", category: "OpenSwiftUI")
    
    @_transparent
    package static func runtimeIssues(
        _ message: @autoclosure () -> StaticString,
        _ args: @autoclosure () -> [CVarArg] = []
    ) {
        #if DEBUG
        unsafeBitCast(
            os_log as (OSLogType, UnsafeRawPointer, OSLog, StaticString, CVarArg...) -> Void,
            to: ((OSLogType, UnsafeRawPointer, OSLog, StaticString, [CVarArg]) -> Void).self
        )(.fault, dso, runtimeIssuesLog, message(), args())
        #else
        os_log(.fault, log: runtimeIssuesLog, message(), args())
        #endif
    }
    
    #endif
    package static let propertyChangeLog: Logger = Logger(subsystem: subsystem, category: "Changed Body Properties")
    package static var unlocatedIssuesLog: Logger = Logger(subsystem: subsystem, category: "Invalid Configuration")

    #if OPENSWIFTUI_SWIFT_LOG
    @usableFromInline
    package static var internalErrorsLog: Logger = Logger(subsystem: subsystem, category: "OpenSwiftUI")
    #else
    #if OPENSWIFTUI_SUPPORT_2022_API
    @usableFromInline
    package static var internalErrorsLog: OSLog = OSLog(subsystem: subsystem, category: "OpenSwiftUI")
    #endif
    
    @usableFromInline
    package static var eventDebuggingLog: OSLog = OSLog(subsystem: "com.apple.diagnostics.events", category: "OpenSwiftUI")
    #endif
    
    package static let archiving: Logger = Logger(subsystem: subsystem, category: "Archiving")
    package static let archivedToggle: Logger = Logger(subsystem: subsystem, category: "ArchivedToggle")
    package static let archivedButton: Logger = Logger(subsystem: subsystem, category: "ArchivedButton")
    package static let archivedPlaybackButton: Logger = Logger(subsystem: subsystem, category: "ArchivedPlaybackButton")
    package static let metadataExtraction: Logger = Logger(subsystem: subsystem, category: "MetadataExtraction")
}

@available(*, unavailable)
extension Log: Sendable {}

@_transparent
package func precondition(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String, file: StaticString = #fileID, line: UInt = #line) {
    guard condition() else {
        Swift.preconditionFailure(message(), file: file, line: line)
    }
}

@_transparent
package func preconditionFailure(_ message: @autoclosure () -> String, file: StaticString, line: UInt) -> Never {
    Swift.preconditionFailure(message(), file: file, line: line)
}

@_transparent
package func preconditionFailure(_ message: @autoclosure () -> String) -> Never {
    preconditionFailure(message(), file: #fileID, line: #line)
}

#if !OPENSWIFTUI_SWIFT_LOG
extension os.OSLog {
    @usableFromInline
    static var runtimeIssuesLog: os.OSLog = OSLog(subsystem: "com.apple.runtime-issues", category: "OpenSwiftUI")
}
#endif