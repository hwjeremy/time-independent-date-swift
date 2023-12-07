/*
Copyright 2023 Hugh Wilson Jeremy

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import Foundation


/// A day date independent of any concept of time.
///
/// Most often, time and time-zone aware Foundation `Date` should be used . In
/// some limited circumstances, such as when parsing data from  third parties,
/// it is useful to have access to a time independent date.
///
/// A `TimeIndependentDate` can be considered to represent approximately 48
/// hours of "real time" on Earth. Therefore, it should only be used to
/// represent such approximate time periods, or strictly within the constraints
/// set by some third party.
public struct TimeIndependentDate: Equatable, Comparable, Hashable,
                                    CustomStringConvertible, Codable {
    
    public let year: Int
    public let month: Self.Month
    public let day: Int
    
    public init(year: Int, month: Self.Month, day: Int) throws {
        
        guard year >= 1000 && year <= 9999 else {
            throw TimeIndependentDateError("""
Time independent date year out of bounds. Max value 9999, min value 1000.
""")
        }

        guard day >= 1 && day <= month.maxDaysGiven(year: year) else {
            throw TimeIndependentDateError("""
Time independent day out of bounds. Min value 1, max value for month \
\(month.maxDaysGiven(year: year)) given month
""")
        }

        self.year = year
        self.month = month
        self.day = day

        return

    }
    
    public init (from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        self = try Self.from(stringValue)
        return
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let stringValue = String(describing: self)
        try container.encode(stringValue)
        return
    }
    
    /// A `String` representation of this `TimeIndependentDate` with
    /// .yearFirst` encoding order.
    public var description: String { get {
        return self.toString(encodingOrder: .yearFirst)
    } }
    
    /// Return a `String` representation of this `TimeIndependentDate`
    public func toString(encodingOrder: EncodingOrder) -> String {
        
        func zeroPad(_ number: Int, expectedDigits: Int) -> String {
            
            var working = String(number)
            
            while working.count < expectedDigits {
                working = "0\(working)"
            }
            
            return working
            
        }
        
        let year = zeroPad(self.year, expectedDigits: 4)
        let month = zeroPad(self.month.rawValue, expectedDigits: 2)
        let day = zeroPad(self.day, expectedDigits: 2)
        
        switch encodingOrder {
        case .dayFirst:
            return "\(day)-\(month)-\(year)"
        case .yearFirst:
            return "\(year)-\(month)-\(day)"
        }

    }
    
    public enum EncodingOrder {
        case yearFirst
        case dayFirst
        
        public var formatMask: String {
            switch self {
            case .dayFirst:
                return "DD-MM-YYYY"
            case .yearFirst:
                return "YYYY-MM-DD"
            }
        }
        
        fileprivate var monthComponentIndex: Int { return 1 }
        
        fileprivate var yearComponentIndex: Int {
            switch self {
            case .dayFirst:
                return 2
            case .yearFirst:
                return 0
            }
        }
        
        fileprivate var dayComponentIndex: Int {
            switch self {
            case .dayFirst:
                return 0
            case .yearFirst:
                return 2
            }
        }
        
    }
    
    /// Return a `TimeIndependentDate` approximately representing now. Because
    /// a `TimeIndependentDate` at best represents a 48 hour period on Earth,
    /// this result should only be used where very coarse-grained time
    /// precision is required.
    public static func approximatelyNow() -> Self {
        
        let dateNow = Date()
        
        let year = Calendar.current.component(.year, from: dateNow)
        let month = Calendar.current.component(.month, from: dateNow)
        let day = Calendar.current.component(.day, from: dateNow)
        
        // We depend on the quality of the Apple Foundation date library
        // to provide valid years, months, and days, else we will crash
        // fatally.
        
        guard let monthEnum = Self.Month(rawValue: month) else {
            fatalError("""
Apple's Foundation library produced a non-sensical month: \(month)
""")
        }
        
        guard let now = try? TimeIndependentDate(
            year: year,
            month: monthEnum,
            day: day
        ) else { fatalError("""
Unable to initialise a TimeIndependentDate from \(year)-\(month)-\(day)
""") }
        
        return now

    }

    public static func from(
        _ string: String,
        encodingOrder: Self.EncodingOrder = .yearFirst
    ) throws -> Self {
        
        let parseString = string
            .replacing("_", with: "-")
            .replacing("/", with: "-")
        
        let mask = encodingOrder.formatMask
        
        for character in parseString {
            if !Array("0123456789-").contains(character) {
                throw TimeIndependentDateError("""
Unable to parse a time-independent date in format \(mask). Unexpected char\
acter encountered. Allowed characters: "01234567890-_/"
""")
            }
        }
        
        let components = parseString.split(separator: "-")
        
        guard components.count == 3 else {
            throw TimeIndependentDateError("""
Unable to parse a time-independent date in format \(mask). Expected three \
integer groups, received \(components.count)
""")
        }
        
        let yearComponentIndex = encodingOrder.yearComponentIndex
        
        guard let year = Int(components[yearComponentIndex]) else {
            throw TimeIndependentDateError("""
Unable to parse a time-independent date in format \(mask). Unable to transl\
ate the YYYY component into an integer number.
""")
        }
        
        let monthComponentIndex = encodingOrder.monthComponentIndex
        
        var monthString = String(components[monthComponentIndex])

        if monthString.first == "0" {
            monthString = String(monthString.dropFirst())
        }
        
        guard let rawMonth = Int(monthString) else {
            throw TimeIndependentDateError("""
Unable to parse a time-independent date in format \(mask). Unable to transl\
ate the MM component into an integer number.
""")
        }
        
        guard let month = Self.Month(rawValue: rawMonth) else {
            throw TimeIndependentDateError("""
Unable to parse a time-independent date in format \(mask). The MM does not \
appear to be a valid month between 01 and 12
""")
        }
        
        let dayComponentIndex = encodingOrder.dayComponentIndex

        var dayString = String(components[dayComponentIndex])
        
        if dayString.first == "0" {
            dayString = String(dayString.dropFirst())
        }
        
        guard let day = Int(dayString) else {
            throw TimeIndependentDateError("""
Unable to parse a time-independent date in format \(mask). The DD component\
could not be interpreted as an integer number.
""")
        }
        
        return try Self.init(year: year, month: month, day: day)
        
    }
    
    public enum Month: Int, Equatable, Hashable, CaseIterable, Comparable {
        
        case january = 1
        case february = 2
        case march = 3
        case april = 4
        case may = 5
        case june = 6
        case july = 7
        case august = 8
        case september = 9
        case october = 10
        case november = 11
        case december = 12
        
        public static var allCases: Array<TimeIndependentDate.Month> = [
            .january,
            .february,
            .march,
            .april,
            .may,
            .june,
            .july,
            .august,
            .september,
            .october,
            .november,
            .december
        ]
            
        public var name: String {
            switch self {
            case .january:
                return "January"
            case .february:
                return "February"
            case .march:
                return "March"
            case .april:
                return "April"
            case .may:
                return "May"
            case .june:
                return "June"
            case .july:
                return "July"
            case .august:
                return "August"
            case .september:
                return "September"
            case .october:
                return "October"
            case .november:
                return "November"
            case .december:
                return "December"
            }
        }
        
        public func maxDaysGiven(year: Int) -> Int {
            
            switch self {
            case .september, .april, .june, .november:
                return 30
            case .january, .march, .may, .july, .august, .october, .december:
                return 31
            case .february:
                if year % 4 != 0 { return 28 }
                return 29
            }
            
        }
        
        public static func < (
            lhs: TimeIndependentDate.Month,
            rhs: TimeIndependentDate.Month
        ) -> Bool {
            if lhs.rawValue < rhs.rawValue { return true }
            return false
        }
        
        public static func > (
            lhs: TimeIndependentDate.Month,
            rhs: TimeIndependentDate.Month
        ) -> Bool {
            if lhs.rawValue > rhs.rawValue { return true }
            return false
        }
        
        public static func <= (
            lhs: TimeIndependentDate.Month,
            rhs: TimeIndependentDate.Month
        ) -> Bool {
            if lhs.rawValue <= rhs.rawValue { return true }
            return false
        }
        
        public static func >= (
            lhs: TimeIndependentDate.Month,
            rhs: TimeIndependentDate.Month
        ) -> Bool {
            if lhs.rawValue >= rhs.rawValue { return true }
            return false
        }
        
        
    }
    
    public static func < (
        lhs: TimeIndependentDate,
        rhs: TimeIndependentDate
    ) -> Bool {
        
        if lhs.year < rhs.year { return true }
        if lhs.month < rhs.month { return true }
        if lhs.day < rhs.day { return true }
        
        return false
        
    }
    
    public static func > (
        lhs: TimeIndependentDate,
        rhs: TimeIndependentDate
    ) -> Bool {
        
        if lhs.year > rhs.year { return true }
        if lhs.month > rhs.month { return true }
        if lhs.day > rhs.day { return true }
        
        return false
        
    }
    
    public static func >=(
        lhs: TimeIndependentDate,
        rhs: TimeIndependentDate
    ) -> Bool {
        
        if lhs.year >= rhs.year { return true }
        if lhs.month >= rhs.month { return true }
        if lhs.day >= rhs.day { return true }

        return false
        
    }
    
    public static func <=(
        lhs: TimeIndependentDate,
        rhs: TimeIndependentDate
    ) -> Bool {
        
        if lhs.year <= rhs.year { return true }
        if lhs.month <= rhs.month { return true }
        if lhs.day <= rhs.day { return true }

        return false
        
    }

    /// Return a `Decimal` representing the approximate number of years until
    /// another `TimeIndependentDate`.
    ///
    /// This function is *approximate* and will typically yield an error of
    /// between 24 and 48 hours from the real difference. The result value
    /// is rounded to three decimal places.
    public func approximateYearsUntil(_ other: Self) -> Decimal {
        return other.approximateYearsSince(self)
    }
    
    
    /// Return a `Decimal` representing the approximate number of years since
    /// another `TimeIndependentDate`.
    ///
    /// This function is *approximate* and will typically yield an error of
    /// between 24 and 48 hours from the real difference. The result value
    /// is rounded to three decimal places.
    public func approximateYearsSince(_ other: Self) -> Decimal {
        
        let yearDifference = Decimal(self.year - other.year)
        let monthDifference = self.month.rawValue - other.month.rawValue
        let dayDifference = self.day - other.day

        let monthFraction: Decimal = Decimal(monthDifference) / Decimal(12)
        let dayFraction: Decimal = Decimal(dayDifference) / Decimal(365)
        
        let difference: Decimal = yearDifference + monthFraction + dayFraction
        
        func r(_ d: Decimal) -> Decimal {
            var o = d; var r = Decimal()
            NSDecimalRound(&r, &o, 3, .plain)
            return r
        }
        
        
        return r(difference)

    }
    
    
}
