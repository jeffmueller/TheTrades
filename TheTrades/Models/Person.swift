import Foundation

struct Person: Identifiable, Codable, Sendable, Hashable {
    let id: Int
    let name: String
    let biography: String?
    let birthday: String?
    let deathday: String?
    let placeOfBirth: String?
    let profilePath: String?
    let knownForDepartment: String?
    let movieCredits: PersonCredits?
    let tvCredits: PersonCredits?

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    var age: Int? {
        guard let birthday,
              let birthDate = Self.dateFormatter.date(from: birthday) else { return nil }
        let endDate: Date
        if let deathday, let deathDate = Self.dateFormatter.date(from: deathday) {
            endDate = deathDate
        } else {
            endDate = Date()
        }
        return Calendar.current.dateComponents([.year], from: birthDate, to: endDate).year
    }

    var isDeceased: Bool {
        deathday != nil
    }

    func ageAtRelease(date: String?) -> Int? {
        guard let birthday,
              let birthDate = Self.dateFormatter.date(from: birthday),
              let date,
              let releaseDate = Self.dateFormatter.date(from: date) else { return nil }
        return Calendar.current.dateComponents([.year], from: birthDate, to: releaseDate).year
    }
}
