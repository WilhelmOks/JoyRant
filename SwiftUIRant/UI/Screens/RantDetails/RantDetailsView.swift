//
//  RantDetailsView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 17.09.22.
//

import SwiftUI

struct RantDetailsView: View {
    @StateObject var viewModel: RantDetailsViewModel
    
    var body: some View {
        content()
            .alert($viewModel.alertMessage)
    }
    
    @ViewBuilder private func content() -> some View {
        if let rant = viewModel.rant, !viewModel.isLoading {
            VStack {
                Text("TODO: Rant Details")
                
                Text(rant.text)
            }
            .padding()
        } else {
            ProgressView()
        }
    }
}

struct RantDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        RantDetailsView(viewModel: .init(rantId: 1))
    }
}
