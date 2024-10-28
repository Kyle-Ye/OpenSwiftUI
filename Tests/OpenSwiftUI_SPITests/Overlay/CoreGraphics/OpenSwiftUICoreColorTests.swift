//
//  CoreFoundationPrivateTests.swift
//  OpenSwiftUI_SPITests

import Numerics
import OpenSwiftUI_SPI
import OpenSwiftUICore
import Testing

#if canImport(Darwin)

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

@MainActor
struct OpenSwiftUICoreColorTests {
    @Test
    func platformColorGetComponents() {
        #if os(macOS)
        let blackColor = NSColor(colorSpace: .extendedSRGB, components: [0, 0, 0, 1], count: 4)
        let grayColor = NSColor(colorSpace: .extendedSRGB, components: [0.5, 0.5, 0.5, 1], count: 4)
        let whiteColor = NSColor(colorSpace: .extendedSRGB, components: [1, 1, 1, 1], count: 4)
        #elseif os(iOS)
        let blackColor = UIColor(white: 0, alpha: 1)
        let grayColor = UIColor(white: 0.5, alpha: 1)
        let whiteColor = UIColor(white: 1, alpha: 1)
        #endif
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        #expect(OpenSwiftUICoreColorPlatformColorGetComponents(isAppKitBased(), blackColor, &r, &g, &b, &a) == true)
        #expect(r.isApproximatelyEqual(to: 0))
        #expect(g.isApproximatelyEqual(to: 0))
        #expect(b.isApproximatelyEqual(to: 0))
        #expect(a.isApproximatelyEqual(to: 1))
        #expect(OpenSwiftUICoreColorPlatformColorGetComponents(isAppKitBased(), grayColor, &r, &g, &b, &a) == true)
        #expect(r.isApproximatelyEqual(to: 0.5))
        #expect(g.isApproximatelyEqual(to: 0.5))
        #expect(b.isApproximatelyEqual(to: 0.5))
        #expect(a.isApproximatelyEqual(to: 1))
        #expect(OpenSwiftUICoreColorPlatformColorGetComponents(isAppKitBased(), whiteColor, &r, &g, &b, &a) == true)
        #expect(r.isApproximatelyEqual(to: 1))
        #expect(g.isApproximatelyEqual(to: 1))
        #expect(b.isApproximatelyEqual(to: 1))
        #expect(a.isApproximatelyEqual(to: 1))
    }
    
    @Test
    func platformColorForRGBA() throws {
        let blackColorObject = try #require(OpenSwiftUICorePlatformColorForRGBA(isAppKitBased(), 0, 0, 0, 1))
        let greyColorObject = try #require(OpenSwiftUICorePlatformColorForRGBA(isAppKitBased(), 0.5, 0.5, 0.5, 1))
        let whiteColorObject = try #require(OpenSwiftUICorePlatformColorForRGBA(isAppKitBased(), 1, 1, 1, 1))
        #if os(macOS)
        let blackColor = try #require((blackColorObject as? NSColor)?.usingColorSpace(.deviceRGB))
        let greyColor = try #require(greyColorObject as? NSColor)
        let whiteColor = try #require(whiteColorObject as? NSColor)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        blackColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(r.isApproximatelyEqual(to: 0))
        #expect(g.isApproximatelyEqual(to: 0))
        #expect(b.isApproximatelyEqual(to: 0))
        #expect(a.isApproximatelyEqual(to: 1))
        greyColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(r.isApproximatelyEqual(to: 0.5))
        #expect(g.isApproximatelyEqual(to: 0.5))
        #expect(b.isApproximatelyEqual(to: 0.5))
        #expect(a.isApproximatelyEqual(to: 1))
        whiteColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(r.isApproximatelyEqual(to: 1))
        #expect(g.isApproximatelyEqual(to: 1))
        #expect(b.isApproximatelyEqual(to: 1))
        #expect(a.isApproximatelyEqual(to: 1))
        #elseif os(iOS)
        let blackColor = try #require(blackColorObject as? UIColor)
        let greyColor = try #require(greyColorObject as? UIColor)
        let whiteColor = try #require(whiteColorObject as? UIColor)
        var white: CGFloat = 0
        var alpha: CGFloat = 0
        blackColor.getWhite(&white, alpha: &alpha)
        #expect(white.isApproximatelyEqual(to: 0))
        #expect(alpha.isApproximatelyEqual(to: 1))
        greyColor.getWhite(&white, alpha: &alpha)
        #expect(white.isApproximatelyEqual(to: 0.5))
        #expect(alpha.isApproximatelyEqual(to: 1))
        whiteColor.getWhite(&white, alpha: &alpha)
        #expect(white.isApproximatelyEqual(to: 1.0000001192092896))
        #expect(alpha.isApproximatelyEqual(to: 1))
        #endif
    }
    
    @Test
    func getKitColorClass() {
        let colorClass: AnyClass? = OpenSwiftUICoreColorGetKitColorClass(isAppKitBased())
        #if os(macOS)
        #expect(colorClass == NSColor.self)
        #elseif os(iOS)
        #expect(colorClass == UIColor.self)
        #endif
    }
}
#endif
