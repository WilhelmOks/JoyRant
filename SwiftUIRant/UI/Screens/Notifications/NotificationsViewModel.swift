//
//  NotificationsViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 10.10.22.
//

import Foundation
import SwiftDevRant

@MainActor final class NotificationsViewModel: ObservableObject {
    let tabs = CategoryTab.allCases
    
    @Published var categoryTab: CategoryTab = .all {
        didSet {
            categoryTabIndex = tabs.firstIndex(of: categoryTab) ?? 0
        }
    }
    @Published var categoryTabIndex: Int = 0
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var alertMessage: AlertMessage = .none()
    
    private(set) var isLoaded = false
    
    private var currentRequestTask: Task<(), Never>? {
        didSet {
            isLoading = currentRequestTask != nil
        }
    }
    
    init() {
        Task {
            await load()
        }
    }
    
    private func fetch() async throws {
        try await DataLoader.shared.loadNotifications()
        try Task.checkCancellation()
        try await DataLoader.shared.loadNumbersOfUnreadNotifications()
    }
    
    func load() async {
        currentRequestTask?.cancel()
        currentRequestTask = nil
        
        //notificationItems = []
        
        currentRequestTask = Task { @MainActor in
            do {
                try await fetch()
                isLoaded = true
            } catch {
                alertMessage = .presentedError(error)
            }
            currentRequestTask = nil
        }
        let _ = await currentRequestTask?.value
    }
    
    func refresh() async {
        currentRequestTask?.cancel()
        currentRequestTask = nil
        
        isRefreshing = true
        
        currentRequestTask = Task { @MainActor in
            do {
                try await fetch()
                isLoaded = true
            } catch {
                dlog("Error refreshing notifications: \(error)")
            }
            currentRequestTask = nil
        }
        let _ = await currentRequestTask?.value
        
        isRefreshing = false
    }
    
    func clear() async {
        isRefreshing = true
                
        do {
            try await Networking.shared.clearNotifications()
            try await fetch()
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isRefreshing = false
    }
    
    func categoryHasUnreadNotifications(category: NotificationFeed.Category) -> Bool {
        DataStore.shared.notifications[category]?
            .filter { item in !UserSettings().ignoredUsers.contains(item.userName) }
            .contains { item in !item.isRead } ?? false
    }
}

extension NotificationsViewModel {
    enum CategoryTab: Int, CaseIterable, Hashable, Identifiable {
        case all
        case upvotes
        case mentions
        case comments
        case subscriptions
        
        var id: Int { rawValue }
        
        var displayName: String {
            switch self {
            case .all:              "All"
            case .upvotes:          "++"
            case .mentions:         "Mentions"
            case .comments:         "Comments"
            case .subscriptions:    "Subscriptions"
            }
        }
        
        static func from(category: NotificationFeed.Category) -> Self {
            switch category {
            case .all:              .all
            case .upvotes:          .upvotes
            case .mentions:         .mentions
            case .comments:         .comments
            case .subscriptions:    .subscriptions
            }
        }
        
        var category: NotificationFeed.Category {
            switch self {
            case .all:              .all
            case .upvotes:          .upvotes
            case .mentions:         .mentions
            case .comments:         .comments
            case .subscriptions:    .subscriptions
            }
        }
    }
}
