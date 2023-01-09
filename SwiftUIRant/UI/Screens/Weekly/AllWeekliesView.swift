//
//  AllWeekliesView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 09.01.23.
//

import SwiftUI

struct AllWeekliesView: View {
    var navigationBar = true

    var body: some View {
        content()
            .if(navigationBar) {
                $0
                .navigationTitle("All Weeklies")
            }
    }
    
    @ViewBuilder func content() -> some View {
        Text("list of weeklies")
    }
}

struct AllWeekliesView_Previews: PreviewProvider {
    static var previews: some View {
        AllWeekliesView()
    }
}
