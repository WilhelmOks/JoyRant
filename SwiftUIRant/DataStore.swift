//
//  DataStore.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import Foundation
import SwiftRant

final class DataStore: ObservableObject {
    static let shared = DataStore()
    
    private init() {}
    
    @Published var rantFeed: RantFeed?
    
    func clear() {
        rantFeed = nil
    }
}
