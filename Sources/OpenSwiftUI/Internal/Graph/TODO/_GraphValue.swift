#if OPENSWIFTUI_USE_AG
internal import AttributeGraph
#else
internal import OpenGraph
#endif

public struct _GraphValue<Value>: Equatable {
    var value: Attribute<Value>

    public subscript<U>(keyPath: KeyPath<Value, U>) -> _GraphValue<U> {
        _GraphValue<U>(value[keyPath])
    }

    public static func == (a: _GraphValue<Value>, b: _GraphValue<Value>) -> Bool {
        a.value == b.value
    }

    init(_ attribute: Attribute<Value>) {
        self.value = attribute
    }
}