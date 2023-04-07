//
//  SwiftUIRantError.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 22.10.22.
//

import Foundation

enum SwiftUIRantError: Error {
    case noAccessTokenInKeychain
    case timeWindowForEditMissed
    case unknownProfileContentType
    case invalidUrl(_ string: String)
    
    var message: String {
        switch self {
        case .noAccessTokenInKeychain:
            return "No access token in keychain."
        case .timeWindowForEditMissed:
            return "Rants and comments can only be edited for 5 minutes (30 minutes for devRant++ subscribers) after they are posted."
        case .unknownProfileContentType:
            return "Unknown Profile Content Type"
        case .invalidUrl(let string):
            return "Invalid URL: \(string)"
        }
    }
}
