//
//  Dial.swift
//  DSSteinerCircles
//
//  Created by Don Sleeter on 6/2/23.
//  Copyright: https://gist.github.com/ts95/9f8e05380824c6ca999ab3bc1ff8541f

/// Rotatable dial view with a machined metallic gradient.
/// Drag to rotate. Uses frame-to-frame angle deltas to avoid
/// atan2 discontinuity jumps.

import SwiftUI

struct Dial: View {

  @Binding var rotation: Double
  var innerRadius: Double
  var thickness: CGFloat

  @State private var previousAngle: Angle?

  private static let gradient: AngularGradient = {
    let spectrum = [
      Color.black.mix(with: .gray, by: 0.42),
      Color.gray,
      Color.white.mix(with: .gray, by: 0.42),
      Color.gray,
      Color.black.mix(with: .gray, by: 0.42),
      Color.gray,
      Color.white.mix(with: .gray, by: 0.42),
      Color.gray,
      Color.black.mix(with: .gray, by: 0.42),
    ]
    return AngularGradient(
      gradient: Gradient(colors: spectrum),
      center: .center,
      angle: .degrees(90)
    )
  }()

  var body: some View {
    GeometryReader { geometry in
      let center = CGPoint(x: geometry.size.width / 2,
                           y: geometry.size.height / 2)

      ZStack {
        Circle()
          .fill(Self.gradient)
          .shadow(color: .gray, radius: 4)

        Circle()
          .fill(Self.gradient)
          .scaleEffect(innerRadius)
          .opacity(0.4)
      }
      .rotationEffect(.degrees(rotation))
      .gesture(
        DragGesture()
          .onChanged { drag in
            let current = angle(of: drag.location, around: center)
            if let prev = previousAngle {
              var delta = (current - prev).degrees
              if delta > 180 { delta -= 360 }
              if delta < -180 { delta += 360 }
              rotation += delta
            }
            previousAngle = current
          }
          .onEnded { _ in
            previousAngle = nil
          }
      )
    }
  }

  private func angle(of point: CGPoint, around center: CGPoint) -> Angle {
    Angle(radians: atan2(point.y - center.y, point.x - center.x))
  }
}

#Preview {
  Dial(
    rotation: .constant(45),
    innerRadius: 0.97,
    thickness: 5.0
  )
  .frame(width: 350)
  .padding(.all, 24)
}
