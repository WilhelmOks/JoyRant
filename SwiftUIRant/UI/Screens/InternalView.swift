//
//  InternalView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import SwiftUI

struct InternalView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @ObservedObject var appState = AppState.shared
    @ObservedObject var dataStore = DataStore.shared
    @ObservedObject var dataLoader = DataLoader.shared
    
    enum Tab: Int, CaseIterable, Hashable, Identifiable {
        case feed
        case weekly
        case notifications
        case settings
        
        var id: Int { rawValue }
        
        var displayName: String {
            switch self {
            case .feed:             return "Feed"
            case .weekly:           return "Weekly"
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
            .onChange(of: tab) { newValue in
                DispatchQueue.main.async {
                    BroadcastEvent.didSwitchToMainTab(newValue).send()
                }
                if newValue != .notifications {
                    Task {
                        try? await dataLoader.loadNumbersOfUnreadNotifications()
                    }
                }
            }
            .onReceive(broadcastEvent: .didReselectMainTab(.feed)) { _ in
                appState.navigateToRoot(from: .feed)
            }
            .onReceive(broadcastEvent: .didReselectMainTab(.notifications)) { _ in
                appState.navigateToRoot(from: .notifications)
            }
            .onReceive(broadcastEvent: .didReselectMainTab(.weekly)) { _ in
                appState.navigateToRoot(from: .weekly)
            }
            .onReceive(broadcastEvent: .didReselectMainTab(.settings)) { _ in
                appState.navigateToRoot(from: .settings)
            }
            .onOpenURL { url in
                AppState.shared.navigate(from: tab, to: url)
            }
    }
    
    @ViewBuilder private func content() -> some View {
        let tabBinding = Binding<Tab>(
            get: { tab },
            set: { newValue in
                if newValue == tab {
                    DispatchQueue.main.async {
                        BroadcastEvent.didReselectMainTab(tab).send()
                    }
                }
                tab = newValue
            }
        )
        
        #if os(iOS)
        tabViewWithTabs(tabBinding)
        #elseif os(macOS)
        switch tab {
        case .feed:
            NavigationStack(path: $appState.feedNavigationPath) {
                tabViewWithTabs(tabBinding)
            }
        case .notifications:
            NavigationStack(path: $appState.notificationsNavigationPath) {
                tabViewWithTabs(tabBinding)
            }
        case .weekly:
            NavigationStack(path: $appState.weeklyNavigationPath) {
                tabViewWithTabs(tabBinding)
            }
        case .settings:
            NavigationStack(path: $appState.settingsNavigationPath) {
                tabViewWithTabs(tabBinding)
            }
        }
        #endif
    }
    
    @ViewBuilder private func tabViewWithTabs(_ tabBinding: Binding<Tab>) -> some View {
        TabView(selection: tabBinding) {
            ForEach(Tab.allCases) { tab in
                tabView(tab)
            }
        }
    }
    
    @ViewBuilder private func wrappedContentForTab(_ tab: Tab) -> some View {
        #if os(iOS)
        switch tab {
        case .feed:
            NavigationStack(path: $appState.feedNavigationPath) {
                contentForTab(tab)
                    .navigationBarTitleDisplayModeInline()
            }
        case .notifications:
            NavigationStack(path: $appState.notificationsNavigationPath) {
                contentForTab(tab)
                    .navigationBarTitleDisplayModeInline()
            }
        case .weekly:
            NavigationStack(path: $appState.weeklyNavigationPath) {
                contentForTab(tab)
                    .navigationBarTitleDisplayModeInline()
            }
        case .settings:
            NavigationStack(path: $appState.settingsNavigationPath) {
                contentForTab(tab)
                    .navigationBarTitleDisplayModeInline()
            }
        /*
        default:
            NavigationStack() {
                contentForTab(tab)
                    .navigationBarTitleDisplayModeInline()
            }
        */
        }
        #elseif os(macOS)
        contentForTab(tab, navigationBar: self.tab == tab)
        #endif
    }
    
    @ViewBuilder private func contentForTab(_ tab: Tab, navigationBar: Bool = true) -> some View {
        switch tab {
        case .feed:
            FeedView(navigationBar: navigationBar)
        case .weekly:
            AllWeekliesView(navigationBar: navigationBar)
        case .notifications:
            NotificationsView(navigationBar: navigationBar)
        case .settings:
            SettingsView(navigationBar: navigationBar)
        }
    }
    
    @ViewBuilder private func tabView(_ tab: Tab) -> some View {
        let title = tab.displayName
        
        let numberOfNotifications = dataStore.unreadNotifications[.all] ?? 0
        
        let badgeNumber = tab == .notifications ? numberOfNotifications : 0
        
        wrappedContentForTab(tab)
            .tabItem {
                Label {
                    Text(title)
                } icon: {
                    tabIcon(tab)
                }
            }
            .tag(tab)
            .badge(badgeNumber)
            .toolbarsVisible()
    }
    
    @ViewBuilder private func tabIcon(_ tab: Tab) -> some View {
        switch tab {
        case .feed:
            Image(systemName: "list.bullet.rectangle")
        case .weekly:
            Image(systemName: "calendar")
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
