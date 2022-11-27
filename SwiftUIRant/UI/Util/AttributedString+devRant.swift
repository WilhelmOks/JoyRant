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
            //guard let nsRange = link.calculatedRange else { return } //TODO: calculatedRange is calculated by searching for link.title. this is a problem when there are multiple titles that are shortened and become equal. such as youtube links.
            
            let nsRange: NSRange
            if let start = link.start, let end = link.end {
                nsRange = .init(location: start, length: end - start)
            } else {
                nsRange = (postedContent as NSString).range(of: link.title)
            }
            
            guard let range: Range<AttributedString.Index> = .init(nsRange, in: result) else { return }
            
            switch LinkInRantType.init(rawValue: link.type) {
            case .url:
                result[range].foregroundColor = .primaryForeground
                result[range].underlineStyle = .single
                result[range].link = rantUrl(link: link.url)
            case .mention:
                result[range].foregroundColor = .primary
                result[range].font = .baseSize(16).bold()
                result[range].swiftUI.font = .baseSize(16).bold()
                result[range].link = mentionUrl(userId: link.url)
            case nil:
                break
            }
        }
        
        return result
    }
    
    private static func rantUrl(link: String) -> URL? {
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
    
    private static func mentionUrl(userId: String) -> URL? {
        return URL(string: "joyrant://profile/\(userId)")
    }
}
