//
//  ProfileViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 19.11.22.
//

import Foundation

@MainActor final class ProfileViewModel: ObservableObject {
    let userId: UserID
    
    init(userId: UserID) {
        self.userId = userId
    }
}
