//
//  ProfileView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 19.11.22.
//

import SwiftUI
import SwiftRant

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    
    var body: some View {
        Text("Hello, World!")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: .init(userId: 0))
    }
}
