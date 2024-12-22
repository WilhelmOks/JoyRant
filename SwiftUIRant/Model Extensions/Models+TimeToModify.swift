//
//  Models+TimeFrames.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 22.10.22.
//

import Foundation
import SwiftDevRant

//TODO: implement this in SwiftDevRant

private let timeToModify: TimeInterval = 60 * 5 // 5 minutes
private let timeToModifyWithDpp: TimeInterval = 60 * 30 // 30 minutes

extension Rant {
    var canEdit: Bool {
        let now = Date().timeIntervalSince1970
        let timeOfCreation = created.timeIntervalSince1970
        let timeWindow = isUserSupporter ? timeToModifyWithDpp : timeToModify
        return now - timeOfCreation < timeWindow
    }
}

extension Comment {
    var canEdit: Bool {
        let now = Date().timeIntervalSince1970
        let timeOfCreation = created.timeIntervalSince1970
        let timeWindow = isUserSupporter ? timeToModifyWithDpp : timeToModify
        return now - timeOfCreation < timeWindow
    }
}
