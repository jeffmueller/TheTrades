import Testing
import Foundation
@testable import TheTrades

@Suite struct URLBuilderTests {

    // MARK: - ImageURLBuilder

    @Test func posterURLBuildsWithSize() {
        let url = ImageURLBuilder.posterURL(path: "/abc.jpg", size: .w342)
        #expect(url == URL(string: "https://image.tmdb.org/t/p/w342/abc.jpg"))
    }

    @Test func profileURLBuildsWithSize() {
        let url = ImageURLBuilder.profileURL(path: "/p.jpg", size: .w185)
        #expect(url == URL(string: "https://image.tmdb.org/t/p/w185/p.jpg"))
    }

    @Test func imageURLNilForNilPath() {
        #expect(ImageURLBuilder.posterURL(path: nil) == nil)
        #expect(ImageURLBuilder.backdropURL(path: nil) == nil)
        #expect(ImageURLBuilder.profileURL(path: nil) == nil)
    }

    // MARK: - TMDBURLBuilder

    @Test func sharingURLs() {
        #expect(TMDBURLBuilder.movie(id: 27205) == URL(string: "https://www.themoviedb.org/movie/27205"))
        #expect(TMDBURLBuilder.tvShow(id: 1396) == URL(string: "https://www.themoviedb.org/tv/1396"))
        #expect(TMDBURLBuilder.person(id: 287) == URL(string: "https://www.themoviedb.org/person/287"))
        #expect(TMDBURLBuilder.season(tvID: 1396, seasonNumber: 1) == URL(string: "https://www.themoviedb.org/tv/1396/season/1"))
        #expect(TMDBURLBuilder.episode(tvID: 1396, seasonNumber: 1, episodeNumber: 2) == URL(string: "https://www.themoviedb.org/tv/1396/season/1/episode/2"))
    }
}
