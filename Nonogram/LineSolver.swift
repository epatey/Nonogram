//
// Created by Eric Patey on 12/23/15.
// Copyright (c) 2015 bouldertop. All rights reserved.
//

import Foundation
import BTSwift

class LineSolver {
    typealias LineSolverAlgorithm = (line:PartialLine, rules:[Int], description: String) -> PartialLine?
    
    static func workForLine(oldLine: PartialLine, rules: [Int], description: String) -> PartialLine? {
        
        let algos:[LineSolverAlgorithm] = [OperlapAlgorithm.execute, MinMaxRangeAlgorithm.execute]
        
        var improvedLine:PartialLine? = nil
        while (true) {
            var i = 0
            var mustRepeat = false
            for algo in algos {
                let firstAlgo = i++ == 0
                if let thisImprovement = algo(line: improvedLine ?? oldLine, rules: rules, description: description) {
                    improvedLine = thisImprovement
                    if (!firstAlgo) {
                        mustRepeat = true
                    }
                }
            }
            
            if (!mustRepeat) {
                break
            }
        }
        
        return improvedLine
    }

    /*
    static func execute(partialSolution: PartialSolution) -> PartialSolution {
        var currentBestSolution = partialSolution
        let context = partialSolution.context

        currentBestSolution.dump()

        var knownCount = 0
        while (true) {
            let beforeCount = currentBestSolution.knownCellCount()
            for rowNumber in 0 ..< context.rows {
                currentBestSolution = applyAlgorithm(OperlapAlgorithm.execute,
                                                     lineNumber: rowNumber,
                                                     currentBestSolution: currentBestSolution,
                                                     lineGetter: context.rowHelper)
                currentBestSolution = applyAlgorithm(MinMaxRangeAlgorithm.execute,
                                                     lineNumber: rowNumber,
                                                     currentBestSolution: currentBestSolution,
                                                     lineGetter: context.rowHelper)
            }

            for colNumber in 0 ..< context.columns {
                currentBestSolution = applyAlgorithm(OperlapAlgorithm.execute,
                                                     lineNumber: colNumber,
                                                     currentBestSolution: currentBestSolution,
                                                     lineGetter: context.columnHelper
                )
                currentBestSolution = applyAlgorithm(MinMaxRangeAlgorithm.execute,
                                                     lineNumber: colNumber,
                                                     currentBestSolution: currentBestSolution,
                                                     lineGetter: context.columnHelper)
            }

            // knownCount = self.knownCellCount(context.mustBe)
            knownCount = currentBestSolution.knownCellCount()

            print("Line Solver computed \(knownCount - beforeCount) known cells. (\(knownCount) out of \(context.rows * context.columns))")
            currentBestSolution.dump()

            if (knownCount - beforeCount == 0) {
                break;
            }
        }

        return currentBestSolution
    }

    private static func applyAlgorithm(algorithm: LineSolverAlgorithm,
                                       lineNumber: Int,
                                       currentBestSolution: PartialSolution,
                                       lineGetter: LineHelper) -> PartialLine? {
        let oldLine = lineGetter.getLine(partialSolution: currentBestSolution, lineNumber: lineNumber)
        if oldLine.complete {
            return nil
        }
        let rules = lineGetter.getRules(lineNumber: lineNumber)
        return algorithm(line: oldLine, rules: rules)
    }
    */
}

class LineUtilities {
    static func encodedLineForLine(line: PartialLine) -> [Int] {
        return Array(line.aggregate(0) {
            (accumulator, element) -> (Int) in
            accumulator + (((accumulator % 2 == 1) != element!) ? 1 : 0)
        })
    }
}

class MinMaxRangeAlgorithm {
    static func execute(line: PartialLine, rules: [Int], description: String) -> PartialLine? {
        if (line.complete) {
            return nil
        }
        let ltrResults = xworkTheEdges(line.cells, rules: rules)
        let rtlResults = xworkTheEdges((ltrResults ?? line.cells).reverse(), rules: rules.reverse())

        guard let totalResults = rtlResults?.reverse() ?? ltrResults else {
            return nil
        }

        let result = PartialLine(input: totalResults)
        
        print("MinMax(\(description)) discovered \(line.unknownCount - result.unknownCount) cells")

        return result
    }


    static func xworkTheEdges(cells: [Bool?], rules: [Int]) -> [Bool?]? {
        let offsetsChanged = intWorkTheEdges(cells, rules: rules)
        if offsetsChanged.count > 0 {
            var newCells = cells
            for x in offsetsChanged {
                newCells[x.0] = x.1
            }
            return newCells
        }

        return nil
    }

    static func intWorkTheEdges(cells: [Bool?], rules: [Int]) -> [(Int, Bool)] {
        let rule = rules[0]

        var leadingFalses = 0
        for x in cells {
            if x == false {
                leadingFalses++
            } else {
                break
            }
        }


        let maxRunOffsetFromEdge = leadingFalses + rule - 1
        var maybeFirstTrueOffset: Int? = nil
        for i in leadingFalses ... maxRunOffsetFromEdge {
            if cells[i] == true {
                maybeFirstTrueOffset = i
                break
            }
        }

        var newCells: [(Int, Bool)] = []
        guard let firstTrueOffset = maybeFirstTrueOffset else {
            return newCells
        }

        if (firstTrueOffset < maxRunOffsetFromEdge) {
            for i in firstTrueOffset + 1 ... maxRunOffsetFromEdge {
                if cells[i] == nil {
                    newCells.append((i, true))
                }
            }
        }

        if (firstTrueOffset == leadingFalses + 0) {
            let lastRun = rules.count == 1
            let trailingFalseOffset = maxRunOffsetFromEdge + 1
            if (lastRun) {
                // All cells after the run must be false
                for i in trailingFalseOffset ..< cells.count {
                    if (cells[i] != false) {
                        newCells.append((i, false))
                    }
                }
            } else {
                // The single cell after the run must be false
                // Add the trailing false if we can
                if (cells[trailingFalseOffset] != false) {
                    newCells.append((trailingFalseOffset, false))
                }

                // Recurse for the next run
                let rec = intWorkTheEdges(Array(cells.suffixFrom(trailingFalseOffset + 1)), rules: Array(rules.suffixFrom(1)))
                let x = rec.map() {
                    ($0.0 + trailingFalseOffset + 1, $0.1)
                }
                newCells.appendContentsOf(x)
            }
        }

        return newCells
    }
}

// Move me to BTUtils/Array
func ==<T: Equatable>(lhs: [T?], rhs: [T?]) -> Bool {
    if lhs.count != rhs.count { return false }
    for (l,r) in zip(lhs,rhs) {
        if l != r { return false }
    }
    return true
}


class OperlapAlgorithm {
    static func execute(line: PartialLine, rules: [Int], description: String) -> PartialLine? {
        if (line.complete) {
            return nil
        }
        
//        print("Getting line overlap solution for \(line.cells.map() {$0 == nil ? "nil" : String($0!)})\nand rules\n\(rules)")

        let left = computePackedLine(line, rules: rules)
        let encodedLeft = LineUtilities.encodedLineForLine(left)
        let right = computePackedLine(line.reverse(), rules: rules.reverse()).reverse()
        let encodedRight = LineUtilities.encodedLineForLine(right)

        let newLine = PartialLine(input: zip(zip(encodedLeft, encodedRight), line)
        .map {
            (x:(l:Int, r:Int), orig:Bool?) -> Bool? in
            if (orig != nil) {
                return orig
            }
            
            if x.l == x.r {
                return (x.l % 2 == 1)
            }
            return nil
        })
        
        let result:PartialLine? = (newLine.cells == line.cells) ? nil : newLine
        
        if result != nil {
            print("Overlap(\(description)) discovered \(line.unknownCount - newLine.unknownCount) cells")
        }
        
        return result
    }

    private static func computePackedLine(line: PartialLine, rules: [Int]) -> PartialLine {
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
            if (adjustPackingForErrors(potentialLine, knownLine: line)) {
                break
            }
        }

        return potentialLine.expand()
    }

    private static func adjustPackingForErrors(potentialLine: PackedLine, knownLine: PartialLine) -> Bool {
        for i in (0 ..< knownLine.count).reverse() {
            if let truth = knownLine[i] {
                let candidate = potentialLine[i]
                if candidate == truth {
                    continue
                }

                let run: PackedLine.Run
                let offsetToShift: Int
                if truth {
                    // Shift prior run such that its last cell is at offset i
                    run = potentialLine.runPriorToOffset(i)!
                    offsetToShift = i - (potentialLine.runOffset(run) + run.length - 1)
                } else {
                    // Shift current run such that its first cell is at offset i + 1
                    run = potentialLine.runAtOffset(i)!
                    offsetToShift = i + 1 - potentialLine.runOffset(run)
                }

                if (!potentialLine.shiftRun(run, offset: offsetToShift)) {
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

        private class Run {
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
            var i = 0
            var consumedSpace = 0
            for rule in rules {
                consumedSpace += ((i > 0) ? 1 : 0) + rule
                runs.append(Run(extraLeadingSpace: 0, index: i++, length: rule))
            }
            totalLineSlop = lineLength - consumedSpace
        }

        private func runOffset(targetRun: Run) -> Int {
            var i = 0
            var firstRun = true
            for run in runs {
                i += (firstRun ? 0 : 1) + run.extraLeadingSpace
                firstRun = false
                if (run.index == targetRun.index) {
                    return i
                }
                i += run.length
            }

            fatalError("Couldn't find target run")
        }

        private func runPriorToOffset(offset: Int) -> Run? {
            if (offset == 0) {
                return nil
            }

            for i in (0 ... offset - 1).reverse() {
                let run = runAtOffset(i)
                if (run != nil) {
                    return run
                }
            }

            return nil
        }

        private func runAtOffset(offset: Int) -> Run? {
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
                if (index >= lineLength) {
                    preconditionFailure("Invalid index")
                }
                var i = index
                var firstRun = true
                for run in runs {
                    let leadingSpace = (firstRun ? 0 : 1) + run.extraLeadingSpace
                    firstRun = false

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
        private func shiftRun(run: Run, offset: Int) -> Bool {
            let isLastRun = run.index == runs.count - 1
            let nextRun: Run? = isLastRun ? nil : runs[run.index + 1]
            let slopAvailableForShift = isLastRun
                    ? self.trailingSpaceOnLine()
                    : nextRun!.extraLeadingSpace

            let shortfall = offset - slopAvailableForShift
            if (shortfall > 0) {
                // TODO: offset should become atLeastOffset
                shiftRun(runs[run.index + 1], offset: shortfall)
            }

            run.extraLeadingSpace += offset
            if (!isLastRun) {
                nextRun!.extraLeadingSpace -= offset
                // TODO Assert the next run had the space to give
            }

            return shortfall <= 0
        }
    }

}
