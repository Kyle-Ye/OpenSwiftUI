#if OPENSWIFTUI_USE_AG
internal import AttributeGraph
#else
internal import OpenGraph
#endif

public struct _GraphValue<Value> {
    var value: Attribute<Value>
//    public subscript<U>(_: Swift.KeyPath<Value, U>) -> SwiftUI._GraphValue<U> {
//        get
//    }
//
//    public static func == (a: SwiftUI._GraphValue<Value>, b: SwiftUI._GraphValue<Value>) -> Swift.Bool
}
