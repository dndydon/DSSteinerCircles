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

    var body: some View {
        VStack {
            CircleRing(ring: ring)
                .scaleEffect(0.90)
                .aspectRatio(1.0, contentMode: .fit)

            PlayPauseControl(
                onFastBackward: { ring.playBackward(fast: true) },
                onPlayBackward:  { ring.playBackward() },
                onStop:          { ring.stopPlayback() },
                onPlay:          { ring.playForward() },
                onFastForward:   { ring.playForward(fast: true) }
            )

            GroupBox(label: Text("Configuration:")) {
                ControlPanel(ring: ring)
            }
            .padding([.horizontal, .bottom])
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 450, height: 600)
}
