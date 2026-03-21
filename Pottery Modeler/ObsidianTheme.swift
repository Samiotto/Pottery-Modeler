//
//  ObsidianTheme.swift
//  Pottery Modeler
//
//  Created by Sam Gamgee on 3/21/26.
//

import SwiftUI

/// The Obsidian Lens Design System
/// High-fidelity dark mode with glassmorphism and tonal layering
struct ObsidianTheme {
    
    // MARK: - Colors
    
    /// Base background: Deep obsidian
    static let base = Color(hex: "#131313")
    
    /// Teal accent for active states and CTAs
    static let tealAccent = Color(hex: "#c3f5ff")
    
    /// Surface colors for layering
    static let surface1 = Color(hex: "#1a1a1a")
    static let surface2 = Color(hex: "#232323")
    static let surface3 = Color(hex: "#2d2d2d")
    
    /// Text colors
    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.7)
    static let textTertiary = Color(white: 0.5)
    
    /// Status colors
    static let statusActive = tealAccent
    static let statusWarning = Color(hex: "#ffb84d")
    static let statusError = Color(hex: "#ff5757")
    static let statusSuccess = Color(hex: "#4dffb0")
    
    // MARK: - Typography
    
    static func interFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    
    static func manropeFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    
    // MARK: - Glass Material
    
    struct GlassMaterial: ViewModifier {
        var tint: Color = .white.opacity(0.05)
        var blur: CGFloat = 20
        
        func body(content: Content) -> some View {
            content
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(tint)
                        .background(
                            .ultraThinMaterial,
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                        )
                }
        }
    }
    
    // MARK: - Shadows
    
    static let shadowRecessed = Color.black.opacity(0.5)
    static let shadowElevated = Color.black.opacity(0.3)
}

// MARK: - View Extensions

extension View {
    func glassMaterial(tint: Color = .white.opacity(0.05), blur: CGFloat = 20) -> some View {
        modifier(ObsidianTheme.GlassMaterial(tint: tint, blur: blur))
    }
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
