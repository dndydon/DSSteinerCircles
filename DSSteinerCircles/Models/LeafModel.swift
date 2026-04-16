//
//  LeafModel.swift
//  DSSteinerCircles
//
//  Created by Don Sleeter on 7/19/23.
//  Copyright © 2023 Don Sleeter. All rights reserved.
//

/// @Observable model for a single leaf circle in a Steiner ring.
/// Each leaf has a global index (for labeling and coloring),
/// a fill color derived from its position, and selection state.

import SwiftUI

@Observable
class LeafModel: Identifiable {
    let id = UUID()
    var index: Int
    var label: String
    var selected: Bool
    var fillColor: Color
    var selectedColor: Color

    init(index: Int,
         label: String = "",
         selected: Bool = false,
         fillColor: Color = .secondary,
         selectedColor: Color = .accentColor) {
        self.index = index
        self.label = label.isEmpty ? "\(index)" : label
        self.selected = selected
        self.fillColor = fillColor
        self.selectedColor = selectedColor
    }

    func toggleSelection() {
        selected.toggle()
    }
}
