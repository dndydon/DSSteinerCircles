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
  
  @State private var count: Double = 8
  @State private var gap: Double = 0.0
  @State private var thickness: CGFloat = 4.0
  
  var body: some View {
    VStack {
      CircleRing(count: Int(count), thickness: thickness, gap: CGFloat(gap))
        .foregroundColor(.secondary)
        .scaleEffect(0.90)
        .aspectRatio(1.0, contentMode: .fit)
    }
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
