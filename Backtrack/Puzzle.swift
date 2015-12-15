//
//  Puzzle.swift
//  Backtrack
//
//  Created by Eric Patey on 12/14/15.
//  Copyright © 2015 bouldertop. All rights reserved.
//

import Foundation

class PuzzleContext {
    let rows = 25
    let columns = 25
    let rowConstraints = [
        [7, 3, 1, 1, 7],
        [1,1,2,2,1,1],
        [1,3,1,3,1,1,3,1],
        [1,3,1,1,6,1,3,1],
        [1,3,1,5,2,1,3,1],
        [1,1,2,1,1],
        [7,1,1,1,1,1,7],
        [3,3],
        [1,2,3,1,1,3,1,1,2],
        [1,1,3,2,1,1],
        [4,1,4,2,1,2],
        [1,1,1,1,1,4,1,3],
        [2,1,1,1,2,5],
        [3,2,2,6,3,1],
        [1,9,1,1,2,1],
        [2,1,2,2,3,1],
        [3,1,1,1,1,5,1],
        [1,2,2,5],
        [7,1,2,1,1,1,3],
        [1,1,2,1,2,2,1],
        [1,3,1,4,5,1],
        [1,3,1,3,10,2],
        [1,3,1,1,6,6],
        [1,1,2,1,1,2],
        [7,2,1,2,5],
    ]

    let columnConstraints = [
        [7,2,1,1,7],
        [1,1,2,2,1,1],
        [1,3,1,3,1,3,1,3,1],
        [1,3,1,1,5,1,3,1],
        [1,3,1,1,4,1,3,1],
        [1,1,1,2,1,1],
        [7,1,1,1,1,1,7],
        [1,1,3],
        [2,1,2,1,8,2,1],
        [2,2,1,2,1,1,1,2],
        [1,7,3,2,1],
        [1,2,3,1,1,1,1,1],
        [4,1,1,2,6],
        [3,3,1,1,1,3,1],
        [1,2,5,2,2],
        [2,2,1,1,1,1,1,2,1],
        [1,3,3,2,1,8,1],
        [6,2,1],
        [7,1,4,1,1,3],
        [1,1,1,1,4],
        [1,3,1,3,7,1],
        [1,3,1,1,1,2,1,1,4],
        [1,3,1,4,3,3],
        [1,1,2,2,2,6,1],
        [7,1,3,2,1,1],
    ]

    let knownCells:[(col:Int, row:Int)] = [
        (3, 3),
        (3, 4),
        (3, 12),
        (3, 13),
        (3, 21),
        (8, 6),
        (8, 7),
        (8, 10),
        (8, 14),
        (8, 15),
        (8, 18),
        (16, 6),
        (16, 11),
        (16, 16),
        (16, 20),
        (21, 3),
        (21, 4),
        (21, 9),
        (21, 10),
        (21, 15),
        (21, 20),
        (21, 21),
    ]

    var mustBe:[[Bool?]]
    init() {
        mustBe = [[Bool?]](count: columns, repeatedValue: [Bool?](count: rows, repeatedValue: nil))
    }
}

protocol Candidate {
    func reject() -> Bool
    func accept() -> Bool
    var children: AnyGenerator<Candidate> {get}
}

class RowColCandidate: Candidate {
    private let context:PuzzleContext
    private let row: Bool
    private let rowColNumber: Int
    private let rowColSize:     Int
    let cells:          [Bool]
    private let runConstraints: [Int]
    private let correct:        Bool?

    init(context:PuzzleContext, rowSize: Int, runConstraints:[Int], row: Bool, rowColNumber: Int) {
        self.context = context
        self.row = row
        self.rowColNumber = rowColNumber
        self.rowColSize = rowSize
        self.cells = []
        self.runConstraints = runConstraints
        self.correct = nil
    }
    
    init(parent: RowColCandidate, nextCell: Bool) {
        self.context = parent.context
        self.row = parent.row
        self.rowColNumber = parent.rowColNumber
        self.rowColSize = parent.rowColSize
        self.cells = parent.cells + [nextCell]
        self.runConstraints = parent.runConstraints

        let eyeeee = self.cells.count - 1
        let maybeMust = self.row ? self.context.mustBe[rowColNumber][eyeeee] : self.context.mustBe[eyeeee][rowColNumber]

        if maybeMust == nil || maybeMust! == nextCell {
            self.correct = RowColCandidate.computeSequenceError(cells, thisDimension: self.rowColSize, expectedInfo: self.runConstraints)
        }
        else {
            self.correct = false
        }
    }

    var children: AnyGenerator<Candidate> {
        if self.cells.count == (self.row ? context.columns : context.rows) {
            // Wish I could figure out how to use EmptyCandidate, but it conflicts with the func's return type
            return anyGenerator({ () -> RowColCandidate? in
                return nil
            })
        }

        var i:Int = 0
        return anyGenerator({ () -> RowColCandidate? in
            if (i == 2) {
                return nil
            }
            i++
            return RowColCandidate(parent: self, nextCell: i == 1)
        })
    }

    func reject() -> Bool {
        return !(correct ?? true)
    }

    func accept() -> Bool {
        return correct ?? false
    }

    private static func computeSequenceError<SeqBool:SequenceType where SeqBool.Generator.Element == Bool>
        (cells: SeqBool,
        thisDimension: Int,
        expectedInfo: [Int]) -> Bool? {
            let thisRowTotalExpectedSet = expectedInfo.reduce(0) {
                (total, this) -> Int in
                return total + this
            }
            let thisRowTotalSet = cells.reduce(0) {
                (total, this) -> Int in
                return total + (this ? 1 : 0)
            }
            let thisCount = cells.reduce(0) {
                (total, this) -> Int in
                return total + 1
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

class PuzzleCandidate {
    let cells:[Bool]
    private let last:Bool
    private let parent: PuzzleCandidate?
    private let correct: Bool?

    init() {
        cells = []
        last = false
        parent = nil
        correct = nil
    }

    init(context: PuzzleContext, parent: PuzzleCandidate, nextCell: Bool) {
        self.parent = parent
        cells = parent.cells + [nextCell]
        last = nextCell
        correct = PuzzleCandidate.checkCorrectness(context, cells: cells)
    }

    func dump(context: PuzzleContext) {
        for i in 0..<context.rows {
            let startIndex = i * context.columns
            let endIndex = min(startIndex + context.columns, cells.count) - 1
            let slice = cells[startIndex...endIndex]
            print(slice)
        }
    }

    private static func checkCorrectness(context: PuzzleContext, cells:[Bool]) -> Bool? {
        guard context.rowConstraints.count == context.rows else {
            fatalError()
        }

        // This method assumes that all full rows/columns are valid. Otherwise, we
        // wouldn't be here.

        if ((checkRows(context, cells: cells) ?? true) == false) {
            return false
        }

        return checkColumns(context, cells: cells)
    }

    private static func checkRows(context: PuzzleContext, cells:[Bool]) -> Bool? {
        let inProgressRow = (cells.count - 1) / context.columns
        let expectedRowInfo = context.rowConstraints[inProgressRow]
        let rowCells = cells.suffixFrom(inProgressRow * context.columns)

//        print("attempt with \(inProgressRow + 1) valid rows")

        let trailingRowCorrect = computeSequenceError(rowCells, thisDimension: context.rows, expectedInfo: expectedRowInfo)
//        let trailingRowCorrect = computeRowError(context, rowCells: rowCells, expectedRowInfo: expectedRowInfo)
        if let lrc = trailingRowCorrect {
            if !lrc {
                return false
            }

            if (inProgressRow == context.rows - 1) {
                return true
            }

            return nil
        }
        else {
            return nil
        }
    }

    private static func checkColumns(context: PuzzleContext, cells:[Bool]) -> Bool? {
        for i in 0..<context.columns {
            let expectedColumnInfo = context.columnConstraints[i]
            if (computeColumnError(context, cells: cells, columnNumber: i, expectedColumnInfo: expectedColumnInfo) ?? true == false) {
                return false
            }
        }

        return cells.count == context.rows * context.columns ? true : nil
    }

    struct ColumnSequence : SequenceType {
        typealias Generator = AnyGenerator<Bool>
        let cells: [Bool]
//        let rowsInThisColumn: Int
        let firstIndex: Int
        let columns: Int

        init(cells: [Bool], columnCount: Int, columnNum: Int) {
            self.cells = cells
            self.columns = columnCount
            self.firstIndex = columnNum
//            let fullRows = (cells.count - 1) / columnCount
//            let columnsInLastRow  = cells.count % columnCount
//            self.rowsInThisColumn = fullRows + columnsInLastRow > columnNum ? 1 : 0
        }

        func generate() -> Generator {
            var i = firstIndex
            return anyGenerator({ () -> Bool? in
                if (i >= self.cells.count) {
                    return nil
                }

                let result = self.cells[i]
                i += self.columns
                return result
            })
        }

    }

    private static func computeSequenceError<SeqBool:SequenceType where SeqBool.Generator.Element == Bool>
            (cells: SeqBool,
             thisDimension: Int,
             expectedInfo: [Int]) -> Bool? {
        let thisRowTotalExpectedSet = expectedInfo.reduce(0) {
            (total, this) -> Int in
            return total + this
        }
        let thisRowTotalSet = cells.reduce(0) {
            (total, this) -> Int in
            return total + (this ? 1 : 0)
        }
        let thisCount = cells.reduce(0) {
            (total, this) -> Int in
            return total + 1
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

    private static func computeColumnError(context: PuzzleContext, cells:[Bool], columnNumber: Int, expectedColumnInfo:[Int]) -> Bool? {
        let foo = ColumnSequence(cells: cells, columnCount: context.columns, columnNum: columnNumber)
        return computeSequenceError(foo, thisDimension: context.columns, expectedInfo: expectedColumnInfo)
    }
    
}

class Puzzle  {
    func bt(context: PuzzleContext, candidate: PuzzleCandidate) {
        if (reject(context, candidate: candidate)) {
            return
        }

        if (accept(context, candidate: candidate)) {
            output(context, candidate: candidate)
//            exit(0)
        }

        var maybeNextCandidate = first(context, candidate: candidate)
        while true {
            if let nextCandidate = maybeNextCandidate {
                bt(context, candidate: nextCandidate)
                maybeNextCandidate = next(context, candidate: nextCandidate)
            }
            else {
                break
            }
        }
    }

     static func findRowColSolutions(context: PuzzleContext, rows: Bool) -> [[Candidate]] {
        let lock:AnyObject = Int(0)
        let count = rows ? context.rows : context.columns
        var solutions: [[Candidate]] = [[Candidate]](count: count, repeatedValue: [])
        dispatch_apply(count, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            rowColNum -> Void in
            let root = RowColCandidate(context: context,
                rowSize: context.columns,
                runConstraints: rows ? context.rowConstraints[rowColNum] : context.columnConstraints[rowColNum],
                row: rows,
                rowColNumber: rowColNum)
            let rowColSolutions = btRow(root)!

            objc_sync_enter(lock)
            solutions[rowColNum] = rowColSolutions
            objc_sync_exit(lock)


            if (rowColSolutions.count == 1) {
                let knownCells = (rowColSolutions[0] as! RowColCandidate).cells
                objc_sync_enter(lock)
                if (rows) {
                    context.mustBe[rowColNum] = knownCells.map() {$0}
                }
                else {
                    // code me
                    var i = 0
                    for knownCell in knownCells {
                        context.mustBe[i++][rowColNum] = knownCell
                    }
                }
                objc_sync_exit(lock)
            }

            print("\(rows ? "Row" : "Column") \(rowColNum) has \(rowColSolutions.count) solutions")
        }

        return solutions
    }

    static func btRow(candidate: Candidate) -> [Candidate]? {
        if (candidate.reject()) {
            return nil
        }

        var result:[Candidate]? = nil
        if (candidate.accept()) {
            result = [candidate]
        }

        for nextCandidate in candidate.children {
            if let childsolutions = btRow(nextCandidate) {
                if let r = result {
                    result = r + childsolutions
                }
                else {
                    result = childsolutions
                }
            }
        }

        return result
    }

    func root(context: PuzzleContext) -> PuzzleCandidate {
        return PuzzleCandidate()
    }

    func reject(context: PuzzleContext, candidate: PuzzleCandidate) -> Bool {
        if let correct = candidate.correct {
            return !correct
        }
        return false
    }

    func accept(context: PuzzleContext, candidate: PuzzleCandidate) -> Bool {
//        print(candidate.cells)
        return candidate.correct ?? false
    }

    func first(context: PuzzleContext, candidate: PuzzleCandidate) -> PuzzleCandidate? {
        if (candidate.cells.count == context.rows * context.columns) {
            return nil
        }

        return PuzzleCandidate(context: context, parent: candidate, nextCell: false)
    }

    func next(context: PuzzleContext, candidate: PuzzleCandidate) -> PuzzleCandidate? {
        if (candidate.last) {
            return nil
        }
        return PuzzleCandidate(context: context, parent: candidate.parent!, nextCell: true)
    }

    func output(context: PuzzleContext, candidate: PuzzleCandidate) {
        print("SOLUTION:")
        candidate.dump(context)
    }
}