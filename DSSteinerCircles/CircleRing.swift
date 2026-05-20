  //
  //  CircleRing.swift
  //  DSSteinerCircles
  //
  //  Created by Don Sleeter on 3/8/20.
  //  Copyright © 2020 Don Sleeter. All rights reserved.
  //

  /// Recursive view that renders a Steiner circle ring using `RadialLayout`.
  ///
  /// At `depth == 0` (root), it shows the toggle, dial, and outer border.
  /// When the ring is hierarchical, it recurses into child `CircleRing`s;
  /// otherwise it renders leaf shapes via `ShapeView`.
  ///
  /// `parentRotation` accumulates rotation from all ancestor rings so that
  /// leaf labels can counter-rotate to stay upright.

import SwiftUI
import SteinerCircleModel

struct CircleRing: View {

  var ring: SteinerRingModel
  var shapeKind: ShapeKind = .circle
  var pointingDirection: PointingDirection = .fixedNorth
  var showChrome: Bool = true
  var depth: Int = 0
  var parentRotation: Angle = .zero

  private let maxViewableCount = 100

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

      GeometryReader { proxy in
        let size = proxy.size
        let radius = min(size.width, size.height) / 2
        let sc = SteinerCircle(outerRadius: radius,
                               circleCount: ring.displayCount,
                               gap: ring.gap)

        ZStack(alignment: .center) {
          // Inner circle stroke
          Circle()
            .inset(by: ring.thickness / 2)
            .stroke(style: StrokeStyle(lineWidth: ring.thickness))
            .frame(width: sc.innerRadius * 2, height: sc.innerRadius * 2)
            .foregroundColor(Color(.yellow).opacity(0.75))

          // Rotatable dial (root only)
          if depth == 0 {
            Dial(rotation: Bindable(ring).rotationAngle,
                 innerRadius: sc.innerRadius / radius,
                 thickness: ring.thickness)
            .opacity(showChrome ? 0.65 : 0)
            .allowsHitTesting(showChrome)
            .aspectRatio(1.0, contentMode: .fit)
            .onTapGesture(count: 2) {
              ring.resetRotation()
            }
            .onTapGesture(count: 1) {
              ring.stopPlayback()
            }
          }

          // Laid-out content
          RadialLayout(steinerCircle: sc) {
            if ring.isHierarchical {
              ForEach(Array(ring.children.enumerated()), id: \.element.id) { idx, child in
                let groupRotation = rotationAngle(for: pointingDirection, index: idx, total: ring.displayCount)
                let dialRotation = Angle.degrees(ring.rotationAngle)
                CircleRing(
                  ring: child,
                  shapeKind: shapeKind,
                  pointingDirection: pointingDirection,
                  depth: depth + 1,
                  parentRotation: parentRotation + groupRotation + dialRotation
                )
                .rotationEffect(groupRotation)
              }
            } else {
              ForEach(ring.leaves) { leaf in
                let idx = leaf.index - ring.startIndex
                leafView(leaf: leaf, index: idx, total: ring.displayCount, cSize: sc.rho * 2)
              }
            }
          }
          .rotationEffect(.degrees(ring.rotationAngle))

          // Outer border stroke
          Circle()
            .stroke(style: StrokeStyle(lineWidth: ring.thickness))

          // Large count label when too many to render individually
          if !ring.isHierarchical && ring.count > maxViewableCount {
            Text("\(ring.count)")
              .font(.title)
          }
        }
      }
      .drawingGroup()
    }
  }

  // MARK: - Leaf View

  @ViewBuilder
  private func leafView(leaf: LeafModel, index: Int, total: Int, cSize: CGFloat) -> some View {
    let shapeRotation = rotationAngle(for: pointingDirection, index: index, total: total)
    let dialRotation = Angle.degrees(ring.rotationAngle)
    let totalRotation = parentRotation + shapeRotation + dialRotation

    ShapeView(shapeKind: shapeKind)
      .foregroundColor(leaf.selected ? leaf.selectedColor : leaf.fillColor)
      .shadow(radius: leaf.selected ? 30 : 0)
      .overlay(
        leaf.selected ? Color.yellow : Color.clear,
        in: Circle().inset(by: 1).stroke(style: StrokeStyle(lineWidth: 2))
      )
      .overlay(
        leaf.selected && total <= maxViewableCount ?
        Text(leaf.label)
          .font(.system(size: cSize / 1.6, weight: .semibold))
          .foregroundColor(.primary)
          .rotationEffect(-totalRotation) : nil
      )
      .rotationEffect(shapeRotation)
      .onTapGesture {
        leaf.toggleSelection()
      }
  }

  // MARK: - Rotation

  private func rotationAngle(for direction: PointingDirection, index: Int, total: Int) -> Angle {
    switch direction {
      case .fixedNorth:
        return .zero
      case .radially:
        let angleStep = Angle.degrees(360).radians / Double(max(total, 1))
        let subviewAngle = angleStep * Double(index)
        return .radians(subviewAngle)
    }
  }
}

#Preview {
  CircleRing(ring: SteinerRingModel(count: 12, gap: 0.050, thickness: 1))
    .frame(width: 400, height: 400)
}
