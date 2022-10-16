//
//  SettingsView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 08.10.22.
//

import SwiftUI

struct SettingsView: View {
    var navigationBar = true
    
    @State private var alertMessage: AlertMessage = .none()
    
    var body: some View {
        Form {
            Button {
                DispatchQueue.main.async {
                    AppState.shared.clearImageCache()
                    alertMessage = .presentedMessage("Image cache cleared.")
                }
            } label: {
                Label {
                    Text("Clear image cache")
                } icon: {
                    Image(systemName: "photo.on.rectangle.angled")
                }
            }
            
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
        .alert($alertMessage)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
