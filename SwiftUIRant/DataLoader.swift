//
//  DataLoader.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import Foundation
import SwiftRant

final class DataLoader: ObservableObject {
    static let shared = DataLoader()
    
    private let dataStore = DataStore.shared
    
    private init() {}
    
    @MainActor func loadFeed(_ sort: RantFeed.Sort) async throws {
        let feed = try await Networking.shared.rants(sort: sort, session: dataStore.currentFeedSession)
        dataStore.currentFeedSession = feed.set
        dlog("current feed session: \(dataStore.currentFeedSession ?? "nil")")
        dataStore.unfilteredRantsInFeed = feed.rants
        dataStore.rantsInFeed = feed.rants
        dataStore.isFeedLoaded = true
        Task {
            try? await loadNumbersOfUnreadNotifications()
        }
    }
    
    @MainActor func loadMoreFeed(_ sort: RantFeed.Sort) async throws {
        let rantsToSkip = dataStore.unfilteredRantsInFeed.count
        let moreFeed = try await Networking.shared.rants(sort: sort, skip: rantsToSkip, session: dataStore.currentFeedSession)
        dataStore.currentFeedSession = moreFeed.set
        dlog("current feed session: \(dataStore.currentFeedSession ?? "nil")")
        addMoreRantsToFeed(moreFeed.rants)
        Task {
            try? await loadNumbersOfUnreadNotifications()
        }
    }
    
    @MainActor func reloadFeed(_ sort: RantFeed.Sort) async throws {
        dataStore.clearFeedForRefresh()
        let feed = try await Networking.shared.rants(sort: sort, session: dataStore.currentFeedSession)
        dataStore.currentFeedSession = feed.set
        dlog("current feed session: \(dataStore.currentFeedSession ?? "nil")")
        dataStore.rantsInFeed = feed.rants
        dataStore.unfilteredRantsInFeed = feed.rants
        dataStore.isFeedLoaded = true
        Task {
            try? await loadNumbersOfUnreadNotifications()
        }
    }
    
    private func addMoreRantsToFeed(_ rants: [RantInFeed]) {
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
    
    @MainActor func loadNumbersOfUnreadNotifications() async throws {
        dataStore.unreadNotifications = try await Networking.shared.getNumbersOfUnreadNotifications()
        dlog("Updated number of unread notifications: (\(dataStore.unreadNotifications[.all] ?? 0))")
    }
}
