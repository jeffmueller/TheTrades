import Testing
@testable import TheTrades

@Suite struct AgeCalculatorTests {

    @Test func computesWholeYears() {
        #expect(AgeCalculator.age(birthday: "1990-01-01", at: "2020-01-01") == 30)
    }

    @Test func roundsDownBeforeBirthday() {
        // Birthday in December; the "at" date is earlier in the same year.
        #expect(AgeCalculator.age(birthday: "1963-12-18", at: "1999-10-15") == 35)
    }

    @Test func handlesLeapDayBirthday() {
        #expect(AgeCalculator.age(birthday: "2000-02-29", at: "2020-03-01") == 20)
    }

    @Test func nilWhenBirthdayMissing() {
        #expect(AgeCalculator.age(birthday: nil, at: "2020-01-01") == nil)
    }

    @Test func nilWhenDateMissing() {
        #expect(AgeCalculator.age(birthday: "1990-01-01", at: nil) == nil)
    }

    @Test func nilWhenUnparseable() {
        #expect(AgeCalculator.age(birthday: "not-a-date", at: "2020-01-01") == nil)
    }
}
