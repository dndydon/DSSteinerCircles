//
//  CircleLabeled.swift
//  DSGaugeView
//
//  Created by Don Sleeter on 3/10/20.
//  Copyright © 2020 Don Sleeter. All rights reserved.
//

import SwiftUI
import SteinerCircleModel

struct CircleLabeled: View {
  
  @State private var didTap: Bool = false
  
  var label: String = "0"
  
  var body: some View {
    ZStack {
      Circle()
        .foregroundColor(didTap ? Color.accentColor : .secondary)
        .shadow(radius: didTap ? 30 : 0)
      Text("\(label)")
        .font(.largeTitle)
        .scaleEffect(5)
        .foregroundColor(.primary)
    }
    .gesture(TapGesture()
    .onEnded { _ in
      self.didTap.toggle()
      }
    )
  }
}

struct CircleLabeled_Previews: PreviewProvider {
  static var previews: some View {
    CircleLabeled(label: "1")
  }
}
