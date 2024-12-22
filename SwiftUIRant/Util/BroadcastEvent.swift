//
//  BroadcastEvent.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 23.09.22.
//

import Foundation
import Combine
import SwiftUI
import SwiftDevRant

enum BroadcastEvent: Equatable {
    case shouldUpdateRantInFeed(rantId: Int)
    case shouldRefreshNotifications
    case shouldScrollFeedToTop
    case shouldScrollNotificationsToTop
    case shouldScrollToComment
    case didSwitchToMainTab(_ tab: InternalView.Tab)
    case didReselectMainTab(_ tab: InternalView.Tab)
    case shouldUpdateRantInLists(_ rant: Rant)
    case shouldUpdateCommentInLists(_ comment: Comment)
}

extension BroadcastEvent {
    static let event = PassthroughSubject<Self, Never>()
    
    func send() {
        Self.event.send(self)
    }
    
    func publisher() -> AnyPublisher<BroadcastEvent, Never> {
        Self.event.filter { $0 == self }.eraseToAnyPublisher()
    }
    
    static func publisher(_ isIncluded: @escaping (Self) -> Bool) -> AnyPublisher<BroadcastEvent, Never> {
        Self.event.filter(isIncluded).eraseToAnyPublisher()
    }
    
    static func publisherMatching<T>(_ match: @escaping (Self) -> T?) -> AnyPublisher<T, Never> {
        Self.event.compactMap(match).eraseToAnyPublisher()
    }
}

extension View {
    func onReceive(broadcastEvent: BroadcastEvent, perform action: @escaping (BroadcastEvent) -> Void) -> some View {
        self.onReceive(broadcastEvent.publisher(), perform: action)
    }
    
    func onReceive<T>(broadcastEvent: @escaping (BroadcastEvent) -> T?, perform action: @escaping (T) -> Void) -> some View {
        self.onReceive(BroadcastEvent.publisherMatching(broadcastEvent), perform: action)
    }
}
