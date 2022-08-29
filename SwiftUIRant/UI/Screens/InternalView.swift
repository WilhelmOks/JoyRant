//
//  InternalView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import SwiftUI

struct InternalView: View {
    var body: some View {
        Text("Logged in")
        
        Button {
            DispatchQueue.main.async {
                Networking.shared.logOut()
            }
        } label: {
            Text("Log out")
        }
    }
}

struct InternalView_Previews: PreviewProvider {
    static var previews: some View {
        InternalView()
    }
}
