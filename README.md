# DSSteinerCircles

A macOS app that visualizes Steiner circle chains — rings of mutually tangent circles packed between concentric inner and outer circles.

## Features

- **Interactive dial** — drag to rotate the ring; double-click to reset.
- **Prime factorization hierarchy** — toggle "Show Factors" to decompose composite counts into nested sub-rings (pairs of 2s collapse into quads).
- **Shape variety** — circle, rounded rect, star, diamond, pentagon, heart, shield.
- **Radial orientation** — shapes point north or rotate to face outward.
- **Transport controls** — play/stop buttons animate count forward or backward.
- **Arrow keys** — left/right step the count by one.
- **Persistent settings** — all controls are saved across sessions via UserDefaults.

## Requirements

- macOS 15.6+
- Xcode 16+
- Swift 5 / SwiftUI

## Dependencies (SPM)

| Package | Source |
|---------|--------|
| [SteinerCircleModel](https://github.com/dndydon/SteinerCircleModel) | Geometry math for Steiner chains |
| [PrimeFactorization](https://github.com/dndydon/PrimeFactorization) | Integer prime factorization |

## Building

Open `DSSteinerCircles.xcodeproj` in Xcode and run the **DSSteinerCircles** scheme.
