//
//  Color.swift
//  DSRadialLayout
//
//  Created by Don Sleeter on 3/20/25.
//

import SwiftUI

/// Create an array of colors and return the right one
/// - Parameters:
///   - value: given a value
///   - total: and the total count
/// - Returns: return a Color (from the array of colors)
///
public func colorForValue(_ value: Int, of total: Int) -> Color {
  let colors: [Color] = {
    let hueValues = Array(0...total)
    return hueValues.map {
      Color(hue: CGFloat(Double($0) / Double(total)) ,
            saturation: 0.85,
            brightness: 0.75,
            opacity: 1.00 )
    }
  }()
  return colors[value]
}
