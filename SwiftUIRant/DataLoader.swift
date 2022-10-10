//
//  DataLoader.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import Foundation
import SwiftRant

final class DataLoader {
    static let shared = DataLoader()
    
    let dataStore = DataStore.shared
    
    private init() {}
    
    @MainActor func loadFeed() async throws {
        let feed = try await Networking.shared.rants(session: dataStore.currentFeedSession)
        //dataStore.currentFeedSession = feed.set
        dlog("current feed session: \(dataStore.currentFeedSession ?? "nil")")
        dataStore.unfilteredRantsInFeed = feed.rants
        dataStore.rantsInFeed = feed.rants
        dataStore.isFeedLoaded = true
    }
    
    @MainActor func loadMoreFeed() async throws {
        let rantsToSkip = dataStore.unfilteredRantsInFeed.count
        let moreFeed = try await Networking.shared.rants(skip: rantsToSkip, session: dataStore.currentFeedSession)
        //dataStore.currentFeedSession = moreFeed.set
        dlog("current feed session: \(dataStore.currentFeedSession ?? "nil")")
        addMoreRantsToFeed(moreFeed.rants)
    }
    
    @MainActor func reloadFeed() async throws {
        dataStore.clearFeed()
        let feed = try await Networking.shared.rants(session: dataStore.currentFeedSession)
        //dataStore.currentFeedSession = feed.set
        dlog("current feed session: \(dataStore.currentFeedSession ?? "nil")")
        dataStore.rantsInFeed = feed.rants
        dataStore.unfilteredRantsInFeed = feed.rants
        dataStore.isFeedLoaded = true
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
    
    @MainActor func loadNotifications(for category: Notifications.Categories) async throws {
        dataStore.notifications = try await Networking.shared.getNotifications(for: category)
    }
}
