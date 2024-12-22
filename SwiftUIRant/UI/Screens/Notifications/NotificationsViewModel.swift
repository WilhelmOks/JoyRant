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
            Task {
                await load()
            }
        }
    }
    @Published var categoryTabIndex: Int = 0
    @Published var notificationItems: [NotificationFeed.MappedNotificationItem] = []
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
    
    func load() async {
        currentRequestTask?.cancel()
        currentRequestTask = nil
        
        notificationItems = []
        
        currentRequestTask = Task { @MainActor in
            do {
                let notifications = try await Networking.shared.getNotifications(for: categoryTab.category)
                try Task.checkCancellation()
                notificationItems = notifications.mappedItems
                Task {
                    try? await DataLoader.shared.loadNumbersOfUnreadNotifications()
                }
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
                let notifications = try await Networking.shared.getNotifications(for: categoryTab.category)
                try Task.checkCancellation()
                notificationItems = notifications.mappedItems
                Task {
                    try? await DataLoader.shared.loadNumbersOfUnreadNotifications()
                }
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
            let notifications = try await Networking.shared.getNotifications(for: categoryTab.category)
            try await DataLoader.shared.loadNumbersOfUnreadNotifications()
            notificationItems = notifications.mappedItems
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isRefreshing = false
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
