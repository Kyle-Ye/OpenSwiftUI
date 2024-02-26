//
//  ViewModifier.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

public protocol ViewModifier {
    //    static func _makeView(view: _GraphValue<_ViewModifier_Content<Modifier>>, inputs: _ViewInputs) -> _ViewOutputs
    //    static func _makeViewList(view: _GraphValue<_ViewModifier_Content<Modifier>>, inputs: _ViewListInputs) -> _ViewListOutputs
    //    static func _viewListCount(inputs: _ViewListCountInputs, body: (_ViewListCountInputs) -> Int?) -> Int?
    
    associatedtype Body: View

    @ViewBuilder
    func body(content: Content) -> Body

    typealias Content = _ViewModifier_Content<Self>
}

// extension ViewModifier {
//  public static func _makeView(modifier: _GraphValue<Self>, inputs: _ViewInputs, body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs) -> _ViewOutputs
//  public static func _makeViewList(modifier: _GraphValue<Self>, inputs: _ViewListInputs, body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs) -> _ViewListOutputs
//  public static func _viewListCount(inputs: _ViewListCountInputs, body: (_ViewListCountInputs) -> Swift.Int?) -> Int?
// }

extension ViewModifier where Body == Never {
    public func body(content _: Content) -> Never {
        bodyError()
    }
    //    static func _viewListCount(inputs: _ViewListCountInputs, body: (_ViewListCountInputs) -> Int?) -> Int?
}

extension ViewModifier {
    @inline(__always)
    func bodyError() -> Never {
        fatalError("body() should not be called on \(Self.self)")
    }
}
