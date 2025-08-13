//
//  IgnoredUsersView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 13.08.25.
//

import SwiftUI

struct IgnoredUsersView: View {
    @State private var ignoredUsers: [String] = UserSettings().ignoredUsers
    @State private var newUsername: String = ""
    
    var body: some View {
        VStack {
            Text("Rants and comments from ignored users are automatically hidden.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top)
            
            List($ignoredUsers, id: \.self, editActions: .delete) { $ignoredUser in
                Text(ignoredUser)
                    .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                        -viewDimensions.width
                    }
            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
            
            VStack {
                TextField("", text: $newUsername, prompt: Text("username"))
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                
                Button {
                    var username = newUsername.trimmingCharacters(in: .whitespacesAndNewlines)
                    username.removeAll { $0 == "@" }
                    ignoredUsers.append(username)
                    newUsername = ""
                } label: {
                    Label {
                        Text("add user to ignore list")
                    } icon: {
                        Image(systemName: "plus")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(newUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle("Ignored Users")
        .onChange(of: ignoredUsers) { newValue in
            UserSettings().ignoredUsers = newValue
        }
    }
}

#Preview {
    NavigationStack {
        IgnoredUsersView()
    }
}
