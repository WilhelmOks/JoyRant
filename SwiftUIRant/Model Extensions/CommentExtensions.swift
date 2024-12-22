//
//  CommentExtensions.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 02.10.22.
//

import Foundation
import SwiftDevRant

extension Comment {
    var isUserSupporter: Bool {
        author.devRantSupporter
    }
    
    var isFromLoggedInUser: Bool {
        voteState == .unvotable
    }
    
    var withResolvedLinks: String {
        self.text.devRant(resolvingLinks: self.linksInText)
    }
}
