import Foundation

enum AgeCalculator {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    /// Computes age at a given date from a birthday string.
    /// Both strings should be in "yyyy-MM-dd" format.
    /// Returns nil if either date is nil or unparseable.
    static func age(birthday: String?, at dateString: String?) -> Int? {
        guard let birthday,
              let birthDate = dateFormatter.date(from: birthday),
              let dateString,
              let date = dateFormatter.date(from: dateString) else { return nil }
        return Calendar.current.dateComponents([.year], from: birthDate, to: date).year
    }
}
