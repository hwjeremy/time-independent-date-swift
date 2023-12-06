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

import XCTest
@testable import TimeIndependentDates

final class TimeIndependentDateTests: XCTestCase {

    func testParsing() throws {
        
        let badStrings = [
            "0124-12-30",
            "2023-12-32",
            "2022-13-10",
            "0111-10-10",
            "2023-12-00",
            "2023-02-29"
        ]
        
        let goodStrings = [
            "2023-02-28",
            "2024-02-29",
            "2020/07/31",
            "1888_01_01",
            "4000/12_31",
        ]
        
        for badString in badStrings {
            
            let date = try? TimeIndependentDate.from(badString)
            XCTAssertNil(date)
            
        }
        
        for goodString in goodStrings {
            
            let date = try? TimeIndependentDate.from(goodString)
            XCTAssertNotNil(date)

        }
        
        return
        
    }
    
    func testReverseParsing() throws {
        
        let badStrings = [
            "30-12-0124",
            "32-12-2023",
            "10-13-2022",
            "10-10-0111",
            "00-12-2023",
            "29-02-2023"
        ]
        
        let goodStrings = [
            "28-02-2023",
            "29-02-2024",
            "31/07/2020",
            "01_01_1888",
            "31_12/4000"
        ]
        
        for badString in badStrings {
            
            let date = try? TimeIndependentDate.from(
                badString,
                encodingOrder: .dayFirst
            )
            XCTAssertNil(date)
            
        }
        
        for goodString in goodStrings {
            
            let date = try? TimeIndependentDate.from(
                goodString,
                encodingOrder: .dayFirst
            )
            XCTAssertNotNil(date)

        }
        
    }
    
    func testPadding() throws {
        
        let cases = ["2000-01-01", "2000-12-31"]
        
        for testCase in cases {
            
            let date = try TimeIndependentDate.from(testCase)
            let string = String(describing: date)
            XCTAssertEqual(string, testCase)
            
        }
        
        return
        
    }
    
    func testYearDifference() throws {
        
        typealias TID = TimeIndependentDate
        typealias D = Decimal
        
        let date1 = try TID(year: 2020, month: .january, day: 1)
        let date2 = try TID(year: 2015, month: .january, day: 1)
        
        XCTAssert(date1.approximateYearsSince(date2) == D(5))
        XCTAssert(date1.approximateYearsUntil(date2) == D(-5))
        XCTAssert(date2.approximateYearsUntil(date1) == D(5))
        XCTAssert(date2.approximateYearsSince(date1) == D(-5))
        
        let date3 = try TID(year: 1995, month: .august, day: 1)
        let date4 = try TID(year: 1995, month: .january, day: 31)
        
        let d3sinced4 = date3.approximateYearsSince(date4)
        let d3untild4 = date3.approximateYearsUntil(date4)
        let d4sinced3 = date4.approximateYearsSince(date3)
        let d4untild3 = date4.approximateYearsUntil(date3)
        
        func r(_ d: D) -> D {
            var o = d; var r = D()
            NSDecimalRound(&r, &o, 2, .plain)
            return r
        }

        XCTAssert(r(d3sinced4) == D(0.50))
        XCTAssert(r(d3untild4) == D(-0.50))
        XCTAssert(r(d4sinced3) == D(-0.50))
        XCTAssert(r(d4untild3) == D(0.50))
    
        return

    }


}
