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
    @Published var alertMessage: AlertMessage = .none()
    
    var canSubmit: Bool {
        !username.isEmpty && !password.isEmpty
    }
    
    @MainActor func submit() async {
        guard canSubmit else { return }
        
        isLoading = true
        
        do {
            try await Networking.shared.logIn(username: username, password: password)
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
}
