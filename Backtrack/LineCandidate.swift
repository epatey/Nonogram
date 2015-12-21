//
// Created by Eric Patey on 12/24/15.
// Copyright (c) 2015 bouldertop. All rights reserved.
//

import Foundation

class LineCandidate: BacktrackCandidate {
    private let partialLine: PartialLine
    private let lineRules:   [Int]
    private let correct:     Bool?
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
            self.correct = LineCandidate.computeSequenceError(cells, thisDimension: partialLine.count, expectedInfo: lineRules)
        }
        else {
            self.correct = false
        }
    }

    var children: AnyGenerator<BacktrackCandidate> {
        if self.cells.count == partialLine.count {
            // Wish I could figure out how to use EmptyCandidate, but it conflicts with the func's return type
            return anyGenerator({
                () -> LineCandidate? in
                return nil
            })
        }

        var i: Int = 0
        return anyGenerator({
            () -> LineCandidate? in
            if (i == 2) {
                return nil
            }
            i++
            return LineCandidate(parent: self, nextCell: i == 1)
        })
    }

    func reject() -> Bool {
        return !(correct ?? true)
    }

    func accept() -> Bool {
        return correct ?? false
    }

    static func computeSequenceError<SeqBool:SequenceType where SeqBool.Generator.Element == Bool>
            (cells: SeqBool,
             thisDimension: Int,
             expectedInfo: [Int]) -> Bool? {
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
        let remainingCells    = thisDimension - thisCount
        if remainingToBetSet > remainingCells {
            //            print("bailing because can't possibly set enough")
            return false
        }

        var runLength          = 0
        var thisRowInfo: [Int] = []
        for cell in cells {
            if (cell) {
                runLength++
            }
            else {
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
            let thisRunSize     = thisRowInfo[i]
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