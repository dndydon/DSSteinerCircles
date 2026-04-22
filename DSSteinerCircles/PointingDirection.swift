//
//  PointingDirection.swift
//  DSSteinerCircles
//
//  Ported from DSRadialLayout (iOS).
//

import Foundation

enum PointingDirection: String, Identifiable, CaseIterable, Codable {
  case fixedNorth, radially

  var id: String { rawValue }

  var displayName: String {
    switch self {
      case .fixedNorth: "Fixed North"
      case .radially:   "Radial"
    }
  }
}
