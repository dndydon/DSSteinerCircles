  //
  //  ContentView.swift
  //  DSSteinerCircles
  //
  //  Created by Don Sleeter on 5/26/20.
  //  Copyright © 2020 Don Sleeter. All rights reserved.
  //

  /// Root view. Owns the `SteinerRingModel` and composes the
  /// circle ring, transport controls, and configuration sliders.

import SwiftUI

struct ContentView: View {

  @State private var ring = SteinerRingModel()
  @State private var shapeKind: ShapeKind = .circle
  @State private var pointingDirection: PointingDirection = .fixedNorth

  var body: some View {
    VStack {
      CircleRing(ring: ring, shapeKind: shapeKind, pointingDirection: pointingDirection)
        .scaleEffect(0.90)
        .aspectRatio(1.0, contentMode: .fit)
      
      PlayPauseControl(
        onFastBackward:  { ring.playBackward(fast: true) },
        onPlayBackward:  { ring.playBackward() },
        onStop:          { ring.stopPlayback() },
        onPlay:          { ring.playForward() },
        onFastForward:   { ring.playForward(fast: true) }
      )
      
      GroupBox(label: Text("Configuration:")) {
        ControlPanel(ring: ring, shapeKind: $shapeKind, pointingDirection: $pointingDirection)
      }
      .padding([.horizontal, .bottom])
    }
    .background {
        // Hidden buttons for arrow key shortcuts (no modifier keys)
      Button("") {
        ring.stopPlayback()
        if ring.count > 1 { ring.countAsDouble -= 1 }
      }
      .keyboardShortcut(.leftArrow, modifiers: [])
      .hidden()
      
      Button("") {
        ring.stopPlayback()
        ring.countAsDouble += 1
      }
      .keyboardShortcut(.rightArrow, modifiers: [])
      .hidden()
    }
  }
}

#Preview {
  ContentView()
    .frame(width: 450, height: 600)
}
