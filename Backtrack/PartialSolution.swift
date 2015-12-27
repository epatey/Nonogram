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
        return PartialLine(input: rows[row].cells)
    }

    func column(column:Int) -> PartialLine {
        return PartialLine(input: rows.map() { $0.cells[column] })
    }

    func addCellValues(newValues: [CellValue]? ) -> PartialSolution {
        if (newValues == nil) {
            return self
        }
        return PartialSolution(numRows: rows.count, numColumns: rows[0].cells.count, copyFrom: self, newValues: newValues!)
    }

    func dump() {
        for row in rows {
            for value in row.cells {
                let x = value == nil ? "?" : value! ? "█" : " "
                print(x, terminator:"")
            }
            print("")
        }
    }

    func knownCellCount() -> Int {
        return rows.reduce(0) { (total, row) -> Int in
            return total + row.cells.reduce(0, combine: { (tt, val) -> Int in
                return tt + (val != nil ? 1 : 0)
            })
        }
    }

    private static func addKnownCells(rows:Int, columns: Int, inputCells: [PartialLine]?, cellsToAdd: [CellValue] ) -> [PartialLine] {
        var x = inputCells ?? [PartialLine](count: rows, repeatedValue: PartialLine(count: columns))
        let groupedCellsToAdd = cellsToAdd.groupBy { $0.row }

        for row in 0..<rows {
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


extension Array {
    func groupBy <U> (groupingFunction group: (Element) -> U) -> [U: Array] {
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
