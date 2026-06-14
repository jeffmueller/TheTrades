import Testing
import Foundation
@testable import TheTrades

private func decode<T: Decodable>(_ type: T.Type, from json: String) throws -> T {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(T.self, from: Data(json.utf8))
}

@Suite struct ModelDecodingTests {

    @Test func decodesMovieAndComputedProperties() throws {
        let json = """
        {
          "id": 27205,
          "title": "Inception",
          "overview": "A thief who steals corporate secrets.",
          "release_date": "2010-07-16",
          "runtime": 148,
          "vote_average": 8.4,
          "tagline": "Your mind is the scene of the crime.",
          "genres": [{"id": 28, "name": "Action"}]
        }
        """
        let movie = try decode(Movie.self, from: json)
        #expect(movie.id == 27205)
        #expect(movie.title == "Inception")
        #expect(movie.year == "2010")
        #expect(movie.formattedRuntime == "2h 28m")
        #expect(movie.genres?.first?.name == "Action")
    }

    @Test func decodesTVShowYearRange() throws {
        let json = """
        {
          "id": 1396,
          "name": "Breaking Bad",
          "first_air_date": "2008-01-20",
          "last_air_date": "2013-09-29",
          "status": "Ended",
          "number_of_seasons": 5
        }
        """
        let show = try decode(TVShow.self, from: json)
        #expect(show.name == "Breaking Bad")
        #expect(show.yearRange == "2008–2013")
    }

    @Test func decodesOngoingTVShowYearRange() throws {
        let json = """
        { "id": 1, "name": "Ongoing", "first_air_date": "2020-01-01", "status": "Returning Series" }
        """
        let show = try decode(TVShow.self, from: json)
        #expect(show.yearRange == "2020–Present")
    }

    @Test func decodesPersonAndAgeAtRelease() throws {
        let json = """
        {
          "id": 287,
          "name": "Brad Pitt",
          "birthday": "1963-12-18",
          "place_of_birth": "Shawnee, Oklahoma, USA"
        }
        """
        let person = try decode(Person.self, from: json)
        #expect(person.isDeceased == false)
        // Born Dec 1963; on a film released Oct 1999 he had not yet turned 36.
        #expect(person.ageAtRelease(date: "1999-10-15") == 35)
    }

    @Test func decodesSearchResultDiscriminator() throws {
        let movie = try decode(SearchResult.self, from: #"{"media_type":"movie","id":1,"title":"A"}"#)
        let tv = try decode(SearchResult.self, from: #"{"media_type":"tv","id":2,"name":"B"}"#)
        let person = try decode(SearchResult.self, from: #"{"media_type":"person","id":3,"name":"C"}"#)

        #expect(movie.typeLabel == "Movie")
        #expect(movie.displayTitle == "A")
        #expect(tv.typeLabel == "TV")
        #expect(tv.displayTitle == "B")
        #expect(person.isPerson)
        #expect(person.appDestination == .person(id: 3))
    }

    @Test func decodesPagedResponseWithMediaType() throws {
        let json = """
        {
          "page": 1,
          "results": [
            {"media_type":"movie","id":1,"title":"A"},
            {"media_type":"tv","id":2,"name":"B"}
          ],
          "total_pages": 10,
          "total_results": 200
        }
        """
        let page = try decode(PagedResponse<SearchResult>.self, from: json)
        #expect(page.results.count == 2)
        #expect(page.totalPages == 10)
    }

    @Test func decodesPagedResponseWithoutMediaType() throws {
        // /movie/popular returns plain movie objects (no media_type).
        let json = """
        {
          "page": 1,
          "results": [{"id": 1, "title": "Popular", "vote_average": 7.0}],
          "total_pages": 5,
          "total_results": 100
        }
        """
        let page = try decode(PagedResponse<MovieSearchResult>.self, from: json)
        #expect(page.results.first?.title == "Popular")
        #expect(page.totalPages == 5)
    }

    @Test func videoBuildsYouTubeURLs() throws {
        let video = try decode(Video.self, from: #"{"id":"x","key":"abc123","name":"Official Trailer","site":"YouTube","type":"Trailer"}"#)
        #expect(video.youtubeURL == URL(string: "https://www.youtube.com/watch?v=abc123"))
        #expect(video.thumbnailURL == URL(string: "https://img.youtube.com/vi/abc123/hqdefault.jpg"))
    }

    @Test func videoResultsFiltersTrailersFirst() throws {
        let json = """
        { "results": [
          {"id":"1","key":"k1","name":"Clip","site":"YouTube","type":"Clip"},
          {"id":"2","key":"k2","name":"Teaser","site":"YouTube","type":"Teaser"},
          {"id":"3","key":"k3","name":"Trailer","site":"YouTube","type":"Trailer"},
          {"id":"4","key":"k4","name":"Vimeo trailer","site":"Vimeo","type":"Trailer"}
        ]}
        """
        let results = try decode(VideoResults.self, from: json)
        let trailers = results.trailers
        #expect(trailers.count == 2) // Clip and Vimeo excluded
        #expect(trailers.first?.type == "Trailer") // trailer ordered before teaser
    }
}
