//
//  PartialLine.swift
//  Nonogram
//
//  Created by Eric Patey on 12/27/15.
//  Copyright © 2015 Eric Patey. All rights reserved.
//

import Foundation

class PartialLine: SequenceType {
    let cells: [Bool?]

    init(count: Int) {
        cells = [Bool?](count: count, repeatedValue: nil)
    }

    init<BoolOptionSequence:SequenceType where BoolOptionSequence.Generator.Element == Bool?>(input: BoolOptionSequence) {
        cells = Array<Bool?>(input)
    }
    private init(cells: [Bool?]) {
        self.cells = cells
    }

    typealias Generator = Array<Bool?>.Generator

    func generate() -> Generator {
        return cells.generate()
    }
    var count: Int {
        get {
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
        } else {
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
