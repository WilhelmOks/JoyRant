//
//  ProfileViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 19.11.22.
//

import Foundation

@MainActor final class ProfileViewModel: ObservableObject {
    let userId: UserID
    
    @Published var isLoading = true
    @Published var alertMessage: AlertMessage = .none()
    @Published var profile: UserProfile?
    @Published var title = ""
    
    var categoryTabs: [CategoryTab] {
        CategoryTab.allCases.filter { categoryCount(tab: $0) > 0 }
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
    
    let placeholderProfile: UserProfile = .init(
        username: "Placeholder",
        score: 100,
        createdTime: 0,
        about: "This is a placeholder text that tells something about the user. It should be long enough to span a few lines.",
        location: "Placeholder Location",
        skills: "first skill\nsecond\nand third scill",
        github: "GithubName",
        website: "https://www.website.com",
        avatar: .init(backgroundColor: "999999", avatarImage: nil),
        avatarSmall: .init(backgroundColor: "999999", avatarImage: nil),
        isSupporter: false,
        content: .init(
            counts: [.rants: 100, .upvoted: 1000, .comments: 500, .favorites: 30, .collabs: 0],
            rants: [.mocked2()],
            upvoted: [],
            comments: [],
            favorites: [],
            viewed: []
        )
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
            profile = .init(profile: try await Networking.shared.userProfile(userId: userId))
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
                createdTime: 0,
                about: "This is a mocked text that tells something about the user. It should be long enough to span a few lines.",
                location: "Bikini Bottom",
                skills: "first skill\nsecond\nand third scill",
                github: "BlobberSponge",
                website: "https://www.example.com",
                avatar: .init(backgroundColor: "999999", avatarImage: nil),
                avatarSmall: .init(backgroundColor: "999999", avatarImage: nil),
                isSupporter: false,
                content: .init(
                    counts: [.rants: 100, .upvoted: 1000, .comments: 500, .favorites: 30, .collabs: 0],
                    rants: [.mocked2()],
                    upvoted: [],
                    comments: [],
                    favorites: [],
                    viewed: []
                )
            )
            title = profile?.username ?? ""
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
    
    func categoryCount(tab: CategoryTab) -> Int {
        (profile ?? placeholderProfile).content.counts[tab.contentType] ?? 0
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
        
        static func from(contentType: UserProfile.ContentType) -> Self {
            switch contentType {
            case .rants:        return .rants
            case .upvoted:      return .upvotes
            case .comments:     return .comments
            case .favorites:    return .favorites
            default:            return .rants
            }
        }
        
        var contentType: UserProfile.ContentType {
            switch self {
            case .rants:        return .rants
            case .upvotes:      return .upvoted
            case .comments:     return .comments
            case .favorites:    return .favorites
            }
        }
    }
}
