# Time Independent Dates in Swift

This library offers `TimeIndependentDate`, a type representing a date
independent of a particular time. It therefore represents approximately 48
hours of real time on Earth.

Most often, it is important that a date also near-precisely represent a point
in time. For that, we have `Foundation.Date`. `TimeIndependentDate` fills a
gap where, in limited circumstances, we need to deal with a date independent
of time. This is particularly useful when interfacing with third party
systems which supply dates independent of time.

## Example Usage

```swift
// Initialise a date, throwing a `TimeIndependentDate` error if the supplied
// literal values are invalid.
let timeIndependentDate = try TimeIndependentDate(
    year: 2020,
    month: .january,
    day: 1
)

// Parse a date from a string. Adjust encoding order as desired. A
// `TimeIndependentDateError` is thrown if the supplied string
// is not a valid date.
let timeIndependentDate = try TimeIndependentDate.from(
    "2021-01-01",
    encodingOrder: .dayFirst
)

```

## Documentation

Select Product > Build Documentation in Xcode to build the library doccarchive. Or, download the latest documentation: [TimeIndependentDates.doccarchive.zip for v1.01](https://github.com/hwjeremy/time-independent-date-swift/files/13592892/TimeIndependentDates.doccarchive.zip)

## Versioning

`TimeIndependentDates` obeys [Semantic Versioning 2.0.0](https://semver.org) specifications.

## Installation

Add TimeIndependentDates as a dependency in your `Package.swift` file. Here is a simple example:

```swift
let package = Package(
    name: "YourLibrary",
    products: [
        .library(
            name: "YourLibrary",
            targets: ["YourLibrary"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hwjeremy/time-independent-date-swift", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "YourLibrary",
            dependencies: [
                .product(name: "TimeIndependentDates", package: "time-independent-date-swift")
            ]
        )
    ]
)
```

## Contact

Comments, pull requests, and issues are welcome on GitHub
- [hugh_jeremy on X/Twitter](https://x.com/hugh_jeremy)
- [Hugh Jeremy on LinkedIn](https://au.linkedin.com/in/hugh-jeremy-2932a140)
