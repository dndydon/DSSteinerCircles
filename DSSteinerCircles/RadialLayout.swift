//
//  RadialLayout.swift
//  DSSteinerCircles
//
//  Ported from DSRadialLayout (iOS).
//

import SwiftUI
import SteinerCircleModel

/// Custom SwiftUI Layout that arranges subviews in a circular formation
/// using Steiner circle geometry for precise sizing and positioning.
struct RadialLayout: Layout {

  var steinerCircle: SteinerCircle

  var radius: CGFloat

  init(steinerCircle: SteinerCircle) {
    self.steinerCircle = steinerCircle
    self.radius = steinerCircle.outerRadius
  }

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
    proposal.replacingUnspecifiedDimensions(by: .init(width: radius * 2, height: radius * 2))
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
    let radius = min(bounds.size.width, bounds.size.height) / 2
    let angleStep = Angle.degrees(360).radians / Double(subviews.count)
    let rho = steinerCircle.rho
    let subviewSize = CGSize(width: rho * 2, height: rho * 2)

    for (index, subview) in subviews.enumerated() {
      let subviewAngle = angleStep * Double(index) - .pi / 2.0
      let xPos = cos(subviewAngle) * (radius - subviewSize.width / 2.0)
      let yPos = sin(subviewAngle) * (radius - subviewSize.height / 2.0)
      let point = CGPoint(x: bounds.midX + xPos, y: bounds.midY + yPos)

      subview.place(
        at: point,
        anchor: .center,
        proposal: .init(subviewSize)
      )
    }
  }
}
