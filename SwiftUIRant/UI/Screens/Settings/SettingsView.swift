//
//  SettingsView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 08.10.22.
//

import SwiftUI

struct SettingsView: View {
    var navigationBar = true
    
    var body: some View {
        Form {
            Button {
                DispatchQueue.main.async {
                    Networking.shared.logOut()
                }
            } label: {
                Label {
                    Text("Log out")
                } icon: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
            }

        }
        .if(navigationBar) {
            $0
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
