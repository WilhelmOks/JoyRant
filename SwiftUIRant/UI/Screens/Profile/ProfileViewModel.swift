//
//  ProfileViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 19.11.22.
//

import Foundation
import SwiftRant

@MainActor final class ProfileViewModel: ObservableObject {
    let userId: UserID
    
    @Published var isLoading = true
    @Published var alertMessage: AlertMessage = .none()
    @Published var profile: Profile?
    @Published var title = ""
    
    let placeholderProfile: Profile = .init(
        username: "Placeholder",
        score: 100,
        about: "This is a placeholder text that tells something about the user. It should be long enough to span a few lines.",
        location: "location",
        createdTime: 0,
        skills: "first skill\nsecond\nand third scill",
        github: "https://github.com/example",
        website: "https://www.website.com",
        content: .init(
            content: .init(rants: [], upvoted: [], comments: []),
            counts: .init(rants: 0, upvoted: 0, comments: 0, favorites: 0, collabs: 0)
        ),
        avatar: .init(backgroundColor: "999999", avatarImage: nil),
        avatarSmall: .init(backgroundColor: "999999", avatarImage: nil),
        isUserDPP: nil
    )
    
    var isLoaded: Bool { profile != nil }
    
    init(userId: UserID) {
        self.userId = userId
        
        Task {
            await load()
        }
    }
    
    func load() async {
        isLoading = true
        
        do {
            profile = try await Networking.shared.userProfile(userId: userId)
            title = profile?.username ?? ""
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
}
