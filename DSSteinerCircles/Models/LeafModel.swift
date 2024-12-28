//
//  LeafModel.swift
//  DSSteinerCircles
//
//  Created by Don Sleeter on 7/19/23.
//  Copyright © 2023 Don Sleeter. All rights reserved.
//

import SwiftUI
import Observation

// For example:
// Voice, Section(s), Chorus
// Instrument, Section(s), Orchestra
//
// Leaf, Branch(es), Tree

// I want to create, view, list, select, edit, delete, and save trees (as iCloud documents) with these things

@Observable
class LeafModel {
  var shape: any Shape
  var label: String
  var selected: Bool
  var fillColor: Color
  var selectedColor: Color

  init(shape: any Shape = Circle(), 
       label: String = "12",
       selected: Bool = false,
       fillColor: Color = .secondary,
       selectedColor: Color = .accentColor) {
    self.shape = shape
    self.label = label
    self.selected = selected
    self.fillColor = fillColor
    self.selectedColor = selectedColor
  }

  static var example: LeafModel {
    return LeafModel()
  }

}

@Observable
class BranchModel {
  var leaves: [LeafModel] = [LeafModel.example]
}

@Observable
class TreeModel {
  var branches: [BranchModel] = []
}
