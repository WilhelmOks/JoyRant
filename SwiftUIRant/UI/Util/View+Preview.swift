//
//  View+Preview.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 11.09.22.
//

import SwiftUI

extension View {
    func eachColorScheme() -> some View {
        Group {
            self.preferredColorScheme(.light)
            self.preferredColorScheme(.dark)
        }
    }
    
    func largeFontDuplicate() -> some View {
        Group {
            self
            self.environment(\.sizeCategory, .accessibilityExtraLarge)
        }
    }
}
