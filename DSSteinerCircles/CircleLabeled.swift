//
//  CircleLabeled.swift
//  DSSteinerCircles
//
//  Created by Don Sleeter on 3/10/20.
//  Copyright © 2020 Don Sleeter. All rights reserved.
//

/// A single leaf circle that shows its index label when selected.
/// The `rotation` parameter counter-rotates the label so it stays
/// upright regardless of how deeply nested this leaf is.

import SwiftUI

struct CircleLabeled: View {

    var leaf: LeafModel
    var rotation: Double = 0.0
    let lineWidth: CGFloat = 8

    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(leaf.selected ? leaf.selectedColor : leaf.fillColor)
                .shadow(radius: leaf.selected ? 30 : 0)
                .overlay(leaf.selected ? Color.yellow : Color.clear,
                         in: Circle().inset(by: lineWidth / 2).stroke(style: StrokeStyle(lineWidth: 8)))
            // Always present in layout to prevent size jumps on selection
            Text(leaf.label)
                .font(.largeTitle)
                .scaleEffect(10)
                .foregroundColor(.primary)
                .rotationEffect(Angle(degrees: rotation))
                .opacity(leaf.selected ? 1 : 0)
        }
        .gesture(TapGesture()
            .onEnded { _ in
                leaf.toggleSelection()
            }
        )
    }
}

#Preview {
    CircleLabeled(leaf: LeafModel(index: 10, selected: true, fillColor: .gray))
        .frame(width: 375)
        .padding()
}
