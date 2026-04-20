//
//  Color.swift
//  DSSteinerCircles
//
//  Created by Don Sleeter on 3/20/25.
//

/// Map an integer index to a hue-based color for consistent rainbow coloring.
/// Colors are evenly spaced around the hue wheel based on `total`.

import SwiftUI

func colorForValue(_ value: Int, of total: Int) -> Color {
  let clamped = max(0, min(value, total))
  let hue = total > 0 ? Double(clamped) / Double(total) : 0
  return Color(hue: hue, saturation: 0.85, brightness: 0.75)
}
