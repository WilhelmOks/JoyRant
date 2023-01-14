//
//  AllWeekliesViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 14.01.23.
//

import Foundation
import SwiftRant

@MainActor final class AllWeekliesViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var alertMessage: AlertMessage = .none()
    @Published var weeks: [WeeklyList.Week] = []
    
    init() {
        Task {
            await load()
        }
    }
    
    func load() async {
        isLoading = true
        
        do {
            let weeklyList = try await Networking.shared.weekyList()
            weeks = weeklyList.weeks
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
    
    func refresh() async {
        guard !isRefreshing && !isLoading else { return }
        
        isRefreshing = true
        
        do {
            let weeklyList = try await Networking.shared.weekyList()
            weeks = weeklyList.weeks
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isRefreshing = false
    }
}
