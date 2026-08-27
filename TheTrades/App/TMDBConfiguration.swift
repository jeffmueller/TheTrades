import Foundation

/// Build-time configuration for the TMDB API.
///
/// The bearer token is never committed. `Config/App.xcconfig` copies the
/// `TMDB_BEARER_TOKEN` build setting into the generated Info.plist, and reads
/// that setting from the gitignored `Config/Local.xcconfig`. See the README.
///
/// With no token configured the app still builds, launches, and passes its
/// tests; only live requests fail, with `TMDBError.missingAPIToken`.
enum TMDBConfiguration {
    /// The TMDB v4 "API Read Access Token", or `nil` when none is configured.
    static let bearerToken: String? = {
        // An environment variable wins, so an Xcode scheme or a CI job can
        // override the baked-in value without touching build settings.
        if let fromEnvironment = ProcessInfo.processInfo.environment["TMDB_BEARER_TOKEN"],
           !fromEnvironment.isEmpty {
            return fromEnvironment
        }

        guard let value = Bundle.main.object(forInfoDictionaryKey: "TMDBBearerToken") as? String else {
            return nil
        }

        let token = value.trimmingCharacters(in: .whitespacesAndNewlines)
        // The placeholder in Config/Local.example.xcconfig is not a token.
        guard !token.isEmpty, token != "YOUR_TMDB_BEARER_TOKEN_HERE" else { return nil }
        return token
    }()
}
