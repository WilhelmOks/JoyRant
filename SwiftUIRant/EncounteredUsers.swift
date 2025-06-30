import Foundation
import SwiftDevRant
import SwiftData

final class EncounteredUsers {
    static let shared = EncounteredUsers()
    
    private init() {}
    
    var users: [User] {
        dataModels.map(\.domainModel)
    }
    
    private var dataModels: [User.DataModel] {
        UserSettings().encounteredUsers.compactMap { decode($0) }
    }
    
    private func decode(_ json: String) -> User.DataModel? {
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(User.DataModel.self, from: data)
    }
    
    private func encode(_ model: User.DataModel) -> String? {
        if let data = try? JSONEncoder().encode(model) {
            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }
    
    func update(user: User) {
        guard user.id != LoginStore.shared.token?.userId else { return }
        
        var modifiedModels = dataModels
        if let foundIndex = dataModels.firstIndex(where: { $0.id == user.id }) {
            modifiedModels.remove(at: foundIndex)
        }
        
        modifiedModels.append(user.dataModel)
        
        UserSettings().encounteredUsers = modifiedModels.compactMap { encode($0) }
    }
    
    func clear() {
        UserSettings().encounteredUsers = []
    }
}
