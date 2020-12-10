//
// Created by Eric Patey on 12/24/15.
// Copyright (c) 2015 bouldertop. All rights reserved.
//

import Foundation

class PartialSolution {
    private let rows: [PartialLine]
    let context: PuzzleContext

    init(context: PuzzleContext) {
        rows = PartialSolution.addKnownCells(rows: context.rowCount,
                                             columns: context.columnCount,
                                             inputCells: nil,
                                             cellsToAdd: context.knownCells.map() {
                                                CellValue(col: $0, row: $1, value: true)
        })
        self.context = context
    }

    private init(numRows: Int, numColumns: Int, copyFrom: PartialSolution, newValues: [CellValue]) {
        rows = PartialSolution.addKnownCells(rows: numRows, columns: numColumns, inputCells: copyFrom.rows, cellsToAdd: newValues)
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
        guard let nv = newValues else {
            return self
        }
        return PartialSolution(numRows: rows.count, numColumns: rows[0].cells.count, copyFrom: self, newValues: nv)
    }

    func dump() {
        print("┌", terminator:"")
        for _ in 0..<context.columnCount {
            print("─", terminator:"")
        }
        print("┐")
        
        for row in rows {
            print("│", terminator: "")
            for value in row.cells {
                let x = value == nil ? "?" : value! ? "█" : " "
                print(x, terminator: "")
            }
            print("│")
        }
        
        print("└", terminator:"")
        for _ in 0..<context.columnCount {
            print("─", terminator:"")
        }
        print("┘")

    }

    func knownCellCount() -> Int {
        return rows.reduce(0) {
            (total, row) -> Int in
            return total + row.cells.reduce(0, {
                (tt, val) -> Int in
                return tt + (val != nil ? 1 : 0)
            })
        }
    }
    
    var complete:Bool {
        get {
            return knownCellCount() == context.rowCount * context.columnCount
        }
    }
    
    private static func addKnownCells(rows: Int, columns: Int, inputCells: [PartialLine]?, cellsToAdd: [CellValue]) -> [PartialLine] {
        var x = inputCells ?? [PartialLine](repeating:  PartialLine(count: columns), count: rows);
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

public extension Array {
    func groupBy<U>(groupingFunction group: (Element) -> U) -> [U:Array] {
        var result = [U: Array]()

        for item in self {
            let groupKey = group(item)
            var dictValue = result[groupKey] ?? []

            // TODO: I still don't quite get the immutability rules of nested collections.
            // when I simply mutated the dictValue in place and didn't re-assign it, it was hosed
            dictValue.append(item)
            result[groupKey] = dictValue
        }

        return result
    }
}
