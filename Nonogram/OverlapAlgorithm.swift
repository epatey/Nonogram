//
//  OverlapAlgorithm.swift
//  Nonogram
//
//  Created by Eric Patey on 12/9/20.
//  Copyright © 2020 Boulder Top Software. All rights reserved.
//

import Foundation

func OverlapAlgorithm(line: PartialLine, rules: [Int], description: String) -> PartialLine? {
    if (line.complete) {
        return nil
    }

    //        print("Getting line overlap solution for \(line.cells.map() {$0 == nil ? "nil" : String($0!)})\nand rules\n\(rules)")

    let left = computePackedLine(line: line, rules: rules)
    let encodedLeft = encodedLineForLine(line: left)
    let right = computePackedLine(line: line.reversed(), rules: rules.reversed()).reversed()
    let encodedRight = encodedLineForLine(line: right)

    // Imagine
    // orig   | | | | | | | | |
    // left   |1|1|1|1|1|2|2|2|
    // right  |0|0|0|1|1|1|1|1|

    let newLine = PartialLine(input: zip(zip(encodedLeft, encodedRight), line.cells)
        .map {
            (packed:(left:Int, right:Int), orig:Bool?) -> Bool? in
            if (orig != nil) {
                return orig
            }

            if packed.left == packed.right {
                return (packed.left % 2 == 1)
            }
            return nil
    })

    if (newLine.cells != line.cells) {
        print("Overlap(\(description)) discovered \(line.unknownCount - newLine.unknownCount) cells")
        return newLine
    }

    return nil
}

private func computePackedLine(line: PartialLine, rules: [Int]) -> PartialLine {
    // This algorithm should proceed as follows:
    //
    // Pack the runs at the extreme left without regard for the mustBe values
    // Pad with space to the right
    // Iterate from the right edge of the candidate looking for error cells.
    //
    // If the error cell is blank, but should be set:
    //      slide the run to the left of the error cell to the right such that
    //      the last cell in the run is in the place of the error cell.
    //
    // else if the error cell is set, but should be blank
    //      slide the run at the error cell to the right such that the first
    //      cell in the run is to the right of the error cell
    //
    // slides set blank into the uncovered cells

    //      [2]
    //      | | |-|x| |
    //      |m|m| | | |
    //      | | |m|m| |
    //      | | | |m|m|

    //      [2,1]
    //      | |x|x| |x|
    //      |m|m| |m| |
    //      |m|m| | |m|
    //      | |m|m| |m|

    //      [3,1]
    //      |-|x|x| | |x|
    //      |m|m|m| |m| |
    //      |m|m|m| | |m|
    //      | |m|m|m| |m|

    let potentialLine = PackedLine(rules: rules, lineLength: line.count)

    // Now scan right to left looking for contradictions
    while (true) {
        if (adjustPackingForErrors(potentialLine: potentialLine, knownLine: line)) {
            break
        }
    }

    return potentialLine.expand()
}


// Returns an 'encoded' line. The encoding represents run numbers and gap numbers
// for each position. Runs will always have odd #'s and gaps will have even #'s.
// For example:
//              | |m|m| |m| | |m|
// encodes as   |0|1|1|2|3|4|4|5|
private func encodedLineForLine(line: PartialLine) -> [Int] {
    var index = 0
    return line.cells.map {
        guard let val = $0 else { fatalError("nil encountered") }
        let currentIndexIsRun = (index % 2 == 1)    // Runs are odd, gaps are even
        if (currentIndexIsRun != val) {
            index += 1
        }
        return index
    }
}

private func adjustPackingForErrors(potentialLine: PackedLine, knownLine: PartialLine) -> Bool {
    for i in (0 ..< knownLine.count).reversed() {
        if let truth = knownLine[i] {
            let candidate = potentialLine[i]
            if candidate == truth {
                continue
            }

            let run: PackedLine.Run
            let offsetToShift: Int
            if truth {
                // Shift prior run such that its last cell is at offset i
                run = potentialLine.runPriorToOffset(offset: i)!
                offsetToShift = i - (potentialLine.runOffset(targetRun: run) + run.length - 1)
            } else {
                // Shift current run such that its first cell is at offset i + 1
                run = potentialLine.runAtOffset(offset: i)!
                offsetToShift = i + 1 - potentialLine.runOffset(targetRun: run)
            }

            if (!potentialLine.shiftRun(run: run, offset: offsetToShift)) {
                return false
            }
        }
    }

    return true
}

private struct PackedLine {
    private var runs: [Run] = []
    private let lineLength: Int
    private let totalLineSlop: Int

    fileprivate class Run {
        var extraLeadingSpace: Int
        let index: Int
        let length: Int

        init(extraLeadingSpace: Int, index: Int, length: Int) {
            self.extraLeadingSpace = extraLeadingSpace
            self.index = index
            self.length = length
        }
    }

    init(rules: [Int], lineLength: Int) {
        self.lineLength = lineLength
        var runIndex = 0
        var consumedSpace = 0
        for rule in rules {
            consumedSpace += ((runIndex > 0) ? 1 : 0) + rule
            runs.append(Run(extraLeadingSpace: 0, index: runIndex, length: rule))
            runIndex += 1
        }
        totalLineSlop = lineLength - consumedSpace
    }

    fileprivate func runOffset(targetRun: Run) -> Int {
        var offset = 0
        for run in runs {
            offset += (offset == 0 ? 0 : 1) + run.extraLeadingSpace
            if (run.index == targetRun.index) {
                return offset
            }
            offset += run.length
        }

        fatalError("Couldn't find target run")
    }

    fileprivate func runPriorToOffset(offset: Int) -> Run? {
        if (offset == 0) {
            return nil
        }

        for i in (0 ... offset - 1).reversed() {
            let run = runAtOffset(offset: i)
            if (run != nil) {
                return run
            }
        }

        return nil
    }

    fileprivate func runAtOffset(offset: Int) -> Run? {
        var i = offset
        var firstRun = true
        for run in runs {
            let leadingSpace = (firstRun ? 0 : 1) + run.extraLeadingSpace
            firstRun = false
            if (i < leadingSpace) {
                return nil
            }
            i -= leadingSpace

            if (i < run.length) {
                return run
            }
            i -= run.length
        }

        return nil
    }

    subscript(index: Int) -> Bool {
        get {
            precondition(index >= lineLength, "Invalid index")

            var i = index
            for run in runs {
                let leadingSpace = (run.index == 0 ? 0 : 1) + run.extraLeadingSpace

                if (i < leadingSpace) {
                    return false
                }
                i -= leadingSpace

                if (i < run.length) {
                    return true
                }
                i -= run.length
            }

            return false
        }
    }

    private func trailingSpaceOnLine() -> Int {
        return totalLineSlop - runs.reduce(0) {
            return $0 + $1.extraLeadingSpace; }
    }

    func expand() -> PartialLine {
        // TODO: make this class a SequenceType
        var result: [Bool?] = []
        for i in 0 ..< lineLength {
            result.append(self[i])
        }
        return PartialLine(input: result)
    }

    // This method will attempt to shift the run specified by the amount specified.
    // If it can shift that run without bumping into that subsequent run, it
    // returns true. Otherwise, if it attempts, recursively, to move the subsequent
    // range enough to avoid the collision and then returns false.
    fileprivate func shiftRun(run: Run, offset: Int) -> Bool {
        let isLastRun = run.index == runs.count - 1
        let nextRun: Run? = isLastRun ? nil : runs[run.index + 1]
        let slopAvailableForShift = isLastRun
            ? self.trailingSpaceOnLine()
            : nextRun!.extraLeadingSpace

        let shortfall = offset - slopAvailableForShift
        if (shortfall > 0) {
            // TODO: offset should become atLeastOffset
            shiftRun(run: runs[run.index + 1], offset: shortfall)
        }

        run.extraLeadingSpace += offset
        if (!isLastRun) {
            nextRun!.extraLeadingSpace -= offset
            // TODO Assert the next run had the space to give
        }

        return shortfall <= 0
    }
}
