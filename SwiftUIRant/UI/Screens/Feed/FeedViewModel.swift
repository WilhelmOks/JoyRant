//
//  FeedViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import Foundation

class FeedViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var alertMessage: AlertMessage = .none()
    
    init() {
        Task {
            await load()
        }
    }
    
    @MainActor func load() async {
        isLoading = true
        
        do {
            try await DataLoader.shared.loadFeed()
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
    
    @MainActor func loadMore() async {
        isLoadingMore = true
        
        do {
            try await DataLoader.shared.loadMoreFeed()
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoadingMore = false
    }
    
    @MainActor func reload() async {
        isLoading = true
        
        do {
            try await DataLoader.shared.reloadFeed()
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
}
