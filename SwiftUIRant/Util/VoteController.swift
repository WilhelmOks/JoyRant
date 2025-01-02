//
//  VoteController.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 21.09.22.
//

import Foundation
import SwiftDevRant

@MainActor final class VoteController: ObservableObject {
    @Published var loadingVoteState: VoteState?
    let voteState: () -> VoteState
    let score: () -> Int
    let voteAction: (VoteState, DownvoteReason?) async throws -> ()
    let handleError: (Error) -> ()
    
    static let empty: VoteController = .init(
        voteState: { .unvotable },
        score: { 0 },
        voteAction: { _, _ in },
        handleError: { _ in }
    )
    
    init(loadingVoteState: VoteState? = nil, voteState: @escaping () -> VoteState, score: @escaping () -> Int, voteAction: @escaping (VoteState, DownvoteReason?) async throws -> (), handleError: @escaping (Error) -> ()) {
        self.loadingVoteState = loadingVoteState
        self.voteState = voteState
        self.score = score
        self.voteAction = voteAction
        self.handleError = handleError
    }
    
    var showAsUpvoted: Bool {
        if let loadingVoteState {
            return loadingVoteState == .upvoted
        } else {
            return voteState() == .upvoted
        }
    }
    
    var showAsDownvoted: Bool {
        if let loadingVoteState {
            return loadingVoteState == .downvoted
        } else {
            return voteState() == .downvoted
        }
    }
    
    var displayedScore: Int {
        var score = score()
        
        switch (loadingVoteState, voteState()) {
        case (.upvoted, .unvoted):
            score += 1
        case (.upvoted, .downvoted):
            score += 1
        case (.downvoted, .unvoted):
            score -= 1
        case (.downvoted, .upvoted):
            score -= 2
        case (.unvoted, .upvoted):
            score -= 1
        case (.unvoted, .downvoted):
            score += 0
        case (nil, .downvoted):
            score -= 1
        default:
            break
        }
        
        return score
    }
    
    func voteUp() async {
        switch voteState() {
        case .unvoted, .downvoted:
            await performVote(voteState: .upvoted)
        case .upvoted:
            await performVote(voteState: .unvoted)
        default:
            break
        }
    }
    
    func voteDown(reason: DownvoteReason? = nil) async {
        let resolvedReason = reason ?? AppState.shared.automaticDownvoteReason
        
        switch voteState() {
        case .unvoted, .upvoted:
            await performVote(voteState: .downvoted, downvoteReason: resolvedReason)
        case .downvoted:
            await performVote(voteState: .unvoted)
        default:
            break
        }
    }
    
    func voteDownAlt() {
        //TODO: 
    }
    
    func voteByContext() async {
        switch voteState() {
        case .downvoted, .upvoted:
            await performVote(voteState: .unvoted)
        case .unvoted:
            await performVote(voteState: .upvoted)
        default:
            break
        }
    }
    
    private func performVote(voteState: VoteState, downvoteReason: DownvoteReason? = nil) async {
        guard loadingVoteState == nil else { return }
        
        loadingVoteState = voteState
        do {
            try await voteAction(voteState, downvoteReason)
        } catch {
            handleError(error)
        }
        loadingVoteState = nil
    }
}
