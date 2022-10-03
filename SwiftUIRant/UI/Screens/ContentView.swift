//
//  ContentView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 24.08.22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var appState = AppState.shared
    
    var body: some View {
        content()
            .onAppear {
                // This is necessary so that Alert buttons, ActionSheets, etc. get the accent color, too.
                AppState.shared.applyAccentColor()
            }
            .accentColor(.accentColor)
    }
    
    @ViewBuilder private func content() -> some View {
        if AppState.shared.isLoggedIn {
            InternalView()
        } else {
            LoginView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
