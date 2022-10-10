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
        .toolbar(.visible, in: .navigationBar, .tabBar)
        #elseif os(macOS)
        .toolbar(.visible, in: .windowToolbar, .automatic)
        #endif
    }
}
