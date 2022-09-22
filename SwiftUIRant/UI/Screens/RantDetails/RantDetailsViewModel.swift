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
    @Published var alertMessage: AlertMessage = .none()
    
    @Published var rant: Rant?
    @Published var comments: [Comment] = []
    
    init(rantId: Int) {
        self.rantId = rantId
        
        Task {
            await load()
        }
    }
    
    /*var rantVoteController: VoteController? {
        guard let rant else { return nil }
        
        return VoteController(
            voteState: { rant.voteState },
            score: { rant.score },
            voteAction: { [weak self] voteState in
                let changedRant = try await Networking.shared.vote(rantID: rant.id, voteState: voteState)
                self?.applyChangedData(changedRant: changedRant)
            },
            handleError: { [weak self] error in
                self?.alertMessage = .presentedError(error)
            }
        )
    }*/
    
    @MainActor func load() async {
        isLoading = true
        
        do {
            let response = try await Networking.shared.getRant(id: rantId)
            rant = response.0
            comments = response.1
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
    
    /*private func applyChangedData(changedRant: Rant) {
        let changedVoteState = changedRant.voteState
        rant?.voteState = changedVoteState
        rant?.score = changedRant.score
        guard let rantId = rant?.id else { return }
        DataStore.shared.update(rantInFeedId: rantId, voteState: changedVoteState, score: changedRant.score)
    }*/
}
