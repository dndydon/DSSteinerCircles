//
//  CircleLabeled.swift
//  DSGaugeView
//
//  Created by Don Sleeter on 3/10/20.
//  Copyright © 2020 Don Sleeter. All rights reserved.
//

import SwiftUI
import SteinerCircleModel


/// Stateful Leaf Node that needs to be given
/// label and selection 
struct CircleLabeled: View {

  // refactor to use this model with Observation
  // var model = LeafModel.self

  // old state variables:
  @State private var selected: Bool = false
  var label: String = "0"
  var color: Color = .gray.opacity(0.5)

  var body: some View {
    ZStack {
      Circle()
        .foregroundColor(selected ? Color.accentColor : color)
        .shadow(radius: selected ? 30 : 0)
        .overlay(selected ? Color.yellow : Color.clear,
                 in: Circle().stroke(style: StrokeStyle(lineWidth: 8)))
      Text("\(label)")
        .font(.largeTitle)
        .scaleEffect(5)
        .foregroundColor(.primary)
    }
    .gesture(TapGesture()
      .onEnded { _ in
        selected.toggle()
      }
    )
  }
}

struct CircleLabeled_Previews: PreviewProvider {
  static var previews: some View {
    CircleLabeled()
      .frame(width: 275)
      .padding()
//    let model = LeafModel()
//    CircleLabeled(model: model)
//      .frame(width: 250)
//      .padding()
  }
}
