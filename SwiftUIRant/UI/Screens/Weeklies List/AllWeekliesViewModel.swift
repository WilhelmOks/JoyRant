//
//  AllWeekliesViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 14.01.23.
//

import Foundation
import SwiftDevRant

@MainActor final class AllWeekliesViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var alertMessage: AlertMessage = .none()
    @Published var weeks: [Weekly] = []
    
    init() {
        Task {
            await load()
        }
    }
    
    func load() async {
        isLoading = true
        
        do {
            weeks = try await Networking.shared.weekyList()
            
            Task {
                try? await DataLoader.shared.loadNumbersOfUnreadNotifications()
            }
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
    
    func refresh() async {
        guard !isRefreshing && !isLoading else { return }
        
        isRefreshing = true
        
        do {
            weeks = try await Networking.shared.weekyList()
            
            Task {
                try? await DataLoader.shared.loadNumbersOfUnreadNotifications()
            }
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isRefreshing = false
    }
}
