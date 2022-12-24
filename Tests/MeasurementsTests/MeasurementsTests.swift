import XCTest
@testable import Measurements

final class MeasurementsTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Measurements().measurementSystem, MeasurementSystem.metric)
    }
}
