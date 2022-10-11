//
//  InternalView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import SwiftUI

struct InternalView: View {
    @ObservedObject var appState = AppState.shared
    @ObservedObject var dataStore = DataStore.shared
    
    enum Tab: Int, CaseIterable, Hashable, Identifiable {
        case feed
        case notifications
        case settings
        
        var id: Int { rawValue }
        
        var displayName: String {
            switch self {
            case .feed:             return "Feed"
            case .notifications:    return "Notifications"
            case .settings:         return "Settings"
            }
        }
    }
    
    @State private var tab: Tab = .feed
    
    var body: some View {
        content()
            .onAppear {
                Task {
                    try? await DataLoader.shared.loadNotificationsNumber()
                }
            }
            .onChange(of: tab) { _ in
                Task {
                    try? await DataLoader.shared.loadNotificationsNumber()
                }
            }
    }
    
    @ViewBuilder private func content() -> some View {
        TabView(selection: $tab) {
            ForEach(Tab.allCases) { tab in
                tabView(tab)
            }
        }
    }
    
    @ViewBuilder private func contentForTab(_ tab: Tab) -> some View {
        switch tab {
        case .feed:             FeedView()
        case .notifications:    NotificationsView()
        case .settings:         SettingsView()
        }
    }
    
    @ViewBuilder private func tabContent(_ tab: Tab) -> some View {
        switch tab {
        case .feed:
            NavigationStack(path: $appState.navigationPath) {
                contentForTab(tab)
            }
        default:
            NavigationStack() {
                contentForTab(tab)
            }
        }
    }
    
    @ViewBuilder private func tabIcon(_ tab: Tab) -> some View {
        switch tab {
        case .feed:
            Image(systemName: "list.bullet.rectangle")
        case .notifications:
            Image(systemName: "bell")
        case .settings:
            Image(systemName: "gear")
        }
    }
    
    @ViewBuilder private func tabView(_ tab: Tab) -> some View {
        //TODO: make a proper number badge
        let title = tab == .notifications ? "\(tab.displayName) (\(dataStore.numberOfUnreadNotifications))" : tab.displayName
        
        tabContent(tab)
        .tabItem {
            Label {
                Text(title)
            } icon: {
                tabIcon(tab)
            }
        }
        .tag(tab)
        .toolbarsVisible()
    }
}

struct InternalView_Previews: PreviewProvider {
    static var previews: some View {
        InternalView()
    }
}
