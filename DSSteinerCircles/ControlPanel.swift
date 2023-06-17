//
//  ControlPanel.swift
//  DSSteinerCircles
//
//  Created by Don Sleeter on 6/3/23.
//  Copyright © 2023 Don Sleeter. All rights reserved.
//

import SwiftUI

struct ControlPanel: View {
  @Binding var count: Double
  @Binding var gap: Double
  @Binding var thickness: CGFloat

  var body: some View {
    HStack {
      VStack {
        Slider(value: $count, in: 1...50, step: 1.0) {
          HStack {
            Text("Circle Count: \(count, specifier: "%.0f")")
          }.frame(width: 110, height: 30, alignment: .leading)
        }.padding(.horizontal)

        Slider(value: $gap, in: 0.0...0.9999) {
          Text("Gap: \(gap, specifier: "%.3f")")
            .frame(width: 110, height: 30, alignment: .leading)
        }.padding(.horizontal)

        Slider(value: $thickness, in: 0.0...10.0) {
          Text("Thickness: \(thickness, specifier: "%.2f")")
            .frame(width: 110, height: 30, alignment: .leading)
        }.padding([.horizontal])

      }
      .padding(.leading)

    }
    .frame(minWidth: 400, idealWidth: 500, maxWidth: 600)
  }
}

struct ControlPanel_Previews: PreviewProvider {
    static var previews: some View {
      ControlPanel(count: .constant(5),
                   gap: .constant(0.1),
                   thickness: .constant(0.2))
      .frame(width: 400)
    }
}
