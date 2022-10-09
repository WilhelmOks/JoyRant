//
//  InternalView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import SwiftUI

struct InternalView: View {
    @ObservedObject var appState = AppState.shared
    
    enum Tab: Int, Hashable {
        case feed
        case notifications
        case settings
    }
    
    @State private var tab: Tab = .feed
    
    var body: some View {
        TabView(selection: $tab) {
            NavigationStack(path: $appState.navigationPath) {
                FeedView()
            }
            .tabItem {
                Label {
                    Text("Feed")
                } icon: {
                    Image(systemName: "list.bullet.rectangle")
                }
            }
            .tag(Tab.feed)
            #if os(iOS)
            .toolbar(.visible, in: .navigationBar, .tabBar)
            #endif
            
            NavigationStack() {
                NotificationsView()
            }
            .tabItem {
                Label {
                    Text("Notifications")
                } icon: {
                    Image(systemName: "bell")
                }
            }
            .tag(Tab.notifications)
            #if os(iOS)
            .toolbar(.visible, in: .navigationBar, .tabBar)
            #endif
            
            NavigationStack() {
                SettingsView()
            }
            .tabItem {
                Label {
                    Text("Settings")
                } icon: {
                    Image(systemName: "gear")
                }
            }
            .tag(Tab.settings)
            #if os(iOS)
            .toolbar(.visible, in: .navigationBar, .tabBar)
            #endif
        }
    }
}

struct InternalView_Previews: PreviewProvider {
    static var previews: some View {
        InternalView()
    }
}
