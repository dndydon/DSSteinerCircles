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
    self.steinerCircle = SteinerCircle(outerRadius: 1, circleCount: count)
  }
  
  public func rho() -> CGFloat {
    //let circleSet = SteinerCircle(outerRadius: 1, circleCount: count)
    // print("\(String(describing: circleSet))")
    let gapEffectedRho = (1 - gap) * steinerCircle.rho()
    return gapEffectedRho
  }

  /// took this out in favor of Dial algorithm
//  var drag: some Gesture {
//    DragGesture()
//      .onChanged { (value) in
//        self.isDragging = true
//        self.rotationAngle = dragToRotation(value: value,
//                                            around: CGPoint(x: 250, y: 250)) // TODO: fix
//    }
//    .onEnded { _ in
//      self.isDragging = false
//      self.animate = false
//    }
//  }
  
  var body: some View {
    ZStack {

      Circle() // innerCircle
        .inset(by: -thickness/2)
        .stroke(style: StrokeStyle(lineWidth: thickness))
        .scaleEffect(steinerCircle.innerRadius(), anchor: UnitPoint(x: 0.50, y: 0.50))
        .foregroundColor(Color(.yellow).opacity(0.3))

      // Dial circular rotation algorithm -- one finger or cursor
      // make this a protocol?
      Dial(value: $rotationAngle)
        .opacity(0.75)
//        .frame(width: 370)
//        .padding(.all, 24)

//      Circle()  // enclosing circle (migrate to Dial() )
//        .foregroundColor(.blue.opacity(0.3))
//        .gesture(TapGesture()
//          .onEnded {_ in
//            self.animate = true // ToDo:  This does not reset to false after rotation finishes
//            self.rotationAngle = 0.0
//        })

//      let anchorPt = UnitPoint(x: 0.50, y: self.count == 1 ? 0.5 : 0.0 )
//      Pointer(anchor: anchorPt)
//        .rotationEffect(Angle.degrees(self.rotationAngle), anchor: .center)
//        .animation(self.animate ? .default : .none)
//        .scaleEffect(steinerCircle.innerRadius(), anchor: UnitPoint(x: 0.50, y: 0.50))
      
      ForEach(1...count, id: \.self) { idx in
        CircleLabeled(label: String(idx))
          .scaleEffect(self.rho(), anchor: UnitPoint(x: 0.50, y: self.count == 1 ? 0.5 : 0.0 ))
          .rotationEffect(.degrees(self.rotationAngle + 360/Double(self.count) * Double(idx)))
          .animation(self.animate ? .default : .none) // should reset to false/.none after zeroed
      }
      
      Circle() // border
        .inset(by: -thickness/2)
        .stroke(style: StrokeStyle(lineWidth: thickness))

    }
//    .gesture(drag)
  }
}

//struct Pointer: View {
//
//  var anchor: UnitPoint
//
//  var body: some View {
//    ZStack {
//      VStack {
//        Rectangle() // pointer
//          .stroke(lineWidth: 7.0)
//          .foregroundColor(Color(.yellow).opacity(0.3))
//          //.fill(Color(.yellow).opacity(0.3))
//          //.opacity(0.7)
//          //.frame(width: 1, height: 250, alignment: .top)
//          .frame(width: 1, height: 250)
//        //.scaleEffect(x: 0.015, y: 0.5, anchor: .top)
//        Spacer()
//      }
//
//      Circle()  // center point
//        .scale(0.011)
//    }
//  }
//}

struct CircleRing_Previews: PreviewProvider {
  static var previews: some View {
    CircleRing()
      .scaleEffect(0.96)
  }
}
