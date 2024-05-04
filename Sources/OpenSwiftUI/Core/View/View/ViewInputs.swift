//
//  ViewInputs.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

internal import OpenGraphShims

public struct _ViewInputs {
    private var base: _GraphInputs
    var preferences: PreferencesInputs
    var transform: Attribute<ViewTransform>
    var position: Attribute<ViewOrigin>
    var containerPosition: Attribute<ViewOrigin>
    var size: Attribute<ViewSize>
    var safeAreaInsets: OptionalAttribute<SafeAreaInsets>
    
    init(
        base: _GraphInputs,
        preferences: PreferencesInputs,
        transform: Attribute<ViewTransform>,
        position: Attribute<ViewOrigin>,
        containerPosition: Attribute<ViewOrigin>,
        size: Attribute<ViewSize>,
        safeAreaInsets: OptionalAttribute<SafeAreaInsets>
    ) {
        self.base = base
        self.preferences = preferences
        self.transform = transform
        self.position = position
        self.containerPosition = containerPosition
        self.size = size
        self.safeAreaInsets = safeAreaInsets
    }
    
    func makeIndirectOutputs() -> _ViewOutputs {
        #if canImport(Darwin)
        struct AddPreferenceVisitor: PreferenceKeyVisitor {
            var outputs = _ViewOutputs()
            mutating func visit<Key: PreferenceKey>(key: Key.Type) {
                let source = ViewGraph.current.intern(Key.defaultValue, id: 0)
                let indirect = IndirectAttribute(source: source)
                outputs.appendPreference(key: Key.self, value: Attribute(identifier: indirect.identifier))
            }
        }
        var visitor = AddPreferenceVisitor()
        preferences.keys.forEach { key in
            key.visitKey(&visitor)
        }
        var outputs = visitor.outputs
        outputs.setLayoutComputer(self) {
            let indirect = IndirectAttribute(source: ViewGraph.current.$defaultLayoutComputer)
            return Attribute(identifier: indirect.identifier)
        }
        return outputs
        #else
        fatalError("See #39")
        #endif
    }
    
    // MARK: - base
    
    @inline(__always)
    mutating func withMutateGraphInputs<R>(_ body: (inout _GraphInputs) -> R) -> R {
        body(&base)
    }
    
    // MARK: - base.customInputs
    
    @inline(__always)
    func withCustomInputs<R>(_ body: (PropertyList) -> R) -> R {
        body(base.customInputs)
    }
    
    @inline(__always)
    mutating func withMutableCustomInputs<R>(_ body: (inout PropertyList) -> R) -> R {
        body(&base.customInputs)
    }
    
    // MARK: - base.cachedEnvironment
    
    @inline(__always)
    func withCachedEnviroment<R>(_ body: (CachedEnvironment) -> R) -> R {
        body(base.cachedEnvironment.wrappedValue)
    }
    
    @inline(__always)
    func withMutableCachedEnviroment<R>(_ body: (inout CachedEnvironment) -> R) -> R {
        body(&base.cachedEnvironment.wrappedValue)
    }
    
    @inline(__always)
    func detechedEnvironmentInputs() -> Self {
        var newInputs = self
        newInputs.base = self.base.detechedEnvironmentInputs()
        return newInputs
    }
    
    // MARK: - base.changedDebugProperties
    
    @inline(__always)
    func withEmptyChangedDebugPropertiesInputs<R>(_ body: (_ViewInputs) -> R) -> R {
        var newInputs = self
        return base.withEmptyChangedDebugPropertiesInputs {
            newInputs.base = $0
            return body(newInputs)
        }
    }
    
    // MARK: Options
        
    @inline(__always)
    var enableLayout: Bool {
        get { base.enableLayout }
        // TODO: setter
    }
}
