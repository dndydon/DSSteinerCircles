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
import PrimeFactorization
import SteinerCircleModel

  /// Controls how collapsed prime factors are ordered in the hierarchy.
  /// The first factor becomes the outermost ring count.
enum FactorOrdering: CaseIterable {
  case largestFirst   // default: biggest factor = outer ring
  case smallestFirst  // smallest factor = outer ring
}

@Observable
class SteinerRingModel: Identifiable {
  
  let id = UUID()
  
    /// Controls how collapsed factors are ordered in the hierarchy.
  var factorOrdering: FactorOrdering = .largestFirst
  
    /// Radius of this ring in its parent's coordinate space (root = 1.0).
  var outerRadius: CGFloat
  
    /// Total leaf count for this ring (all levels combined).
    /// On child rings, set directly by parent's `rebuildHierarchy`
    /// (which calls `rebuild()` explicitly after all properties are set).
  var count: Int
  
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
    /// Use `toggleShowPrimes()` for user-initiated changes (preserves selection).
  var showPrimes: Bool = false
  
    /// Toggle showPrimes from a user action, preserving selection state.
  func toggleShowPrimes() {
    selectedIndices = gatherSelectedIndices()
    showPrimes.toggle()
    rebuild()
  }
  
    /// Leaf circles at this level (empty when hierarchical).
  var leaves: [LeafModel] = []
  
    /// Child rings at this level (empty when flat).
  var children: [SteinerRingModel] = []
  
    /// Root's total leaf count, passed down for consistent hue coloring.
  var totalCount: Int
  
    /// 1-based global index of the first leaf in this ring.
  var startIndex: Int
  
    /// Global indices of selected leaves, preserved across rebuilds.
  var selectedIndices: Set<Int> = []
  
    /// True when this ring contains sub-rings rather than direct leaves.
  var isHierarchical: Bool { !children.isEmpty }
  
    // MARK: - Init
  
  init(count: Int = 6, outerRadius: CGFloat = 1.0, gap: Double = 0.050, thickness: CGFloat = 0.0,
       totalCount: Int? = nil, startIndex: Int = 1, selectedIndices: Set<Int> = []) {
    self.count = count
    self.totalCount = totalCount ?? count
    self.startIndex = startIndex
    self.outerRadius = outerRadius
    self.gap = gap
    self.thickness = thickness
    self.selectedIndices = selectedIndices
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
    switch factorOrdering {
      case .largestFirst:
        return result.sorted(by: >)
      case .smallestFirst:
        return result.sorted(by: <)
    }
  }
  
    /// Radius of each chain circle (gap already applied by the package).
  var rho: CGFloat {
    steinerCircle.rho
  }
  
    /// Radius of the inner circle.
  var innerRadius: CGFloat {
    steinerCircle.innerRadius
  }
  
    // MARK: - Slider Bridge
  
    /// Two-way Double bridge so Slider can bind to the Int `count`.
    /// Resets totalCount/startIndex for root-level usage.
  var countAsDouble: Double {
    get { Double(count) }
    set {
      let newCount = max(1, Int(newValue))
      selectedIndices = gatherSelectedIndices()
      totalCount = newCount
      startIndex = 1
      count = newCount
      rebuild()
    }
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
    guard newCount >= 1 else {
      stopPlayback()
      return
    }
    selectedIndices = gatherSelectedIndices()
    totalCount = newCount
    startIndex = 1
    count = newCount
    rebuild()
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
    selectedIndices.removeAll()
    for leaf in leaves {
      leaf.selected = false
    }
    for child in children {
      child.deselectAll()
    }
  }
  
    // MARK: - Propagation
  
    /// Push gap, thickness, and factor ordering down to child rings.
  private func propagateToChildren() {
    for child in children {
      child.gap = gap
      child.thickness = thickness
      child.factorOrdering = factorOrdering
    }
  }
  
    // MARK: - Rebuild
  
    /// Rebuild leaves or children based on current showPrimes and factors.
  func rebuild() {
    let cf = collapsedFactors
    if showPrimes && cf.count > 1 {
      rebuildHierarchy(cf)
    } else {
      rebuildFlat()
    }
  }
  
    /// Gather all selected leaf indices from the current tree.
  private func gatherSelectedIndices() -> Set<Int> {
    func gather(_ ring: SteinerRingModel) -> Set<Int> {
      if ring.isHierarchical {
        return ring.children.reduce(into: Set<Int>()) { $0.formUnion(gather($1)) }
      }
      return Set(ring.leaves.filter(\.selected).map(\.index))
    }
    return gather(self)
  }
  
    /// Create a flat ring of `count` leaf circles, reusing existing
    /// LeafModel instances where possible to reduce allocations.
    /// Restores selection from `selectedIndices`.
  private func rebuildFlat() {
    children = []
    let n = max(1, count)
    if leaves.count > n {
      leaves.removeLast(leaves.count - n)
    }
    for i in 0..<min(leaves.count, n) {
      let globalIndex = startIndex + i
      leaves[i].index = globalIndex
      leaves[i].fillColor = colorForValue(globalIndex, of: totalCount)
      leaves[i].selected = selectedIndices.contains(globalIndex)
    }
    for i in leaves.count..<n {
      let globalIndex = startIndex + i
      leaves.append(LeafModel(
        index: globalIndex,
        selected: selectedIndices.contains(globalIndex),
        fillColor: colorForValue(globalIndex, of: totalCount)
      ))
    }
  }
  
    /// Decompose into nested sub-rings using collapsed prime factors.
    /// The largest factor becomes the outer ring count; remaining factors
    /// are passed recursively to each child.
    /// Reuses existing child objects when possible to preserve SwiftUI identity.
  private func rebuildHierarchy(_ cf: [Int]) {
    leaves = []
    guard let outerCount = cf.first else {
      rebuildFlat()
      return
    }
    
    let remainingFactors = Array(cf.dropFirst())
    let childCount = remainingFactors.reduce(1, *)
    let showChildPrimes = remainingFactors.count > 1
    
    let outerSteiner = SteinerCircle(outerRadius: outerRadius, circleCount: outerCount, gap: gap)
    let childRadius = outerSteiner.rho
    
      // Reuse existing children where possible
    if children.count > outerCount {
      children.removeLast(children.count - outerCount)
    }
    for i in 0..<min(children.count, outerCount) {
      let child = children[i]
      child.selectedIndices = selectedIndices
      child.totalCount = totalCount
      child.startIndex = startIndex + i * childCount
      child.outerRadius = childRadius
      child.gap = gap
      child.thickness = thickness
      child.factorOrdering = factorOrdering
      child.showPrimes = showChildPrimes
      child.count = childCount
        // Force rebuild to restore selection even if count/showPrimes didn't change
      child.rebuild()
    }
    for i in children.count..<outerCount {
      let child = SteinerRingModel(
        count: childCount,
        outerRadius: childRadius,
        gap: gap,
        thickness: thickness,
        totalCount: totalCount,
        startIndex: startIndex + i * childCount,
        selectedIndices: selectedIndices
      )
      child.showPrimes = showChildPrimes
      child.factorOrdering = factorOrdering
      if showChildPrimes {
        child.rebuild() // re-rebuild now that showPrimes is set
      }
      children.append(child)
    }
  }
}
