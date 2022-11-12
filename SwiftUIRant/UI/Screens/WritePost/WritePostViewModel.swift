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
                try await Networking.shared.postRant(type: rantKind.rantType, content: content, tags: tags, image: selectedImageData)
                //TODO: navigate to new rant
            case .editRant(rant: let rant):
                //TODO: pass the rant type from the original rant
                try await Networking.shared.editRant(rantId: rant.id, type: rantKind.rantType, content: content, tags: tags, image: nil)
            case .postComment(rantId: let rantId):
                try await Networking.shared.postComment(rantId: rantId, content: content, image: selectedImageData)
            case .editComment(comment: let comment):
                guard comment.canEdit else { throw SwiftUIRantError.timeWindowForEditMissed }
                try await Networking.shared.editComment(commentId: comment.id, content: content, image: nil)
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
        
        var rantType: Rant.RantType {
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
