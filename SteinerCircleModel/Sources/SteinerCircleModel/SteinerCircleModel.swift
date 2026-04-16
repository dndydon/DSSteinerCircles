import SwiftUI

/// Steiner Chain algorithm. Given count, gap, and overall radius, compute circles.
/// θ = 180°/N (half the angular spacing between adjacent circle centers).
/// ρ = R sin θ / (1 + sin θ) — radius of each chain circle.
/// r = R − 2ρ(1 − gap) — inner circle radius.
public struct SteinerCircle {

  public let outerRadius: CGFloat
  public var circleCount: Int
  public var gap: CGFloat
  public var theta: Double
  public var direction: CGFloat? = -90

  private var sineTheta: CGFloat

  public init(outerRadius: CGFloat, circleCount: Int, gap: CGFloat = 0.001) {
    self.outerRadius = outerRadius
    self.circleCount = circleCount
    self.direction = -90
    self.theta = Double(180.0 / Double(circleCount)).asRadians
    self.sineTheta = sin(theta)
    self.gap = max(gap, 0.001)
  }

  /// Inner circle radius: r = R − 2ρ(1 − gap)
  public func innerRadius() -> CGFloat {
    outerRadius - 2 * rho() * (1 - gap)
  }

  /// Radius of each Steiner chain circle: ρ = R sin θ / (1 + sin θ)
  public func rho() -> CGFloat {
    guard circleCount != 1 else { return outerRadius }
    let rho = outerRadius * sineTheta / (1 + sineTheta)
    guard rho > .zero else { return .zero }
    return rho * (1 + gap)
  }
}

extension SteinerCircle: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    """
    SteinerCircle circleCount = \(circleCount)
    theta = \(theta), sineTheta = \(sineTheta)
    outerRadius: \(outerRadius), innerRadius: \(innerRadius())
    \(circleCount) circles each with radius rho: \(rho())
    """
  }
  public var debugDescription: String { description }
}
