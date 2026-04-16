//
//  ControlPanel.swift
//  DSSteinerCircles
//
//  Created by Don Sleeter on 6/3/23.
//  Copyright © 2023 Don Sleeter. All rights reserved.
//

/// Slider controls for circle count, gap, and border thickness.

import SwiftUI

struct ControlPanel: View {

    @Bindable var ring: SteinerRingModel

    var body: some View {
        HStack {
            VStack {
                Slider(value: $ring.countAsDouble, in: 1...150, step: 1.0) {
                    HStack {
                        Text("Circle Count: \(ring.count)")
                    }.frame(width: 110, height: 30, alignment: .leading)
                }.padding(.horizontal)

                Slider(value: $ring.gap, in: 0.0...0.9999) {
                    Text("Gap: \(ring.gap, specifier: "%.3f")")
                        .frame(width: 110, height: 20, alignment: .leading)
                }.padding(.horizontal)

                Slider(value: $ring.thickness, in: 0.0...10.0) {
                    Text("Thickness: \(ring.thickness, specifier: "%.2f")")
                        .frame(width: 110, height: 30, alignment: .leading)
                }.padding(.horizontal)
            }
            .padding(.leading)
        }
        .frame(minWidth: 400, idealWidth: 500, maxWidth: 600)
    }
}

#Preview {
    ControlPanel(ring: SteinerRingModel())
        .frame(width: 400)
}
