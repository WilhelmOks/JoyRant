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
    
    @Published var isFeedLoaded = false
    @Published var rantsInFeed: [RantInFeed] = []
    
    var currentFeedSession: String?
    
    func clear() {
        rantsInFeed = []
        isFeedLoaded = false
    }
    
    func update(rantInFeedId rantId: Int, voteState: RantInFeed.VoteState, score: Int) {
        if let index = rantsInFeed.firstIndex(where: { $0.id == rantId }) {
            rantsInFeed[index].voteState = voteState
            rantsInFeed[index].score = score
        }
    }
}
