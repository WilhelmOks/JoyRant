//
//  NotificationsViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 10.10.22.
//

import Foundation
import SwiftRant

@MainActor final class NotificationsViewModel: ObservableObject {
    let tabs = NotificationCategoryTab.allCases
    
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
            let category = AppState.shared.notificationCategoryTab.category
            try await DataLoader.shared.loadNotifications(for: category)
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
}
