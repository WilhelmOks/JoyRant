//
//  DataStore.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import Foundation
import SwiftRant

@MainActor final class DataStore: ObservableObject {
    static let shared = DataStore()
    
    private init() {}
    
    @Published var isFeedLoaded = false
    @Published var unfilteredRantsInFeed: [RantInFeed] = []
    @Published var rantsInFeed: [RantInFeed] = []
    @Published var unreadNotifications: [Notifications.Categories: Int] = [:]
    
    @Published var writeCommentContent = ""
    
    var currentFeedSession: String?
    var duplicatesInFeed = 0
    
    //TODO: reset navigation stack when logged out
    
    func clear() {
        clearFeed()
        unreadNotifications = [:]
    }
    
    func clearFeed() {
        unfilteredRantsInFeed = []
        rantsInFeed = []
        isFeedLoaded = false
        currentFeedSession = nil
        duplicatesInFeed = 0
    }
    
    func clearFeedForRefresh() {
        unfilteredRantsInFeed = []
        currentFeedSession = nil
        duplicatesInFeed = 0
    }
    
    func rantInFeed(byId id: Int) -> RantInFeed? {
        rantsInFeed.first { $0.id == id }
    }

    func update(rantInFeed rant: Rant) {
        if let index = rantsInFeed.firstIndex(where: { $0.id == rant.id }) {
            rantsInFeed[index] = rantsInFeed[index].withData(fromRant: rant)
            BroadcastEvent.shouldUpdateRantInFeed(rantId: rant.id).send()
        }
    }
}
