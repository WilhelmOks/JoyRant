//
//  AttributedString+devRant.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 04.11.22.
//

import Foundation
import SwiftRant

//TODO: implement in SwiftRant
enum LinkInRantType: String {
    case url = "url"
    case mention = "mention"
}

extension AttributedString {
    static func from(postedContent: String, links: [Rant.Link]?) -> AttributedString {
        var result = AttributedString(stringLiteral: postedContent)
        
        links?.forEach { link in
            if let range = result.range(of: link.title) {
                switch LinkInRantType.init(rawValue: link.type) {
                case .url:
                    result[range].foregroundColor = .primaryForeground
                    result[range].underlineStyle = .single
                    result[range].link = url(link: link.url)
                case .mention:
                    result[range].foregroundColor = .primary
                    result[range].font = .baseSize(16).bold()
                    result[range].swiftUI.font = .baseSize(16).bold()
                    result[range].link = URL(string: link.url)
                case nil:
                    break
                }
            }
        }
        
        return result
    }
    
    private static func url(link: String) -> URL? {
        let rantPrefix = "https://devrant.com/rants/"
        if link.hasPrefix(rantPrefix) {
            // A rant link looks like this:
            // https://devrant.com/rants/<rant-id>/first-few-letters-of-rant-content
            // Convert it into this:
            // joyrant://rant/<rant-id>
            // so that it can be opened in this app.
            let withCustomScheme = link.replacing(rantPrefix, with: "joyrant://rant/")
            let components = withCustomScheme.split(separator: "/", omittingEmptySubsequences: false)
            let joinedUntilRantId = components.prefix(upTo: 4).joined(separator: "/")
            return URL(string: joinedUntilRantId)
        } else {
            return URL(string: link)
        }
    }
}
