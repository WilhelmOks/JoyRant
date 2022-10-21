//
//  WriteCommentViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 18.10.22.
//

import Foundation
import Combine

final class WriteCommentViewModel: ObservableObject {
    let kind: Kind
    let onSubmitted: () -> ()
    @Published var alertMessage: AlertMessage = .none()
    @Published var isLoading = false

    let dismiss = PassthroughSubject<Void, Never>()
    
    enum Kind {
        case post(rantId: Int)
    }
    
    init(kind: Kind, onSubmitted: @escaping () -> ()) {
        self.kind = kind
        self.onSubmitted = onSubmitted
    }
    
    @MainActor func submit() async {
        guard !isLoading else { return }
        guard case .post(rantId: let rantId) = kind else { return }
        
        isLoading = true
        
        do {
            let content = DataStore.shared.writeCommentContent
            
            try await Networking.shared.postComment(rantId: rantId, content: content, image: nil) //TODO: image
            
            DataStore.shared.writeCommentContent = ""
            dismiss.send()
            onSubmitted()
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }    
}
