//
//  MolodetzMention.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 09.11.25.
//

import Foundation
import SwiftDevRant

struct MolodetzMention: Hashable {
    let id: String
    let rantId: Int
    let commentId: Int?
    let created: Date
    let userAvatar: User.Avatar
    let userName: String
    let isRead: Bool
}

extension MolodetzMention {
    struct CodingData: Decodable {
        let from: String
        let to: String
        let rant_id: UInt64
        let comment_id: UInt64?
        let created_time: UInt64
    }
}

extension MolodetzMention.CodingData {
    var id: String {
        [
            "molodetz-mention",
            String(rant_id),
            comment_id.flatMap{ String($0) } ?? "-",
            String(created_time),
            String(from),
        ].joined(separator: "|")
    }
}
