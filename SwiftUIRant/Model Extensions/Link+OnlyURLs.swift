//
//  Link+OnlyURLs.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 26.10.25.
//

import Foundation
import SwiftDevRant

extension [Link] {
    func urls() -> [String] {
        filter { $0.kind == .url }.compactMap { $0.url }
    }
    
    func imageURLs() -> [String] {
        urls().filter { URLImage.supports(url: $0) }
    }
}
