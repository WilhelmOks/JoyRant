//
//  FeedRantViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 11.09.22.
//

import Foundation
import SwiftDevRant

@MainActor final class FeedRantViewModel: ObservableObject {
    @Published var rant: Rant
    
    @Published var alertMessage: AlertMessage = .none()
    
    @Published var voteController: VoteController!
    
    init(rant: Rant) {
        self.rant = rant
        
        voteController = .init(
            voteState: { [weak self] in
                self?.rant.voteState ?? .unvoted
            },
            score: { [weak self] in
                self?.rant.score ?? 0
            },
            voteAction: { [weak self] voteState, downvoteReason in
                let changedRant = try await Networking.shared.vote(rantId: rant.id, voteState: voteState, downvoteReason: downvoteReason ?? .notForMe)
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
        rant = changedRant
        DataStore.shared.update(rantInFeed: changedRant)
    }
}
