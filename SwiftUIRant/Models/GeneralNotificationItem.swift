//
//  GeneralNotificationItem.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 09.11.25.
//

import Foundation
import SwiftDevRant

struct GeneralNotificationItem: Hashable, Sendable {
    enum Source {
        case devRant
        case molodetz
    }
    
    let source: Source
    
    let id: String
    let rantId: Rant.ID
    let commentId: Comment.ID?
    let userAvatar: User.Avatar
    let userName: String
    let notificationKind: SwiftDevRant.Notification.Kind
    let created: Date
    let isRead: Bool
    
    static func from(_ devRantModel: NotificationFeed.MappedNotificationItem) -> Self {
        .init(
            source: .devRant,
            id: devRantModel.id,
            rantId: devRantModel.rantId,
            commentId: devRantModel.commentId,
            userAvatar: devRantModel.userAvatar,
            userName: devRantModel.userName,
            notificationKind: devRantModel.notificationKind,
            created: devRantModel.created,
            isRead: devRantModel.isRead,
        )
    }
    
    static func from(_ molodetzModel: MolodetzMention) -> Self {
        .init(
            source: .molodetz,
            id: molodetzModel.id,
            rantId: molodetzModel.rantId,
            commentId: molodetzModel.commentId,
            userAvatar: molodetzModel.userAvatar,
            userName: molodetzModel.userName,
            notificationKind: .mentionInComment, //TODO: implement "mention in rant"
            created: molodetzModel.created,
            isRead: molodetzModel.isRead,
        )
    }
}
