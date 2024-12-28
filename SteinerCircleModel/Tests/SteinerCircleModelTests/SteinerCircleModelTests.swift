import XCTest
@testable import SteinerCircleModel

final class SteinerCircleModelTests: XCTestCase {
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    let steinerCircle = SteinerCircleModel.SteinerCircle(outerRadius: 1, circleCount: 1)
    XCTAssertEqual(steinerCircle.circleCount, 1)
    print("===========================")
    print(steinerCircle.description)
    print("===========================")
    XCTAssertEqual(steinerCircle.rho(), 1.0)
  }
  
  static var allTests = [
    ("testExample", testExample),
  ]
}
