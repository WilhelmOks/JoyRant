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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    toolbarReloadButton()
                }
            }
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
                    .id(rant.uuid)
                    
                    ForEach(viewModel.comments, id: \.id) { comment in
                        VStack(spacing: 0) {
                            Divider()
                            
                            RantCommentView(
                                viewModel: .init(
                                    comment: comment
                                )
                            )
                            //.id(comment.uuid) //TODO: make uuid public
                            .id("\(rant.uuid.uuidString)_ \(comment.id)")
                        }
                    }
                }
                .padding(.bottom, 10)
            }
        } else {
            ProgressView()
        }
    }
    
    @ViewBuilder private func toolbarReloadButton() -> some View {
        if viewModel.isReloading {
            ProgressView()
        } else {
            Button {
                Task {
                    await viewModel.reload()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .disabled(viewModel.isLoading)
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
