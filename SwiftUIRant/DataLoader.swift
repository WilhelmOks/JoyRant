//
//  DataLoader.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import Foundation

final class DataLoader {
    static let shared = DataLoader()
    
    let dataStore = DataStore.shared
    
    private init() {}
    
    @MainActor func loadFeed() async throws {
        let feed = try await Networking.shared.rants(session: dataStore.currentFeedSession)
        dataStore.currentFeedSession = feed.set
        dlog("current feed session: \(dataStore.currentFeedSession ?? "nil")")
        dataStore.rantsInFeed = feed.rants
        dataStore.isFeedLoaded = true
    }
    
    @MainActor func loadMoreFeed() async throws {
        let moreFeed = try await Networking.shared.rants(skip: dataStore.rantsInFeed.count, session: dataStore.currentFeedSession)
        dataStore.currentFeedSession = moreFeed.set
        dlog("current feed session: \(dataStore.currentFeedSession ?? "nil")")
        dataStore.rantsInFeed += moreFeed.rants
        
        let groups = Dictionary(grouping: dataStore.rantsInFeed, by: \.id)
        let hasDuplicates = groups.first { $1.count > 1 } != nil
        if hasDuplicates {
            dlog("Found duplicates in rant feed!") //TODO: Still getting duplicates. I don't know how to prevent it.
        }
    }
}
