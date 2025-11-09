//
//  DataStore.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import Foundation
import SwiftDevRant

@MainActor final class DataStore: ObservableObject {
    static let shared = DataStore()
    
    private init() {}
    
    @Published var isFeedLoaded = false
    @Published var unfilteredRantsInFeed: [Rant] = []
    @Published var rantsInFeed: [Rant] = []
    @Published var notificationsDevRant: [NotificationFeed.Category: [NotificationFeed.MappedNotificationItem]] = [:]
    
    @Published var calculatedNumberOfUnreadNotifications: Int = 0
    
    @Published var molodetzMentionsRaw: [MolodetzMention.CodingData] = []
    
    @Published var writePostContent = ""
    
    var currentFeedSession: String?
    var duplicatesInFeed = 0
    
    var ownUsername: String?
        
    func clear() {
        clearFeed()
        calculatedNumberOfUnreadNotifications = 0
        notificationsDevRant = [:]
        molodetzMentionsRaw = []
        ownUsername = nil
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
    
    func rantInFeed(byId id: Int) -> Rant? {
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
    
    func upvoters(forRant rant: Rant) -> [String] {
        let upvoters = notifications[.upvotes]?.filter { item in
            item.rantId == rant.id
        }.map { $0.userName } ?? []
        return upvoters.uniqued().sorted()
    }
    
    func upvoters(forComment comment: Comment) -> [String] {
        let upvoters = notifications[.upvotes]?.filter { item in
            item.commentId == comment.id
        }.map { $0.userName } ?? []
        return upvoters.uniqued().sorted()
    }
    
    var notifications: [NotificationFeed.Category: [GeneralNotificationItem]] {
        var devRant = notificationsDevRant.mapValues { items in
            items.map(GeneralNotificationItem.from)
        }
        let molodetz = molodetzMentions.map(GeneralNotificationItem.from)
        
        devRant[.mentions]?.append(contentsOf: molodetz)
        devRant[.mentions] = devRant[.mentions]?.sorted { $0.created > $1.created }
        
        devRant[.all]?.append(contentsOf: molodetz)
        devRant[.all] = devRant[.all]?.sorted { $0.created > $1.created }
        
        return devRant
    }
    
    var molodetzMentions: [MolodetzMention] {
        molodetzMentions(from: molodetzMentionsRaw)
    }
    
    func molodetzMentions(from raw: [MolodetzMention.CodingData]) -> [MolodetzMention] {
        let readIds = UserSettings().molodetzReadMentionIds
        let encounteredUsers = EncounteredUsers.shared.users
        
        return raw.map { mention in
            let id = mention.id
            let avatar = encounteredUsers.first(where: { $0.name == mention.from })?.avatarSmall ?? .init(colorHex: "999", imageUrlPath: nil)
            
            return .init(
                id: id,
                rantId: Int(mention.rant_id),
                commentId: mention.comment_id.flatMap(Int.init),
                created: .init(timeIntervalSince1970: TimeInterval(mention.created_time)),
                userAvatar: avatar,
                userName: mention.from,
                isRead: readIds.contains(id),
            )
        }
    }
}
