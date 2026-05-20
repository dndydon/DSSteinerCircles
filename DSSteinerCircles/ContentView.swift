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

  @State private var ring: SteinerRingModel = {
    let d = UserDefaults.standard
    return SteinerRingModel(
      count: d.integer(forKey: "count"),
      gap: d.double(forKey: "gap"),
      thickness: CGFloat(d.double(forKey: "thickness")),
      showPrimes: d.bool(forKey: "showPrimes")
    )
  }()
  @AppStorage("shapeKind") private var shapeKind: ShapeKind = .circle
  @AppStorage("pointingDirection") private var pointingDirection: PointingDirection = .fixedNorth
  @AppStorage("showChrome") private var showChrome = true

  var body: some View {
    VStack {
      CircleRing(ring: ring, shapeKind: shapeKind, pointingDirection: pointingDirection, showChrome: showChrome)
        .scaleEffect(0.90)
        .aspectRatio(1.0, contentMode: .fit)
        .overlay(alignment: .topTrailing) {
          Toggle("Show Chrome", isOn: $showChrome)
            .toggleStyle(.checkbox)
            .padding()
        }

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
    .onChange(of: ring.count) { _, new in
      UserDefaults.standard.set(new, forKey: "count")
    }
    .onChange(of: ring.gap) { _, new in
      UserDefaults.standard.set(new, forKey: "gap")
    }
    .onChange(of: ring.thickness) { _, new in
      UserDefaults.standard.set(Double(new), forKey: "thickness")
    }
    .onChange(of: ring.showPrimes) { _, new in
      UserDefaults.standard.set(new, forKey: "showPrimes")
    }
  }
}

#Preview {
  ContentView()
    .frame(width: 450, height: 600)
}
