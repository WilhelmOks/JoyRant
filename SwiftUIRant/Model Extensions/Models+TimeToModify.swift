//
//  Models+TimeFrames.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 22.10.22.
//

import Foundation
import SwiftRant

//TODO: implement this in SwiftRant

private let timeToModify: TimeInterval = 60 * 5 // 5 minutes
private let timeToModifyWithDpp: TimeInterval = 60 * 30 // 30 minutes

extension Rant {
    var canEdit: Bool {
        let now = Date().timeIntervalSince1970
        let timeOfCreation = TimeInterval(createdTime)
        let timeWindow = isUserDPP == 1 ? timeToModifyWithDpp : timeToModify
        return now - timeOfCreation < timeWindow
    }
}

extension Comment {
    var canEdit: Bool {
        let now = Date().timeIntervalSince1970
        let timeOfCreation = TimeInterval(createdTime)
        let timeWindow = isUserDPP == 1 ? timeToModifyWithDpp : timeToModify
        return now - timeOfCreation < timeWindow
    }
}
