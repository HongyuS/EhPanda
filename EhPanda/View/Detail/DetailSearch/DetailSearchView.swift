//
//  DetailSearchView.swift
//  EhPanda
//
//  Created by 荒木辰造 on R 4/01/12.
//

import SwiftUI
import ComposableArchitecture

struct DetailSearchView: View {
    @Bindable private var store: StoreOf<DetailSearchReducer>
    private let keyword: String
    private let user: User
    @Binding private var setting: Setting
    private let blurRadius: Double
    private let tagTranslator: TagTranslator

    init(
        store: StoreOf<DetailSearchReducer>,
        keyword: String, user: User, setting: Binding<Setting>, blurRadius: Double, tagTranslator: TagTranslator
    ) {
        self.store = store
        self.keyword = keyword
        self.user = user
        _setting = setting
        self.blurRadius = blurRadius
        self.tagTranslator = tagTranslator
    }

    var body: some View {
        let content =
        GenericList(
            galleries: store.galleries,
            setting: setting,
            pageNumber: store.pageNumber,
            loadingState: store.loadingState,
            footerLoadingState: store.footerLoadingState,
            fetchAction: { store.send(.fetchGalleries()) },
            fetchMoreAction: { store.send(.fetchMoreGalleries) },
            navigateAction: { store.send(.setNavigation(.detail($0))) },
            translateAction: {
                tagTranslator.lookup(word: $0, returnOriginal: !setting.translatesTags)
            }
        )
        .sheet(unwrapping: $store.route, case: /DetailSearchReducer.Route.quickSearch) { _ in
            QuickSearchView(
                store: store.scope(state: \.quickDetailSearchState, action: \.quickSearch)
            ) { keyword in
                store.send(.setNavigation(nil))
                store.send(.fetchGalleries(keyword))
            }
            .accentColor(setting.accentColor)
            .autoBlur(radius: blurRadius)
        }
        .sheet(unwrapping: $store.route, case: /DetailSearchReducer.Route.filters) { _ in
            FiltersView(store: store.scope(state: \.filtersState, action: \.filters))
                .accentColor(setting.accentColor).autoBlur(radius: blurRadius)
        }
        .searchable(text: $store.keyword)
        .searchSuggestions {
            TagSuggestionView(
                keyword: $store.keyword, translations: tagTranslator.translations,
                showsImages: setting.showsImagesInTags, isEnabled: setting.showsTagsSearchSuggestion
            )
        }
        .onSubmit(of: .search) {
            store.send(.fetchGalleries())
        }
        .onAppear {
            if store.galleries.isEmpty {
                DispatchQueue.main.async {
                    store.send(.fetchGalleries(keyword))
                }
            }
        }
        .background(navigationLink)
        .toolbar(content: toolbar)
        .navigationTitle(store.lastKeyword)

        if DeviceUtil.isPad {
            content
                .sheet(unwrapping: $store.route, case: /DetailSearchReducer.Route.detail) { route in
                    NavigationView {
                        DetailView(
                            store: store.scope(state: \.detailState.wrappedValue!, action: \.detail),
                            gid: route.wrappedValue, user: user, setting: $setting,
                            blurRadius: blurRadius, tagTranslator: tagTranslator
                        )
                    }
                    .autoBlur(radius: blurRadius).environment(\.inSheet, true).navigationViewStyle(.stack)
                }
        } else {
            content
        }
    }

    @ViewBuilder private var navigationLink: some View {
        if DeviceUtil.isPhone {
            NavigationLink(unwrapping: $store.route, case: /DetailSearchReducer.Route.detail) { route in
                DetailView(
                    store: store.scope(state: \.detailState.wrappedValue!, action: \.detail),
                    gid: route.wrappedValue, user: user, setting: $setting,
                    blurRadius: blurRadius, tagTranslator: tagTranslator
                )
            }
        }
    }
    private func toolbar() -> some ToolbarContent {
        CustomToolbarItem {
            ToolbarFeaturesMenu {
                FiltersButton {
                    store.send(.setNavigation(.filters))
                }
                QuickSearchButton {
                    store.send(.setNavigation(.quickSearch))
                }
            }
        }
    }
}

struct DetailSearchView_Previews: PreviewProvider {
    static var previews: some View {
        DetailSearchView(
            store: .init(initialState: .init(), reducer: DetailSearchReducer.init),
            keyword: .init(),
            user: .init(),
            setting: .constant(.init()),
            blurRadius: 0,
            tagTranslator: .init()
        )
    }
}
