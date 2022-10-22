//
//  SwiftRantAsync.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 24.08.22.
//

import Foundation
import SwiftRant

#if os(iOS)
import UIKit
typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
typealias PlatformImage = NSImage
#endif

struct Networking {
    static let shared = Self()
    
    private let swiftRant = SwiftRant(shouldUseKeychainAndUserDefaults: false)
    
    private init() {}

    func logIn(username: String, password: String) async throws {
        LoginStore.shared.token = try await swiftRant.logIn(username: username, password: password).get()
        
        DispatchQueue.main.async {
            AppState.shared.objectWillChange.send()
        }
    }
    
    func logOut() {
        LoginStore.shared.token = nil
        
        DataStore.shared.clear()
        
        DispatchQueue.main.async {
            AppState.shared.objectWillChange.send()
        }
    }
    
    private func token() throws -> UserCredentials {
        guard let token = LoginStore.shared.token else {
            throw SwiftUIRantError.noAccessTokenInKeychain
        }
        return token
    }
    
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
    
    func postComment(rantId: Rant.ID, content: String, image: PlatformImage?) async throws {
        try await swiftRant.postComment(try token(), rantID: rantId, content: content, image: image).get()
    }
    
    func editComment(commentId: Comment.ID, content: String, image: PlatformImage?) async throws {
        try await swiftRant.editComment(try token(), commentID: commentId, content: content, image: image).get()
    }
    
    func deleteComment(commentId: Comment.ID) async throws {
        try await swiftRant.deleteComment(try token(), commentID: commentId).get()
    }
}
