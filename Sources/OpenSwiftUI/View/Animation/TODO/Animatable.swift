//
//  Animatable.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Blocked by Graph

// MARK: - Animatable

public protocol Animatable {
    associatedtype AnimatableData: VectorArithmetic
    var animatableData: AnimatableData { get set }
    static func _makeAnimatable(value: inout _GraphValue<Self>, inputs: _GraphInputs)
}

// MARK: - Animateble + Extension

extension Animatable {
    public static func _makeAnimatable(value _: inout _GraphValue<Self>, inputs _: _GraphInputs) {
        // TODO
    }
}

extension Animatable where Self: VectorArithmetic {
    public var animatableData: Self {
        get { self }
        set { self = newValue }
    }
}

extension Animatable where AnimatableData == EmptyAnimatableData {
    public var animatableData: EmptyAnimatableData {
        @inlinable
        get { EmptyAnimatableData() }
        @inlinable
        set {}
    }

    public static func _makeAnimatable(value _: inout _GraphValue<Self>, inputs _: _GraphInputs) {
        // TODO
    }
}

#if canImport(Darwin)
import CoreGraphics
#else
import Foundation
#endif

// MARK: - Animatable + CoreGraphics

extension CGPoint: Animatable {
    public var animatableData: AnimatablePair<CGFloat, CGFloat> {
        @inlinable
        get { .init(x, y) }
        @inlinable
        set { (x, y) = newValue[] }
    }
}

extension CGSize: Animatable {
    public var animatableData: AnimatablePair<CGFloat, CGFloat> {
        @inlinable
        get { .init(width, height) }
        @inlinable
        set { (width, height) = newValue[] }
    }
}

extension CGRect: Animatable {
    public var animatableData: AnimatablePair<CGPoint.AnimatableData, CGSize.AnimatableData> {
        @inlinable
        get {
            .init(origin.animatableData, size.animatableData)
        }
        @inlinable
        set {
            (origin.animatableData, size.animatableData) = newValue[]
        }
    }
}
