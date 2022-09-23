//
//  FeedRantViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 11.09.22.
//

import Foundation
import SwiftRant

@MainActor final class FeedRantViewModel: ObservableObject {
    @Published var rant: RantInFeed
    
    @Published var alertMessage: AlertMessage = .none()
    
    @Published var voteController: VoteController!
    
    init(rant: RantInFeed) {
        self.rant = rant
        
        voteController = .init(
            voteState: { [weak self] in
                self?.rant.voteState ?? .unvoted
            },
            score: { [weak self] in
                self?.rant.score ?? 0
            },
            voteAction: { [weak self] voteState in
                let changedRant = try await Networking.shared.vote(rantID: rant.id, voteState: voteState)
                self?.applyChangedData(changedRant: changedRant)
            },
            handleError: { [weak self] error in
                self?.alertMessage = .presentedError(error)
            }
        )
    }
    
    func updateRant() {
        guard let changedRant = DataStore.shared.rantInFeed(byId: rant.id) else { return }
        self.rant = changedRant
    }
    
    private func applyChangedData(changedRant: Rant) {
        let changedVoteState = changedRant.voteState
        rant.voteState = changedVoteState
        rant.score = changedRant.score
        DataStore.shared.update(rantInFeedId: rant.id, voteState: changedVoteState, score: changedRant.score)
    }
}
