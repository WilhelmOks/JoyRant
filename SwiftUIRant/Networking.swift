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
    
    struct SwiftRantError: Swift.Error {
        let message: String
    }
    
    private init() {}
    
    func logIn(username: String, password: String) async throws {
        let response = await SwiftRant.shared.logIn(username: username, password: password)
        
        if let errorMessage = response.0 {
            throw SwiftRantError(message: errorMessage)
        } else {
            DispatchQueue.main.async {
                AppState.shared.objectWillChange.send()
            }
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
            throw SwiftRantError(message: "No token in keychain.")
        }
        return token
    }
    
    private func noOutputError() -> SwiftRantError {
        SwiftRantError(message: "No output received.")
    }
    
    func rants() async throws -> RantFeed {
        let result = await SwiftRant.shared.getRantFeed(token: try token(), skip: 0, prevSet: nil) // "Algo"
        
        if let errorMessage = result.0 {
            throw SwiftRantError(message: errorMessage)
        } else {
            guard let output = result.1 else {
                throw noOutputError()
            }
            
            return output
        }
    }
    
    func vote(rantID: Int, voteState: RantInFeed.VoteState) async throws -> Rant {
        let result = await SwiftRant.shared.voteOnRant(try token(), rantID: rantID, vote: voteState.rawValue)
        
        //TODO: check why downvoting doesn't decrement the score
        
        if let errorMessage = result.0 {
            throw SwiftRantError(message: errorMessage)
        } else {
            guard let output = result.1 else {
                throw noOutputError()
            }
            
            return output
        }
    }
}
