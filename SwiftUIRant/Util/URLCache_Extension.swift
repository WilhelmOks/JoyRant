//
//  URLCache_Extension.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 25.09.22.
//

import Foundation

extension URLCache {
    static let userAvatarCache = URLCache(memoryCapacity: 10*1000*1000, diskCapacity: 1*1000*1000*1000) // 10 MB, 1 GB
    static let postedImageCache = URLCache(memoryCapacity: 100*1000*1000, diskCapacity: 200*1000*1000) // 100 MB, 200 MB
}
