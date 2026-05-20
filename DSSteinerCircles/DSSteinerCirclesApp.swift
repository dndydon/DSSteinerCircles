  //
  //  DSSteinerCirclesApp.swift
  //  DSSteinerCircles
  //
  //  Created by Don Sleeter on 4/13/26.
  //

import SwiftUI

@main
struct DSSteinerCirclesApp: App {
  init() {
    UserDefaults.standard.register(defaults: [
      "count": 6,
      "gap": 0.050,
      "thickness": 0.0,
      "showPrimes": false,
      "showChrome": true,
    ])
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .frame(minWidth: 480, minHeight: 600)
    }
  }
}
