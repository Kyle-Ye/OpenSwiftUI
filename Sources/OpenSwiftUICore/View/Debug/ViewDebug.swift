//
//  ViewDebug.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 5A14269649C60F846422EA0FA4C5E535 (SwiftUI)
//  ID: 43DA1754B0518AF1D72B90677BF266DB (SwiftUICore)

public import Foundation
import OpenGraphShims
import OpenSwiftUI_SPI

/// Namespace for view debug information.
public enum _ViewDebug {
    /// All debuggable view properties.
    public enum Property: UInt32, Hashable {
        case type
        case value
        case transform
        case position
        case size
        case environment
        case phase
        case layoutComputer
        case displayList
    }
    
    /// Bitmask of requested view debug properties.
    public struct Properties: OptionSet {
        public let rawValue: UInt32
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
        
        @inlinable
        package init(_ property: Property) {
            self.init(rawValue: 1 << property.rawValue)
        }
        
        public static let type = Properties(.type)
        public static let value = Properties(.value)
        public static let transform = Properties(.transform)
        public static let position = Properties(.position)
        public static let size = Properties(.size)
        public static let environment = Properties(.environment)
        public static let phase = Properties(.phase)
        public static let layoutComputer = Properties(.layoutComputer)
        public static let displayList = Properties(.displayList)
        public static let all = Properties(rawValue: 0xFFFF_FFFF)
    }
    
    package static var properties = Properties()
    
    /// View debug data for a view and all its child views.
    public struct Data {
        package var data: [Property: Any]
        package var childData: [_ViewDebug.Data]
        
        package init() {
            data = [:]
            childData = []
        }
    }
    
    package static var isInitialized = false
}

@available(*, unavailable)
extension _ViewDebug.Properties: Sendable {}

@available(*, unavailable)
extension _ViewDebug.Property: Sendable {}

@available(*, unavailable)
extension _ViewDebug.Data: Sendable {}

@available(*, unavailable)
extension _ViewDebug: Sendable {}

extension _ViewDebug {
    package static func initialize(inputs: inout _ViewInputs) {
        if !isInitialized {
            if let debugValue = EnvironmentHelper.int32(for: "OPENSWIFTUI_VIEW_DEBUG") {
                properties = Properties(rawValue: UInt32(bitPattern: debugValue))
            }
            isInitialized = true
        }
        if !properties.isEmpty {
            Subgraph.setShouldRecordTree()
        }
    }
    
    fileprivate static func reallyWrap<Value>(_ outputs: inout _ViewOutputs, value: _GraphValue<Value>, inputs: UnsafePointer<_ViewInputs>) {
        var debugProperiets = outputs.preferences.debugProperties.union(inputs.pointee.changedDebugProperties)
        outputs.preferences.debugProperties = []
        if debugProperiets.contains(.layoutComputer) {
            debugProperiets.setValue(outputs.layoutComputer != nil, for: .layoutComputer)
        }
        guard debugProperiets.subtracting(.displayList) != [] else {
            return
        }
        guard Subgraph.shouldRecordTree else {
            return
        }
        if debugProperiets.contains(.transform) {
            Subgraph.addTreeValue(inputs.pointee.transform, forKey: "transfrom", flags: 0)
        }
        if debugProperiets.contains(.position) {
            Subgraph.addTreeValue(inputs.pointee.position, forKey: "position", flags: 0)
        }
        if debugProperiets.contains(.size) {
            Subgraph.addTreeValue(inputs.pointee.size, forKey: "size", flags: 0)
        }
        if debugProperiets.contains(.environment) {
            Subgraph.addTreeValue(inputs.pointee.environment, forKey: "environment", flags: 0)
        }
        if debugProperiets.contains(.phase) {
            Subgraph.addTreeValue(inputs.pointee.base.phase, forKey: "phase", flags: 0)
        }
        if debugProperiets.contains(.layoutComputer) {
            Subgraph.addTreeValue(outputs.layoutComputer!, forKey: "layoutComputer", flags: 0)
        }
    }
}

// MARK: View and ViewModifier

extension ViewModifier {
    @inline(__always)
    nonisolated package static func makeDebuggableView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        Subgraph.beginTreeElement(value: modifier.value, flags: 0)
        var outputs = _makeView(
            modifier: modifier,
            inputs: inputs.withoutChangedDebugProperties,
            body: body
        )
        if Subgraph.shouldRecordTree {
            withUnsafePointer(to: inputs) { pointer in
                _ViewDebug.reallyWrap(&outputs, value: modifier, inputs: pointer)
            }
        }
        Subgraph.endTreeElement(value: modifier.value)
        return outputs
    }
    
    @inline(__always)
    nonisolated package static func makeDebuggableViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        Subgraph.beginTreeElement(value: modifier.value, flags: 1)
        defer { Subgraph.endTreeElement(value: modifier.value) }
        return _makeViewList(modifier: modifier, inputs: inputs, body: body)
    }
}

extension View {
    @inline(__always)
    nonisolated package static func makeDebuggableView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        Subgraph.beginTreeElement(value: view.value, flags: 0)
        var outputs = _makeView(
            view: view,
            inputs: inputs.withoutChangedDebugProperties
        )
        if Subgraph.shouldRecordTree {
            withUnsafePointer(to: inputs) { pointer in
                _ViewDebug.reallyWrap(&outputs, value: view, inputs: pointer)
            }
        }
        Subgraph.endTreeElement(value: view.value)
        return outputs
    }
    
    @inline(__always)
    nonisolated package static func makeDebuggableViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        Subgraph.beginTreeElement(value: view.value, flags: 1)
        defer { Subgraph.endTreeElement(value: view.value) }
        return _makeViewList(view: view, inputs: inputs)
    }
}

extension _ViewDebug {
    // Fix -werror issue
    // @available(*, deprecated, message: "To be refactored into View.makeDebuggableView")
    @inline(__always)
    static func makeView<Value>(
        view: _GraphValue<Value>,
        inputs: _ViewInputs,
        body: (_ view: _GraphValue<Value>, _ inputs: _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        Subgraph.beginTreeElement(value: view.value, flags: 0)
        var outputs = body(view, inputs.withoutChangedDebugProperties)
        if Subgraph.shouldRecordTree {
            withUnsafePointer(to: inputs) { pointer in
                _ViewDebug.reallyWrap(&outputs, value: view, inputs: pointer)
            }
        }
        OGSubgraph.endTreeElement(value: view.value)
        return outputs
    }
}

// MARK: - ViewDebug + Debug Data

// FIXME
extension Subgraph {
    func treeRoot() -> Int? { nil }
}

extension _ViewDebug {
    package static func makeDebugData(subgraph: Subgraph) -> [_ViewDebug.Data] {
        var result: [_ViewDebug.Data] = []
        if let rootElement = subgraph.treeRoot() {
            appendDebugData(from: rootElement, to: &result)
        }
        return result
    }
    
    private static func appendDebugData(from element: Int/*AGTreeElement*/ , to result: inout [_ViewDebug.Data]) {
        preconditionFailure("TODO")
    }
}

extension _ViewDebug {
    public static func serializedData(_ viewDebugData: [_ViewDebug.Data]) -> Foundation.Data? {
        let encoder = JSONEncoder()
        encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "inf", negativeInfinity: "-inf", nan: "nan")
        do {
            let data = try encoder.encode(viewDebugData)
            return data
        } catch {
            let dic = ["error": error.localizedDescription]
            return try? encoder.encode(dic)
        }
    }
}

// MARK: _ViewDebug.Data

extension _ViewDebug.Data: Encodable {
    enum CodingKeys: CodingKey {
        case properties
        case children
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(serializedProperties(), forKey: .properties)
        try container.encode(childData, forKey: .children)
    }

    private func serializedProperties() -> [SerializedProperty] {
        data.compactMap { key, value -> SerializedProperty? in
            if key == .value {
                if let attribute = serializedAttribute(for: value, label: nil, reflectionDepth: 6) {
                    return SerializedProperty(id: key.rawValue, attribute: attribute)
                } else {
                    return nil
                }
            } else if key == .type {
                let type = value as? Any.Type ?? type(of: value)
                let attribute = SerializedAttribute(type: type)
                return SerializedProperty(id: 0, attribute: attribute)
            } else {
                if let attribute = serializedAttribute(for: value, label: nil, reflectionDepth: 4) {
                    return SerializedProperty(id: key.rawValue, attribute: attribute)
                } else {
                    return nil
                }
            }
        }
    }

    // TODO
    // Mirror API
    private func serializedAttribute(for value: Any, label: String?, reflectionDepth depth: Int) -> SerializedAttribute? {
//            let unwrapped = unwrapped(value)

        return nil

//            let mirror = Mirror(reflecting: value)
//            mirror.displayStyle = .tuple

    }

    private func unwrapped(_ value: Any) -> Any? {
        if let value = value as? ValueWrapper {
            return value.wrappedValue
        } else {
            return nil
        }
    }
    
}

// MARK: _ViewDebug.Data.SerializedProperty

extension _ViewDebug.Data {
    private struct SerializedProperty: Encodable {
        let id: UInt32
        let attribute: SerializedAttribute

        enum CodingKeys: CodingKey {
            case id
            case attribute
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(attribute, forKey: .attribute)
        }
    }
}

// MARK: _ViewDebug.Data.SerializedAttribute

extension _ViewDebug.Data {
    // Size: 0x60
    private struct SerializedAttribute: Encodable {
        // TODO:
        static func serialize(value _: Any) -> Any? {
            // Mirror API
            nil
        }

        init(type anyType: Any.Type) {
            name = nil
            type = String(reflecting: anyType)
            readableType = OGTypeID(anyType).description
            flags = [
                conformsToProtocol(anyType, _OpenSwiftUI_viewProtocolDescriptor()) ? .view : [],
                conformsToProtocol(anyType, _OpenSwiftUI_viewModifierProtocolDescriptor()) ? .viewModifier : [],
            ]
            value = nil
            subattributes = nil
        }

        init(value inputValue: Any, serializeValue: Bool, label: String?, subattributes inputSubattributes: [SerializedAttribute]) {
            name = label
            let anyType = Swift.type(of: inputValue)
            type = String(reflecting: anyType)
            readableType = OGTypeID(anyType).description
            flags = [
                conformsToProtocol(anyType, _OpenSwiftUI_viewProtocolDescriptor()) ? .view : [],
                conformsToProtocol(anyType, _OpenSwiftUI_viewModifierProtocolDescriptor()) ? .viewModifier : [],
            ]
            if serializeValue {
                value = SerializedAttribute.serialize(value: inputValue)
            } else {
                value = nil
            }
            subattributes = inputSubattributes
        }

        struct Flags: OptionSet, Encodable {
            let rawValue: Int

            static let view = Flags(rawValue: 1 << 0)
            static let viewModifier = Flags(rawValue: 1 << 1)
        }

        let name: String?
        let type: String
        let readableType: String
        let flags: Flags
        let value: Any?
        let subattributes: [SerializedAttribute]?
        
        enum CodingKeys: CodingKey {
            case name
            case type
            case readableType
            case flags
            case value
            case subattributes
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(name, forKey: .name)
            try container.encode(type, forKey: .type)
            try container.encode(readableType, forKey: .readableType)
            try container.encode(flags, forKey: .flags)
            if let value = value as? Encodable {
                try container.encodeIfPresent(value, forKey: .value)
            }
            try container.encodeIfPresent(subattributes, forKey: .subattributes)
        }
    }
}

package protocol CustomViewDebugReflectable {
    var customViewDebugMirror: Mirror? { get }
}

package protocol CustomViewDebugValueConvertible {
    var viewDebugValue: Any { get }
}

@_spi(ForOpenSwiftUIOnly)
extension ViewTransform.Item: Encodable {
    package func encode(to encoder: any Encoder) throws {
        preconditionFailure("TODO")
    }
}

package protocol ValueWrapper {
    var wrappedValue: Any? { get }
}

extension Optional: ValueWrapper {
    package var wrappedValue: Any? {
        if case let .some(wrapped) = self {
            return wrapped
        } else {
            return nil
        }
    }
}

#if canImport(Darwin)
@objc
package protocol XcodeViewDebugDataProvider {
    @objc
    func makeViewDebugData() -> Foundation.Data?
}
#endif
