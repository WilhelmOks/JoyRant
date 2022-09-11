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
        
        return score
    }
    
    @MainActor func voteUp() async {
        switch rant.voteState {
        case .unvoted, .downvoted:
            loadingVoteState = .upvoted
            do {
                let changedRant = try await Networking.shared.vote(rantID: rant.id, voteState: .upvoted)
                rant.voteState = .init(rawValue: changedRant.voteState) ?? .unvoted
                rant.score = changedRant.score
            } catch {
                alertMessage = .presentedError(error)
            }
        case .upvoted:
            loadingVoteState = .unvoted
            do {
                let changedRant = try await Networking.shared.vote(rantID: rant.id, voteState: .unvoted)
                rant.voteState = .init(rawValue: changedRant.voteState) ?? .unvoted
                rant.score = changedRant.score
            } catch {
                alertMessage = .presentedError(error)
            }
        default:
            break
        }
        
        loadingVoteState = nil
    }
    
    @MainActor func voteDown() async {
        switch rant.voteState {
        case .unvoted, .upvoted:
            loadingVoteState = .downvoted
            do {
                let changedRant = try await Networking.shared.vote(rantID: rant.id, voteState: .downvoted)
                rant.voteState = .init(rawValue: changedRant.voteState) ?? .unvoted
                rant.score = changedRant.score
            } catch {
                alertMessage = .presentedError(error)
            }
        case .downvoted:
            loadingVoteState = .unvoted
            do {
                let changedRant = try await Networking.shared.vote(rantID: rant.id, voteState: .unvoted)
                rant.voteState = .init(rawValue: changedRant.voteState) ?? .unvoted
                rant.score = changedRant.score
            } catch {
                alertMessage = .presentedError(error)
            }
        default:
            break
        }
        
        loadingVoteState = nil
    }
}
