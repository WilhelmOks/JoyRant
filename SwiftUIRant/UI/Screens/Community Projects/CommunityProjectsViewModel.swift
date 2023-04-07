//
//  CommunityProjectsViewModel.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 07.04.23.
//

import Foundation

@MainActor final class CommunityProjectsViewModel: ObservableObject {
    var loadedItems: [CommunityProject] = []
    @Published var items: [CommunityProject] = []
    @Published var isLoading = false
    @Published var alertMessage: AlertMessage = .none()
    @Published var selectedTypeIndex = 0 {
        didSet {
            items = filter(searchText: searchText, items: loadedItems)
        }
    }
    @Published var selectedOsIndex = 0 {
        didSet {
            items = filter(searchText: searchText, items: loadedItems)
        }
    }
    @Published var activeOnly = false {
        didSet {
            items = filter(searchText: searchText, items: loadedItems)
        }
    }
    @Published var searchText = "" {
        didSet {
            items = filter(searchText: searchText, items: loadedItems)
        }
    }
    
    init() {
        Task {
            await load()
        }
    }
    
    func load() async {
        isLoading = true
        
        do {
            loadedItems = try await Networking.shared.communityProjects()
            items = filter(searchText: searchText, items: loadedItems)
        } catch {
            alertMessage = .presentedError(error)
        }
        
        isLoading = false
    }
    
    func filter(searchText: String, items: [CommunityProject]) -> [CommunityProject] {
        return items.filter { item in
            let searchTextMatches = searchText.isEmpty ||
                item.title.localizedCaseInsensitiveContains(searchText) ||
                item.description.localizedCaseInsensitiveContains(searchText) ||
                item.owner.localizedCaseInsensitiveContains(searchText) ||
                item.language.localizedCaseInsensitiveContains(searchText)
            
            let typeMatches = matches(filterItems: pickableTypeItems(), selectedFilterIndex: selectedTypeIndex, item: item, keyPath: \.type)
            let osMatches = matches(filterItems: pickableOsItems(), selectedFilterIndex: selectedOsIndex, item: item, keyPath: \.operatingSystems)
            let activeMatches = activeOnly ? item.active : true
                        
            return searchTextMatches && typeMatches && osMatches && activeMatches
        }
    }
    
    func matches(filterItems: [PickableFilterItem], selectedFilterIndex index: Int, item: CommunityProject, keyPath: KeyPath<CommunityProject, String>) -> Bool {
        guard filterItems.indices.contains(index) else { return true }
        let selected = filterItems[index]
        switch selected {
        case .all: return true
        case .named(let name): return name == item[keyPath: keyPath]
        }
    }
    
    func matches(filterItems: [PickableFilterItem], selectedFilterIndex index: Int, item: CommunityProject, keyPath: KeyPath<CommunityProject, [String]>) -> Bool {
        guard filterItems.indices.contains(index) else { return true }
        let selected = filterItems[index]
        switch selected {
        case .all: return true
        case .named(let name): return item[keyPath: keyPath].contains(name)
        }
    }
    
    func pickableTypeItems() -> [PickableFilterItem] {
        [.all] + loadedItems.map(\.type).uniqued().map { .named($0) }
    }
    
    func pickableOsItems() -> [PickableFilterItem] {
        [.all] + loadedItems.flatMap(\.operatingSystems).uniqued().map { .named($0) }.sorted()
    }
}

extension CommunityProjectsViewModel {
    enum PickableFilterItem: Hashable, Comparable {
        case all
        case named(_ name: String)
        
        var displayName: String {
            switch self {
            case .all: return "all"
            case .named(let name): return name
            }
        }
        
        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs == .all ? true : lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
        }
    }
}
