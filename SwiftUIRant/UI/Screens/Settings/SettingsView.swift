//
//  SettingsView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 08.10.22.
//

import SwiftUI
#if canImport(HexUIColor)
import HexUIColor
#elseif canImport(HexNSColor)
import HexNSColor
#endif

struct SettingsView: View {
    var navigationBar = true
    
    @State private var alertMessage: AlertMessage = .none()
    //@State private var colorSelection: CGColor// = .init(red: 0, green: 0, blue: 0, alpha: 1)
    
    private let fallbackColor: CGColor = .init(red: 0, green: 0, blue: 0, alpha: 1)
    
    var body: some View {
        Form {
            Group {
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
                
                Section("Accent Color") {
                    let colorSelection = Binding<CGColor>(
                        get: {
                            if let hexString = UserDefaults.standard.string(forKey: "accent_color") {
                                return PlatformColor.fromHexString(hexString)?.cgColor ?? fallbackColor
                            } else {
                                return PlatformColor(Color.accentColor).cgColor
                            }
                        },
                        set: { newValue in
                            let hexString = hexStringFromColor(color: .init(cgColor: newValue))
                            UserDefaults.standard.set(hexString, forKey: "accent_color")
                        }
                    )
                    
                    ColorPicker(selection: colorSelection, supportsOpacity: false) {
                        Label {
                            Text("Custom color")
                        } icon: {
                            Image(systemName: "paintbrush.fill")
                        }
                    }
                    
                    Button {
                        
                    } label: {
                        Label {
                            Text("Reset to default")
                        } icon: {
                            Image(systemName: "paintbrush")
                        }
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
            .foregroundColor(.primaryForeground)
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
