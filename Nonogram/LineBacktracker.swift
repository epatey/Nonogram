//
//  LineBacktracker.swift
//  Backtrack
//
//  Created by Eric Patey on 12/27/15.
//  Copyright © 2015 bouldertop. All rights reserved.
//

import Foundation

class LineBacktracker {
    static func executeOld(partialSolution: PartialSolution) -> PartialSolution {
        return partialSolution
        /*
        let context = partialSolution.context
        var currentBest = partialSolution
        var knownCount = currentBest.knownCellCount()

        while (true) {
            currentBest = findLineSolutions(currentBest, lineGetter: context.rowHelper)
            currentBest = findLineSolutions(currentBest, lineGetter: context.columnHelper)
            let newKnownCount = currentBest.knownCellCount()

            print("Line Backtracker computed \(newKnownCount - knownCount) known cells. (\(newKnownCount) out of \(context.rows * context.columns))")
            currentBest.dump()

            if (newKnownCount - knownCount == 0) {
                break;
            }
            knownCount = newKnownCount
        }

        return currentBest
*/
    }
    
    static func execute(line: PartialLine, rules: [Int], stopAfter:Int?, description: String) -> PartialLine? {
        let root = LineCandidate(partialLine: line, lineRules: rules)
        let ls = Backtracker.solve(candidate: root, stopAfter: stopAfter)
        let completeSolutionSet = !ls.1
        guard let lineSolutions = ls.0 else {
            return nil
        }
        
        if (lineSolutions.count == 1) {
            let lineSolution = (lineSolutions[0] as! LineCandidate).cells
            let partialLine = PartialLine(input: lineSolution.map() {
                $0
                })
            return partialLine
        }
        
        if (!completeSolutionSet) {
            return nil
        }
        
        // If we have a complete set of solutions, see if any of the offsets have the same value for all solutions
        let sol0 = (lineSolutions[0] as! LineCandidate).cells
        let count = sol0.count
        var matches:[(lineOffset:Int, value:Bool)]?
        for i in 0..<count {
            if line.cells[i] != nil {
                continue
            }
            var mismatchFound = false
            let ref = sol0[i]
            for solnum in 1..<lineSolutions.count {
                let solx = (lineSolutions[solnum] as! LineCandidate).cells
                if (solx[i] != ref) {
                    mismatchFound = true
                    break;
                }
            }
            if (!mismatchFound) {
                if (matches == nil) {
                    matches = []
                }
                matches!.append((i, ref))
            }
        }
        
        if matches == nil {
            return nil
        }
        
        var newLineCells = line.cells
        for (i, value) in matches! {
            newLineCells[i] = value
        }
        
        let result = PartialLine(input: newLineCells)
        print("Backtrack(\(description)) discovered \(line.unknownCount - result.unknownCount) cells")
        return result
    }

    class LineCandidate: BacktrackCandidate {
        private let partialLine: PartialLine
        private let lineRules: [Int]
        private let correct: Bool?
        let cells: [Bool]

        init(partialLine: PartialLine, lineRules: [Int]) {
            self.partialLine = partialLine
            self.lineRules = lineRules
            self.cells = []
            self.correct = nil
        }

        init(parent: LineCandidate, nextCell: Bool) {
            self.partialLine = parent.partialLine
            self.cells = parent.cells + [nextCell]
            self.lineRules = parent.lineRules

            let maybeMust = partialLine[self.cells.count - 1]

            if maybeMust == nil || maybeMust! == nextCell {
                self.correct = LineCandidate.computeSequenceError(cells: cells, thisDimension: partialLine.count, expectedInfo: lineRules)
            } else {
                self.correct = false
            }
        }

        var children: [BacktrackCandidate] {
            if self.cells.count == partialLine.count {
                // Wish I could figure out how to use EmptyCandidate, but it conflicts with the func's return type
                return []
            }

            let nextCell = partialLine[cells.count]
            let c:[Bool]
            if let nc = nextCell {
                c = [nc]
            }
            else {
                c = [true, false]
            }
            var i: Int = 0
            return anyGenerator({
                () -> LineCandidate? in
                if (i == c.count) {
                    return nil
                }
                return LineCandidate(parent: self, nextCell: c[i++])
            })
        }

        func reject() -> Bool {
            return !(correct ?? true)
        }

        func accept() -> Bool {
            return correct ?? false
        }

        static func computeSequenceError(cells: [Bool], thisDimension: Int, expectedInfo: [Int]) -> Bool? {
            let thisRowTotalExpectedSet = expectedInfo.reduce(0) {
                $0 + $1
            }
            let thisRowTotalSet = cells.reduce(0) {
                $0 + ($1 ? 1 : 0)
            }

            let thisCount = cells.reduce(0) {
                $0.0 + 1
            }

            if thisRowTotalSet > thisRowTotalExpectedSet {
                //            print("bailing because too many set")
                return false
            }

            let remainingToBetSet = thisRowTotalExpectedSet - thisRowTotalSet
            let remainingCells = thisDimension - thisCount
            if remainingToBetSet > remainingCells {
                //            print("bailing because can't possibly set enough")
                return false
            }

            var runLength = 0
            var thisRowInfo: [Int] = []
            for cell in cells {
                if (cell) {
                    runLength += 1
                } else {
                    if (runLength != 0) {
                        thisRowInfo.append(runLength)
                        runLength = 0
                    }
                }
            }

            if (runLength != 0) {
                thisRowInfo.append(runLength)
            }

            if thisRowInfo.count > expectedInfo.count {
                //            print("bailing because already have too many runs")
                return false
            }

            // If we have the entire row, it must match
            if (remainingCells == 0) {
                return thisRowInfo == expectedInfo
            }

            for i in 0 ..< thisRowInfo.count {
                let thisRunSize = thisRowInfo[i]
                let expectedRunSize = expectedInfo[i]

                // If it's not the last run we're aware of, it has to match
                if (i < thisRowInfo.count - 1 && thisRunSize != expectedRunSize) {
                    //                print("bailing because non-last run doesn't match")
                    return false
                }

                // If it is the last match we're aware of, it can't be bigger than expected
                if (thisRunSize > expectedRunSize) {
                    //                print("bailing because last run is too big")
                    return false
                }
            }

            // For now, we'll return nil. This needs to be optimized to account for the
            // very common scenario of knowing that it's bogus before having the entire row
            return nil
        }
    }

}
