//
//  RantSummaryViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 11.09.22.
//

import Foundation
import SwiftRant

final class RantSummaryViewModel: ObservableObject {
    @Published var rant: RantInFeed
    
    @Published var loadingVoteState: RantInFeed.VoteState?
    @Published var alertMessage: AlertMessage = .none()
    
    init(rant: RantInFeed) {
        self.rant = rant
    }
    
    var showAsUpvoted: Bool {
        if let loadingVoteState {
            return loadingVoteState == .upvoted
        } else {
            return rant.voteState == .upvoted
        }
    }
    
    var showAsDownvoted: Bool {
        if let loadingVoteState {
            return loadingVoteState == .downvoted
        } else {
            return rant.voteState == .downvoted
        }
    }
    
    var voteScore: Int {
        var score = rant.score
        
        /*
        switch (loadingVoteState, rant.voteState) {
        case (.upvoted, .unvoted):
            score += 1
        case (.upvoted, .downvoted):
            score += 2
        case (.downvoted, .unvoted):
            score -= 1
        case (.downvoted, .upvoted):
            score -= 2
        case (.unvoted, .upvoted):
            score -= 1
        case (.unvoted, .downvoted):
            score += 1
        default:
            break
        }
        */
        
        switch (loadingVoteState, rant.voteState) {
        case (.upvoted, .unvoted):
            score += 1
        case (.upvoted, .downvoted):
            score += 1
        case (.downvoted, .unvoted):
            score -= 0
        case (.downvoted, .upvoted):
            score -= 1
        case (.unvoted, .upvoted):
            score -= 1
        case (.unvoted, .downvoted):
            score += 0
        default:
            break
        }
        
        return score
    }
    
    @MainActor func voteUp() async {
        switch rant.voteState {
        case .unvoted, .downvoted:
            await performVote(voteState: .upvoted)
        case .upvoted:
            await performVote(voteState: .unvoted)
        default:
            break
        }
    }
    
    @MainActor func voteDown() async {
        switch rant.voteState {
        case .unvoted, .upvoted:
            await performVote(voteState: .downvoted)
        case .downvoted:
            await performVote(voteState: .unvoted)
        default:
            break
        }
    }
    
    @MainActor private func performVote(voteState: RantInFeed.VoteState) async {
        loadingVoteState = voteState
        do {
            let changedRant = try await Networking.shared.vote(rantID: rant.id, voteState: voteState)
            applyChangedData(changedRant: changedRant)
        } catch {
            alertMessage = .presentedError(error)
        }
        loadingVoteState = nil
    }
    
    private func applyChangedData(changedRant: Rant) {
        let changedVoteState: RantInFeed.VoteState = .init(rawValue: changedRant.voteState) ?? .unvoted
        rant.voteState = changedVoteState
        rant.score = changedRant.score
        DataStore.shared.update(rantInFeedId: rant.id, voteState: changedVoteState, score: changedRant.score)
    }
}
