//
//  UserProfile.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 25.11.22.
//

import Foundation
import SwiftRant

struct UserProfile: Hashable {
    var username: String
    var score: Int
    var createdTime: Int
    var about: String?
    var location: String?
    var skills: String?
    var github: String?
    var website: String?
    var avatar: Rant.UserAvatar
    var avatarSmall: Rant.UserAvatar
    var isSupporter: Bool
    var content: Content
}

extension UserProfile {
    init(profile: Profile) {
        username = profile.username
        score = profile.score
        createdTime = profile.createdTime
        about = profile.about.emptyToNil
        location = profile.location.emptyToNil
        skills = profile.skills.emptyToNil
        github = profile.github.emptyToNil
        website = profile.website?.emptyToNil
        avatar = profile.avatar
        avatarSmall = profile.avatarSmall
        isSupporter = profile.isUserDPP == 1
        content = .init(
            counts: [
                .rants: profile.content.counts.rants,
                .upvoted: profile.content.counts.upvoted,
                .comments: profile.content.counts.comments,
                .favorites: profile.content.counts.favorites,
                .collabs: profile.content.counts.collabs,
            ],
            rants: profile.content.content.rants,
            upvoted: profile.content.content.upvoted,
            comments: profile.content.content.comments,
            favorites: profile.content.content.favorites ?? [],
            viewed: profile.content.content.viewed ?? []
        )
    }
    
    mutating func append(profile: Profile) {
        username = profile.username
        score = profile.score
        createdTime = profile.createdTime
        about = profile.about.emptyToNil
        location = profile.location.emptyToNil
        skills = profile.skills.emptyToNil
        github = profile.github.emptyToNil
        website = profile.website?.emptyToNil
        avatar = profile.avatar
        avatarSmall = profile.avatarSmall
        isSupporter = profile.isUserDPP == 1
        content.counts = [
            .rants: profile.content.counts.rants,
            .upvoted: profile.content.counts.upvoted,
            .comments: profile.content.counts.comments,
            .favorites: profile.content.counts.favorites,
            .collabs: profile.content.counts.collabs,
        ]
        content.rants += profile.content.content.rants
        content.upvoted += profile.content.content.upvoted
        content.comments += profile.content.content.comments
        content.viewed += profile.content.content.viewed ?? []
        content.favorites += profile.content.content.favorites ?? []
    }
}

extension UserProfile {
    struct Content: Hashable {
        var counts: [ContentType: Int]
        var rants: [RantInFeed]
        var upvoted: [RantInFeed]
        var comments: [Comment]
        var favorites: [RantInFeed]
        var viewed: [RantInFeed] //only for the logged in user
    }
    
    enum ContentType {
        case all
        case rants
        case upvoted
        case comments
        case favorites
        case viewed
        case collabs
        
        var profileContentType: Profile.ProfileContentTypes? {
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
        
        init(from profileContentType: Profile.ProfileContentTypes) {
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
