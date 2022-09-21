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
            .alert($viewModel.alertMessage)
    }
    
    @ViewBuilder private func content() -> some View {
        if let rant = viewModel.rant, !viewModel.isLoading {
            ScrollView {
                LazyVStack {
                    RantView(rant: rant)
                    
                    ForEach(viewModel.comments, id: \.id) { comment in
                        VStack(spacing: 0) {
                            Divider()
                            
                            RantCommentView(comment: comment)
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
        RantDetailsView(viewModel: .init(rantId: 1))
    }
}
