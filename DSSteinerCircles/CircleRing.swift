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

  @State private var rotationAngle = 0.0
  @State private var showPrimes: Bool = false

  var count: Int
  var thickness: CGFloat
  var gap: CGFloat
  var steinerCircle: SteinerCircle
  let factors: [Int]  // need a type for this to be safe:
                      // no more than 32 elements -> 4.294967296G maximum
                      // uses SIMD or Accelerate Framework for Primes and factorization
                      //@State private var tree: [LeafModel]

  internal init(count: Int = 6,
                thickness: CGFloat = 6.5,
                gap: CGFloat = 0.00,
                showPrimes: Bool = false) {
    self.count = count
    self.thickness = thickness
    self.gap = gap
    self.steinerCircle = SteinerCircle(outerRadius: 1, circleCount: count, gap: gap)
    self.factors = count.primeFactors.reversed().map { $0 }
    self.showPrimes = showPrimes
      //self.tree = [LeafModel]()

  }

  public func rho() -> CGFloat {
    let gapEffectedRho = (1 - gap) * steinerCircle.rho()
      //print("gapEffected vs. regular Rho: ", gapEffectedRho, steinerCircle.rho())
    return gapEffectedRho
  }

  private func resetSelectionAndRotation() {
    withAnimation(.spring) {
        // figure out resetting selection here
      print("rotationAngle:", rotationAngle)
      rotationAngle = 0.0
    }
//    for radians in stride(from: 0.0, to: .pi * 2, by: .pi / 2) {
//      let degrees = Int(radians * 180 / .pi)
//      print("Degrees: \(degrees), radians: \(radians)")
//    }
//      // Degrees: 0, radians: 0.0
//      // Degrees: 90, radians: 1.5707963267949
//      // Degrees: 180, radians: 3.14159265358979
//      // Degrees: 270, radians: 4.71238898038469

  }

  var body: some View {
    ZStack(alignment: .topLeading) {
      Toggle(isOn: $showPrimes) {
        let biggest = Int(factors.first!)
        let remainder = count/biggest
        Text("Show: \(biggest) x \(remainder)")
          .font(.headline)
      }

      ZStack(alignment: .center) {

        Circle() // innerCircle
          .inset(by: thickness/2)
          .stroke(style: StrokeStyle(lineWidth: thickness))
          .scaleEffect(steinerCircle.innerRadius(), anchor: UnitPoint(x: 0.50, y: 0.50))
          .foregroundColor(Color(.yellow).opacity(0.75))

          // Dial circular rotation algorithm -- one finger or cursor rotates it
          // make this a protocol?
        Dial(value: $rotationAngle, innerRadius: steinerCircle.innerRadius(), thickness: thickness)
          .opacity(0.5)
          .aspectRatio(1.0, contentMode: .fit)
          .onTapGesture(count: 2) {
            resetSelectionAndRotation()
          }

        ForEach(1...count, id: \.self) { idx in
          let label = String(idx)
          CircleLabeled(label: label, color: colorForValue(idx, of: count))
            .scaleEffect(self.rho(), anchor: UnitPoint(x: 0.50, y: self.count == 1 ? 0.5 : 0.0 ))
            .rotationEffect(.degrees(self.rotationAngle + 360/Double(self.count) * Double(idx)))
        }

        Circle() // outer border
          .inset(by: -thickness/2)
          .stroke(style: StrokeStyle(lineWidth: thickness))

      }
    }
  }
}


struct CircleRing_Previews: PreviewProvider {
  static var previews: some View {
    CircleRing(count: 12, thickness: 1, gap: 0.20)
      .scaleEffect(0.96)
      .frame(width: 400)
  }
}
