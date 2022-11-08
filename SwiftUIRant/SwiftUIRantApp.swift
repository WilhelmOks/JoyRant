//
//  SwiftUIRantApp.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 24.08.22.
//

import SwiftUI

@main
struct SwiftUIRantApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .handlesExternalEvents(preferring: ["*"], allowing: ["*"])
                .onAppear {
                    #if os(iOS)
                    UITabBarItem.appearance().badgeColor = UIColor(Color("BadgeBG"))
                    #endif
                }
        }
        .handlesExternalEvents(matching: ["*"])
    }
}
