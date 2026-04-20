  //
  //  CircleRing.swift
  //  DSSteinerCircles
  //
  //  Created by Don Sleeter on 3/8/20.
  //  Copyright © 2020 Don Sleeter. All rights reserved.
  //

  /// Recursive view that renders a Steiner circle ring.
  ///
  /// At `depth == 0` (root), it shows the toggle, dial, and outer border.
  /// When the ring is hierarchical, it recurses into child `CircleRing`s;
  /// otherwise it renders `CircleLabeled` leaves.
  ///
  /// `parentRotation` accumulates rotation from all ancestor rings so that
  /// leaf labels can counter-rotate to stay upright.

import SwiftUI

struct CircleRing: View {

  var ring: SteinerRingModel
  var depth: Int = 0
  var parentRotation: Double = 0.0

    /// Scale factor for leaves/children relative to this ring's size.
  private var normalizedRho: CGFloat {
    guard ring.outerRadius > 0 else { return 0 }
    return ring.rho / ring.outerRadius
  }

    /// Inner circle radius as a fraction of this ring's size.
  private var normalizedInnerRadius: CGFloat {
    guard ring.outerRadius > 0 else { return 0 }
    return ring.innerRadius / ring.outerRadius
  }

  var body: some View {
    ZStack(alignment: .topLeading) {
        // Show toggles only at the root level
      if depth == 0 {
        VStack(alignment: .leading) {
          Toggle(isOn: Binding(
            get: { ring.showPrimes },
            set: { _ in ring.toggleShowPrimes() }
          )) {
            let factors = String(describing: ring.factors)
            let biggest = ring.collapsedFactors.first ?? ring.count
            let remainder = ring.count / biggest
            VStack(alignment: .leading) {
              Text("Show factors:")
              Text("\(factors)")
              Text("\(ring.count) = \(biggest) x \(remainder)")
                .font(.headline)
            }
          }
        }
        .zIndex(1)
      }

      ZStack(alignment: .center) {

          // Inner circle stroke
        Circle()
          .inset(by: ring.thickness / 2)
          .stroke(style: StrokeStyle(lineWidth: ring.thickness))
          .scaleEffect(normalizedInnerRadius, anchor: UnitPoint(x: 0.50, y: 0.50))
          .foregroundColor(Color(.yellow).opacity(0.75))

          // Rotatable dial (root only)
        if depth == 0 {
          Dial(rotation: Bindable(ring).rotationAngle,
               innerRadius: normalizedInnerRadius,
               thickness: ring.thickness)
          .opacity(0.65)
          .aspectRatio(1.0, contentMode: .fit)
          .onTapGesture(count: 2) {
            ring.resetRotation()
          }
          .onTapGesture(count: 1) {
            ring.stopPlayback()
          }
        }

        if ring.isHierarchical {
            // Hierarchical: place child rings around this ring
          ForEach(Array(ring.children.enumerated()), id: \.element.id) { idx, child in
            let direction = ring.rotationAngle + 360 / Double(ring.displayCount) * Double(idx)
            CircleRing(ring: child, depth: depth + 1, parentRotation: parentRotation + direction)
              .scaleEffect(normalizedRho,
                           anchor: UnitPoint(x: 0.50, y: ring.displayCount == 1 ? 0.5 : 0.0))
              .rotationEffect(.degrees(direction))
          }
        } else {
            // Flat: place leaf circles around this ring
          ForEach(ring.leaves) { leaf in
            let direction = ring.rotationAngle + 360 / Double(ring.displayCount) * Double(leaf.index - ring.startIndex)
            let totalRotation = parentRotation + direction
            CircleLabeled(leaf: leaf, rotation: -totalRotation, showLabels: ring.totalCount <= 100)
              .scaleEffect(normalizedRho,
                           anchor: UnitPoint(x: 0.50, y: ring.displayCount == 1 ? 0.5 : 0.0))
              .rotationEffect(.degrees(direction))
          }
        }

          // Outer border stroke
        Circle()
          .stroke(style: StrokeStyle(lineWidth: ring.thickness))

      }
      .drawingGroup()
    }
  }
}

#Preview {
  CircleRing(ring: SteinerRingModel(count: 12, gap: 0.050, thickness: 1))
    .scaleEffect(0.96)
    .frame(width: 400, height: 400)
}
