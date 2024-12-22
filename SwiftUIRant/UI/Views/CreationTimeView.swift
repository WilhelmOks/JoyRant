//
//  CreationTimeView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 01.10.22.
//

import SwiftUI

struct CreationTimeView: View {
    let createdTime: Date
    var isEdited: Bool = false
    var addedPrefix = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 5) {
            let prefix = addedPrefix ? "added " : ""
            let formattedTime = prefix + TimeFormatter.shared.string(fromDate: createdTime)
            
            Text(formattedTime)
                .font(baseSize: 12, weight: .medium)
                .foregroundColor(.secondaryForeground)
            
            if isEdited {
                Text("Edited")
                    .font(baseSize: 12, weight: .medium)
                    .foregroundColor(.secondaryForeground)
            }
        }
    }
}

struct CreationTimeView_Previews: PreviewProvider {
    static var previews: some View {
        CreationTimeView(
            createdTime: Date().addingTimeInterval(-15),
            isEdited: true,
            addedPrefix: false
        )
    }
}
