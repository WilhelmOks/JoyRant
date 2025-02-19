//
//  ProfileView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 19.11.22.
//

import SwiftUI
import SwiftDevRant
import CachedAsyncImage

struct ProfileView: View {
    let sourceTab: InternalView.Tab
    
    @StateObject var viewModel: ProfileViewModel
    
    @Environment(\.openURL) private var openURL
    
    @State private var moreMenuId = UUID()
    
    private let emptyBgColor = Color.gray.opacity(0.3)
        
    var profile: UserProfile {
        viewModel.profile ?? viewModel.placeholderProfile
    }
    
    var body: some View {
        content()
            .background(Color.primaryBackground)
            .alert($viewModel.alertMessage)
            .navigationTitle(viewModel.title)
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .principal) {
                    Text(viewModel.title).fontWeight(.semibold)
                }
                #endif
                
                ToolbarItem(placement: .automatic) {
                    toolbarMoreButton()
                }
            }
            .onReceive { event in
                switch event {
                case .shouldUpdateRantInLists(let rant): return rant
                default: return nil
                }
            } perform: { (rant: Rant) in
                viewModel.profile?.content.rants.updateRant(rant)
                viewModel.profile?.content.upvoted.updateRant(rant)
                viewModel.profile?.content.favorites.updateRant(rant)
                viewModel.profile?.content.viewed.updateRant(rant)
            }
            .onReceive { event in
                switch event {
                case .shouldUpdateCommentInLists(let comment): return comment
                default: return nil
                }
            } perform: { (comment: Comment) in
                viewModel.profile?.content.comments.updateComment(comment)
            }
            .onChange(of: viewModel.categoryTabIndex) { newValue in
                if let tab = viewModel.categoryTab(atIndex: newValue) {
                    Task {
                        await viewModel.loadFirstDataSetIfEmpty(tab: tab)
                    }
                }
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
                    .overlay(alignment: .topTrailing) {
                        subscribedInfo()
                            .padding(10)
                    }
                
                infoArea()
                    .fillHorizontally(.leading)
                    .padding(.horizontal, 10)
                
                if !viewModel.categoryTabs.isEmpty {
                    categoryPicker()
                    
                    if viewModel.isLoadingFirst {
                        ProgressView()
                            .fillHorizontally()
                            .padding(.vertical, 10)
                    } else {
                        switch viewModel.categoryTab {
                        case .rants:
                            rantList(profile.content.rants)
                        case .upvotes:
                            rantList(profile.content.upvoted)
                        case .comments:
                            commentList(profile.content.comments)
                        case .viewed:
                            rantList(profile.content.viewed)
                        case .favorites:
                            rantList(profile.content.favorites)
                        }
                    }
                }
            }
            .if(!viewModel.isLoaded) {
                $0.redacted(reason: .placeholder)
            }
            .disabled(!viewModel.isLoaded)
        }
    }
    
    @ViewBuilder private func rantList(_ rants: [Rant]) -> some View {
        RantList(
            sourceTab: sourceTab,
            rants: rants,
            isLoadingMore: viewModel.isLoadingMore,
            loadMore: {
                Task {
                    await viewModel.loadMore(tab: viewModel.categoryTab)
                }
            }
        )
    }
    
    @ViewBuilder private func commentList(_ comments: [Comment]) -> some View {
        LazyVStack(spacing: 0) {
            ForEach(comments, id: \.id) { comment in
                VStack(spacing: 0) {
                    if comment != comments.first {
                        Divider()
                    }
                    
                    RantCommentView(
                        viewModel: .init(comment: comment),
                        isLinkToRant: true
                    )
                    .padding(.bottom, 10)
                    .onTapGesture {
                        AppState.shared.navigate(
                            from: sourceTab,
                            to: .rantDetails(rantId: comment.rantId, scrollToCommentWithId: comment.id)
                        )
                    }
                }
            }
            
            Divider()
            
            Button {
                Task {
                    await viewModel.loadMore(tab: viewModel.categoryTab)
                }
            } label: {
                Text("load more")
                    .foregroundColor(.primaryAccent)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLoadingMore)
            .fillHorizontally(.center)
            .padding()
        }
    }
    
    @ViewBuilder private func infoArea() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let about = profile.profile.about {
                infoRow {
                    infoRowIcon(systemName: "person")
                } content: {
                    infoRowText(text: about)
                }
            }

            if let skills = profile.profile.skills {
                infoRow {
                    infoRowIcon(systemName: "curlybraces")
                } content: {
                    infoRowText(text: skills)
                }
            }
            
            if let location = profile.profile.location {
                infoRow {
                    infoRowIcon(systemName: "mappin.and.ellipse")
                } content: {
                    infoRowText(text: location)
                }
            }
            
            if let website = profile.profile.website {
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
            
            if let github = profile.profile.github {
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
            if profile.profile.devRantSupporter {
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
            
            let score = profile.profile.score
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
        let formattedDate = AbsoluteDateFormatter.shared.string(fromDate: profile.profile.created)
        Text("Joined on\n\(formattedDate)")
            .font(baseSize: 13, weightDelta: 2)
            .multilineTextAlignment(.trailing)
            .foregroundColor(.white)
    }
    
    @ViewBuilder private func subscribedInfo() -> some View {
        if viewModel.profile?.profile.subscribed == true {
            Label("Subscribed", systemImage: "star.fill")
                .font(baseSize: 13, weightDelta: 2)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.white)
        }
    }
    
    @ViewBuilder private func header() -> some View {
        if let url = avatarUrl() {
            CachedAsyncImage(url: url, urlCache: .profileImageCache) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .fillHorizontally()
                    .background(userColor())
                    .onAppear {
                        DispatchQueue.main.async {
                            moreMenuId = UUID()
                        }
                    }
            } placeholder: {
                userColor()
            }
        } else {
            userColor()
        }
    }
    
    private func avatarUrl() -> URL? {
        profile.profile.avatarLarge.imageUrl
    }
    
    private func userColor() -> Color {
        Color(hexString: profile.profile.avatarLarge.colorHex) ?? emptyBgColor
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
                        .if(segment.item == .viewed) {
                            // show clock icon instead of the number 0 but occupy the same space to align with the rest.
                            $0.opacity(0).accessibility(hidden: true)
                                .overlay {
                                    Image(systemName: "clock")
                                        .font(baseSize: 17)
                                }
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
            }
            .padding(.vertical, 1)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder private func toolbarMoreButton() -> some View {
        Menu {
            Button {
                let devRantLink = "https://devrant.com/users/\(profile.profile.username)"
                Pasteboard.shared.copy(devRantLink)
            } label: {
                Label("Copy Profile Link", systemImage: "doc.on.doc")
            }
            
            Button {
                if viewModel.profile?.profile.subscribed == true {
                    Task {
                        await viewModel.unsubscribe()
                    }
                } else {
                    Task {
                        await viewModel.subscribe()
                    }
                }
            } label: {
                if viewModel.profile?.profile.subscribed == true {
                    Label("Unsubscribe from User's Rants", systemImage: "star.fill")
                } else {
                    Label("Subscribe to User's Rants", systemImage: "star")
                }
            }

            if let avatarImage = cachedImage().flatMap({ Image(platformImage: $0) }) {
                ShareLink(
                    item: avatarImage,
                    preview: SharePreview("User Avatar", image: avatarImage)
                ) {
                    Label("Share Avatar", systemImage: "photo")
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .frame(width: 26, height: 26)
        }
        .disabled(viewModel.isLoading)
        .id(moreMenuId)
    }
    
    private func cachedImage() -> PlatformImage? {
        guard let url = profile.profile.avatarLarge.imageUrl else { return nil }
        guard let response = URLCache.profileImageCache.cachedResponse(for: .init(url: url)) else { return nil }
        return .init(data: response.data)
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
