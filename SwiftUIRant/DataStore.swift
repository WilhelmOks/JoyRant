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
    var duplicatesInFeed = 0
    
    func clear() {
        clearFeed()
    }
    
    func clearFeed() {
        rantsInFeed = []
        isFeedLoaded = false
        currentFeedSession = nil
        duplicatesInFeed = 0
    }
    
    func update(rantInFeedId rantId: Int, voteState: VoteState, score: Int) {
        if let index = rantsInFeed.firstIndex(where: { $0.id == rantId }) {
            rantsInFeed[index].voteState = voteState
            rantsInFeed[index].score = score
            
            //rantsInFeed.append(.mocked())
            //rantsInFeed.removeLast()
            
            //self.objectWillChange.send()
            
            //NotificationCenter.default.post(name: .init(rawValue: "ShouldUpdateFeed"), object: nil)
        }
    }
}
