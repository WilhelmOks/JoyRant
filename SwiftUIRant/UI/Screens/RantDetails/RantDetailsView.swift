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
                    rantContent(rant)
                    
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
    
    @ViewBuilder private func rantContent(_ rant: Rant) -> some View {
        VStack(spacing: 20) {
            Text("TODO: Rant Details")
            Text(rant.text)
        }
    }
}

struct RantDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        RantDetailsView(viewModel: .init(rantId: 1))
    }
}
