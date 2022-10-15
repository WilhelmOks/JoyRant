//
//  NotificationRowView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 11.10.22.
//

import SwiftUI
import SwiftRant

struct NotificationRowView: View {
    let item: Notifications.MappedNotificationItem
    
    var body: some View {
        HStack(spacing: 10) {
            UserAvatarView(avatar: item.userAvatar)
                //.opacity(isRead ? 0.5 : 1.0)
                        
            VStack(alignment: .leading, spacing: 4) {
                Text(item.userName)
                    .font(baseSize: 15, weightDelta: item.isRead ? 1 : 3)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primaryForeground)
                
                Text(message())
                    .font(baseSize: 15, weightDelta: item.isRead ? -1 : 0)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primaryForeground)
            }
            .opacity(item.isRead ? 0.5 : 1.0)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                CreationTimeView(createdTime: item.createdTime, isEdited: false)
                                
                icon()
                    .foregroundColor(.secondaryForeground)
            }
        }
        .background(Color.primaryBackground)
    }
    
    private func message() -> String {
        switch item.notificationType {
        case .rantUpvote:
            return "++'d your rant"
        case .commentUpvote:
            return "++'d your comment"
        case .commentContent:
            return "posted a comment in your rant"
        case .commentDiscuss:
            return "posted a comment"
        case .commentMention:
            return "mentioned you"
        case .rantSub:
            return "posted a rant"
        }
    }
    
    @ViewBuilder private func icon() -> some View {
        switch item.notificationType {
        case .rantUpvote:
            Text("++")
                .font(baseSize: 12, weightDelta: 1)
        case .commentUpvote:
            Text("++")
                .font(baseSize: 12, weightDelta: 1)
        case .commentContent:
            Image(systemName: "bubble.right")
                .font(baseSize: 11)
        case .commentDiscuss:
            Image(systemName: "bubble.right")
                .font(baseSize: 11)
        case .commentMention:
            Text("@")
                .font(baseSize: 13, weightDelta: 1)
        case .rantSub:
            Image(systemName: "bubble.right.fill")
                .font(baseSize: 11)
        }
    }
}

private struct ExampleView: View {
    let notificationTypes: [NotificationType] = [
        .rantUpvote,
        .commentUpvote,
        .commentContent,
        .commentDiscuss,
        .commentMention,
        .rantSub,
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            ForEach(notificationTypes, id: \.rawValue) { notificationType in
                row(notificationType)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                
                Divider()
            }
        }
    }
    
    @ViewBuilder private func row(_ notificationType: NotificationType) -> some View {
        NotificationRowView(
            item: .init(
                rantId: 13,
                commentId: 14,
                userId: 1,
                userAvatar: .init(
                    backgroundColor: "99cc99",
                    avatarImage: "v-37_c-3_b-6_g-m_9-1_1-4_16-3_3-4_8-1_7-1_5-1_12-4_6-102_10-1_2-39_22-2_15-10_11-1_4-1.jpg"
                ),
                userName: "ShorelockHelms",
                notificationType: notificationType,
                createdTime: Int(Date().addingTimeInterval(60 * -5).timeIntervalSince1970),
                isRead: false
            )
        )
    }
}

struct NotificationRowView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleView()
            .previewLayout(.sizeThatFits)
    }
}
