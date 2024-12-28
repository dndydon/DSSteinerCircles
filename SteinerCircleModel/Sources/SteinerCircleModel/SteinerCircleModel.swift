import SwiftUI

/// Steiner Chain algorithm. Given count, gap, and overall radius, compute circles
public struct SteinerCircle {
  
  public let outerRadius: CGFloat

  public var circleCount: Int
  
  public var gap: CGFloat
  
  //  The angle 2θ between the centers of the Steiner-chain circles is 360°/n
  //  so, θ = 180/N, theta = Double(180.0 / Double(circleCount)).asRadians
  public var theta: Double // in degrees.  use this to draw the Steiner-chain circles
  
  private var sineTheta: CGFloat   // = CGFloat(Math.sine(degrees: theta))
  
  public var direction: CGFloat? = -90  // this is "up" in SwiftUI

  public init(outerRadius: CGFloat, circleCount: Int, gap: CGFloat = 0.001) {
    self.outerRadius = outerRadius
    self.circleCount = circleCount
    self.direction = -90
    self.theta = Double(180.0 / Double(circleCount)).asRadians
    self.sineTheta = sin(theta) //CGFloat(sin(theta))
    self.gap = gap > 0.001 ? gap : 0.001  // range 0 to 1
    //self.innerRadius = outerRadius - 2 * rho()
    //print(description)
  }
  
//  // Given θ and R, the formula for r is: r = R ( 1 − sin θ )/( 1 + sin θ )
//  public func innerRadius() -> CGFloat {
//    let uncorrectedInnerRadius = outerRadius * ( 1 - sineTheta) / (1 + sineTheta)
//    // account for gap here, too
//    //let uncorrectedRho = uncorrectedInnerRadius * sineTheta / (1.0 - sineTheta)
//    //let gapCorrectredInnerRadius = uncorrectedInnerRadius + (1 - gap) * (uncorrectedRho)
//    //let gapEffectedRho = (1 - gap) * steinerCircle.rho()
//    //innerRadius = outerRadius + gapEffectedRho * 2
//    return uncorrectedInnerRadius //gapCorrectredInnerRadius
//  }

  // Given θ and R, the formula for r is: r = R ( 1 − sin θ )/( 1 + sin θ )
  // new way: Given θ and R, the formula for r is: r = R − 2 * ρ
  public func innerRadius() -> CGFloat {
    // old way: let innerRadius = outerRadius * ( ( 1 - sineTheta) / (1 + sineTheta) )
    let innerRadius = outerRadius - 2 * rho() * (1 - gap)
    return innerRadius
  }

  // rho (written as ρ) is the radius of the Steiner-chain circles
  public func rho() -> CGFloat {
    guard circleCount != 1 else {
      return outerRadius
    }

    // the old way
    // Given θ and r, the formula for rho (ρ) is: ρ = ( r sin θ )/( 1 − sin θ )
    // let rho = innerRadius() * sineTheta / (1.0 - sineTheta)  // problem when sineTheta is 1 (for two circles)

    // given θ and R, the formula for rho (ρ) is:
    // R sin θ / ( 1 + sin θ )
    let rho = outerRadius * sineTheta / (1 + sineTheta)
    if rho > .zero {
      let gapCorrection = (1 + gap) // new gap correction, beware complications downstream
      return rho * gapCorrection
    } else {
      return .zero
    }
  }
  
//  public func centerPoints() -> [CGPoint] {
//    let points = Array(repeating: CGPoint.zero, count: circleCount)
//    // using direction and gap, compute the center point of each circle and 
//    return points
//  }
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
