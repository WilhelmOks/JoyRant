//
//  RantUpdating.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 24.11.22.
//

import Foundation
import SwiftDevRant

extension Array where Element == Rant {
    @discardableResult mutating func updateRant(_ rant: Rant) -> Bool {
        if let index = self.firstIndex(where: { $0.id == rant.id }) {
            self[index] = rant //self[index].withData(fromRant: rant)
            return true
        }
        return false
    }
}
