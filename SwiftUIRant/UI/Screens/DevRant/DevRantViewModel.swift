//
//  DevRantViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import Foundation

class DevRantViewModel: ObservableObject {
    @Published var isLoading = false
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
}
