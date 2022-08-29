//
//  LoginViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 24.08.22.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    
    var canSubmit: Bool {
        !username.isEmpty && !password.isEmpty
    }
    
    @MainActor func submit() async {
        guard canSubmit else { return }
        
        isLoading = true
        
        do {
            try await Networking.shared.logIn(username: username, password: password)
            try await Networking.shared.rants()
        } catch {
            dlog(error)
        }
        
        isLoading = false
    }
}
