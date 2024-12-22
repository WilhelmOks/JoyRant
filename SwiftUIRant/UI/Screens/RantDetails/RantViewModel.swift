//
//  RantViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 22.09.22.
//

import Foundation
import SwiftDevRant

@MainActor final class RantViewModel: ObservableObject {
    @Published var rant: Rant
    
    @Published var isLoading = false
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
            voteAction: { [weak self] voteState in
                let changedRant = try await Networking.shared.vote(rantId: rant.id, voteState: voteState)
                self?.applyChangedData(changedRant: changedRant)
            },
            handleError: { [weak self] error in
                self?.alertMessage = .presentedError(error)
            }
        )
    }
    
    private func applyChangedData(changedRant: Rant) {
        rant = changedRant
        BroadcastEvent.shouldUpdateRantInLists(rant).send()
    }
    
    func favorite() async {
        guard !isLoading else { return }
        
        isLoading = true
        
        do {
            try await Networking.shared.favorite(rantId: rant.id, favorite: true)
            rant.isFavorite = true
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
    
    func unfavorite() async {
        guard !isLoading else { return }
        
        isLoading = true
        
        do {
            try await Networking.shared.favorite(rantId: rant.id, favorite: false)
            rant.isFavorite = false
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
}
