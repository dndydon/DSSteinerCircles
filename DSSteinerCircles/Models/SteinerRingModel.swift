//
//  SteinerRingModel.swift
//  DSSteinerCircles
//
//  Created by Don Sleeter on 4/13/26.
//

/// Central @Observable model for a Steiner circle ring.
///
/// Owns the configuration (count, gap, thickness) and can represent either:
/// - A **flat** ring of `count` leaf circles, or
/// - A **hierarchical** ring whose children are smaller `SteinerRingModel`s,
///   decomposed by prime factorization (with pairs of 2s collapsed into 4s).
///
/// The root instance is owned by `ContentView` via `@State`. Child instances
/// are created during `rebuild()` and inherit gap, thickness, and coloring
/// context (`totalCount`, `startIndex`) from their parent.

import SwiftUI
import SteinerCircleModel
import PrimeFactorization

@Observable
class SteinerRingModel: Identifiable {

    let id = UUID()

    /// Radius of this ring in its parent's coordinate space (root = 1.0).
    var outerRadius: CGFloat

    /// Total leaf count for this ring (all levels combined).
    /// Setting this on the root triggers a full rebuild.
    var count: Int {
        didSet {
            if count != oldValue {
                totalCount = count
                startIndex = 1
                rebuild()
            }
        }
    }

    /// Spacing between adjacent chain circles (0 = touching, ~1 = maximally spaced).
    var gap: Double {
        didSet { propagateToChildren() }
    }

    /// Stroke width for ring borders.
    var thickness: CGFloat {
        didSet { propagateToChildren() }
    }

    /// Current rotation of this ring (degrees), driven by the Dial gesture.
    var rotationAngle: Double = 0.0

    /// When true, composite counts are decomposed into nested sub-rings.
    var showPrimes: Bool = false {
        didSet {
            if showPrimes != oldValue {
                rebuild()
            }
        }
    }

    /// Leaf circles at this level (empty when hierarchical).
    var leaves: [LeafModel] = []

    /// Child rings at this level (empty when flat).
    var children: [SteinerRingModel] = []

    /// Root's total leaf count, passed down for consistent hue coloring.
    var totalCount: Int

    /// 1-based global index of the first leaf in this ring.
    var startIndex: Int

    /// True when this ring contains sub-rings rather than direct leaves.
    var isHierarchical: Bool { !children.isEmpty }

    // MARK: - Init

    init(count: Int = 6, outerRadius: CGFloat = 1.0, gap: Double = 0.149, thickness: CGFloat = 0.0,
         totalCount: Int? = nil, startIndex: Int = 1) {
        self.count = count
        self.totalCount = totalCount ?? count
        self.startIndex = startIndex
        self.outerRadius = outerRadius
        self.gap = gap
        self.thickness = thickness
        rebuild()
    }

    // MARK: - Computed Properties

    /// Number of items this ring actually lays out at its own level.
    /// Hierarchical: the largest collapsed factor. Flat: count.
    var displayCount: Int {
        if isHierarchical, let outerCount = collapsedFactors.first {
            return outerCount
        }
        return count
    }

    /// Geometry calculator for this ring's Steiner chain layout.
    var steinerCircle: SteinerCircle {
        SteinerCircle(outerRadius: outerRadius, circleCount: displayCount, gap: gap)
    }

    /// Raw prime factors of `count`, largest first.
    var factors: [Int] {
        count.primeFactors.reversed()
    }

    /// Prime factors with consecutive pairs of 2s collapsed into 4s.
    /// This produces a better visual layout than nesting rings of 2.
    /// e.g. [3, 2, 2] -> [3, 4],  [2, 2, 2] -> [4, 2],  [2, 2] -> [4]
    var collapsedFactors: [Int] {
        let sorted = factors
        var result: [Int] = []
        var twos = 0
        for f in sorted {
            if f == 2 {
                twos += 1
                if twos == 2 {
                    result.append(4)
                    twos = 0
                }
            } else {
                result.append(f)
            }
        }
        if twos == 1 {
            result.append(2)
        }
        return result.sorted(by: >)
    }

    /// Radius of each chain circle, adjusted for gap.
    var rho: CGFloat {
        (1 - gap) * steinerCircle.rho
    }

    /// Radius of the inner circle.
    var innerRadius: CGFloat {
        steinerCircle.innerRadius
    }

    // MARK: - Slider Bridge

    /// Two-way Double bridge so Slider can bind to the Int `count`.
    var countAsDouble: Double {
        get { Double(count) }
        set { count = max(1, Int(newValue)) }
    }

    // MARK: - Playback

    /// Transport control state for animated count stepping.
    enum PlaybackState {
        case stopped
        case forward(fast: Bool)
        case backward(fast: Bool)
    }

    var playback: PlaybackState = .stopped
    private var timer: Timer?

    /// Start incrementing count on a timer (1.0s normal, 0.33s fast).
    func playForward(fast: Bool = false) {
        stopPlayback()
        playback = .forward(fast: fast)
        stepCount(by: 1)
        let interval = fast ? 0.33 : 1.0
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.stepCount(by: 1)
        }
    }

    /// Start decrementing count on a timer.
    func playBackward(fast: Bool = false) {
        stopPlayback()
        playback = .backward(fast: fast)
        stepCount(by: -1)
        let interval = fast ? 0.33 : 1.0
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.stepCount(by: -1)
        }
    }

    /// Stop any active playback timer.
    func stopPlayback() {
        timer?.invalidate()
        timer = nil
        playback = .stopped
    }

    private func stepCount(by delta: Int) {
        let newCount = count + delta
        guard newCount >= 1, newCount <= 500 else {
            stopPlayback()
            return
        }
        withAnimation(.snappy(duration: 0.3)) {
            count = newCount
        }
    }

    // MARK: - Actions

    /// Animate rotation back to zero via the shortest path.
    func resetRotation() {
        var normalized = rotationAngle.truncatingRemainder(dividingBy: 360)
        if normalized > 180 { normalized -= 360 }
        if normalized < -180 { normalized += 360 }
        rotationAngle = normalized
        withAnimation(.spring) {
            rotationAngle = 0.0
        }
    }

    func deselectAll() {
        for leaf in leaves {
            leaf.selected = false
        }
        for child in children {
            child.deselectAll()
        }
    }

    // MARK: - Propagation

    /// Push gap and thickness changes down to child rings.
    private func propagateToChildren() {
        for child in children {
            child.gap = gap
            child.thickness = thickness
        }
    }

    // MARK: - Rebuild

    /// Rebuild leaves or children based on current showPrimes and factors.
    private func rebuild() {
        let cf = collapsedFactors
        if showPrimes && cf.count > 1 {
            rebuildHierarchy(cf)
        } else {
            rebuildFlat()
        }
    }

    /// Create a flat ring of `count` leaf circles.
    private func rebuildFlat() {
        children = []
        leaves = (0..<max(1, count)).map { i in
            let globalIndex = startIndex + i
            return LeafModel(index: globalIndex, fillColor: colorForValue(globalIndex, of: totalCount))
        }
    }

    /// Decompose into nested sub-rings using collapsed prime factors.
    /// The largest factor becomes the outer ring count; remaining factors
    /// are passed recursively to each child.
    private func rebuildHierarchy(_ cf: [Int]) {
        leaves = []
        guard let outerCount = cf.first else {
            rebuildFlat()
            return
        }

        let remainingFactors = Array(cf.dropFirst())
        let childCount = remainingFactors.reduce(1, *)

        let outerSteiner = SteinerCircle(outerRadius: outerRadius, circleCount: outerCount, gap: gap)
        let childRadius = (1 - gap) * outerSteiner.rho

        children = (0..<outerCount).map { i in
            let child = SteinerRingModel(
                count: childCount,
                outerRadius: childRadius,
                gap: gap,
                thickness: thickness,
                totalCount: totalCount,
                startIndex: startIndex + i * childCount
            )
            child.showPrimes = (remainingFactors.count > 1)
            return child
        }
    }
}
