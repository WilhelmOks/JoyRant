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
        (try? AppState.shared.swiftDataModelContext?.fetch(FetchDescriptor<User.DataModel>())) ?? []
    }
    
    func update(user: User) {
        guard user.id != LoginStore.shared.token?.userId else { return }
        guard let context = AppState.shared.swiftDataModelContext else { return }
        
        if let found = dataModels.first(where: { $0.id == user.id }) {
            context.delete(found)
        }
        
        context.insert(user.dataModel)
        
        try? context.save()
    }
    
    func clear() {
        guard let context = AppState.shared.swiftDataModelContext else { return }
        
        try? context.delete(model: User.DataModel.self)
        
        try? context.save()
    }
}
