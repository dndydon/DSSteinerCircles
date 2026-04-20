//
//  DSSteinerCirclesTests.swift
//  DSSteinerCirclesTests
//
//  Created by Don Sleeter on 5/26/20.
//  Copyright © 2020 Don Sleeter. All rights reserved.
//

import Testing
@testable import DSSteinerCircles

// MARK: - LeafModel Tests

@Suite("LeafModel")
struct LeafModelTests {

  @Test("Default init sets label from index")
  func defaultLabel() {
    let leaf = LeafModel(index: 7)
    #expect(leaf.index == 7)
    #expect(leaf.label == "7")
    #expect(leaf.selected == false)
  }

  @Test("Custom label overrides index-derived label")
  func customLabel() {
    let leaf = LeafModel(index: 3, label: "Three")
    #expect(leaf.label == "Three")
  }

  @Test("Changing index updates label")
  func indexUpdatesLabel() {
    let leaf = LeafModel(index: 1)
    leaf.index = 42
    #expect(leaf.label == "42")
  }

  @Test("Toggle selection flips state")
  func toggleSelection() {
    let leaf = LeafModel(index: 1)
    #expect(leaf.selected == false)
    leaf.toggleSelection()
    #expect(leaf.selected == true)
    leaf.toggleSelection()
    #expect(leaf.selected == false)
  }
}

// MARK: - SteinerRingModel Flat Tests

@Suite("SteinerRingModel — Flat")
struct SteinerRingModelFlatTests {

  @Test("Default init creates 6 leaves")
  func defaultInit() {
    let ring = SteinerRingModel()
    #expect(ring.count == 6)
    #expect(ring.leaves.count == 6)
    #expect(ring.children.isEmpty)
    #expect(ring.isHierarchical == false)
  }

  @Test("Leaf indices are 1-based and sequential")
  func leafIndices() {
    let ring = SteinerRingModel(count: 5)
    let indices = ring.leaves.map(\.index)
    #expect(indices == [1, 2, 3, 4, 5])
  }

  @Test("Changing count rebuilds leaves")
  func countChange() {
    let ring = SteinerRingModel(count: 3)
    #expect(ring.leaves.count == 3)
    ring.countAsDouble = 7
    #expect(ring.leaves.count == 7)
    #expect(ring.leaves.map(\.index) == [1, 2, 3, 4, 5, 6, 7])
  }

  @Test("Count of 1 produces single leaf")
  func singleLeaf() {
    let ring = SteinerRingModel(count: 1)
    #expect(ring.leaves.count == 1)
    #expect(ring.leaves[0].index == 1)
  }

  @Test("displayCount equals count in flat mode")
  func displayCountFlat() {
    let ring = SteinerRingModel(count: 10)
    #expect(ring.displayCount == 10)
  }

  @Test("countAsDouble bridges correctly")
  func countAsDouble() {
    let ring = SteinerRingModel(count: 8)
    #expect(ring.countAsDouble == 8.0)
    ring.countAsDouble = 12.7
    #expect(ring.count == 12)
  }

  @Test("countAsDouble clamps to minimum 1")
  func countAsDoubleClamp() {
    let ring = SteinerRingModel(count: 5)
    ring.countAsDouble = -3.0
    #expect(ring.count == 1)
  }

  @Test("deselectAll clears all leaf selections")
  func deselectAll() {
    let ring = SteinerRingModel(count: 4)
    ring.leaves[0].selected = true
    ring.leaves[2].selected = true
    ring.deselectAll()
    #expect(ring.leaves.allSatisfy { !$0.selected })
  }
}

// MARK: - SteinerRingModel Hierarchy Tests

@Suite("SteinerRingModel — Hierarchy")
struct SteinerRingModelHierarchyTests {

  @Test("Prime count stays flat even with showPrimes")
  func primeStaysFlat() {
    let ring = SteinerRingModel(count: 7)
    ring.toggleShowPrimes()
    // 7 is prime — only one factor, so stays flat
    #expect(ring.isHierarchical == false)
    #expect(ring.leaves.count == 7)
  }

  @Test("Composite count creates hierarchy with showPrimes")
  func compositeCreatesHierarchy() {
    let ring = SteinerRingModel(count: 12)
    ring.toggleShowPrimes()
    // 12 = [3, 2, 2] → collapsed [4, 3] → 4 children of 3
    #expect(ring.isHierarchical == true)
    #expect(ring.children.count == 4)
    for child in ring.children {
      #expect(child.count == 3)
      #expect(child.leaves.count == 3)
    }
  }

  @Test("Total leaf count is preserved across hierarchy")
  func totalLeafCount() {
    let ring = SteinerRingModel(count: 30)
    ring.toggleShowPrimes()
    // Count all leaves recursively
    func leafCount(_ r: SteinerRingModel) -> Int {
      if r.isHierarchical {
        return r.children.reduce(0) { $0 + leafCount($1) }
      }
      return r.leaves.count
    }
    #expect(leafCount(ring) == 30)
  }

  @Test("Leaf indices cover 1...count without gaps")
  func leafIndicesCoverage() {
    let ring = SteinerRingModel(count: 24)
    ring.toggleShowPrimes()
    func allIndices(_ r: SteinerRingModel) -> [Int] {
      if r.isHierarchical {
        return r.children.flatMap { allIndices($0) }
      }
      return r.leaves.map(\.index)
    }
    let indices = allIndices(ring).sorted()
    #expect(indices == Array(1...24))
  }

  @Test("Toggling showPrimes off flattens hierarchy")
  func toggleShowPrimesOff() {
    let ring = SteinerRingModel(count: 12)
    ring.toggleShowPrimes()
    #expect(ring.isHierarchical == true)
    ring.toggleShowPrimes()
    #expect(ring.isHierarchical == false)
    #expect(ring.leaves.count == 12)
  }

  @Test("deselectAll recurses into children")
  func deselectAllRecursive() {
    let ring = SteinerRingModel(count: 12)
    ring.toggleShowPrimes()
    ring.children[0].leaves[0].selected = true
    ring.children[2].leaves[1].selected = true
    ring.deselectAll()
    for child in ring.children {
      #expect(child.leaves.allSatisfy { !$0.selected })
    }
  }
}

// MARK: - Collapsed Factors & Ordering Tests

@Suite("CollapsedFactors & Ordering")
struct CollapsedFactorsTests {

  @Test("Pairs of 2s collapse into 4s",
        arguments: [
          (12, [4, 3]),   // [3, 2, 2] → [4, 3]
          (8, [4, 2]),    // [2, 2, 2] → [4, 2]
          (4, [4]),       // [2, 2] → [4]
          (16, [4, 4]),   // [2, 2, 2, 2] → [4, 4]
          (6, [3, 2]),    // [3, 2] → [3, 2]
          (10, [5, 2]),   // [5, 2] → [5, 2]
        ])
  func collapsedFactors(input: (Int, [Int])) {
    let ring = SteinerRingModel(count: input.0)
    #expect(ring.collapsedFactors == input.1)
  }

  @Test("smallestFirst reverses ordering")
  func smallestFirstOrdering() {
    let ring = SteinerRingModel(count: 12)
    ring.factorOrdering = .smallestFirst
    #expect(ring.collapsedFactors == [3, 4])
  }

  @Test("Prime number has single-element factors")
  func primeFactors() {
    let ring = SteinerRingModel(count: 13)
    #expect(ring.collapsedFactors == [13])
  }

  @Test("largestFirst: outer ring gets largest factor")
  func largestFirstHierarchy() {
    let ring = SteinerRingModel(count: 12)
    ring.toggleShowPrimes()
    #expect(ring.children.count == 4)
    #expect(ring.children[0].count == 3)
  }

  @Test("smallestFirst: outer ring gets smallest factor")
  func smallestFirstHierarchy() {
    let ring = SteinerRingModel(count: 12)
    ring.factorOrdering = .smallestFirst
    ring.toggleShowPrimes()
    #expect(ring.children.count == 3)
    #expect(ring.children[0].count == 4)
  }
}

// MARK: - Selection Persistence Tests

@Suite("Selection Persistence")
struct SelectionPersistenceTests {

  /// Helper: collect all leaf indices from the tree that are selected.
  private func selectedIndices(_ ring: SteinerRingModel) -> Set<Int> {
    if ring.isHierarchical {
      return ring.children.reduce(into: Set<Int>()) {
        $0.formUnion(selectedIndices($1))
      }
    }
    return Set(ring.leaves.filter(\.selected).map(\.index))
  }

  @Test("Selection preserved when stepping count in flat mode")
  func flatStepPreservesSelection() {
    let ring = SteinerRingModel(count: 6)
    ring.leaves[1].selected = true  // index 2
    ring.leaves[3].selected = true  // index 4
    ring.countAsDouble = 7
    let sel = selectedIndices(ring)
    #expect(sel.contains(2))
    #expect(sel.contains(4))
  }

  @Test("Selection preserved when stepping count down in flat mode")
  func flatStepDownPreservesSelection() {
    let ring = SteinerRingModel(count: 8)
    ring.leaves[0].selected = true  // index 1
    ring.leaves[2].selected = true  // index 3
    ring.countAsDouble = 7
    let sel = selectedIndices(ring)
    #expect(sel.contains(1))
    #expect(sel.contains(3))
  }

  @Test("Selection preserved transitioning flat to hierarchy (e.g. 11→12)")
  func flatToHierarchyPreservesSelection() {
    let ring = SteinerRingModel(count: 11)
    ring.showPrimes = true  // 11 is prime, stays flat
    ring.leaves[2].selected = true  // index 3
    ring.leaves[6].selected = true  // index 7
    ring.countAsDouble = 12  // 12 is composite → hierarchy
    let sel = selectedIndices(ring)
    #expect(sel.contains(3))
    #expect(sel.contains(7))
  }

  @Test("Selection preserved transitioning hierarchy to flat (e.g. 12→13)")
  func hierarchyToFlatPreservesSelection() {
    let ring = SteinerRingModel(count: 12)
    ring.toggleShowPrimes()
    // Select a leaf deep in the hierarchy
    ring.children[0].leaves[1].selected = true  // some index in first child
    let selectedBefore = selectedIndices(ring)
    #expect(!selectedBefore.isEmpty)
    ring.countAsDouble = 13  // 13 is prime → flat
    let sel = selectedIndices(ring)
    #expect(sel.isSuperset(of: selectedBefore))
  }

  @Test("Selection preserved across hierarchy→hierarchy transition")
  func hierarchyToHierarchyPreservesSelection() {
    let ring = SteinerRingModel(count: 12)
    ring.toggleShowPrimes()
    ring.children[1].leaves[0].selected = true
    let selectedBefore = selectedIndices(ring)
    ring.countAsDouble = 18  // 18 = [3, 3, 2] → hierarchy
    let sel = selectedIndices(ring)
    #expect(sel.isSuperset(of: selectedBefore))
  }

  @Test("toggleShowPrimes preserves selection")
  func togglePreservesSelection() {
    let ring = SteinerRingModel(count: 12)
    ring.leaves[4].selected = true  // index 5
    ring.toggleShowPrimes()
    let sel = selectedIndices(ring)
    #expect(sel.contains(5))
    ring.toggleShowPrimes()  // back to flat
    let sel2 = selectedIndices(ring)
    #expect(sel2.contains(5))
  }
}

// MARK: - Child Propagation Tests

@Suite("Child Propagation")
struct ChildPropagationTests {

  @Test("Gap propagates to children")
  func gapPropagates() {
    let ring = SteinerRingModel(count: 12, gap: 0.05)
    ring.toggleShowPrimes()
    ring.gap = 0.2
    for child in ring.children {
      #expect(child.gap == 0.2)
    }
  }

  @Test("Thickness propagates to children")
  func thicknessPropagates() {
    let ring = SteinerRingModel(count: 12, thickness: 1.0)
    ring.toggleShowPrimes()
    ring.thickness = 3.0
    for child in ring.children {
      #expect(child.thickness == 3.0)
    }
  }

  @Test("Children get correct totalCount and startIndex")
  func childContextIsCorrect() {
    let ring = SteinerRingModel(count: 12)
    ring.toggleShowPrimes()
    // 12 = [4, 3] → 4 children of 3
    for child in ring.children {
      #expect(child.totalCount == 12)
    }
    // startIndex should be sequential: 1, 4, 7, 10
    let starts = ring.children.map(\.startIndex)
    #expect(starts == [1, 4, 7, 10])
  }

  @Test("Child colors match global hue sequence")
  func childColorsAreCorrect() {
    let ring = SteinerRingModel(count: 12)
    ring.toggleShowPrimes()
    // Gather all leaf colors in order
    func allLeaves(_ r: SteinerRingModel) -> [LeafModel] {
      if r.isHierarchical {
        return r.children.flatMap { allLeaves($0) }
      }
      return r.leaves
    }
    let leaves = allLeaves(ring)
    // Each leaf's color should match colorForValue(index, of: 12)
    for leaf in leaves {
      #expect(leaf.fillColor == colorForValue(leaf.index, of: 12))
    }
  }
}

// MARK: - Geometry Tests

@Suite("Geometry")
struct GeometryTests {

  @Test("rho is positive for count > 1")
  func rhoPositive() {
    let ring = SteinerRingModel(count: 6)
    #expect(ring.rho > 0)
  }

  @Test("innerRadius is less than outerRadius")
  func innerLessThanOuter() {
    let ring = SteinerRingModel(count: 8)
    #expect(ring.innerRadius < ring.outerRadius)
    #expect(ring.innerRadius > 0)
  }

  @Test("rho decreases as count increases")
  func rhoDecreasesWithCount() {
    let ring6 = SteinerRingModel(count: 6)
    let ring12 = SteinerRingModel(count: 12)
    #expect(ring12.rho < ring6.rho)
  }

  @Test("Gap 0 gives larger rho than gap 0.5")
  func gapReducesRho() {
    let noGap = SteinerRingModel(count: 8, gap: 0.001)
    let gapped = SteinerRingModel(count: 8, gap: 0.5)
    #expect(noGap.rho > gapped.rho)
  }
}

// MARK: - Playback Tests

@Suite("Playback")
struct PlaybackTests {

  @Test("stepCount increments via playForward")
  func playForwardIncrements() {
    let ring = SteinerRingModel(count: 5)
    ring.playForward()
    // After playForward, count should have stepped once
    #expect(ring.count == 6)
    ring.stopPlayback()
  }

  @Test("stepCount decrements via playBackward")
  func playBackwardDecrements() {
    let ring = SteinerRingModel(count: 5)
    ring.playBackward()
    #expect(ring.count == 4)
    ring.stopPlayback()
  }

  @Test("stopPlayback sets state to stopped")
  func stopSetsState() {
    let ring = SteinerRingModel(count: 5)
    ring.playForward()
    ring.stopPlayback()
    if case .stopped = ring.playback {
      // expected
    } else {
      Issue.record("Expected .stopped state")
    }
  }

  @Test("Playback stops at lower bound")
  func stopsAtLowerBound() {
    let ring = SteinerRingModel(count: 1)
    ring.playBackward()
    // Should not go below 1
    #expect(ring.count == 1)
    ring.stopPlayback()
  }
}

// MARK: - Rotation Tests

@Suite("Rotation")
struct RotationTests {

  @Test("resetRotation normalizes large angles to zero")
  func resetNormalizesLargeAngle() {
    let ring = SteinerRingModel()
    ring.rotationAngle = 720
    ring.resetRotation()
    #expect(ring.rotationAngle == 0.0)
  }

  @Test("resetRotation normalizes negative angles to zero")
  func resetNormalizesNegativeAngle() {
    let ring = SteinerRingModel()
    ring.rotationAngle = -450
    ring.resetRotation()
    #expect(ring.rotationAngle == 0.0)
  }
}

// MARK: - Color Tests

@Suite("colorForValue")
struct ColorTests {

  @Test("Returns a color for valid range")
  func validRange() {
    // Just verify it doesn't crash for boundary values
    let _ = colorForValue(0, of: 10)
    let _ = colorForValue(5, of: 10)
    let _ = colorForValue(10, of: 10)
  }

  @Test("Clamps out-of-range values")
  func clampsOutOfRange() {
    // Should not crash for values outside [0, total]
    let _ = colorForValue(-1, of: 10)
    let _ = colorForValue(15, of: 10)
  }
}

// MARK: - Performance Tests

@Suite("Performance")
struct PerformanceTests {

  @Test("Rebuild flat ring of 500 is fast")
  func rebuildFlat500() {
    let ring = SteinerRingModel(count: 500)
    // Trigger rebuild by changing count
    ring.countAsDouble = 499
    ring.countAsDouble = 500
    #expect(ring.leaves.count == 500)
  }

  @Test("Hierarchy rebuild for 360 (deep factorization)")
  func rebuildHierarchy360() {
    let ring = SteinerRingModel(count: 360)
    ring.toggleShowPrimes()
    // 360 = 2^3 * 3^2 * 5 → deep hierarchy
    #expect(ring.isHierarchical == true)
    // All leaves should still sum to 360
    func leafCount(_ r: SteinerRingModel) -> Int {
      if r.isHierarchical {
        return r.children.reduce(0) { $0 + leafCount($1) }
      }
      return r.leaves.count
    }
    #expect(leafCount(ring) == 360)
  }

  @Test("Rapid count changes don't crash")
  func rapidCountChanges() {
    let ring = SteinerRingModel(count: 10)
    for i in 1...100 {
      ring.countAsDouble = Double(i)
    }
    #expect(ring.count == 100)
    #expect(ring.leaves.count == 100)
  }
}
