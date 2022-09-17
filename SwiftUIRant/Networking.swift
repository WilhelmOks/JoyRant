//
//  SwiftRantAsync.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 24.08.22.
//

import Foundation
import SwiftRant
import SwiftKeychainWrapper

struct Networking {
    static let shared = Self()
    
    struct SwiftUIRantError: Swift.Error {
        let message: String
    }
    
    private init() {}
    
    func logIn(username: String, password: String) async throws {
        _ = try await SwiftRant.shared.logIn(username: username, password: password).get()
        
        DispatchQueue.main.async {
            AppState.shared.objectWillChange.send()
        }
    }
    
    func logOut() {
        SwiftRant.shared.logOut()
        
        DataStore.shared.clear()
        
        DispatchQueue.main.async {
            AppState.shared.objectWillChange.send()
        }
    }
    
    private func token() throws -> UserCredentials {
        guard let token = SwiftRant.shared.tokenFromKeychain else {
            throw SwiftUIRantError(message: "No token in keychain.")
        }
        return token
    }
    
    func rants() async throws -> RantFeed {
        // "Algo"
        try await SwiftRant.shared.getRantFeed(token: try token(), skip: 0, prevSet: nil).get()
    }
    
    func getRant(id: Int) async throws -> (Rant, [Comment]) {
        try await SwiftRant.shared.getRantFromID(token: try token(), id: id, lastCommentID: nil).get()
    }
    
    func vote(rantID: Int, voteState: RantInFeed.VoteState) async throws -> Rant {
        try await SwiftRant.shared.voteOnRant(try token(), rantID: rantID, vote: voteState.rawValue).get()
        
        //TODO: check why downvoting doesn't decrement the score
    }
}
