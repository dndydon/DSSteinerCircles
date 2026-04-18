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

    /// True while the user is editing the count field.
    @State private var isEditingCount = false
    @State private var countText: String = ""

    var body: some View {
        HStack {
            VStack {
                Slider(value: $ring.countAsDouble, in: 1...500, step: 1.0) {
                    HStack {
                        Text("Count:")
                        if isEditingCount {
                            TextField("", text: $countText)
                                .frame(width: 50)
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.trailing)
                                .onSubmit { applyCountText() }
                        } else {
                            Text("\(ring.count)")
                                .frame(width: 50, alignment: .trailing)
                                .onTapGesture {
                                    countText = "\(ring.count)"
                                    isEditingCount = true
                                }
                        }
                    }.frame(width: 110, height: 30, alignment: .leading)
                }
                .padding(.horizontal)

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

    private func applyCountText() {
        if let value = Int(countText), value >= 1, value <= 1024 {
            ring.count = value
        } else {
            countText = "\(ring.count)"
        }
        isEditingCount = false
    }
}

#Preview {
    ControlPanel(ring: SteinerRingModel())
        .frame(width: 400)
}
