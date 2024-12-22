//
//  UserProfile.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 25.11.22.
//

import Foundation
import SwiftDevRant

struct UserProfile: Hashable {
    var profile: Profile
    var content: Content
}

extension UserProfile {
    init(profile: Profile) {
        self.profile = profile
        content = .init(
            counts: [
                .rants: profile.content.numbers.rants,
                .upvoted: profile.content.numbers.upvotedRants,
                .comments: profile.content.numbers.comments,
                .favorites: profile.content.numbers.favorites,
                .collabs: profile.content.numbers.collaborations,
            ],
            rants: profile.content.elements.rants,
            upvoted: profile.content.elements.upvotedRants,
            comments: profile.content.elements.comments,
            favorites: profile.content.elements.favorites,
            viewed: profile.content.elements.viewed
        )
    }
    
    mutating func append(profile: Profile) {
        self.profile = profile
        content.counts = [
            .rants: profile.content.numbers.rants,
            .upvoted: profile.content.numbers.upvotedRants,
            .comments: profile.content.numbers.comments,
            .favorites: profile.content.numbers.favorites,
            .collabs: profile.content.numbers.collaborations,
        ]
        content.rants += profile.content.elements.rants
        content.upvoted += profile.content.elements.upvotedRants
        content.comments += profile.content.elements.comments
        content.viewed += profile.content.elements.viewed
        content.favorites += profile.content.elements.favorites
    }
}

extension UserProfile {
    struct Content: Hashable {
        var counts: [ContentType: Int]
        var rants: [Rant]
        var upvoted: [Rant]
        var comments: [Comment]
        var favorites: [Rant]
        var viewed: [Rant] //only for the logged in user
    }
    
    enum ContentType {
        case all
        case rants
        case upvoted
        case comments
        case favorites
        case viewed
        case collabs
        
        var profileContentType: Profile.ContentType? {
            switch self {
            case .all: return .all
            case .rants: return .rants
            case .upvoted: return .upvoted
            case .comments: return .comments
            case .favorites: return .favorite
            case .viewed: return .viewed
            case .collabs: return nil
            }
        }
        
        init(from profileContentType: Profile.ContentType) {
            switch profileContentType {
            case .all: self = .all
            case .rants: self = .rants
            case .upvoted: self = .upvoted
            case .comments: self = .comments
            case .favorite: self = .favorites
            case .viewed: self = .viewed
            }
        }
    }
}
