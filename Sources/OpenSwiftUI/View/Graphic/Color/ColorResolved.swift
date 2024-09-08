//
//  ColorResolved.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: WIP

import Foundation

// MARK: - Color.Resolved

extension Color {    
    @frozen
    public struct Resolved: Hashable {
        public var linearRed: Float
        public var linearGreen: Float
        public var linearBlue: Float
        public var opacity: Float
        
        package init(linearRed: Float, linearGreen: Float, linearBlue: Float, opacity: Float = 1) {
            self.linearRed = linearRed
            self.linearGreen = linearGreen
            self.linearBlue = linearBlue
            self.opacity = opacity
        }
        
        package func multiplyingOpacity(by opacity: Float) -> Color.Resolved {
            Color.Resolved(linearRed: linearRed, linearGreen: linearGreen, linearBlue: linearBlue, opacity: opacity * self.opacity)
        }
        
        package func over(_ s: Resolved) -> Color.Resolved {
            fatalError("TODO")
        }
    }
    
    package struct ResolvedVibrant: Equatable {
        package var scale: Float
        package var bias: (Float, Float, Float)
        // package var colorMatrix: _ColorMatrix { fatalError("TODO") }
        
        package static func == (lhs: ResolvedVibrant, rhs: ResolvedVibrant) -> Bool {
            lhs.scale == rhs.scale && lhs.bias == rhs.bias
        }
    }
    
    public init(_ resolved: Resolved) {
        // TODO
    }
}

// MARK: - Color.Resolved + ResolvedPaint

extension Color.Resolved/*: ResolvedPaint*/ {
    //    func draw(path: Path, style: paathDrawingStyle, in context: GraphicsContext, bounds: CGRect?)
    
    var isClear: Bool { opacity == 0 }
    var isOpaque: Bool { opacity == 1 }
    
//    static leafProtobufTag: CodableResolvedPaint.Tag?
}

// MARK: - Color.Resolved + ShapeStyle

extension Color.Resolved: ShapeStyle/*, PrimitiveShapeStyle*/ {
    public func _apply(to shape: inout _ShapeStyle_Shape) {
        fatalError("TODO")
    }
    
    public typealias Resolved = Never
}

extension Color.Resolved: CustomStringConvertible {
    public var description: String {
        "TODO"
    }
}

// MARK: - Color.Resolved + Animatable

extension Color.Resolved : Animatable {
    package static var legacyInterpolation: Bool = {
        // TODO: Semantic.v6
        return false
    }()

    public var animatableData: AnimatablePair<Float, AnimatablePair<Float, AnimatablePair<Float, Float>>> {
        get {
            if Self.legacyInterpolation {
                // ResolvedGradient.Color.Space.convertIn(self)
                fatalError("TODO")
            } else {
                let factor: Float = 128.0
                return AnimatablePair(linearRed * factor, AnimatablePair(linearGreen * factor, AnimatablePair(linearBlue * factor, opacity * factor)))
            }
        }

        set {
            let factor: Float = 0.0078125
            if Self.legacyInterpolation {
                // ResolvedGradient.Color.Space.convertOut(self)
                fatalError("TODO")
            } else {
                linearRed = newValue.first * factor
                linearGreen = newValue.second.first * factor
                linearBlue = newValue.second.second.first * factor
                opacity = newValue.second.second.second * factor
            }
        }
    }
}

extension Color.ResolvedVibrant : Animatable {
    package var animatableData: AnimatablePair<Float, AnimatablePair<Float, AnimatablePair<Float, Float>>> {
        get {
            let factor: Float = 128.0
            return AnimatablePair(scale * factor, AnimatablePair(bias.0 * factor, AnimatablePair(bias.1 * factor, bias.2 * factor)))
        }
        set {
            let factor: Float = 0.0078125
            scale = newValue.first * factor
            bias = (newValue.second.first * factor, newValue.second.second.first * factor, newValue.second.second.second * factor)
        }
    }
}

// MARK: - Color.Resolved + extension

extension Color.Resolved {
    package static let clear: Color.Resolved = Color.Resolved(linearRed: 0, linearGreen: 0, linearBlue: 0, opacity: 0)
    package static let black: Color.Resolved = Color.Resolved(linearRed: 0, linearGreen: 0, linearBlue: 0, opacity: 1)
    package static let gray_75: Color.Resolved = Color.Resolved(linearRed: 0.522522, linearGreen: 0.522522, linearBlue: 0.522522, opacity: 1)
    package static let gray_50: Color.Resolved = Color.Resolved(linearRed: 0.214041, linearGreen: 0.214041, linearBlue: 0.214041, opacity: 1)
    package static let gray_25: Color.Resolved = Color.Resolved(linearRed: 0.0508761, linearGreen: 0.0508761, linearBlue: 0.0508761, opacity: 1)
    package static let white: Color.Resolved = Color.Resolved(linearRed: 1, linearGreen: 1, linearBlue: 1, opacity: 1)
    package static let red: Color.Resolved = Color.Resolved(linearRed: 1, linearGreen: 0, linearBlue: 0, opacity: 1)
    package static let blue: Color.Resolved = Color.Resolved(linearRed: 0, linearGreen: 0, linearBlue: 1, opacity: 1)
    package static let green: Color.Resolved = Color.Resolved(linearRed: 0, linearGreen: 1, linearBlue: 0, opacity: 1)

    package init(red: Float, green: Float, blue: Float, opacity: Float = 1) {
        self.init(linearRed: sRGBToLinear(red), linearGreen: sRGBToLinear(green), linearBlue: sRGBToLinear(blue), opacity: opacity)
    }

    public init(colorSpace: Color.RGBColorSpace = .sRGB, red: Float, green: Float, blue: Float, opacity: Float = 1) {
        switch colorSpace {
        case .sRGB:
            self.init(red: red, green: green, blue: blue, opacity: opacity)
        case .sRGBLinear:
            self.init(linearRed: red, linearGreen: green, linearBlue: blue, opacity: opacity)
        case .displayP3:
            self.init(displayP3Red: red, green: green, blue: blue, opacity: opacity)
        }
    }

    package init(linearWhite: Float, opacity: Float = 1) {
        self.init(linearRed: linearWhite, linearGreen: linearWhite, linearBlue: linearWhite, opacity: opacity)
    }

    package init(white: Float, opacity: Float = 1) {
        let linearWhite = sRGBToLinear(white)
        self.init(linearWhite: linearWhite, opacity: opacity)
    }

    package var red: Float {
        get { sRGBFromLinear(linearRed) }
        set { linearRed = sRGBToLinear(newValue) }
    }

    package var green: Float {
        get { sRGBFromLinear(linearGreen) }
        set { linearGreen = sRGBToLinear(newValue) }
    }

    package var blue: Float {
        get { sRGBFromLinear(linearBlue) }
        set { linearBlue = sRGBToLinear(newValue) }
    }

    package var white: Float {
        sRGBFromLinear(linearWhite)
    }

    package var linearWhite: Float {
        linearRed * 0.2126 + linearGreen * 0.7152 + linearBlue * 0.0722
    }
}

// MARK: - Color.Resolved + Display P3

extension Color.Resolved {
    package init(linearDisplayP3Red: Float, green: Float, blue: Float, opacity: Float = 1) {
        // Convert from Display P3 to sRGB linear color space
        let linearRed = linearDisplayP3Red * 1.2249 + green * -0.2247
        let linearGreen = linearDisplayP3Red * -0.0420 + green * 1.0419
        let linearBlue = linearDisplayP3Red * -0.0197 + green * -0.0786 + blue * 1.0979
        self.init(linearRed: linearRed, linearGreen: linearGreen, linearBlue: linearBlue, opacity: opacity)
    }

    package init(displayP3Red: Float, green: Float, blue: Float, opacity: Float = 1) {
        self.init(linearDisplayP3Red: sRGBToLinear(displayP3Red), green: sRGBToLinear(green), blue: sRGBToLinear(blue), opacity: opacity)
    }

    package var linearDisplayP3Components: (Float, Float, Float) {
        // Convert from sRGB linear color space to Display P3
        let linearDisplayP3Red = linearRed * 0.8225 + linearGreen * 0.1774
        let linearDisplayP3Green = linearRed * 0.0332 + linearGreen * 0.9669
        let linearDisplayP3Blue = linearRed * 0.0171 + linearGreen * 0.0724 + blue * 0.9108
        return (linearDisplayP3Red, linearDisplayP3Green, linearDisplayP3Blue)
    }

    package var displayP3Components: (Float, Float, Float) {
        let linearDisplayP3Components = linearDisplayP3Components
        return (sRGBFromLinear(linearDisplayP3Components.0), sRGBFromLinear(linearDisplayP3Components.1), sRGBFromLinear(linearDisplayP3Components.2))
    }
}

// MARK: - Color.Resolved + Codable
extension Color.Resolved: Codable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(red)
        try container.encode(green)
        try container.encode(blue)
        try container.encode(opacity)
    }

    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let red = try container.decode(Float.self)
        let green = try container.decode(Float.self)
        let blue = try container.decode(Float.self)
        let opacity = try container.decode(Float.self)
        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
}

// MARK: - Color.Resolved + ProtobufMessage

//extension Color.Resolved: ProtobufMessage {
//  package func encode(to encoder: inout ProtobufEncoder)
//  package init(from decoder: inout ProtobufDecoder) throws
//}

// MARK: - Util method

func sRGBFromLinear(_ linear: Float) -> Float {
    let nonNegativeLinear = linear > 0 ? linear : -linear
    let result = if nonNegativeLinear <= 0.0031308 {
        nonNegativeLinear * 12.92
    } else if nonNegativeLinear == 1.0 {
        Float(1.0)
    } else {
        pow(nonNegativeLinear, 1.0 / 2.4) * 1.055 - 0.055
    }
    return linear > 0 ? result : -result
}

func sRGBToLinear(_ sRGB: Float) -> Float {
    let nonNegativeSRGB = sRGB > 0 ? sRGB : -sRGB
    let result = if nonNegativeSRGB <= 0.04045 {
        nonNegativeSRGB * 0.0773994
    } else if nonNegativeSRGB == 1.0 {
        Float(1.0)
    } else {
        pow(nonNegativeSRGB * 0.947867 + 0.0521327, 2.4)
    }
    return sRGB > 0 ? result : -result
}
