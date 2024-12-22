//
//  RantDetailsViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 17.09.22.
//

import Foundation
import Combine
import Algorithms
import SwiftDevRant

final class RantDetailsViewModel: ObservableObject {
    let rantId: Int
    
    @Published var isLoading = false
    @Published var isReloading = false
    @Published var alertMessage: AlertMessage = .none()
    
    @Published var rant: Rant?
    @Published var comments: [Comment] = []
    
    let dismiss = PassthroughSubject<Void, Never>()
    
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
            
            Task {
                try? await DataLoader.shared.loadNumbersOfUnreadNotifications()
            }
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
            scrollToCommentWithId = comments.last { $0.author.id == scrollToLastCommentWithUserId }?.id
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
    
    @MainActor func deleteRant(rant: Rant) async {
        isLoading = true
        
        do {
            try await Networking.shared.deleteRant(rantId: rant.id)
            DataStore.shared.remove(rantInFeed: rant)
            dismiss.send()
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
    
    @MainActor func deleteComment(comment: Comment) async {
        isLoading = true
        
        do {
            try await Networking.shared.deleteComment(commentId: comment.id)
            await reload()
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
    
    func commentMentionSuggestions() -> [String] {
        let filtered = comments.filter { comment in
            !comment.isFromLoggedInUser // && rant?.userID != comment.userID
        }
        let rantAuthorMention = "@" + (rant?.author.name ?? "")
        let mentiones = [rantAuthorMention] + filtered.map { "@" + $0.author.name }
        return Array(mentiones.uniqued())
    }
}
