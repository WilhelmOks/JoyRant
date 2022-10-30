//
//  FeedViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import Foundation
import SwiftRant

final class FeedViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var isReloading = false
    @Published var alertMessage: AlertMessage = .none()
    
    @Published var sort: Sort = .algorithm {
        didSet {
            DataStore.shared.currentFeedSession = nil
            Task {
                await reload()
            }
        }
    }
    
    init() {
        Task {
            await load()
        }
    }
    
    @MainActor func load() async {
        isLoading = true
        
        do {
            try await DataLoader.shared.loadFeed(sort.swiftRantSort)
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
    
    @MainActor func loadMore() async {
        isLoadingMore = true
        
        do {
            try await DataLoader.shared.loadMoreFeed(sort.swiftRantSort)
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoadingMore = false
    }
    
    @MainActor func reload() async {
        isReloading = true
        
        do {
            try await DataLoader.shared.reloadFeed(sort.swiftRantSort)
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isReloading = false
    }
}

extension FeedViewModel {
    enum Sort: Int, CaseIterable, Hashable, Identifiable {
        case algorithm
        case recent
        case topDay
        case topWeek
        case topMonth
        case topAll
        
        var id: Int { return rawValue }
        
        var swiftRantSort: RantFeed.Sort {
            switch self {
            case .algorithm:    return .algorithm
            case .recent:       return .recent
            case .topDay:       return .top(range: .day)
            case .topWeek:      return .top(range: .week)
            case .topMonth:     return .top(range: .month)
            case .topAll:       return .top(range: .all)
            }
        }
        
        var name: String {
            switch self {
            case .algorithm:    return "Algo"
            case .recent:       return "Recent"
            case .topDay:       return "Top: Day"
            case .topWeek:      return "Top: Week"
            case .topMonth:     return "Top: Month"
            case .topAll:       return "Top: All"
            }
        }
    }
}
