//
//  RantCommentViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 25.09.22.
//

import Foundation
import SwiftRant

@MainActor final class RantCommentViewModel: ObservableObject {
    @Published var comment: Comment
    
    @Published var alertMessage: AlertMessage = .none()
    
    @Published var voteController: VoteController!
    
    init(comment: Comment) {
        self.comment = comment
        
        voteController = .init(
            voteState: { [weak self] in
                self?.comment.voteState ?? .unvoted
            },
            score: { [weak self] in
                self?.comment.score ?? 0
            },
            voteAction: { [weak self] voteState in
                let changedComment = try await Networking.shared.vote(commentID: comment.id, voteState: voteState)
                self?.applyChangedData(changedComment: changedComment)
            },
            handleError: { [weak self] error in
                self?.alertMessage = .presentedError(error)
            }
        )
    }
    
    private func applyChangedData(changedComment: Comment) {
        comment = changedComment
    }
    
    func editComment() {
        //TODO: ...
        alertMessage = .presentedError(message: "Edit comment is not implemented yet.")
    }
}
