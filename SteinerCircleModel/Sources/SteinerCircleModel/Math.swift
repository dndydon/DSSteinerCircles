//
//  Math.swift
//  SteinerCircleModel
//
//  Created by Don Sleeter on 1/3/19.
//  Copyright © 2019 Don Sleeter. All rights reserved.
//

import Foundation
@_exported import PrimeFactorization

public extension Double {
  var asDegrees: Double { self * 180 / .pi }
  var asRadians: Double { self * .pi / 180 }
}

public extension CGFloat {
  var asDegrees: CGFloat { self * 180 / .pi }
  var asRadians: CGFloat { self * .pi / 180 }
}

