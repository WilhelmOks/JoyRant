//
//  RantExtensions.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 02.10.22.
//

import Foundation
import SwiftRant

extension Rant {
    var isUserSupporter: Bool {
        isUserDPP == 1
    }
    
    var isFromLoggedInUser: Bool {
        voteState == .unvotable
    }
}
