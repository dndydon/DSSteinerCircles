//
//  Gauge.swift
//  DSGaugeView
//
//  Created by Don Sleeter on 3/8/20.
//  Copyright © 2020 Don Sleeter. All rights reserved.
//

import SwiftUI
import SteinerCircleModel

struct CircleRing: View {

  @State private var animate = false
  @State private var isDragging = false
  @State private var rotationAngle = 0.0

  var count: Int
  var thickness: CGFloat
  var gap: CGFloat
  var steinerCircle: SteinerCircle

  internal init(count: Int = 6, thickness: CGFloat = 6.5, gap: CGFloat = 0.00) {
    self.count = count
    self.thickness = thickness
    self.gap = gap
    self.steinerCircle = SteinerCircle(outerRadius: 1, circleCount: count, gap: gap)
  }

  public func rho() -> CGFloat {
    let gapEffectedRho = (1 - gap) * steinerCircle.rho()
    //print("gapEffected vs. regular Rho: ", gapEffectedRho, steinerCircle.rho())
    return gapEffectedRho
  }

  var body: some View {
    ZStack(alignment: .center) {

      Circle() // innerCircle
        .inset(by: -thickness/2)
        .stroke(style: StrokeStyle(lineWidth: thickness))
        .scaleEffect(steinerCircle.innerRadius(), anchor: UnitPoint(x: 0.50, y: 0.50))
        .foregroundColor(Color(.yellow).opacity(0.75))

      // Dial circular rotation algorithm -- one finger or cursor rotates it
      // make this a protocol?
      Dial(value: $rotationAngle, innerRadius: steinerCircle.innerRadius())
          .opacity(0.75)
          .aspectRatio(1.0, contentMode: .fit)
          //.onTapGesture(count: 2, perform: clearSelection)

      ForEach(1...count, id: \.self) { idx in
        CircleLabeled(label: String(idx))
          .scaleEffect(self.rho(), anchor: UnitPoint(x: 0.50, y: self.count == 1 ? 0.5 : 0.0 ))
          .rotationEffect(.degrees(self.rotationAngle + 360/Double(self.count) * Double(idx)))
          .animation(self.animate ? .default : .none) // should reset to false/.none after zeroed
      }

      Circle() // outer border
        .inset(by: -thickness/2)
        .stroke(style: StrokeStyle(lineWidth: thickness))

    }
  }
}


struct CircleRing_Previews: PreviewProvider {
  static var previews: some View {
    CircleRing()
      .scaleEffect(0.96)
  }
}
