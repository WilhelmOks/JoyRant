//
//  CommunityProjectsViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 07.04.23.
//

import Foundation

@MainActor final class CommunityProjectsViewModel: ObservableObject {
    var loadedItems: [CommunityProject] = []
    @Published var items: [CommunityProject] = []
    @Published var isLoading = false
    @Published var alertMessage: AlertMessage = .none()
    @Published var searchText = "" {
        didSet {
            items = filter(searchText: searchText, items: loadedItems)
        }
    }
    
    init() {
        Task {
            await load()
        }
    }
    
    func load() async {
        isLoading = true
        
        do {
            loadedItems = try await Networking.shared.communityProjects()
            items = filter(searchText: searchText, items: loadedItems)
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
    
    func filter(searchText: String, items: [CommunityProject]) -> [CommunityProject] {
        guard !searchText.isEmpty else { return items }
        return items.filter { item in
            return
                item.title.localizedCaseInsensitiveContains(searchText) ||
                item.description.localizedCaseInsensitiveContains(searchText) ||
                item.owner.localizedCaseInsensitiveContains(searchText)
        }
    }
}
