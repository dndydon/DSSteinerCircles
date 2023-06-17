//
//  ContentView.swift
//  DSSteinerCircles
//
//  Created by Don Sleeter on 5/26/20.
//  Copyright © 2020 Don Sleeter. All rights reserved.
//

import SwiftUI
import SteinerCircleModel

struct ContentView: View {

  @State var count: Double = 5  // why Double?  Because Slider needs it?
  @State private var gap: Double = 0.0
  @State private var thickness: CGFloat = 4.0
  
  var body: some View {
    VStack {
      CircleRing(count: Int(count), thickness: thickness, gap: gap)
        .foregroundColor(.secondary)
        .scaleEffect(0.90)
        .aspectRatio(1.0, contentMode: .fit)

      GroupBox(label: Text("Configuration:")) {
        ControlPanel(count: self.$count,
                     gap: self.$gap,
                     thickness: self.$thickness)
      }
      .padding([.horizontal, .bottom])
    }
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .frame(width: 450, height: 600)
  }
}
