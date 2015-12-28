//
// Created by Eric Patey on 12/24/15.
// Copyright (c) 2015 bouldertop. All rights reserved.
//

import Foundation

class PartialSolution {
    private let rows: [PartialLine]
    let context: PuzzleContext

    init(context: PuzzleContext) {
        rows = PartialSolution.addKnownCells(context.rows,
                                             columns: context.columns,
                                             inputCells: nil,
                                             cellsToAdd: context.knownCells.map() {
                                                 ($0, $1, true)
                                             })
        self.context = context
    }

    var rowHelper: LineHelper {
        get {
            return LineHelper(getLine: { self.row($0) },
                              getRules: { self.context.rowConstraints[$0] },
                              getCellValue: { (col: $1, row: $0, value: $2) },
                              getLineCount: { self.context.rows },
                              getDescription: { "Row" })
        }
    }

    var columnHelper: LineHelper {
        get {
            return LineHelper(getLine: { self.column($0) },
                              getRules: { self.context.columnConstraints[$0] },
                              getCellValue: { (col: $0, row: $1, value: $2) },
                              getLineCount: { self.context.columns },
                              getDescription: { "Column" })
        }
    }

    private init(numRows: Int, numColumns: Int, copyFrom: PartialSolution, newValues: [CellValue]) {
        rows = PartialSolution.addKnownCells(numRows, columns: numColumns, inputCells: copyFrom.rows, cellsToAdd: newValues)
        context = copyFrom.context
    }

    func row(row: Int) -> PartialLine {
        return PartialLine(input: rows[row].cells)
    }

    func column(column: Int) -> PartialLine {
        return PartialLine(input: rows.map() {
            $0.cells[column]
        })
    }

    func addCellValues(newValues: [CellValue]?) -> PartialSolution {
        if (newValues == nil) {
            return self
        }
        return PartialSolution(numRows: rows.count, numColumns: rows[0].cells.count, copyFrom: self, newValues: newValues!)
    }

    func dump() {
        for row in rows {
            for value in row.cells {
                let x = value == nil ? "?" : value! ? "█" : " "
                print(x, terminator: "")
            }
            print("")
        }
    }

    func knownCellCount() -> Int {
        return rows.reduce(0) {
            (total, row) -> Int in
            return total + row.cells.reduce(0, combine: {
                (tt, val) -> Int in
                return tt + (val != nil ? 1 : 0)
            })
        }
    }

    private static func addKnownCells(rows: Int, columns: Int, inputCells: [PartialLine]?, cellsToAdd: [CellValue]) -> [PartialLine] {
        var x = inputCells ?? [PartialLine](count: rows, repeatedValue: PartialLine(count: columns))
        let groupedCellsToAdd = cellsToAdd.groupBy {
            $0.row
        }

        for row in 0 ..< rows {
            guard let cellsToAddForThisRow = groupedCellsToAdd[row] else {
                continue
            }

            var scratchCells = x[row].cells
            for cellValue in cellsToAddForThisRow {
                scratchCells[cellValue.col] = cellValue.value
            }
            x[row] = PartialLine(input: scratchCells)
        }

        return x
    }
}

