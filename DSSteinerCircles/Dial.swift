//
//  Dial.swift
//  DSSteinerCircles
//
//  Created by Don Sleeter on 6/2/23.
//  Copyright: https://gist.github.com/ts95/9f8e05380824c6ca999ab3bc1ff8541f

/// Rotatable dial view with a machined metallic gradient.
/// Drag to rotate; the bound `value` tracks cumulative degrees.
/// Uses frame-to-frame angle deltas to avoid atan2 discontinuity jumps.

import SwiftUI

struct Dial: View {

    @Binding public var value: Double
    public var innerRadius: Double
    public var thickness: CGFloat

    /// Previous frame's angle during a drag, used to compute small deltas.
    @State private var previousAngle: Angle?

    /// Machined metallic look via angular gradient.
    var metallicGradient: AngularGradient {
        let spectrum = [
            Color.black.mix(with: .gray, by: 0.2),
            Color.gray,
            Color.white.mix(with: .gray, by: 0.2),
            Color.gray,
            Color.black.mix(with: .gray, by: 0.2),
            Color.gray,
            Color.white.mix(with: .gray, by: 0.2),
            Color.gray,
            Color.black.mix(with: .gray, by: 0.2)
        ]
        return AngularGradient(
            gradient: Gradient(colors: spectrum),
            center: .center,
            angle: .degrees(45)
        )
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .fill(metallicGradient)
                    .opacity(0.8)
                    .rotationEffect(.init(degrees: 45), anchor: .center)
                    .shadow(color: .gray, radius: 4)

                Circle()
                    .inset(by: thickness)
                    .fill(metallicGradient)
                    .opacity(0.3)
                    .scaleEffect(innerRadius, anchor: .center)
            }
            .rotationEffect(.degrees(value))
            .gesture(rotationDragGesture(geometry: geometry))
        }
    }

    /// Drag gesture that accumulates angle deltas frame-to-frame,
    /// normalizing to [-180, 180] to avoid the atan2 wrap-around spike.
    private func rotationDragGesture(geometry: GeometryProxy) -> some Gesture {
        let frame = geometry.frame(in: .local)
        let center = CGPoint(x: frame.midX, y: frame.midY)
        return DragGesture()
            .onChanged { dragValue in
                let currentAngle = angle(of: dragValue.location, around: center)
                if let prev = previousAngle {
                    var delta = (currentAngle - prev).degrees
                    if delta > 180 { delta -= 360 }
                    if delta < -180 { delta += 360 }
                    value += delta
                }
                previousAngle = currentAngle
            }
            .onEnded { _ in
                previousAngle = nil
            }
    }

    private func angle(of point: CGPoint, around center: CGPoint) -> Angle {
        Angle(radians: Double(atan2(point.y - center.y, point.x - center.x)))
    }
}

#Preview {
    Dial(value: .constant(50), innerRadius: 0.97, thickness: 5.0)
        .frame(width: 350)
        .padding(.all, 24)
}
