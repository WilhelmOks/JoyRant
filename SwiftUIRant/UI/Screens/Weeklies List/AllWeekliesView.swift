//
//  AllWeekliesView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 09.01.23.
//

import SwiftUI
import SwiftRant

struct AllWeekliesView: View {
    var navigationBar = true
    
    @StateObject var viewModel: AllWeekliesViewModel = .init()

    var body: some View {
        content()
            .if(navigationBar) {
                $0
                .navigationTitle("All Weeklies")
            }
            .navigationDestination(for: AppState.NavigationDestination.self) { destination in
                switch destination {
                case .rantWeek(week: let week):
                    WeekRantsView(viewModel: .init(week: week))
                case .rantDetails(rantId: let rantId, scrollToCommentWithId: let scrollToCommentWithId):
                    RantDetailsView(
                        sourceTab: .weekly,
                        viewModel: .init(
                            rantId: rantId,
                            scrollToCommentWithId: scrollToCommentWithId
                        )
                    )
                case .userProfile(userId: let userId):
                    ProfileView(
                        sourceTab: .weekly,
                        viewModel: .init(
                            userId: userId
                        )
                    )
                }
            }
            .onReceive(broadcastEvent: .didReselectMainTab(.weekly)) { _ in
                if AppState.shared.weeklyNavigationPath.isEmpty {
                    Task {
                        await viewModel.refresh()
                    }
                }
            }
    }
    
    @ViewBuilder func content() -> some View {
        if viewModel.isLoading {
            ProgressView()
        } else {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.weeks, id: \.week) { week in
                        row(week)
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
    
    @ViewBuilder func row(_ week: WeeklyList.Week) -> some View {
        VStack(spacing: 0) {
            NavigationLink(value: AppState.NavigationDestination.rantWeek(week: week)) {
                WeekRowView(week: week)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
            }
            .buttonStyle(.plain)
            
            Divider()
        }
    }
}

struct AllWeekliesView_Previews: PreviewProvider {
    static var previews: some View {
        AllWeekliesView()
    }
}
