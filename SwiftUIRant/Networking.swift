//
//  SwiftRantAsync.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 24.08.22.
//

import Foundation
import SwiftRant
import SwiftKeychainWrapper

struct Networking {
    static let shared = Self()
    
    struct SwiftUIRantError: Swift.Error {
        let message: String
    }
    
    private let swiftRant = SwiftRant.shared //SwiftRant(shouldUseKeychainAndUserDefaults: false)
    
    private let keychainWrapper = KeychainWrapper(serviceName: "SwiftRant")
    
    var userCredentials: UserCredentials? {
        get {
            return keychainWrapper.decode(forKey: "DRToken")
        }
        set {
            let success = keychainWrapper.encodeAndSet(
                newValue,
                forKey: "DRToken",
                withAccessibility: .whenUnlockedThisDeviceOnly
            )
            if !success {
                dlog("Error: failed to store token in keychain")
            }
        }
    }
    
    private init() {}
    
    func logIn(username: String, password: String) async throws {
        _ = try await swiftRant.logIn(username: username, password: password).get()
        
        DispatchQueue.main.async {
            AppState.shared.objectWillChange.send()
        }
    }
    
    func logOut() {
        swiftRant.logOut()
        
        DataStore.shared.clear()
        
        DispatchQueue.main.async {
            AppState.shared.objectWillChange.send()
        }
    }
    
    private func token() throws -> UserCredentials {
        //guard let token = SwiftRant.shared.tokenFromKeychain else {
        guard let userCredentials else {
            throw SwiftUIRantError(message: "No access token in keychain.")
        }
        return userCredentials
    }
    
    func rants(skip: Int = 0, session: String?) async throws -> RantFeed {
        try await swiftRant.getRantFeed(
            token: try token(),
            skip: skip,
            prevSet: session
        ).get()
    }
    
    func getRant(id: Int) async throws -> (Rant, [Comment]) {
        try await swiftRant.getRantFromID(
            token: try token(),
            id: id,
            lastCommentID: nil
        ).get()
    }
    
    func vote(rantID: Int, voteState: VoteState) async throws -> Rant {
        try await swiftRant.voteOnRant(
            try token(),
            rantID: rantID,
            vote: voteState
        ).get()
    }
    
    func vote(commentID: Int, voteState: VoteState) async throws -> Comment {
        try await swiftRant.voteOnComment(
            try token(),
            commentID: commentID,
            vote: voteState
        ).get()
    }
    
    func favorite(rantID: Int) async throws {
        try await swiftRant.favoriteRant(
            try token(),
            rantID: rantID
        ).get()
    }
    
    func unfavorite(rantID: Int) async throws {
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
        
        dlog("### notifications.items.count: \(notifications.items.count)")
        
        return notifications.unreadByCategory
    }
    
    func clearNotifications() async throws {
        try await swiftRant.clearNotifications(try token()).get()
    }
}
