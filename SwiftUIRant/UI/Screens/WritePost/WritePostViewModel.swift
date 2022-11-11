//
//  WritePostViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 18.10.22.
//

import Foundation
import Combine
import SwiftRant

final class WritePostViewModel: ObservableObject {
    let kind: Kind
    let mentionSuggestions: [String]
    let onSubmitted: () -> ()
    @Published var alertMessage: AlertMessage = .none()
    @Published var isLoading = false
    @Published var selectedImage: PlatformImage? = nil
    var selectedImageData: Data? = nil

    let dismiss = PassthroughSubject<Void, Never>()
    
    enum Kind {
        case post(rantId: Rant.ID)
        case edit(comment: Comment)
    }
    
    init(kind: Kind, mentionSuggestions: [String] = [], onSubmitted: @escaping () -> ()) {
        self.kind = kind
        self.mentionSuggestions = mentionSuggestions
        self.onSubmitted = onSubmitted
    }
    
    deinit {
        switch kind {
        case .edit(comment: _):
            DispatchQueue.main.async {
                DataStore.shared.writePostContent = ""
            }
        case .post(rantId: _):
            break
        }
    }
    
    @MainActor func submit() async {
        guard !isLoading else { return }
        
        isLoading = true
        
        do {
            let content = DataStore.shared.writePostContent
            
            switch kind {
            case .post(rantId: let rantId):
                try await Networking.shared.postComment(rantId: rantId, content: content, image: selectedImageData)
            case .edit(comment: let comment):
                guard comment.canEdit else { throw SwiftUIRantError.timeWindowForEditMissed }
                try await Networking.shared.editComment(commentId: comment.id, content: content, image: selectedImageData)
            }
            
            DataStore.shared.writePostContent = ""
            dismiss.send()
            onSubmitted()
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
}
