//
//  View+OS.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 10.10.22.
//

import SwiftUI

extension View {
    func navigationBarTitleDisplayModeInline() -> some View {
        self
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    func toolbarsVisible() -> some View {
        self
        #if os(iOS)
            .toolbar(.visible, for: .navigationBar, .tabBar)
        #elseif os(macOS)
            .toolbar(.visible, for: .windowToolbar, .automatic)
        #endif
    }
}
