//
//  WeekRantsView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 04.02.23.
//

import SwiftUI

struct WeekRantsView: View {
    @StateObject var viewModel: WeekRantsViewModel
    
    var body: some View {
        content()
            .navigationTitle(Text("Week \(viewModel.week.week)"))
            .alert($viewModel.alertMessage)
            .onReceive { event in
                switch event {
                case .shouldUpdateRantInLists(let rant): return rant
                default: return nil
                }
            } perform: { rant in
                viewModel.rants.updateRant(rant)
            }
    }
    
    @ViewBuilder private func content() -> some View {
        if viewModel.isLoaded {
            VStack(spacing: 0) {
                weekInfo()
                
                Divider()
                
                ScrollView {
                    //TODO: weekly panel
                    
                    RantList(
                        sourceTab: .weekly,
                        rants: viewModel.rants,
                        isLoadingMore: viewModel.isLoadingMore,
                        loadMore: {
                            Task {
                                await viewModel.loadMore()
                            }
                        }
                    )
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
        } else {
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : 0)
        }
    }
    
    @ViewBuilder private func weekInfo() -> some View {
        VStack(spacing: 4) {
            Text(viewModel.week.prompt)
                .font(baseSize: 15, weightDelta: 1)
                .multilineTextAlignment(.leading)
                .fillHorizontally(.leading)
                .foregroundColor(.primaryForeground)
            
            Text(AbsoluteDateFormatter.shared.string(fromDevRantUS: viewModel.week.date))
                .font(baseSize: 13, weightDelta: 1)
                .multilineTextAlignment(.leading)
                .fillHorizontally(.leading)
                .foregroundColor(.secondaryForeground)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
    }
}

struct WeekRantsView_Previews: PreviewProvider {
    static var previews: some View {
        WeekRantsView(
            viewModel: .init(
                week: .init(
                    week: 123,
                    prompt: "Reasons to dislike JS?",
                    date: "12/31/22",
                    rantCount: 17
                )
            )
        )
    }
}
