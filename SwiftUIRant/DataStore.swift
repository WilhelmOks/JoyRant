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
    
    @Published var writePostContent = ""
    
    var currentFeedSession: String?
    var duplicatesInFeed = 0
        
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
        let updated = rantsInFeed.updateRant(rant)
        if updated {
            //BroadcastEvent.shouldUpdateRantInFeed(rantId: rant.id).send() //TODO: remove everywhere if not needed anymore
        }
    }
    
    func remove(rantInFeed rant: Rant) {
        rantsInFeed.removeAll { $0.id == rant.id }
    }
}
