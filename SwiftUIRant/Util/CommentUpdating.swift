//
//  CommentUpdating.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 25.11.22.
//

import Foundation
import SwiftRant

extension Array where Element == Comment {
    @discardableResult mutating func updateComment(_ comment: Comment) -> Bool {
        if let index = self.firstIndex(where: { $0.id == comment.id }) {
            self[index] = comment
            return true
        }
        return false
    }
}
