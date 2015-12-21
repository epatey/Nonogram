//
// Created by Eric Patey on 12/24/15.
// Copyright (c) 2015 bouldertop. All rights reserved.
//

import Foundation

class PartialSolution {
    private let rows: [PartialLine]

    init(numRows:Int, numColumns: Int, newValues: [CellValue] ) {
        rows = PartialSolution.addKnownCells(numRows, columns: numColumns, inputCells: nil, cellsToAdd: newValues)
    }

    private init(numRows:Int, numColumns: Int, copyFrom: PartialSolution, newValues:  [CellValue] ) {
        rows = PartialSolution.addKnownCells(numRows, columns: numColumns, inputCells: copyFrom.rows, cellsToAdd: newValues)
    }
    
    func row(row:Int) -> PartialLine {
        return rows[row]
    }

    func column(column:Int) -> PartialLine {
        var result: PartialLine = []
        for row in rows {
            result.append(row[column])
        }

        return result
    }

    func addCellValues(newValues: [CellValue]? ) -> PartialSolution {
        if (newValues == nil) {
            return self
        }
        return PartialSolution(numRows: rows.count, numColumns: rows[0].count, copyFrom: self, newValues: newValues!)
    }

    func dump() {
        for row in rows {
            for value in row {
                let x = value == nil ? "?" : value! ? "█" : " "
                print(x, terminator:"")
            }
            print("")
        }
    }

    func knownCellCount() -> Int {
        return rows.reduce(0) { (total, row) -> Int in
            return total + row.reduce(0, combine: { (tt, val) -> Int in
                return tt + (val != nil ? 1 : 0)
            })
        }
    }

    private static func addKnownCells(rows:Int, columns: Int, inputCells: [PartialLine]?, cellsToAdd: [CellValue] ) -> [PartialLine] {
        var x = inputCells ?? [PartialLine](count: rows, repeatedValue: PartialLine(count: columns, repeatedValue: nil))
        for colRow in cellsToAdd {
            x[colRow.row][colRow.col] = colRow.value
        }
        return x
    }
}
