//
//  Networking2.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 17.12.24.
//

import Foundation
import SwiftDevRant
import KreeRequest
import SpamDetector

struct Networking {
    static let shared = Self()
    
    private let devRant = DevRantRequest(requestLogger: RequestLogger())
    
    private init() {}
    
    func logIn(username: String, password: String) async throws {
        LoginStore.shared.token = try await devRant.logIn(username: username, password: password)
        
        DispatchQueue.main.async {
            AppState.shared.objectWillChange.send()
        }
    }
    
    func logOut() {
        LoginStore.shared.token = nil
        LoginStore.shared.username = nil
        LoginStore.shared.password = nil
        
        DispatchQueue.main.async {
            DataStore.shared.clear()
            
            AppState.shared.feedNavigationPath = .init()
            AppState.shared.notificationsNavigationPath = .init()
            
            AppState.shared.objectWillChange.send()
        }
    }
    
    private func token() throws -> AuthToken {
        guard let token = LoginStore.shared.token else {
            throw SwiftUIRantError.noAccessTokenInKeychain
        }
        return token
    }
    
    func relogInIfNeeded() async {
        do {
            let token = try token()
            if token.isExpired {
                if let username = LoginStore.shared.username, let password = LoginStore.shared.password {
                    dlog("Logging in again due to expired token")
                    try await logIn(username: username, password: password)
                } else {
                    dlog("Failed to re-logIn with expired token due to missing username or password.")
                }
            }
        } catch {
            dlog("relogInIfNeeded failed due to missing token: \(error)")
        }
    }
    
    // rants
    
    func rants(sort: RantFeed.Sort, skip: Int = 0, session: String?) async throws -> RantFeed {
        await loadSpamDetectionConfig()
        
        await relogInIfNeeded()
        let feed = try await devRant.getRantFeed(
            token: try token(),
            sort: sort,
            skip: skip,
            sessionHash: session
        )
        
        let scannedFeed = AppState.shared.scanForSpam(feed: feed)
        
        return scannedFeed
    }
    
    func getRant(id: Rant.ID) async throws -> (rant: Rant, comments: [Comment]) {
        await relogInIfNeeded()
        
        let result = try await devRant.getRant(
            token: try token(),
            rantId: id,
            lastCommentId: nil
        )
        
        EncounteredUsers.shared.update(user: result.rant.author)
        
        for commentAuthor in result.comments.map(\.author) {
            EncounteredUsers.shared.update(user: commentAuthor)
        }
        
        return result
    }
    
    // weekly
    
    func weekyList() async throws -> [Weekly] {
        await relogInIfNeeded()
        return try await devRant.getWeeklies(token: try token())
    }
    
    func weeklyRants(week: Int, skip: Int = 0, session: String?) async throws -> RantFeed {
        await relogInIfNeeded()
        return try await devRant.getWeeklyRants(
            token: try token(),
            week: week,
            skip: skip
        )
    }
    
    // vote
    
    func vote(rantId: Rant.ID, voteState: VoteState, downvoteReason: DownvoteReason = .notForMe) async throws -> Rant {
        await relogInIfNeeded()
        return try await devRant.voteOnRant(
            token: try token(),
            rantId: rantId,
            vote: voteState,
            downvoteReason: downvoteReason
        )
    }
    
    func vote(commentId: Comment.ID, voteState: VoteState, downvoteReason: DownvoteReason = .notForMe) async throws -> Comment {
        await relogInIfNeeded()
        return try await devRant.voteOnComment(
            token: try token(),
            commentId: commentId,
            vote: voteState,
            downvoteReason: downvoteReason
        )
    }
    
    // favorite
    
    func favorite(rantId: Rant.ID, favorite: Bool) async throws {
        await relogInIfNeeded()
        try await devRant.favoriteRant(
            token: try token(),
            rantId: rantId,
            favorite: favorite
        )
    }
    
    // notifications
    
    func getNotifications(for category: NotificationFeed.Category) async throws -> NotificationFeed {
        await relogInIfNeeded()
        return try await devRant.getNotificationFeed(
            token: try token(),
            lastChecked: nil,
            category: category
        )
    }
    
    func getNumbersOfUnreadNotifications() async throws -> [NotificationFeed.Category: Int] {
        await relogInIfNeeded()
        let notifications = try await devRant.getNotificationFeed(
            token: try token(),
            lastChecked: nil,
            category: .all
        )
        return notifications.unreadByCategory
    }
    
    func clearNotifications() async throws {
        await relogInIfNeeded()
        try await devRant.markAllNotificationsAsRead(token: try token())
    }
    
    // rant
    
    func postRant(kind: Rant.Kind, text: String, tags: String, image: Data?) async throws -> Rant.ID {
        await relogInIfNeeded()
        return try await devRant.postRant(
            token: try token(),
            kind: kind,
            text: text,
            tags: tags,
            image: image
        )
    }
    
    func editRant(rantId: Rant.ID, text: String, tags: String, image: Data?) async throws {
        await relogInIfNeeded()
        try await devRant.editRant(
            token: try token(),
            rantId: rantId,
            text: text,
            tags: tags,
            image: image
        )
    }
    
    func deleteRant(rantId: Rant.ID) async throws {
        await relogInIfNeeded()
        try await devRant.deleteRant(token: try token(), rantId: rantId)
    }
    
    // comment
    
    func postComment(rantId: Rant.ID, text: String, image: Data?) async throws {
        await relogInIfNeeded()
        try await devRant.postComment(token: try token(), rantId: rantId, text: text, image: image)
    }
    
    func editComment(commentId: Comment.ID, text: String, image: Data?) async throws {
        await relogInIfNeeded()
        try await devRant.editComment(token: try token(), commentId: commentId, text: text, image: image)
    }
    
    func deleteComment(commentId: Comment.ID) async throws {
        await relogInIfNeeded()
        try await devRant.deleteComment(token: try token(), commentId: commentId)
    }
    
    // profile
    
    func userProfile(userId: Int, contentType: Profile.ContentType = .all, skip: Int = 0) async throws -> Profile {
        await relogInIfNeeded()
        return try await devRant.getProfile(token: try token(), userId: userId, contentType: contentType, skip: skip)
    }
    
    func getOwnUserName() async throws -> String {
        await relogInIfNeeded()
        let token = try token()
        let ownProfile = try await devRant.getProfile(token: token, userId: token.userId, contentType: .favorite, skip: 0)
        return ownProfile.username
    }
    
    func subscribe(userId: UserID, subscribe: Bool) async throws {
        await relogInIfNeeded()
        if subscribe {
            try await devRant.subscribeToUser(token: try token(), userId: userId)
        } else {
            try await devRant.unsubscribeFromUser(token: try token(), userId: userId)
        }
    }
    
    // community projects
    
    func communityProjects() async throws -> [CommunityProject] {
        //TODO: use KreeRequest here
        let urlString = "https://raw.githubusercontent.com/joewilliams007/jsonapi/gh-pages/community.json"
        guard let url = URL(string: urlString) else { throw SwiftUIRantError.invalidUrl(urlString) }
        let response = try await URLSession.shared.data(for: .init(url: url))
        let container = try JSONDecoder().decode(CommunityProject.CodingData.Container.self, from: response.0)
        return container.projects.map(\.decoded)
    }
    
    // spam detection
    
    func loadSpamDetectionConfig() async {
        let url = "https://raw.githubusercontent.com/WilhelmOks/JoyRant/refs/heads/main/spam_detection_config.json"
        if let config = await SpamDetector.Config.fromRemoteUrl(jsonUrl: url) {
            AppState.shared.spamDetectorConfig = config
        }
    }
    
    // molodetz mentions
    
    func molodetzMentions() async throws -> [MolodetzMention.CodingData] {
        guard UserSettings().loadMentionsFromMolodetz else { return [] }
        //TODO: use KreeRequest here
        let urlString = "https://static.molodetz.nl/dr.mentions.json"
        guard let url = URL(string: urlString) else { throw SwiftUIRantError.invalidUrl(urlString) }
        let response = try await URLSession.shared.data(for: .init(url: url))
        let codingData = try JSONDecoder().decode([MolodetzMention.CodingData].self, from: response.0)
        let withoutDuplicates = codingData.uniqued(on: \.self)
        let ownUsername = await DataStore.shared.ownUsername
        return withoutDuplicates.filter { $0.to == ownUsername }
    }
}

struct RequestLogger: Logger {
    func log(_ message: String) {
        dlog(message)
    }
}
