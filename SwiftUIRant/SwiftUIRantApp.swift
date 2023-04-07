//
//  SwiftUIRantApp.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 24.08.22.
//

import SwiftUI
import ArrayBuilderModule

typealias ArrayBuilder = ArrayBuilderModule.ArrayBuilder

@main
struct SwiftUIRantApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .handlesExternalEvents(preferring: ["*"], allowing: ["*"])
                .onAppear {
                    #if os(iOS)
                    UITabBarItem.appearance().badgeColor = UIColor(Color.badgeBackground)
                    #endif
                }
        }
        .handlesExternalEvents(matching: ["*"])
    }
}
