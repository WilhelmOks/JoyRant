//
//  WritePostViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 18.10.22.
//

import Foundation
import Combine
import SwiftDevRant

#if os(iOS)
import UIKit
#endif

final class WritePostViewModel: NSObject, ObservableObject {
    let kind: WriteKind
    let mentionSuggestions: [String]
    let onSubmitted: () -> ()
    @Published var alertMessage: AlertMessage = .none()
    @Published var isLoading = false
    @Published var tags = ""
    @Published var rantKind: RantKind = .rant
    @Published var selectedImage: PlatformImage? = nil
    var selectedImageData: Data? = nil

    let dismiss = PassthroughSubject<Void, Never>()
    let textCursorChanged = PassthroughSubject<Void, Never>()
    
    init(kind: WriteKind, mentionSuggestions: [String] = [], onSubmitted: @escaping () -> ()) {
        self.kind = kind
        self.mentionSuggestions = mentionSuggestions
        self.onSubmitted = onSubmitted
        
        switch kind {
        case .editRant(rant: let rant):
            self.tags = rant.tags.joined(separator: ", ")
        default:
            break
        }
    }
    
    deinit {
        switch kind {
        case .editComment(comment: _), .editRant(rant: _):
            DispatchQueue.main.async {
                DataStore.shared.writePostContent = ""
            }
        case .postComment(rantId: _), .postRant:
            break
        }
    }
    
    @MainActor func submit() async {
        guard !isLoading else { return }
        
        isLoading = true
        
        do {
            let content = DataStore.shared.writePostContent
            
            switch kind {
            case .postRant:
                let newRantId = try await Networking.shared.postRant(kind: rantKind.rantType, text: content, tags: tags, image: selectedImageData)
                AppState.shared.navigate(from: .feed, to: .rantDetails(rantId: newRantId))
            case .editRant(rant: let rant):
                //We can not change the rant type when editing, so we pass the standard .rant type. The rant type seems to be determined by the tags.
                try await Networking.shared.editRant(rantId: rant.id, text: content, tags: tags, image: selectedImageData)
            case .postComment(rantId: let rantId):
                try await Networking.shared.postComment(rantId: rantId, text: content, image: selectedImageData)
            case .editComment(comment: let comment):
                guard comment.canEdit else { throw SwiftUIRantError.timeWindowForEditMissed }
                try await Networking.shared.editComment(commentId: comment.id, text: content, image: selectedImageData)
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

extension WritePostViewModel {
    enum WriteKind {
        case postRant
        case editRant(rant: Rant)
        case postComment(rantId: Rant.ID)
        case editComment(comment: Comment)
    }
}

extension WritePostViewModel {
    enum RantKind: Int, CaseIterable, Identifiable {
        case rant
        case jokeMeme
        case question
        case devRant
        case random
        
        var id: Int { rawValue }
        
        var rantType: Rant.Kind {
            switch self {
            case .rant:     return .rant
            case .jokeMeme: return .meme
            case .question: return .question
            case .devRant:  return .devRant
            case .random:   return .random
            }
        }
    }
}

#if os(iOS)
extension WritePostViewModel: UITextInputDelegate {
    @available(iOS 18.4, *)
    func conversationContext(_ context: UIConversationContext?, didChange textInput: (any UITextInput)?) {
        
    }
    
    func selectionWillChange(_ textInput: UITextInput?) {
        
    }
    
    func selectionDidChange(_ textInput: UITextInput?) {
        textCursorChanged.send()
    }
    
    func textWillChange(_ textInput: UITextInput?) {
        
    }
    
    func textDidChange(_ textInput: UITextInput?) {
        textCursorChanged.send()
    }
}
#endif
