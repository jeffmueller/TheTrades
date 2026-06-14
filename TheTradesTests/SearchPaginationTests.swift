import Testing
@testable import TheTrades

@MainActor
@Suite struct SearchPaginationTests {

    private func makeState(searchPages: [Int: PagedResponse<SearchResult>]) -> AppState {
        AppState(client: StubMediaClient(searchPages: searchPages), store: makeIsolatedStore())
    }

    @Test func searchPopulatesResultsAndPaging() async {
        let page1 = PagedResponse<SearchResult>(page: 1, results: [movieResult(1), personResult(2)], totalPages: 3, totalResults: 6)
        let state = makeState(searchPages: [1: page1])

        state.searchText = "batman"
        await state.search()

        #expect(state.searchResults.count == 2)
        #expect(state.canLoadMore) // page 1 of 3
    }

    @Test func filterNarrowsWithoutRefetch() async {
        let page1 = PagedResponse<SearchResult>(
            page: 1,
            results: [movieResult(1), personResult(2), movieResult(3)],
            totalPages: 1, totalResults: 3
        )
        let state = makeState(searchPages: [1: page1])

        state.searchText = "x"
        await state.search()

        state.searchFilter = .movies
        #expect(state.filteredSearchResults.count == 2)
        state.searchFilter = .people
        #expect(state.filteredSearchResults.count == 1)
        state.searchFilter = .all
        #expect(state.filteredSearchResults.count == 3)
    }

    @Test func loadMoreAppendsAndDedupes() async {
        let page1 = PagedResponse<SearchResult>(page: 1, results: [movieResult(1), movieResult(2)], totalPages: 2, totalResults: 4)
        let page2 = PagedResponse<SearchResult>(page: 2, results: [movieResult(2), movieResult(3)], totalPages: 2, totalResults: 4)
        let state = makeState(searchPages: [1: page1, 2: page2])

        state.searchText = "x"
        await state.search()
        await state.loadMoreSearchResults()

        #expect(state.searchResults.count == 3) // id 2 deduped
        #expect(state.canLoadMore == false) // reached last page
    }

    @Test func loadMoreIsNoOpOnLastPage() async {
        let page1 = PagedResponse<SearchResult>(page: 1, results: [movieResult(1)], totalPages: 1, totalResults: 1)
        let state = makeState(searchPages: [1: page1])

        state.searchText = "x"
        await state.search()
        #expect(state.canLoadMore == false)

        await state.loadMoreSearchResults()
        #expect(state.searchResults.count == 1)
    }
}
