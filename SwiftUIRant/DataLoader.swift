//
//  DataLoader.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import Foundation

final class DataLoader {
    static let shared = DataLoader()
    
    private init() {}
    
    @MainActor func loadFeed() async throws {
        DataStore.shared.rantFeed = try await Networking.shared.rants()
    }
}
