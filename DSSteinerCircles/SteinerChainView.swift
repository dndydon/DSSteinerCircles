//
//  SteinerChainView.swift
//  DSSteinerCircles
//
//  Created by Don Sleeter on 4/16/26.
//  Copyright © 2026 Don Sleeter. All rights reserved.
//

/// **Canvas-based Steiner chain rendering.**
///
/// This view demonstrates the *direct drawing* approach to rendering a
/// Steiner chain using `SteinerCircle.chainCircles`, which provides
/// pre-computed center points and radii for each chain circle.
///
/// ## Two rendering strategies
///
/// The `SteinerCircleModel` package supports two ways to draw a chain:
///
/// ### 1. Canvas / Direct Drawing (this view)
///
/// Uses `SteinerCircle.chainCircles` — an array of positioned circles
/// with absolute `center` and `radius` values.
///
/// **Pros:**
/// - Simple, minimal code — just iterate and draw
/// - High performance — single `Canvas` draw pass, no view diffing
/// - Good for static or high-count visualizations (hundreds/thousands)
/// - Works well with CoreGraphics, Metal, or any drawing API
///
/// **Cons:**
/// - No built-in interactivity (tap, selection, accessibility)
/// - Labels and hit-testing require manual geometry math
/// - No SwiftUI animation or transition support
///
/// ### 2. SwiftUI View Composition (`CircleRing`)
///
/// Uses `SteinerCircle.rho` and `SteinerCircle.innerRadius` to size
/// child views, positioned via `rotationEffect` and `scaleEffect`.
///
/// **Pros:**
/// - Full SwiftUI interactivity (tap gestures, selection state)
/// - Labels, accessibility, and animations come naturally
/// - Supports recursive hierarchy (nested sub-rings via prime factors)
/// - Each circle is an independent view with its own state
///
/// **Cons:**
/// - Higher overhead — SwiftUI creates and diffs a view per circle
/// - Performance degrades with very high counts (use `.drawingGroup()`)
/// - Positioning via transforms is less intuitive than absolute coordinates

import SwiftUI
import SteinerCircleModel

struct SteinerChainView: View {
  var circleCount: Int = 8
  var gap: Double = 0.05
  var thickness: CGFloat = 0.5

  var body: some View {
    Canvas { context, size in
      let outerRadius = min(size.width, size.height) / 2 * 0.95
      let chain = SteinerCircle(outerRadius: outerRadius, circleCount: circleCount, gap: gap)
      let center = CGPoint(x: size.width / 2, y: size.height / 2)

      // Outer circle
      let outerRect = CGRect(
        x: center.x - chain.outerRadius,
        y: center.y - chain.outerRadius,
        width: chain.outerRadius * 2,
        height: chain.outerRadius * 2
      )
      context.stroke(Path(ellipseIn: outerRect), with: .color(.gray), lineWidth: thickness)

      // Inner circle
      let innerRect = CGRect(
        x: center.x - chain.innerRadius,
        y: center.y - chain.innerRadius,
        width: chain.innerRadius * 2,
        height: chain.innerRadius * 2
      )
      context.stroke(Path(ellipseIn: innerRect), with: .color(.yellow.opacity(0.75)), lineWidth: thickness)

      // Chain circles with hue coloring
      for (i, circle) in chain.chainCircles.enumerated() {
        let rect = CGRect(
          x: center.x + circle.center.x - circle.radius,
          y: center.y + circle.center.y - circle.radius,
          width: circle.radius * 2,
          height: circle.radius * 2
        )
        let hue = Double(i + 1) / Double(circleCount)
        let color = Color(hue: hue, saturation: 0.85, brightness: 0.75)
        context.fill(Path(ellipseIn: rect), with: .color(color.opacity(0.6)))
        context.stroke(Path(ellipseIn: rect), with: .color(color), lineWidth: thickness)
      }
    }
  }
}

#Preview("Canvas — 8 circles") {
  SteinerChainView()
    .frame(width: 350, height: 350)
}

#Preview("Canvas — 20 circles") {
  SteinerChainView(circleCount: 20, gap: 0.02, thickness: 0.5)
    .frame(width: 350, height: 350)
}
