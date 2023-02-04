//
//  WeekRantsViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 04.02.23.
//

import Foundation
import SwiftRant

@MainActor final class WeekRantsViewModel: ObservableObject {
    let week: WeeklyList.Week
    
    @Published var rants: [RantInFeed] = []
    
    @Published var isLoaded = false
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var isRefreshing = false
    @Published var alertMessage: AlertMessage = .none()
    
    private var feed: RantFeed?
    
    init(week: WeeklyList.Week) {
        self.week = week
        
        Task {
            await load()
        }
    }
    
    func load() async {
        isLoading = true
        
        do {
            let feed = try await Networking.shared.weeklyRants(week: week.week, skip: 0, session: nil)
            self.feed = feed
            rants = feed.rants
            isLoaded = true
            
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
            let feed = try await Networking.shared.weeklyRants(week: week.week, skip: 0, session: nil)
            self.feed = feed
            rants = feed.rants
            
            Task {
                try? await DataLoader.shared.loadNumbersOfUnreadNotifications()
            }
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
    
    func loadMore() async {
        isLoadingMore = true
        
        do {
            let feed = try await Networking.shared.weeklyRants(week: week.week, skip: rants.count, session: feed?.set)
            self.feed = feed
            rants += feed.rants
            
            Task {
                try? await DataLoader.shared.loadNumbersOfUnreadNotifications()
            }
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoadingMore = false
    }
}
