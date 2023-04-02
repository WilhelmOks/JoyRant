//
//  CommentExtensions.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 02.10.22.
//

import Foundation
import SwiftRant

extension Comment {
    var isUserSupporter: Bool {
        isUserDPP == 1
    }
    
    var isFromLoggedInUser: Bool {
        voteState == .unvotable
    }
    
    var withResolvedLinks: String {
        self.body.devRant(resolvingLinks: self.links)
    }
}
