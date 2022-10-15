//
//  RantDetailsViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 17.09.22.
//

import Foundation
import SwiftRant

final class RantDetailsViewModel: ObservableObject {
    let rantId: Int
    
    @Published var isLoading = false
    @Published var isReloading = false
    @Published var alertMessage: AlertMessage = .none()
    
    @Published var rant: Rant?
    @Published var comments: [Comment] = []
    
    var scrollToCommentWithId: Int?
    private let scrollToLastCommentWithUserId: Int?
    
    init(rantId: Int, scrollToCommentWithId: Int? = nil, scrollToLastCommentWithUserId: Int? = nil) {
        self.rantId = rantId
        self.scrollToCommentWithId = scrollToCommentWithId
        self.scrollToLastCommentWithUserId = scrollToLastCommentWithUserId
        
        Task {
            await load()
        }
    }
    
    @MainActor private func performLoad() async {
        do {
            let response = try await Networking.shared.getRant(id: rantId)
            rant = response.0
            comments = response.1
        } catch {
            alertMessage = .presentedError(error)
        }
    }
    
    @MainActor func load() async {
        isLoading = true
        await performLoad()
        BroadcastEvent.shouldRefreshNotifications.send()
        isLoading = false
        
        if let scrollToLastCommentWithUserId {
            scrollToCommentWithId = comments.last { $0.userID == scrollToLastCommentWithUserId }?.id
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            BroadcastEvent.shouldScrollToComment.send()
        }
    }
    
    @MainActor func reload() async {
        isReloading = true
        await performLoad()
        isReloading = false
    }
}
