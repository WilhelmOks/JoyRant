//
//  Color.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 06.09.22.
//

import Foundation
import SwiftUI

extension Color {
    static let primaryBackground = Color("PrimaryBackground")
    static let secondaryBackground = Color("SecondaryBackground")
    static let primaryForeground = Color("PrimaryForeground")
    static let secondaryForeground = Color("SecondaryForeground")
    static let badgeBackground = Color("BadgeBG")
    
    static var primaryAccent: Color { AppState.shared.customAccentColor.flatMap { Color($0) } ?? Color("AccentColor") }
}
