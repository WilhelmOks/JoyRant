import Foundation
import SwiftDevRant

//TODO: implement with SwiftData

final class EncounteredUsers {
    static let shared = EncounteredUsers()
    
    private init() {}
    
    private var transientMemory: [User] = []
    
    var users: [User] {
        return transientMemory
    }
    
    func update(user: User) {
        if let foundIndex = transientMemory.firstIndex(where: { $0.id == user.id }) {
            transientMemory[foundIndex] = user
        }
    }
}
