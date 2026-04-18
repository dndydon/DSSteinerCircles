//
//  SteinerChainView.swift
//  DSSteinerCircles
//
//  Created by Don Sleeter on 4/16/26.
//  Copyright © 2026 Don Sleeter. All rights reserved.
//

import SwiftUI
import SteinerCircleModel

struct SteinerChainView: View {
  let chain = SteinerCircle(outerRadius: 150, circleCount: 8, gap: 0.05)

  var body: some View {
    Canvas { context, size in
      let center = CGPoint(x: size.width / 2, y: size.height / 2)

      // Draw outer circle
      let outerRect = CGRect(
        x: center.x - chain.outerRadius,
        y: center.y - chain.outerRadius,
        width: chain.outerRadius * 2,
        height: chain.outerRadius * 2
      )
      context.stroke(Path(ellipseIn: outerRect), with: .color(.gray))

      // Draw chain circles
      for circle in chain.chainCircles {
        let rect = CGRect(
          x: center.x + circle.center.x - circle.radius,
          y: center.y + circle.center.y - circle.radius,
          width: circle.radius * 2,
          height: circle.radius * 2
        )
        context.stroke(Path(ellipseIn: rect), with: .color(.blue))
      }
    }
  }
}

#Preview {
  Group {
    SteinerChainView()
      .frame(width: 350, height: 350)
  }
}
