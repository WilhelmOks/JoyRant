//
//  MappedNotificationItem+Id.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 17.08.25.
//

import SwiftDevRant

//TODO: move to SwiftDevRant
extension NotificationFeed.MappedNotificationItem {
    var id: String {
        [
            String(rantId),
            commentId.flatMap{ String($0) } ?? "-",
            String(Int(created.timeIntervalSince1970)),
            String(isRead),
            notificationKind.rawValue,
            String(userId)
        ].joined(separator: "|")
    }
}
