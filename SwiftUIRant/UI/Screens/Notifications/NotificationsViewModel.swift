//
//  NotificationsViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 10.10.22.
//

import Foundation
import SwiftRant

@MainActor final class NotificationsViewModel: ObservableObject {
    let tabs = CategoryTab.allCases
    
    @Published var categoryTab: CategoryTab = .all {
        didSet {
            Task {
                await load()
            }
        }
    }
    @Published var notificationItems: [Notifications.MappedNotificationItem] = []
    @Published var isLoading = false
    @Published var alertMessage: AlertMessage = .none()
    
    init() {
        Task {
            await load()
        }
    }
    
    func load() async {
        isLoading = true
        
        notificationItems = []
        
        do {
            let notifications = try await Networking.shared.getNotifications(for: categoryTab.category)
            notificationItems = notifications.mappedItems
            Task {
                try? await DataLoader.shared.loadNumbersOfUnreadNotifications()
            }
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
    
    func refresh() async {
        isLoading = true
        
        do {
            let notifications = try await Networking.shared.getNotifications(for: categoryTab.category)
            notificationItems = notifications.mappedItems
            Task {
                try? await DataLoader.shared.loadNumbersOfUnreadNotifications()
            }
        } catch {
            dlog("Error refreshing notifications: \(error)")
        }
        
        isLoading = false
    }
    
    func clear() async {
        isLoading = true
                
        do {
            try await Networking.shared.clearNotifications()
            let notifications = try await Networking.shared.getNotifications(for: categoryTab.category)
            try await DataLoader.shared.loadNumbersOfUnreadNotifications()
            notificationItems = notifications.mappedItems
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
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
            case .all:              return "All"
            case .upvotes:          return "++"
            case .mentions:         return "Mentions"
            case .comments:         return "Comments"
            case .subscriptions:    return "Subscriptions"
            }
        }
        
        static func from(category: Notifications.Categories) -> Self {
            switch category {
            case .all:      return .all
            case .upvotes:  return .upvotes
            case .mentions: return .mentions
            case .comments: return .comments
            case .subs:     return .subscriptions
            }
        }
        
        var category: Notifications.Categories {
            switch self {
            case .all:              return .all
            case .upvotes:          return .upvotes
            case .mentions:         return .mentions
            case .comments:         return .comments
            case .subscriptions:    return .subs
            }
        }
    }
}
