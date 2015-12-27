//
//  Puzzle.swift
//  Backtrack
//
//  Created by Eric Patey on 12/14/15.
//  Copyright © 2015 bouldertop. All rights reserved.
//

import Foundation

class PartialLine : SequenceType {
    let cells: [Bool?]

    init(count: Int) {
        cells = [Bool?](count: count, repeatedValue: nil)
    }

    init<BoolOptionSequence:SequenceType where BoolOptionSequence.Generator.Element == Bool?>(input: BoolOptionSequence) {
        cells = Array<Bool?>(input)
    }
    private init(cells:[Bool?]) {
        self.cells = cells
    }

    typealias Generator = Array<Bool?>.Generator
    func generate() -> Generator {
        return cells.generate()
    }
    var count: Int {
        get  {
            return cells.count
        }
    }

    func reverse() -> PartialLine {
        return PartialLine(cells: cells.reverse())
    }

    subscript(index: Int) -> Bool? {
        return cells[index]
    }

    func newCellValues(newLine: PartialLine,
                       lineNumber: Int,
                       isRow: Bool) -> [CellValue]? {
        let x: (lineNumber:Int, lineOffset:Int, value:Bool) -> CellValue
        if (isRow) {
            x = rowCell
        }
        else {
            x = columnCell
        }

        return PartialLine.newCellValuesx(self,
                              newLine: newLine,
                              lineNumber: lineNumber,
                              changeCreator: x)
    }

    private static func newCellValuesx(oldLine: PartialLine,
                                       newLine: PartialLine,
                                       lineNumber: Int,
                                       changeCreator: (lineNumber:Int, lineOffset:Int, value:Bool) -> CellValue) -> [CellValue]? {
        var changes: [CellValue]?
        for lineOffset in 0 ..< oldLine.cells.count {
            guard let newValue = newLine.cells[lineOffset] where oldLine.cells[lineOffset] == nil else {
                continue
            }

            if (changes == nil) {
                changes = []
            }
            let change = changeCreator(lineNumber: lineNumber, lineOffset: lineOffset, value: newValue)
            changes!.append(change)
        }

        return changes
    }


}

typealias DEPRECATED_PartialLine = [Bool?]
typealias CellValue = (col:Int, row:Int, value:Bool)

// TODO: These should go into some sort of polymorphic cell vs column helper
func rowCell(lineNumber: Int, lineOffset: Int, value: Bool) -> CellValue {
    return (col: lineOffset, row: lineNumber, value: value)
}

func columnCell(lineNumber: Int, lineOffset: Int, value: Bool) -> CellValue {
    return (col: lineNumber, row: lineOffset, value: value)
}


class PuzzleContext {
    let rows           = 10
    let columns        = 5
    let rowConstraints = [
        [2],
        [2, 1],
        [1, 1],
        [3],
        [1, 1],
        [1, 1],
        [2],
        [1, 1],
        [1, 2],
        [2],
    ]

    let columnConstraints = [
        [2,1],
        [2,1,3],
        [7],
        [1,3],
        [2,1],
    ]

let knownCells: [(col:Int, row:Int)] = [
    ]

    /*
var rowsSolutions: [[BacktrackCandidate]] = []

    let rows           = 25
    let columns        = 25
    let rowConstraints = [
            [7, 3, 1, 1, 7],
            [1, 1, 2, 2, 1, 1],
            [1, 3, 1, 3, 1, 1, 3, 1],
            [1, 3, 1, 1, 6, 1, 3, 1],
            [1, 3, 1, 5, 2, 1, 3, 1],
            [1, 1, 2, 1, 1],
            [7, 1, 1, 1, 1, 1, 7],
            [3, 3],
            [1, 2, 3, 1, 1, 3, 1, 1, 2],
            [1, 1, 3, 2, 1, 1],
            [4, 1, 4, 2, 1, 2],
            [1, 1, 1, 1, 1, 4, 1, 3],
            [2, 1, 1, 1, 2, 5],
            [3, 2, 2, 6, 3, 1],
            [1, 9, 1, 1, 2, 1],
            [2, 1, 2, 2, 3, 1],
            [3, 1, 1, 1, 1, 5, 1],
            [1, 2, 2, 5],
            [7, 1, 2, 1, 1, 1, 3],
            [1, 1, 2, 1, 2, 2, 1],
            [1, 3, 1, 4, 5, 1],
            [1, 3, 1, 3, 10, 2],
            [1, 3, 1, 1, 6, 6],
            [1, 1, 2, 1, 1, 2],
            [7, 2, 1, 2, 5],
    ]

    let columnConstraints = [
            [7, 2, 1, 1, 7],
            [1, 1, 2, 2, 1, 1],
            [1, 3, 1, 3, 1, 3, 1, 3, 1],
            [1, 3, 1, 1, 5, 1, 3, 1],
            [1, 3, 1, 1, 4, 1, 3, 1],
            [1, 1, 1, 2, 1, 1],
            [7, 1, 1, 1, 1, 1, 7],
            [1, 1, 3],
            [2, 1, 2, 1, 8, 2, 1],
            [2, 2, 1, 2, 1, 1, 1, 2],
            [1, 7, 3, 2, 1],
            [1, 2, 3, 1, 1, 1, 1, 1],
            [4, 1, 1, 2, 6],
            [3, 3, 1, 1, 1, 3, 1],
            [1, 2, 5, 2, 2],
            [2, 2, 1, 1, 1, 1, 1, 2, 1],
            [1, 3, 3, 2, 1, 8, 1],
            [6, 2, 1],
            [7, 1, 4, 1, 1, 3],
            [1, 1, 1, 1, 4],
            [1, 3, 1, 3, 7, 1],
            [1, 3, 1, 1, 1, 2, 1, 1, 4],
            [1, 3, 1, 4, 3, 3],
            [1, 1, 2, 2, 2, 6, 1],
            [7, 1, 3, 2, 1, 1],
    ]

    let knownCells: [(col:Int, row:Int)] = [
            (3, 3),
            (4, 3),
            (12, 3),
            (13, 3),
            (21, 3),
            (6, 8),
            (7, 8),
            (10, 8),
            (14, 8),
            (15, 8),
            (18, 8),
            (6, 16),
            (11, 16),
            (16, 16),
            (20, 20),
            (3, 21),
            (4, 21),
            (9, 21),
            (10, 21),
            (15, 21),
            (20, 21),
            (21, 21),
    ]
*/
}

struct ColumnSequence: SequenceType {
    typealias Generator = AnyGenerator<Bool>
    let cells:      [Bool]
    //        let rowsInThisColumn: Int
    let firstIndex: Int
    let columns:    Int

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
        return anyGenerator({
            () -> Bool? in
            if (i >= self.cells.count) {
                return nil
            }

            let result = self.cells[i]
            i += self.columns
            return result
        })
    }
}

class Puzzle {
    static func findLineSolutions(context: PuzzleContext, partialSolution: PartialSolution, rowAspect: Bool) -> PartialSolution {
        let lock: AnyObject = Int(0)
        let count           = rowAspect ? context.rows : context.columns
        var solutions       = [[BacktrackCandidate]](count: count, repeatedValue: [])
//        dispatch_apply(count, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
//            lineNum -> Void in


        var currentSolution = partialSolution
        for lineNum in 0 ..< count {
            let line: PartialLine = rowAspect ? currentSolution.row(lineNum) : currentSolution.column(lineNum)
            let lineMissing = line.reduce(0) {
                $0 + ($1 == nil ? 1 : 0)
            }
            if (lineMissing == 0) {
                continue
            }

            let lineRules     = rowAspect ? context.rowConstraints[lineNum] : context.columnConstraints[lineNum]
            let root          = LineCandidate(partialLine: line, lineRules: lineRules)
            let lineSolutions = backtrackSolve(root)!

//            objc_sync_enter(lock)
            solutions[lineNum] = lineSolutions

            if (lineSolutions.count == 1) {
                let lineSolution                        = (lineSolutions[0] as! LineCandidate).cells
                let partialLine = PartialLine(input: lineSolution.map() { $0 })

                let ncv = line.newCellValues(partialLine, lineNumber: lineNum, isRow: rowAspect)
                if (ncv != nil) {
                    currentSolution = currentSolution.addCellValues(ncv)
                }

                /*
                if (rowAspect) {
                    context.mustBe[lineNum] = lineSolution.map() {
                        $0
                    }
                }
                else {
                    var i = 0
                    for knownCell in lineSolution {
                        context.mustBe[i++][lineNum] = knownCell
                    }
                }
*/
            }
//            objc_sync_exit(lock)

            print("\(rowAspect ? "Row" : "Column") \(lineNum) has \(lineSolutions.count) solutions")
        }

        return currentSolution
    }

    static func backtrackSolve(candidate: BacktrackCandidate) -> [BacktrackCandidate]? {
        if (candidate.reject()) {
            return nil
        }

        var result: [BacktrackCandidate]? = nil
        if (candidate.accept()) {
            result = [candidate]
        }

        for nextCandidate in candidate.children {
            if let childsolutions = backtrackSolve(nextCandidate) {
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
}

