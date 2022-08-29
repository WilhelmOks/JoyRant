//
//  LoginView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 24.08.22.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    enum FocusedField: Hashable {
        case username
        case password
    }

    @FocusState private var focusedField: FocusedField?

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                TextField("Username", text: $viewModel.username)
                    .focused($focusedField, equals: .username)
                    .onSubmit {
                        focusedField = .password
                    }
                    .textInputAutocapitalization(.never)
                    .textContentType(.username)
                    .autocorrectionDisabled()
                
                SecureField("Password", text: $viewModel.password)
                    .focused($focusedField, equals: .password)
                    .onSubmit {
                        focusedField = nil
                        Task {
                            await viewModel.submit()
                        }
                    }
                    .textContentType(.password)
                
                Button {
                    Task {
                        await viewModel.submit()
                    }
                } label: {
                    Text("Login")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canSubmit)
                
                ProgressView()
                    .opacity(viewModel.isLoading ? 1 : 0)
            }
            .textFieldStyle(.roundedBorder)
            .disabled(viewModel.isLoading)
            .padding()
        }
        .alert($viewModel.alertMessage)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
