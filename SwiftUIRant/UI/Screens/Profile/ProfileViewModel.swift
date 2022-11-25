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
    
    var categoryTabs: [CategoryTab] {
        CategoryTab.allCases.filter { (categoryCounts[$0] ?? 0) > 0 }
    }
    var categoryTab: CategoryTab {
        guard categoryTabIndex >= 0 && categoryTabIndex < categoryTabs.count else { return .rants }
        return categoryTabs[categoryTabIndex]
    }
    @Published var categoryTabIndex: Int = 0 {
        didSet {
            Task {
                //await load()
            }
        }
    }
    
    let placeholderProfile: Profile = .init(
        username: "Placeholder",
        score: 100,
        about: "This is a placeholder text that tells something about the user. It should be long enough to span a few lines.",
        location: "Placeholder Location",
        createdTime: 0,
        skills: "first skill\nsecond\nand third scill",
        github: "GithubName",
        website: "https://www.website.com",
        content: .init(
            content: .init(rants: [.mocked2()], upvoted: [], comments: []),
            counts: .init(rants: 100, upvoted: 1000, comments: 500, favorites: 30, collabs: 0)
        ),
        avatar: .init(backgroundColor: "999999", avatarImage: nil),
        avatarSmall: .init(backgroundColor: "999999", avatarImage: nil),
        isUserDPP: nil
    )
    
    var isLoaded: Bool { profile != nil }
    
    private let mocked: Bool
    
    init(userId: UserID, mocked: Bool = false) {
        self.userId = userId
        self.mocked = mocked
        
        Task {
            await load()
        }
    }
    
    func load() async {
        guard !mocked else {
            await loadMocked()
            return
        }
        
        isLoading = true
        
        do {
            profile = try await Networking.shared.userProfile(userId: userId)
            title = profile?.username ?? ""
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
    
    private func loadMocked() async {
        isLoading = true
        
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            profile = .init(
                username: "Spongeblob",
                score: 100,
                about: "This is a mocked text that tells something about the user. It should be long enough to span a few lines.",
                location: "Bikini Bottom",
                createdTime: 0,
                skills: "first skill\nsecond\nand third scill",
                github: "BlobberSponge",
                website: "https://www.example.com",
                content: .init(
                    content: .init(rants: [.mocked2()], upvoted: [], comments: []),
                    counts: .init(rants: 100, upvoted: 1000, comments: 500, favorites: 30, collabs: 0)
                ),
                avatar: .init(backgroundColor: "999999", avatarImage: nil),
                avatarSmall: .init(backgroundColor: "999999", avatarImage: nil),
                isUserDPP: nil
            )
            title = profile?.username ?? ""
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
    
    var categoryCounts: [CategoryTab: Int] {
        let counts = (profile ?? placeholderProfile).content.counts
        return [
            .rants: counts.rants,
            .upvotes: counts.upvoted,
            .comments: counts.comments,
            .favorites: counts.favorites,
        ]
    }
}

extension ProfileViewModel {
    enum CategoryTab: Int, CaseIterable, Hashable, Identifiable {
        case rants
        case upvotes
        case comments
        case favorites
        
        var id: Int { rawValue }
        
        var displayName: String {
            switch self {
            case .rants:        return "Rants"
            case .upvotes:      return "++'s"
            case .comments:     return "Comments"
            case .favorites:    return "Favorites"
            }
        }
        
        //TODO: there is more in Profile.ProfileContentTypes: "all" and "viewed". Check what to do with it.
        static func from(category: Profile.ProfileContentTypes) -> Self {
            switch category {
            case .rants:    return .rants
            case .upvoted:  return .upvotes
            case .comments: return .comments
            case .favorite: return .favorites
            default:        return .rants
            }
        }
        
        var profileContentType: Profile.ProfileContentTypes {
            switch self {
            case .rants:        return .rants
            case .upvotes:      return .upvoted
            case .comments:     return .comments
            case .favorites:    return .favorite
            }
        }
    }
}
