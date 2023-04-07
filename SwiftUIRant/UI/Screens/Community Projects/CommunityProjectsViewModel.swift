//
//  CommunityProjectsViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 07.04.23.
//

import Foundation

@MainActor final class CommunityProjectsViewModel: ObservableObject {
    @Published var items: [CommunityProject] = []
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
            items = try await Networking.shared.communityProjects()
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
}
