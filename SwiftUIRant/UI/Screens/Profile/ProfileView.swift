//
//  ProfileView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 19.11.22.
//

import SwiftUI
import SwiftRant
import CachedAsyncImage

struct ProfileView: View {
    let sourceTab: InternalView.Tab
    
    @StateObject var viewModel: ProfileViewModel
    
    @Environment(\.openURL) private var openURL
    
    private let emptyBgColor = Color.gray.opacity(0.3)
        
    var profile: UserProfile {
        viewModel.profile ?? viewModel.placeholderProfile
    }
    
    var body: some View {
        content()
            .background(Color.primaryBackground)
            .alert($viewModel.alertMessage)
            .navigationTitle(viewModel.title)
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(viewModel.title).fontWeight(.semibold)
                }
            }
            #endif
            .onReceive { event in
                switch event {
                case .shouldUpdateRantInLists(let rant): return rant
                default: return nil
                }
            } perform: { (rant: Rant) in
                viewModel.profile?.content.rants.updateRant(rant)
            }
    }
    
    @ViewBuilder private func content() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                header()
                    .frame(height: 220)
                    .overlay(alignment: .bottomLeading) {
                        score()
                            .padding(10)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        joinedOnDate()
                            .padding(10)
                    }
                
                infoArea()
                    .fillHorizontally(.leading)
                    .padding(.horizontal, 10)
                
                if !viewModel.categoryTabs.isEmpty {
                    categoryPicker()
                    
                    switch viewModel.categoryTab {
                    case .rants:
                        RantList(
                            sourceTab: sourceTab,
                            rants: profile.content.rants,
                            isLoadingMore: false,
                            loadMore: nil
                        )
                    default:
                        EmptyView()
                    }
                }
            }
            .if(!viewModel.isLoaded) {
                $0.redacted(reason: .placeholder)
            }
            .disabled(!viewModel.isLoaded)
        }
    }
    
    @ViewBuilder private func infoArea() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let about = profile.about {
                infoRow {
                    infoRowIcon(systemName: "person")
                } content: {
                    infoRowText(text: about)
                }
            }

            if let skills = profile.skills {
                infoRow {
                    infoRowIcon(systemName: "curlybraces")
                } content: {
                    infoRowText(text: skills)
                }
            }
            
            if let location = profile.location {
                infoRow {
                    infoRowIcon(systemName: "mappin.and.ellipse")
                } content: {
                    infoRowText(text: location)
                }
            }
            
            if let website = profile.website {
                infoRow {
                    infoRowIcon(systemName: "globe")
                } content: {
                    infoRowText(text: website)
                } action: {
                    if let url = URL(string: website) {
                        openURL(url)
                    }
                }
            }
            
            if let github = profile.github {
                infoRow {
                    infoRowIcon(name: "github")
                } content: {
                    infoRowText(text: github)
                } action: {
                    if let url = URL(string: "https://github.com/\(github)") {
                        openURL(url)
                    }
                }
            }
        }
    }
    
    @ViewBuilder private func infoRow<Icon: View, Content: View>(@ViewBuilder icon: () -> Icon, @ViewBuilder content: () -> Content, action: (() -> ())? = nil) -> some View {
        if let action {
            Button {
                action()
            } label: {
                infoRowLabel {
                    icon()
                } content: {
                    content()
                }
                .background(Color.primaryBackground)
            }
            .buttonStyle(.plain)
        } else {
            infoRowLabel {
                icon()
            } content: {
                content()
            }
        }
    }
    
    @ViewBuilder private func infoRowLabel<Icon: View, Content: View>(@ViewBuilder icon: () -> Icon, @ViewBuilder content: () -> Content) -> some View {
        HStack(alignment: .center, spacing: 10) {
            icon()
                .frame(width: 18, height: 18)
                .foregroundColor(.primaryForeground)
                .alignmentGuide(VerticalAlignment.center) { dim in
                    dim[VerticalAlignment.center] + 5
                }
            
            content()
                .foregroundColor(.primaryForeground)
                .alignmentGuide(VerticalAlignment.center) { dim in
                    dim[.firstTextBaseline]
                }
        }
    }
    
    @ViewBuilder private func infoRowIcon(systemName: String) -> some View {
        Image(systemName: systemName)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
    
    @ViewBuilder private func infoRowIcon(name: String) -> some View {
        Image(name)
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
    
    @ViewBuilder private func infoRowText(text: String) -> some View {
        Text(text)
            .font(baseSize: 16)
            .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder private func score() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if profile.isSupporter {
                Text("Supporter")
                    .font(baseSize: 13, weightDelta: 2)
                    .foregroundColor(.primaryForeground)
                    .padding(.vertical, 1)
                    .padding(.horizontal, 5)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.secondaryBackground)
                    }
            }
            
            let score = profile.score
            let scoreText = score > 0 ? "+\(score)" : "\(score)"
            
            Text(scoreText)
                .font(baseSize: 13, weightDelta: 2)
                .foregroundColor(.primaryForeground)
                .padding(.vertical, 1)
                .padding(.horizontal, 5)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.secondaryBackground)
                }
        }
    }
    
    @ViewBuilder private func joinedOnDate() -> some View {
        let formattedDate = AbsoluteDateFormatter.shared.string(fromSeconds: profile.createdTime)
        Text("Joined on\n\(formattedDate)")
            .font(baseSize: 13, weightDelta: 2)
            .multilineTextAlignment(.trailing)
            .foregroundColor(.white)
    }
    
    @ViewBuilder private func header() -> some View {
        if let url = avatarUrl() {
            CachedAsyncImage(url: url, urlCache: .profileImageCache) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .fillHorizontally()
                    .background(userColor())
            } placeholder: {
                userColor()
            }
        } else {
            userColor()
        }
    }
    
    private func avatarUrl() -> URL? {
        profile.avatar.avatarImage.flatMap { path in
            URL(string: "https://avatars.devrant.com/\(path)")
        }
    }
    
    private func userColor() -> Color {
        Color(hexString: profile.avatar.backgroundColor) ?? emptyBgColor
    }
    
    @ViewBuilder private func categoryPicker() -> some View {
        ViewThatFits(in: .horizontal) {
            categoryPicker(scrolling: false)
            categoryPicker(scrolling: true)
        }
    }
    
    @ViewBuilder private func categoryPicker(scrolling: Bool) -> some View {
        SegmentedPicker(selectedIndex: $viewModel.categoryTabIndex, items: viewModel.categoryTabs, spacing: 8, horizontalScrolling: scrolling) { segment in
            HStack(spacing: 4) {
                let count = viewModel.categoryCount(tab: segment.item)
                VStack(spacing: 2) {
                    Text("\(count)")
                        .font(baseSize: 17, weightDelta: 1)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .if(!scrolling) {
                            $0.fillHorizontally()
                        }
                    
                    Text(segment.item.displayName)
                        .font(baseSize: 15, weightDelta: 1)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .if(!scrolling) {
                            $0.fillHorizontally()
                        }
                }
                .foregroundColor(segment.selected ? .primaryForeground : .primaryForeground)
                .padding(.bottom, 3)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background {
                // this is needed so that the View is tappable in empty regions
                Color.primaryBackground
            }
            .overlay(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .foregroundColor(segment.selected ? .primaryAccent : .secondaryBackground)
                    .frame(height: 3)
                    .animation(.easeInOut.speed(2), value: viewModel.categoryTabIndex)
            }
            .padding(.vertical, 1)
        }
        .buttonStyle(.plain)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView(sourceTab: .feed, viewModel: .init(userId: 0, mocked: true))
                .navigationBarTitleDisplayModeInline()
        }
    }
}
