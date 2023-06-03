import XCTest
@testable import SteinerCircleModel

final class SteinerCircleModelTests: XCTestCase {
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    let steinerCircle = SteinerCircleModel.SteinerCircle(outerRadius: 1, circleCount: 4)
    XCTAssertEqual(steinerCircle.circleCount, 4)
    print("===========================")
    print(steinerCircle.description)
    print("===========================")
    XCTAssertEqual(steinerCircle.rho(), 0.4142135623730951)
  }
  
  static var allTests = [
    ("testExample", testExample),
  ]
}
