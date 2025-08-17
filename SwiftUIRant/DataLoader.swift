//
//  DataLoader.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import Foundation
import SwiftDevRant

@MainActor final class DataLoader: ObservableObject {
    static let shared = DataLoader()
    
    private let dataStore = DataStore.shared
    
    private init() {}
    
    func loadFeed(_ sort: RantFeed.Sort) async throws {
        let feed = try await Networking.shared.rants(sort: sort, session: dataStore.currentFeedSession)
        dataStore.currentFeedSession = feed.sessionHash
        dlog("current feed session: \(dataStore.currentFeedSession ?? "nil")")
        dataStore.unfilteredRantsInFeed = []
        dataStore.unfilteredRantsInFeed = feed.rants
        dataStore.rantsInFeed = []
        dataStore.rantsInFeed = feed.rants
        dataStore.isFeedLoaded = true
        Task {
            try? await loadNumbersOfUnreadNotifications()
        }
    }
    
    func loadMoreFeed(_ sort: RantFeed.Sort) async throws {
        let rantsToSkip = dataStore.unfilteredRantsInFeed.count
        let moreFeed = try await Networking.shared.rants(sort: sort, skip: rantsToSkip, session: dataStore.currentFeedSession)
        dataStore.currentFeedSession = moreFeed.sessionHash
        dlog("current feed session: \(dataStore.currentFeedSession ?? "nil")")
        addMoreRantsToFeed(moreFeed.rants)
        Task {
            try? await loadNumbersOfUnreadNotifications()
        }
    }
    
    func reloadFeed(_ sort: RantFeed.Sort) async throws {
        dataStore.clearFeedForRefresh()
        let feed = try await Networking.shared.rants(sort: sort, session: dataStore.currentFeedSession)
        dataStore.currentFeedSession = feed.sessionHash
        dlog("current feed session: \(dataStore.currentFeedSession ?? "nil")")
        dataStore.rantsInFeed = []
        try? await Task.sleep(for: .milliseconds(10)) //This gives the UI time to reset the view so that the scroll view scrolls to the top before the new rants come in.
        dataStore.rantsInFeed = feed.rants
        dataStore.unfilteredRantsInFeed = []
        dataStore.unfilteredRantsInFeed = feed.rants
        dataStore.isFeedLoaded = true
        Task {
            try? await loadNumbersOfUnreadNotifications()
        }
    }
    
    private func addMoreRantsToFeed(_ rants: [Rant]) {
        for rant in rants {
            // According to OmerFlame, duplicates are normal and should be filtered out by the app.
            let isDuplicate = dataStore.rantsInFeed.first(where: { $0.id == rant.id }) != nil
            if isDuplicate {
                dataStore.duplicatesInFeed += 1
                dlog("duplicates in feed filtered out in UI: \(dataStore.duplicatesInFeed)")
            } else {
                dataStore.rantsInFeed.append(rant)
            }
            dataStore.unfilteredRantsInFeed.append(rant)
        }
    }
    
    func loadNumbersOfUnreadNotifications() async throws {
        let calculatedUnread = try await Networking.shared.getNotifications(for: .all).mappedItems.count { notification in
            notification.isRead == false && !UserSettings().ignoredUsers.contains(notification.userName)
        }
        dataStore.calculatedNumberOfUnreadNotifications = calculatedUnread
        dlog("Updated number of unread notifications: (\(dataStore.calculatedNumberOfUnreadNotifications))")
    }
    
    func loadNotifications() async throws {
        dataStore.notifications = try await [
            .all: Networking.shared.getNotifications(for: .all).mappedItems,
            .comments: Networking.shared.getNotifications(for: .comments).mappedItems,
            .mentions: Networking.shared.getNotifications(for: .mentions).mappedItems,
            .upvotes: Networking.shared.getNotifications(for: .upvotes).mappedItems,
            .subscriptions: Networking.shared.getNotifications(for: .subscriptions).mappedItems
        ]
    }
}
