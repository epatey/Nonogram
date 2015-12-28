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
                       cellValueBuilder: CellValueBuilder) -> [CellValue]? {
        return PartialLine.newCellValues(self,
                                         newLine: newLine,
                                         lineNumber: lineNumber,
                                         cellValueBuilder: cellValueBuilder)
    }

    private static func newCellValues(oldLine: PartialLine,
                                      newLine: PartialLine,
                                      lineNumber: Int,
                                      cellValueBuilder: CellValueBuilder) -> [CellValue]? {
        var changes: [CellValue]?
        for lineOffset in 0 ..< oldLine.cells.count {
            guard let newValue = newLine.cells[lineOffset] where oldLine.cells[lineOffset] == nil else {
                continue
            }

            if (changes == nil) {
                changes = []
            }
            let change = cellValueBuilder(lineNumber: lineNumber, lineOffset: lineOffset, value: newValue)
            changes!.append(change)
        }

        return changes
    }
}
