//
//  User+SwiftData.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 14.06.25.
//

import Foundation
import SwiftData
import SwiftDevRant

extension User {
    struct DataModel: Codable {
        var id: Int
        var name: String
        var score: Int
        var devRantSupporter: Bool
        var colorHex: String
        var imageUrlPath: String?
        
        init(id: Int, name: String, score: Int, devRantSupporter: Bool, colorHex: String, imageUrlPath: String?) {
            self.id = id
            self.name = name
            self.score = score
            self.devRantSupporter = devRantSupporter
            self.colorHex = colorHex
            self.imageUrlPath = imageUrlPath
        }
        
        var domainModel: User {
            User(
                id: id,
                name: name,
                score: score,
                devRantSupporter: devRantSupporter,
                avatarSmall: Avatar(colorHex: colorHex, imageUrlPath: imageUrlPath),
                avatarLarge: nil
            )
        }
    }
    
    var dataModel: DataModel {
        DataModel(
            id: id,
            name: name,
            score: score,
            devRantSupporter: devRantSupporter,
            colorHex: avatarSmall.colorHex,
            imageUrlPath: avatarSmall.imageUrlPath
        )
    }
}
