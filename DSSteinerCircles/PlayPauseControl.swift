//
//  PlayPauseControl.swift
//  DSSteinerCircles
//
//  Created by Don Sleeter on 4/15/26.
//  Copyright © 2026 Don Sleeter. All rights reserved.
//

/// Transport-style control bar for animated count stepping.
/// Fast = 0.33s interval, normal = 1.0s interval.

import SwiftUI

struct PlayPauseControl: View {

    var onFastBackward: () -> Void = {}
    var onPlayBackward: () -> Void = {}
    var onStop: () -> Void = {}
    var onPlay: () -> Void = {}
    var onFastForward: () -> Void = {}

    var body: some View {
        HStack(spacing: 4) {
            transportButton("backward.fill", action: onFastBackward)
            transportButton("arrowtriangle.backward.fill", action: onPlayBackward)
            transportButton("stop.fill", action: onStop)
            transportButton("play.fill", action: onPlay)
            transportButton("forward.fill", action: onFastForward)
        }
    }

    private func transportButton(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title2)
                .frame(width: 44, height: 36)
        }
        .buttonStyle(.bordered)
    }
}

#Preview {
    PlayPauseControl()
        .padding()
}
