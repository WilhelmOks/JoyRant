//
//  CommunityProject.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 07.04.23.
//

import Foundation

struct CommunityProject: Hashable {
    let title: String
    let operatingSystem: String
    let type: String
    let addedDate: Int
    let description: String
    let relevantDevRantUrl: String
    let website: String
    let github: String
    let language: String
    let active: Bool
    let owner: String
}

// MARK: Codable

extension CommunityProject {
    struct CodingData: Codable {
        struct Container: Codable {
            let last_updated: Int
            let projects: [CodingData]
        }
        
        let title: String
        let os: String
        let type: String
        let timestamp_added: Int
        let desc: String
        let relevant_dr_url: String
        let website: String
        let github: String
        let language: String
        let active: Bool
        let owner: String
        
        var decoded: CommunityProject {
            .init(
                title: title,
                operatingSystem: os,
                type: type,
                addedDate: timestamp_added,
                description: desc,
                relevantDevRantUrl: relevant_dr_url,
                website: website,
                github: github,
                language: language,
                active: active,
                owner: owner
            )
        }
    }
}

// MARK: Mock

extension CommunityProject {
    private static func randomString(in range: ClosedRange<Int>) -> String {
        let uuid2 = UUID().uuidString + "|" + UUID().uuidString
        return String(uuid2.prefix(Int.random(in: range)))
    }
    
    static func mockedRandom() -> Self {
        return .init(
            title: randomString(in: 3...30),
            operatingSystem: randomString(in: 2...10),
            type: randomString(in: 4...20),
            addedDate: 0,
            description: randomString(in: 3...100),
            relevantDevRantUrl: randomString(in: 20...100),
            website: randomString(in: 20...50),
            github: randomString(in: 20...50),
            language: randomString(in: 2...10),
            active: .random(),
            owner: randomString(in: 3...20)
        )
    }
}
