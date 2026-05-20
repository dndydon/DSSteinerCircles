//
//  ShapeView.swift
//  DSSteinerCircles
//
//  Ported from DSRadialLayout (iOS).
//

import SwiftUI

enum ShapeKind: String, CaseIterable, Identifiable, Codable {
  case circle
  case roundedRectangle
  case star
  case diamond
  case pentagon
  case heart
  case shield

  var id: String { rawValue }

  var displayName: String {
    switch self {
      case .circle:           return "Circle"
      case .roundedRectangle: return "Rounded Rect"
      case .star:             return "Star"
      case .diamond:          return "Diamond"
      case .pentagon:         return "Pentagon"
      case .heart:            return "Heart"
      case .shield:           return "Shield"
    }
  }
}

// MARK: - ShapeView

/// Renders the selected shape kind, scaling proportionally to its frame.
struct ShapeView: View {
  let shapeKind: ShapeKind

  var body: some View {
    switch shapeKind {
      case .circle:
        Circle()
      case .roundedRectangle:
        GeometryReader { proxy in
          let r = min(proxy.size.width, proxy.size.height) * 0.25
          RoundedRectangle(cornerRadius: r, style: .continuous)
        }
      case .star:
        StarShape()
      case .diamond:
        DiamondShape()
      case .pentagon:
        PentagonShape()
      case .heart:
        HeartShape()
      case .shield:
        ShieldShape()
    }
  }
}

// MARK: - Custom Shapes

struct StarShape: Shape {
  func path(in rect: CGRect) -> Path {
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let outerRadius = min(rect.width, rect.height) / 2
    let innerRadius = outerRadius * 0.4
    let points = 5

    var path = Path()
    for i in 0..<(points * 2) {
      let angle = Angle.degrees(Double(i) * 360.0 / Double(points * 2) - 90)
      let r = i.isMultiple(of: 2) ? outerRadius : innerRadius
      let pt = CGPoint(
        x: center.x + r * cos(angle.radians),
        y: center.y + r * sin(angle.radians)
      )
      if i == 0 {
        path.move(to: pt)
      } else {
        path.addLine(to: pt)
      }
    }
    path.closeSubpath()
    return path
  }
}

struct DiamondShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.midX, y: 0))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
    path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
    path.addLine(to: CGPoint(x: 0, y: rect.midY))
    path.closeSubpath()
    return path
  }
}

struct PentagonShape: Shape {
  func path(in rect: CGRect) -> Path {
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let radius = min(rect.width, rect.height) / 2
    let sides = 5

    var path = Path()
    for i in 0..<sides {
      let angle = Angle.degrees(Double(i) * 360.0 / Double(sides) - 90)
      let pt = CGPoint(
        x: center.x + radius * cos(angle.radians),
        y: center.y + radius * sin(angle.radians)
      )
      if i == 0 {
        path.move(to: pt)
      } else {
        path.addLine(to: pt)
      }
    }
    path.closeSubpath()
    return path
  }
}

struct HeartShape: Shape {
  func path(in rect: CGRect) -> Path {
    let w = rect.width
    let h = rect.height

    var path = Path()
    path.move(to: CGPoint(x: w / 2, y: h * 0.25))

    path.addCurve(
      to: CGPoint(x: 0, y: h * 0.25),
      control1: CGPoint(x: w * 0.4, y: 0),
      control2: CGPoint(x: 0, y: 0)
    )
    path.addCurve(
      to: CGPoint(x: w / 2, y: h),
      control1: CGPoint(x: 0, y: h * 0.55),
      control2: CGPoint(x: w / 2, y: h * 0.7)
    )

    path.addCurve(
      to: CGPoint(x: w, y: h * 0.25),
      control1: CGPoint(x: w / 2, y: h * 0.7),
      control2: CGPoint(x: w, y: h * 0.55)
    )
    path.addCurve(
      to: CGPoint(x: w / 2, y: h * 0.25),
      control1: CGPoint(x: w, y: 0),
      control2: CGPoint(x: w * 0.6, y: 0)
    )
    path.closeSubpath()
    return path
  }
}

struct ShieldShape: Shape {
  func path(in rect: CGRect) -> Path {
    let w = rect.width
    let h = rect.height

    var path = Path()
    path.move(to: CGPoint(x: w / 2, y: 0))
    path.addLine(to: CGPoint(x: w, y: h * 0.1))
    path.addLine(to: CGPoint(x: w, y: h * 0.55))
    path.addCurve(
      to: CGPoint(x: w / 2, y: h),
      control1: CGPoint(x: w, y: h * 0.8),
      control2: CGPoint(x: w * 0.65, y: h * 0.95)
    )
    path.addCurve(
      to: CGPoint(x: 0, y: h * 0.55),
      control1: CGPoint(x: w * 0.35, y: h * 0.95),
      control2: CGPoint(x: 0, y: h * 0.8)
    )
    path.addLine(to: CGPoint(x: 0, y: h * 0.1))
    path.closeSubpath()
    return path
  }
}

#Preview {
  @Previewable @State var shapeKind: ShapeKind = .circle

  ShapeView(shapeKind: shapeKind)
    .frame(width: 380, height: 380)
    .foregroundStyle(Color.secondary)
    .padding(10)
    .safeAreaInset(edge: .bottom) {
      Picker("Shape", selection: $shapeKind) {
        ForEach(ShapeKind.allCases) { shapeCase in
          Text(shapeCase.displayName).tag(shapeCase)
        }
      }
      .pickerStyle(.segmented)
    }
}
