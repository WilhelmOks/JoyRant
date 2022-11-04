//
//  AttributedString+devRant.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 04.11.22.
//

import Foundation
import SwiftRant

extension AttributedString {
    static func from(postedContent: String, links: [Rant.Link]?) -> AttributedString {
        var result = AttributedString(stringLiteral: postedContent)
        
        //TODO: handle devrant links
        
        links?.forEach { link in
            if let range = result.range(of: link.title) {
                //TODO: make an enum for link.type
                if link.type == "url" {
                    result[range].foregroundColor = .primaryForeground
                    result[range].underlineStyle = .single
                    result[range].link = url(link: link.url)
                } else if link.type == "mention" {
                    result[range].foregroundColor = .primary
                    result[range].font = .baseSize(16).bold()
                    result[range].swiftUI.font = .baseSize(16).bold()
                    result[range].link = URL(string: link.url)
                }
            }
        }
        
        return result
    }
    
    private static func url(link: String) -> URL? {
        if link.hasPrefix("https://devrant.com/rants/") {
            // a rant link looks like this:
            // https://devrant.com/rants/<rant-id>/first-few-letters-of-rant-content
            // convert it into this:
            // joyrant://rant/<rant-id>
            // so that it can be opened in this app.
            let withCustomScheme = link.replacing("https://devrant.com/rants/", with: "joyrant://rant/")
            let components = withCustomScheme.split(separator: "/", omittingEmptySubsequences: false)
            let joinedUntilRantId = components.prefix(upTo: 4).joined(separator: "/")
            return URL(string: joinedUntilRantId)
        } else {
            return URL(string: link)
        }
    }
}
