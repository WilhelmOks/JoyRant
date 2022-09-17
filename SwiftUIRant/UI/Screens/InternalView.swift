//
//  InternalView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import SwiftUI

struct InternalView: View {
    @ObservedObject var appState = AppState.shared
    
    var body: some View {
        NavigationStack(path: $appState.navigationPath) {
            DevRantView()
        }
    }
}

struct InternalView_Previews: PreviewProvider {
    static var previews: some View {
        InternalView()
    }
}
