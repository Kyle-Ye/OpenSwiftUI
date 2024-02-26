//
//  EmptyModifier.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

@frozen
public struct EmptyModifier: PrimitiveViewModifier, PrimitiveSceneModifier {
    public static let identity = EmptyModifier()

    @inlinable
    public init() {}

//    public static func _makeView(modifier: _GraphValue<EmptyModifier>, inputs: _ViewInputs, body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs) -> _ViewOutputs
//    public static func _makeViewList(modifier: _GraphValue<EmptyModifier>, inputs: _ViewListInputs, body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs) -> _ViewListOutputs
//    public static func _viewListCount(inputs: _ViewListCountInputs, body: (_ViewListCountInputs) -> Int?) -> Int?
}
