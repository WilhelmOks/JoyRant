//
//  SwiftUIRantApp.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 24.08.22.
//

import SwiftUI
import SwiftData
import SwiftDevRant
import ArrayBuilderModule

typealias ArrayBuilder = ArrayBuilderModule.ArrayBuilder

@main
struct SwiftUIRantApp: App {
    let modelContainer: ModelContainer = {
        do {
            let container = try ModelContainer(for: User.DataModel.self)
            AppState.shared.swiftDataModelContext = container.mainContext
            return container
        } catch {
            print(error)
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }()
    
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
        .modelContainer(modelContainer)
    }
}
