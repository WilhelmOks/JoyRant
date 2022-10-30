//
//  WriteCommentViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 18.10.22.
//

import Foundation
import Combine
import SwiftRant

final class WriteCommentViewModel: ObservableObject {
    let kind: Kind
    let onSubmitted: () -> ()
    @Published var alertMessage: AlertMessage = .none()
    @Published var isLoading = false

    let dismiss = PassthroughSubject<Void, Never>()
    
    enum Kind {
        case post(rantId: Rant.ID)
        case edit(comment: Comment)
    }
    
    init(kind: Kind, onSubmitted: @escaping () -> ()) {
        self.kind = kind
        self.onSubmitted = onSubmitted
    }
    
    deinit {
        switch kind {
        case .edit(comment: _):
            DispatchQueue.main.async {
                DataStore.shared.writeCommentContent = ""                
            }
        case .post(rantId: _):
            break
        }
    }
    
    @MainActor func submit() async {
        guard !isLoading else { return }
        
        isLoading = true
        
        do {
            let content = DataStore.shared.writeCommentContent
            
            switch kind {
            case .post(rantId: let rantId):
                try await Networking.shared.postComment(rantId: rantId, content: content, image: nil) //TODO: image
            case .edit(comment: let comment):
                guard comment.canEdit else { throw SwiftUIRantError.timeWindowForEditMissed }
                try await Networking.shared.editComment(commentId: comment.id, content: content, image: nil) //TODO: image
            }
            
            DataStore.shared.writeCommentContent = ""
            dismiss.send()
            onSubmitted()
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
}
