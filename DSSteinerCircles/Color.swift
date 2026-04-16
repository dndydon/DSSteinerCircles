//
//  Color.swift
//  DSSteinerCircles
//
//  Created by Don Sleeter on 3/20/25.
//

/// Map an integer index to a hue-based color for consistent rainbow coloring.
/// Colors are evenly spaced around the hue wheel based on `total`.

import SwiftUI

public func colorForValue(_ value: Int, of total: Int) -> Color {
    let colors: [Color] = {
        let hueValues = Array(0...total)
        return hueValues.map {
            Color(hue: CGFloat(Double($0) / Double(total)),
                  saturation: 0.85,
                  brightness: 0.75,
                  opacity: 1.00)
        }
    }()
    let clampedValue = max(0, min(value, colors.count - 1))
    return colors[clampedValue]
}
