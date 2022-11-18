//
//  ContentView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 24.08.22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var appState = AppState.shared
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        content()
            .onAppear {
                // This is necessary so that Alert buttons, ActionSheets, etc. get the accent color, too.
                AppState.shared.applyAccentColor()
            }
            .tint(.primaryAccent)
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active && AppState.shared.isLoggedIn {
                    Task {
                        try? await DataLoader.shared.loadNumbersOfUnreadNotifications()
                    }
                }
            }
    }
    
    @ViewBuilder private func content() -> some View {
        #if os(macOS)
        if AppState.shared.isLoggedIn {
            InternalView()
        } else {
            LoginView()
        }
        #elseif os(iOS)
        LoginView()
            .fullScreenCover(isPresented: .constant(AppState.shared.isLoggedIn)) {
                InternalView()
            }
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
