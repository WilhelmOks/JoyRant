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
    @Published var isLoadingMore = false
    @Published var isLoadingFirst = false
    @Published var alertMessage: AlertMessage = .none()
    @Published var profile: UserProfile?
    @Published var title = ""
    
    var categoryTabs: [CategoryTab] {
        CategoryTab.allCases
            .filter { $0 == .viewed || categoryCount(tab: $0) > 0 }
            .filter { isOwnProfile || $0 != .viewed }
    }
    var categoryTab: CategoryTab {
        guard categoryTabIndex >= 0 && categoryTabIndex < categoryTabs.count else { return .rants }
        return categoryTabs[categoryTabIndex]
    }
    @Published var categoryTabIndex: Int = 0
    
    private var isOwnProfile: Bool {
        LoginStore.shared.token?.authToken.userID == userId
    }
    
    // This will be visible as a redacted view while the actual profile data is loading.
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
    
    private func currentLoadedContentCount(tab: CategoryTab) -> Int {
        guard let content = profile?.content else { return 0 }
        switch tab {
        case .rants:        return content.rants.count
        case .upvotes:      return content.upvoted.count
        case .comments:     return content.comments.count
        case .viewed:       return content.viewed.count
        case .favorites:    return content.favorites.count
        }
    }
    
    func categoryTab(atIndex index: Int) -> CategoryTab? {
        guard index >= 0 && index < categoryTabs.count else { return nil }
        return categoryTabs[index]
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
    
    func loadMore(tab: CategoryTab) async {
        isLoadingMore = true
        
        do {
            guard let contentType = tab.contentType.profileContentType else {
                throw SwiftUIRantError.unknownProfileContentType
            }
            let skip = currentLoadedContentCount(tab: tab)
            let moreProfile = try await Networking.shared.userProfile(userId: userId, contentType: contentType, skip: skip)
            profile?.append(profile: moreProfile)
            title = profile?.username ?? ""
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoadingMore = false
    }
    
    func loadFirstDataSetIfEmpty(tab: CategoryTab) async {
        guard currentLoadedContentCount(tab: tab) == 0 else { return }
        
        isLoadingFirst = true
        
        await loadMore(tab: tab)
        
        isLoadingFirst = false
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
        case viewed
        case favorites
        
        var id: Int { rawValue }
        
        var displayName: String {
            switch self {
            case .rants:        return "Rants"
            case .upvotes:      return "++'s"
            case .comments:     return "Comments"
            case .viewed:       return "Viewed"
            case .favorites:    return "Favorites"
            }
        }
        
        static func from(contentType: UserProfile.ContentType) -> Self {
            switch contentType {
            case .rants:        return .rants
            case .upvoted:      return .upvotes
            case .comments:     return .comments
            case .viewed:       return .viewed
            case .favorites:    return .favorites
            default:            return .rants
            }
        }
        
        var contentType: UserProfile.ContentType {
            switch self {
            case .rants:        return .rants
            case .upvotes:      return .upvoted
            case .comments:     return .comments
            case .viewed:       return .viewed
            case .favorites:    return .favorites
            }
        }
    }
}
