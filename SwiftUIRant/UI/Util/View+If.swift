//
//  View+If.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 11.10.22.
//

import SwiftUI

extension View {
    @ViewBuilder func `if`<IfView: View>(_ condition: Bool, modifier: (Self) -> IfView) -> some View {
        if condition {
            modifier(self)
        } else {
            self
        }
    }
}
