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
                    result[range].link = URL(string: link.url)
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
}
