//
//  Text+FontExtensions.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 06.09.22.
//

import Foundation
import SwiftUI

extension Text {
    func font(baseSize: Int = 17, weight: Font.Weight) -> Self {
        self.font(fontFromBaseSize(baseSize)).fontWeight(weight)
    }
    
    func font(baseSize: Int = 17, weightDelta: Int = 0) -> Self {
        self.font(fontFromBaseSize(baseSize)).fontWeight(weightFromNormalizedNumber(weightDelta))
    }
}

extension Image {
    func font(baseSize: Int = 17) -> some View {
        self.font(fontFromBaseSize(baseSize))
    }
}

extension Label {
    func font(baseSize: Int = 17, weight: Font.Weight) -> some View {
        self.font(fontFromBaseSize(baseSize)).fontWeight(weight)
    }
    
    func font(baseSize: Int = 17, weightDelta: Int = 0) -> some View {
        self.font(fontFromBaseSize(baseSize)).fontWeight(weightFromNormalizedNumber(weightDelta))
    }
}

extension Link {
    func font(baseSize: Int = 17, weight: Font.Weight) -> some View {
        self.font(fontFromBaseSize(baseSize)).fontWeight(weight)
    }
    
    func font(baseSize: Int = 17, weightDelta: Int = 0) -> some View {
        self.font(fontFromBaseSize(baseSize)).fontWeight(weightFromNormalizedNumber(weightDelta))
    }
}

extension Font {
    static func baseSize(_ baseSize: Int = 17, weight: Font.Weight) -> Font {
        fontFromBaseSize(baseSize).weight(weight)
    }
    
    static func baseSize(_ baseSize: Int = 17, weightDelta: Int = 0) -> Font {
        fontFromBaseSize(baseSize)
            .weight(weightFromNormalizedNumber(weightDelta))
    }
}

private func fontFromBaseSize(_ baseSize: Int) -> Font {
    switch baseSize {
    case ...11:     return .caption2
    case 12:        return .caption
    case 13, 14:    return .footnote
    case 15:        return .subheadline
    case 16:        return .callout
    case 17, 18:    return .body
    case 19, 20:    return .title3
    case 21...24:   return .title2
    case 25...30:   return .title
    case 31...:     return .largeTitle
    default:        return .body
    }
}

private func weightFromNormalizedNumber(_ normalized: Int) -> Font.Weight {
    switch normalized {
    case ...(-3):   return .ultraLight
    case -2:        return .thin
    case -1:        return .light
    case 0:         return .regular
    case 1:         return .medium
    case 2:         return .semibold
    case 3:         return .bold
    case 4:         return .heavy
    case 5...:      return .black
    default:        return .regular
    }
}
