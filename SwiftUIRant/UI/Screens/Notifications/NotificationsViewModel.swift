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
    
    @Published var categoryTab: CategoryTab = .all
    @Published var isLoading = false
    @Published var alertMessage: AlertMessage = .none()
    
    init() {
        Task {
            await load()
        }
    }
    
    func load() async {
        isLoading = true
        
        do {
            try await DataLoader.shared.loadNotifications(for: categoryTab.category)
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
