//
// Created by Eric Patey on 12/23/15.
// Copyright (c) 2015 bouldertop. All rights reserved.
//

import Foundation

class LineSolver {
    static func execute(context: PuzzleContext, partialSolution: PartialSolution) -> PartialSolution {
        var currentBestSolution = partialSolution

        currentBestSolution.dump()

        var knownCount = 0
        while (true) {
            let beforeCount = currentBestSolution.knownCellCount()
            for rowNumber in 0 ..< context.rows {
                currentBestSolution = rowOverlap(rowNumber, currentBestSolution: currentBestSolution, context: context)
            }

            for colNumber in 0 ..< context.columns {
                currentBestSolution = columnOverlap(colNumber, currentBestSolution: currentBestSolution, context: context)
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

    private static func lineOverlapLearnings(line: PartialLine, rules: [Int], lineNumber: Int, isRow: Bool) -> [CellValue]? {
        let newLine = LineSolver.computeLineOverlap(line, rules: rules)
        return line.newCellValues(newLine, lineNumber: lineNumber, isRow: isRow)
    }

    private static func rowOverlap(rowNumber: Int, currentBestSolution: PartialSolution, context: PuzzleContext) -> PartialSolution {
        let oldLine = currentBestSolution.row(rowNumber)
        let rules = context.rowConstraints[rowNumber]
        let changes = lineOverlapLearnings(oldLine, rules: rules, lineNumber: rowNumber, isRow: true)
        return currentBestSolution.addCellValues(changes)
    }

    private static func columnOverlap(columnNumber: Int, currentBestSolution: PartialSolution, context: PuzzleContext) -> PartialSolution {
        let oldLine = currentBestSolution.column(columnNumber)
        let rules = context.columnConstraints[columnNumber]
        let changes = lineOverlapLearnings(oldLine, rules: rules, lineNumber: columnNumber, isRow: false)
        return currentBestSolution.addCellValues(changes)
    }

    private static func computeLineOverlap(line: PartialLine, rules: [Int]) -> PartialLine {
        let left         = LineSolver.computePackedLine(line, rules: rules)
        let encodedLeft  = encodedLineForLine(left)
        let right        = LineSolver.computePackedLine(line.reverse(), rules: rules.reverse()).reverse()
        let encodedRight = encodedLineForLine(right)

        return PartialLine(input: zip(encodedLeft, encodedRight)
            .map { (l, r) -> Bool? in
                if l == r {
                    return (l % 2 == 1)
                }
                return nil
            })
    }
    
    private static func encodedLineForLine(line: PartialLine) -> [Int] {
        return Array(line.aggregate(0) { (accumulator, element) -> (Int) in
             accumulator + (((accumulator % 2 == 1) != element!) ? 1 : 0)
            })
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

                let run:           PackedLine.Run
                let offsetToShift: Int
                if truth {
                    // Shift prior run such that its last cell is at offset i
                    run = potentialLine.runPriorToOffset(i)!
                    offsetToShift = i - (potentialLine.runOffset(run) + run.length - 1)
                }
                else {
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
        private var runs:          [Run] = []
        private let lineLength:    Int
        private let totalLineSlop: Int

        private class Run {
            var extraLeadingSpace: Int
            let index:             Int
            let length:            Int

            init(extraLeadingSpace: Int, index: Int, length: Int) {
                self.extraLeadingSpace = extraLeadingSpace
                self.index = index
                self.length = length
            }
        }


        init(rules: [Int], lineLength: Int) {
            self.lineLength = lineLength
            var i             = 0
            var consumedSpace = 0
            for rule in rules {
                consumedSpace += ((i > 0) ? 1 : 0) + rule
                runs.append(Run(extraLeadingSpace: 0, index: i++, length: rule))
            }
            totalLineSlop = lineLength - consumedSpace
        }

        private func runOffset(targetRun: Run) -> Int {
            var i        = 0
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
            var i        = offset
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
                var i        = index
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
            let isLastRun             = run.index == runs.count - 1
            let nextRun: Run?         = isLastRun ? nil : runs[run.index + 1]
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

extension SequenceType {
    func aggregate<T>(initial: T, combine: (accumulator: T, element: Generator.Element) -> T) -> [T] {
        var accumulator = initial
        return map { e in
            accumulator = combine(accumulator: accumulator, element: e)
            return accumulator
        }
    }
}

