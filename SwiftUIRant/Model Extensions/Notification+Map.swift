//
//  Notification+Map.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 13.10.22.
//

import Foundation
import SwiftRant

//TODO: move this to the SwiftRant package
extension Notifications {
    struct MappedNotificationItem: Identifiable {
        let id = UUID()
        let rantId: Int
        let commentId: Int?
        let userId: Int
        let userAvatar: Rant.UserAvatar //TODO: UserAvatar shouldn't be in a rant because it can also be in a notification or somewhere else, not related to a rant.
        let userName: String
        let notificationType: NotificationType
        let createdTime: Int
        let isRead: Bool
    }
    
    var mappedItems: [MappedNotificationItem] {
        items.map { notification in
            let rantId = notification.rantID
            let commentId = notification.commentID
            let userId = notification.uid
            let userInfo = usernameMap?.array.first(where: { map in map.uidForUsername == String(userId) })
            let userAvatar = userInfo?.avatar ?? .init(backgroundColor: "cccccc", avatarImage: nil)
            let userName = userInfo?.name ?? ""
            
            return MappedNotificationItem(
                rantId: rantId,
                commentId: commentId,
                userId: userId,
                userAvatar: userAvatar,
                userName: userName,
                notificationType: notification.type,
                createdTime: notification.createdTime,
                isRead: notification.read == 1
            )
        }
    }
    
    var unreadByCategory: [Notifications.Categories: Int] {
        [
            .all:       unread.all,
            .upvotes:   unread.upvotes,
            .mentions:  unread.mentions,
            .comments:  unread.comments,
            .subs:      unread.subs,
        ]
    }
}