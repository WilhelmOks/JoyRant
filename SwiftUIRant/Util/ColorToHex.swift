//
//  ColorToHex.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 16.11.22.
//

import Foundation
#if canImport(UIKit)
import UIKit
typealias PlatformColor = UIColor
#elseif canImport(AppKit)
import AppKit
typealias PlatformColor = NSColor
#endif

#if os(iOS)

func hexStringFromColor(color: PlatformColor) -> String {
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var opacity: CGFloat = 0.0
    
    guard color.getRed(&red, green: &green, blue: &blue, alpha: &opacity) else { return "-" }
    
    let hexString = String(
        format: "#%02lX%02lX%02lX",
        lroundf(Float(red * 255)),
        lroundf(Float(green * 255)),
        lroundf(Float(blue * 255))
    )
    return hexString
}

#elseif os(macOS)

func hexStringFromColor(color: PlatformColor) -> String {
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var opacity: CGFloat = 0.0
    
    color.getRed(&red, green: &green, blue: &blue, alpha: &opacity)
    
    let hexString = String(
        format: "#%02lX%02lX%02lX",
        lroundf(Float(red * 255)),
        lroundf(Float(green * 255)),
        lroundf(Float(blue * 255))
    )
    return hexString
}

#endif
