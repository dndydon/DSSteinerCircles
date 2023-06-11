import SwiftUI

public struct SteinerCircle {
  
  public var outerRadius: CGFloat {
    didSet {
      print("outerRadius set to \(outerRadius)")
    }
  }
  
  public var circleCount: Int {
    didSet {
      self.theta = 180.0 / Double(circleCount)
      self.sineTheta = CGFloat(sin(theta))
    }
  }
  
  public var gap: CGFloat //= .zero // make this initializable and compute innerRadius from it.
  
  //  The angle 2θ between the centers of the Steiner-chain circles is 360°/n
  //  so, θ = 180/N, theta = Double(180.0 / Double(circleCount)).asRadians
  public var theta: Double // in degrees.  use this to draw the Steiner-chain circles
  
  private var sineTheta: CGFloat   // = CGFloat(Math.sine(degrees: theta))
  
  public var direction: CGFloat? = -90
  
  public init(outerRadius: CGFloat, circleCount: Int, gap: CGFloat = .zero) {
    self.outerRadius = outerRadius
    self.circleCount = circleCount
    self.direction = -90
    self.theta = Double(180.0 / Double(circleCount)).asRadians
    self.sineTheta = CGFloat(sin(theta))
    self.gap = gap  // range .zero to 1
    print(description)
  }
  
  // Given θ and R, the formula for r is: r = R ( 1 − sin θ )/( 1 + sin θ )
  public func innerRadius() -> CGFloat {
    let uncorrectedInnerRadius = outerRadius * ( ( 1 - sineTheta) / (1 + sineTheta) )
    let uncorrectedRho = uncorrectedInnerRadius * sineTheta / (1.0 - sineTheta)
    let gapCorrectredInnerRadius = uncorrectedInnerRadius + (1 - gap) * (uncorrectedRho)
    // need to account for gap here, too
    //let gapEffectedRho = (1 - gap) * steinerCircle.rho()
    //innerRadius = outerRadius + gapEffectedRho * 2
    return uncorrectedInnerRadius //gapCorrectredInnerRadius
  }
  
  // rho (written as ρ) is the radius of the Steiner-chain circles
  // Given θ and r, the formula for rho (ρ) is: ρ = ( r sin θ )/( 1 − sin θ )
  public func rho() -> CGFloat {
    guard circleCount != 2 else {
      let twoRho = outerRadius/2
      //print("Found Two Rho", twoRho)
      return twoRho
    }
    guard circleCount != 1 else {
      //print("Found One Whole Dude", outerRadius)
      return outerRadius
    }
    let rho = innerRadius() * sineTheta / (1.0 - sineTheta)  // problem when sineTheta is 1 (for two circles)
    if rho > 0 {
      return (1 - gap) * rho // new gap correction, beware complications downstream
    } else {
      return CGFloat.zero
    }
  }
  
  public func centerPoints() -> [CGPoint] {
    let points = Array(repeating: CGPoint.zero, count: circleCount)
    // using direction and gap, compute the center point of each circle and 
    return points
  }
}

extension SteinerCircle : CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    return """
    SteinerCircle circleCount = \(circleCount)
    theta = \(theta), sineTheta = \(sineTheta)
    outerRadius: \(outerRadius), innerRadius: \(innerRadius())
    \(circleCount) circles each with radius rho: \(rho())
    """
  }
  public var debugDescription: String {
    return description
  }
}

/*
 //import SwiftUI  // for Angle
 
 func distanceAndDirection(from pt1: CGPoint, to pt2: CGPoint) -> (distance: CGFloat, angle: Angle) {
 
 let angle = atan((pt1.y-pt2.y) / (pt2.x - pt1.x))
 let length = CGFloat((pt1.y - pt2.y) / sin(angle))
 
 return (length, Angle(radians: Double(angle)))
 }
 */
