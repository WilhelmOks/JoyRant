//
//  SwiftRantAsync.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 24.08.22.
//

import Foundation
import SwiftRant

struct Networking {
    static let shared = Self()
    
    private let swiftRant = SwiftRant(shouldUseKeychainAndUserDefaults: false)
    
    private init() {}
    
    // login

    func logIn(username: String, password: String) async throws {
        LoginStore.shared.token = try await swiftRant.logIn(username: username, password: password).get()
        
        DispatchQueue.main.async {
            AppState.shared.objectWillChange.send()
        }
    }
    
    func logOut() {
        LoginStore.shared.token = nil
        
        DispatchQueue.main.async {
            DataStore.shared.clear()
            
            AppState.shared.feedNavigationPath = .init()
            AppState.shared.notificationsNavigationPath = .init()
            
            AppState.shared.objectWillChange.send()
        }
    }
    
    private func token() throws -> UserCredentials {
        guard let token = LoginStore.shared.token else {
            throw SwiftUIRantError.noAccessTokenInKeychain
        }
        return token
    }
    
    // rants
    
    func rants(sort: RantFeed.Sort, skip: Int = 0, session: String?) async throws -> RantFeed {
        try await swiftRant.getRantFeed(
            token: try token(),
            sort: sort,
            skip: skip,
            prevSet: session
        ).get()
    }
    
    func getRant(id: Rant.ID) async throws -> (Rant, [Comment]) {
        try await swiftRant.getRantFromID(
            token: try token(),
            id: id,
            lastCommentID: nil
        ).get()
    }
    
    // weekly
    
    func weekyList() async throws -> WeeklyList {
        try await swiftRant.getWeekList(token: try token()).get()
    }
    
    func weeklyRants(week: Int, skip: Int = 0, session: String?) async throws -> RantFeed {
        try await swiftRant.getWeeklyRants(
            token: try token(),
            skip: skip,
            week: week
        ).get()
    }
    
    // vote
    
    func vote(rantID: Rant.ID, voteState: VoteState) async throws -> Rant {
        try await swiftRant.voteOnRant(
            try token(),
            rantID: rantID,
            vote: voteState
        ).get()
    }
    
    func vote(commentID: Comment.ID, voteState: VoteState) async throws -> Comment {
        try await swiftRant.voteOnComment(
            try token(),
            commentID: commentID,
            vote: voteState
        ).get()
    }
    
    // favorite
    
    func favorite(rantID: Rant.ID) async throws {
        try await swiftRant.favoriteRant(
            try token(),
            rantID: rantID
        ).get()
    }
    
    func unfavorite(rantID: Rant.ID) async throws {
        try await swiftRant.unfavoriteRant(
            try token(),
            rantID: rantID
        ).get()
    }
    
    // notifications
    
    func getNotifications(for category: Notifications.Categories) async throws -> Notifications {
        try await swiftRant.getNotificationFeed(
            token: try token(),
            lastCheckTime: nil,
            shouldGetNewNotifs: false,
            category: category
        ).get()
    }
    
    func getNumbersOfUnreadNotifications() async throws -> [Notifications.Categories: Int] {
        let notifications = try await swiftRant.getNotificationFeed(
            token: try token(),
            lastCheckTime: Int(Date().timeIntervalSince1970),
            shouldGetNewNotifs: true,
            category: .all
        ).get()
                
        return notifications.unreadByCategory
    }
    
    func clearNotifications() async throws {
        try await swiftRant.clearNotifications(try token()).get()
    }
    
    //TODO: missing API: tag suggestions
    
    // rant
    
    func postRant(type: Rant.RantType, content: String, tags: String?, image: Data?) async throws -> Rant.ID {
        try await swiftRant.postRant(try token(), postType: type, content: content, tags: tags, image: image).get()
    }
    
    func editRant(rantId: Rant.ID, type: Rant.RantType, content: String, tags: String?, image: Data?) async throws {
        try await swiftRant.editRant(try token(), rantID: rantId, postType: type, content: content, tags: tags, image: image).get()
    }
    
    func deleteRant(rantId: Rant.ID) async throws {
        try await swiftRant.deleteRant(try token(), rantID: rantId).get()
    }
    
    // comment
    
    func postComment(rantId: Rant.ID, content: String, image: Data?) async throws {
        try await swiftRant.postComment(try token(), rantID: rantId, content: content, image: image).get()        
    }
    
    func editComment(commentId: Comment.ID, content: String, image: Data?) async throws {
        try await swiftRant.editComment(try token(), commentID: commentId, content: content, image: image).get()
    }
    
    func deleteComment(commentId: Comment.ID) async throws {
        try await swiftRant.deleteComment(try token(), commentID: commentId).get()
    }
    
    // profile
    
    func userProfile(userId: UserID, contentType: Profile.ProfileContentTypes = .all, skip: Int = 0) async throws -> Profile {
        try await swiftRant.getProfileFromID(userId, token: try token(), userContentType: contentType, skip: skip).get()
    }
    
    func subscribe(userId: UserID) async throws {
        try await swiftRant.subscribeToUser(try token(), userID: userId).get()
    }
    
    func unsubscribe(userId: UserID) async throws {
        try await swiftRant.unsubscribeFromUser(try token(), userID: userId).get()
    }
    
    // community projects
    
    func communityProjects() async throws -> [CommunityProject] {
        let urlString = "https://raw.githubusercontent.com/joewilliams007/jsonapi/gh-pages/community.json"
        guard let url = URL(string: urlString) else { throw SwiftUIRantError.invalidUrl(urlString) }
        let response = try await URLSession.shared.data(for: .init(url: url))
        let container = try JSONDecoder().decode(CommunityProject.CodingData.Container.self, from: response.0)
        return container.projects.map(\.decoded)
    }
}
