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
    @ObservedObject var dataLoader = DataLoader.shared
    
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
                    try? await dataLoader.loadNumbersOfUnreadNotifications()
                }
            }
            .onChange(of: tab) { _ in
                Task {
                    try? await dataLoader.loadNumbersOfUnreadNotifications()
                }
            }
    }
    
    @ViewBuilder private func content() -> some View {
        #if os(iOS)
        TabView(selection: $tab) {
            ForEach(Tab.allCases) { tab in
                tabView(tab)
            }
        }
        #elseif os(macOS)
        NavigationStack(path: $appState.navigationPath) {
            TabView(selection: $tab) {
                ForEach(Tab.allCases) { tab in
                    tabView(tab)
                }
            }
        }
        #endif
    }
    
    @ViewBuilder private func wrappedContentForTab(_ tab: Tab) -> some View {
        #if os(iOS)
        switch tab {
        case .feed:
            NavigationStack(path: $appState.navigationPath) {
                contentForTab(tab)
                    .navigationBarTitleDisplayModeInline()
            }
        default:
            NavigationStack() {
                contentForTab(tab)
                    .navigationBarTitleDisplayModeInline()
            }
        }
        #elseif os(macOS)
        contentForTab(tab, navigationBar: self.tab == tab)
        #endif
    }
    
    @ViewBuilder private func contentForTab(_ tab: Tab, navigationBar: Bool = true) -> some View {
        switch tab {
        case .feed:
            FeedView(navigationBar: navigationBar)
        case .notifications:
            NotificationsView(navigationBar: navigationBar)
        case .settings:
            SettingsView(navigationBar: navigationBar)
        }
    }
    
    @ViewBuilder private func tabView(_ tab: Tab) -> some View {
        let numberOfNotifications = dataStore.unreadNotifications[.all] ?? 0
        // It's not possible to make nice looking number badges for the tab bar. As a workaround, the number is shown in the title:
        let title = tab == .notifications ? "\(tab.displayName) (\(numberOfNotifications))" : tab.displayName
        
        wrappedContentForTab(tab)
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
}

struct InternalView_Previews: PreviewProvider {
    static var previews: some View {
        InternalView()
    }
}
