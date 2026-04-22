  //
  //  ControlPanel.swift
  //  DSSteinerCircles
  //
  //  Created by Don Sleeter on 6/3/23.
  //  Copyright © 2023 Don Sleeter. All rights reserved.
  //

  /// Configuration controls: count, gap, thickness, shape, and orientation.

import SwiftUI

struct ControlPanel: View {
  
  @Bindable var ring: SteinerRingModel
  @Binding var shapeKind: ShapeKind
  @Binding var pointingDirection: PointingDirection

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
          }.frame(width: 117, height: 30, alignment: .leading)
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

        HStack {
          Picker("Shape:", selection: $shapeKind) {
            ForEach(ShapeKind.allCases) { shape in
              Text(shape.displayName).tag(shape)
            }
          }
          .frame(maxWidth: 200)

          Picker("Direction:", selection: $pointingDirection) {
            ForEach(PointingDirection.allCases) { dir in
              Text(dir.displayName).tag(dir)
            }
          }
          .frame(maxWidth: 200)
        }
        .padding(.horizontal)
      }
      .padding(.leading)
    }
    .frame(minWidth: 400, idealWidth: 500, maxWidth: 600)
  }
  
  private func applyCountText() {
    if let value = Int(countText), value >= 1 {
      ring.countAsDouble = Double(value)
    } else {
      countText = "\(ring.count)"
    }
    isEditingCount = false
  }
}

#Preview {
  @Previewable @State var shape: ShapeKind = .circle
  @Previewable @State var direction: PointingDirection = .fixedNorth
  ControlPanel(ring: SteinerRingModel(), shapeKind: $shape, pointingDirection: $direction)
    .frame(width: 400)
}
