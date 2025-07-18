//
//  Rant+SpamInfo.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 18.07.25.
//

import Foundation
import SwiftDevRant
import SpamDetector

extension Rant {
    struct SpamInfo {
        let scanResult: SpamDetector.Result
    }
    
    static var spamInfoCache: [Int: SpamInfo] = [:]
    
    var spamInfo: SpamInfo? {
        get {
            Self.spamInfoCache[self.id]
        }
        set {
            Self.spamInfoCache[self.id] = newValue
        }
    }
    
    var showAsSpam: Bool {
        guard UserSettings().reduceVisibilityOfSpam else { return false }
        return spamInfo?.scanResult.isSpam ?? false
    }
}
