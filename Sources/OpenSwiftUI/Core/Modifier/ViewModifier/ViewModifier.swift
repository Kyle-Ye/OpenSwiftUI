//
//  ViewModifier.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

public protocol ViewModifier {
    associatedtype Body: View
    
    static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs

    static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs

    static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int?
    
    typealias Content = _ViewModifier_Content<Self>
    
    @ViewBuilder
    @MainActor(unsafe)
    func body(content: Content) -> Body
}

extension ViewModifier {
    public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeView(modifier: modifier, inputs: inputs, body: body)
    }
    
    public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        makeViewList(modifier: modifier, inputs: inputs, body: body)
    }

    public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        viewListCount(inputs: inputs, body: body)
    }
}

extension ViewModifier where Body == Never {
    public func body(content _: Content) -> Never {
        bodyError()
    }
    
    public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        body(inputs)
    }
}

extension ViewModifier where Self: _GraphInputsModifier, Body == Never {
    public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var inputs = inputs
        inputs.withMutateGraphInputs { inputs in
            _makeInputs(modifier: modifier, inputs: &inputs)
        }
        let outputs = body(_Graph(), inputs)
        return outputs
    }
    
    public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        var inputs = inputs
        inputs.withMutateGraphInputs { inputs in
            _makeInputs(modifier: modifier, inputs: &inputs)
        }
        let outputs = body(_Graph(), inputs)
        return outputs
    }

    public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        body(inputs)
    }
}

extension ViewModifier {
    func bodyError() -> Never {
        fatalError("body() should not be called on \(Self.self)")
    }
}
