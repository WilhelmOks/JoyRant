//
//  DataStore.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import Foundation
import SwiftRant

final class DataStore: ObservableObject {
    static let shared = DataStore()
    
    private init() {}
    
    @Published var rantFeed: RantFeed?
    
    func clear() {
        rantFeed = nil
    }
    
    func update(rantInFeedId rantId: Int, voteState: RantInFeed.VoteState, score: Int) {
        if let index = rantFeed?.rants.firstIndex(where: { $0.id == rantId }) {
            rantFeed?.rants[index].voteState = voteState
            rantFeed?.rants[index].score = score
        }
    }
}
