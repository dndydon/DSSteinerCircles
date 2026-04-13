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

  func testTwoCircles() {
    let steinerCircle = SteinerCircleModel.SteinerCircle(outerRadius: 1, circleCount: 2)
    XCTAssertEqual(steinerCircle.circleCount, 2)
    print("===========================")
    print(steinerCircle.description)
    print("===========================")
  }

  func testThreeCircles() {
    let steinerCircle = SteinerCircleModel.SteinerCircle(outerRadius: 1, circleCount: 3)
    XCTAssertEqual(steinerCircle.circleCount, 3)
    print("===========================")
    print(steinerCircle.description)
    print("===========================")
  }

  func testSixCircles() {
    let steinerCircle = SteinerCircleModel.SteinerCircle(outerRadius: 1, circleCount: 6)
    XCTAssertEqual(steinerCircle.circleCount, 6)
    print("===========================")
    print(steinerCircle.description)
    print("===========================")
  }

  func testTwelveCircles() {
    let steinerCircle = SteinerCircleModel.SteinerCircle(outerRadius: 1, circleCount: 12)
    XCTAssertEqual(steinerCircle.circleCount, 12)
    print("===========================")
    print(steinerCircle.description)
    print("===========================")
  }

  static var allTests = [
    ("testExample", testExample),
    ("testTwoCircles", testTwoCircles),
    ("testThreeCircles", testThreeCircles),
    ("testSixCircles", testSixCircles),
    ("testTwelveCircles", testTwelveCircles),
  ]
}
