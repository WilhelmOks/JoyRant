//
//  RantDetailsView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 17.09.22.
//

import SwiftUI
import SwiftRant

struct RantDetailsView: View {
    @StateObject var viewModel: RantDetailsViewModel
    
    var body: some View {
        content()
            .navigationTitle("Rant")
            .alert($viewModel.alertMessage)
    }
    
    @ViewBuilder private func content() -> some View {
        if let rant = viewModel.rant, !viewModel.isLoading {
            ScrollView {
                LazyVStack {
                    RantView(
                        viewModel: .init(
                            rant: rant
                        )
                    )
                    
                    ForEach(viewModel.comments, id: \.id) { comment in
                        VStack(spacing: 0) {
                            Divider()
                            
                            RantCommentView(viewModel: .init(comment: comment))
                        }
                    }
                }
            }
        } else {
            ProgressView()
        }
    }
}

struct RantDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        RantDetailsView(
            viewModel: .init(
                rantId: 1
            )
        )
    }
}
