//
//  PartialLine.swift
//  Nonogram
//
//  Created by Eric Patey on 12/27/15.
//  Copyright © 2015 Eric Patey. All rights reserved.
//

import Foundation

class PartialLine {
    let cells: [Bool?]

    init(count: Int) {
        cells = [Bool?](repeating: nil, count: count)
    }

    init<S>(input: S) where S: Sequence, Bool? == S.Element {
        cells = [Bool?](input)
    }

    // TODO: This would be cleaner if I made PartialLine conform to Sequence
    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Bool?) throws -> Result) rethrows -> Result {
        return try cells.reduce(initialResult, nextPartialResult)
    }

    private init(cells: [Bool?]) {
        self.cells = cells
    }

    var count: Int {
        get { cells.count }
    }

    // TODO: rename to isComplete
    var complete: Bool {
        get { cells.filter({ $0 == nil }).isEmpty }
    }

    var unknownCount: Int {
        get { cells.filter({ $0 == nil }).count }
    }

    func reversed() -> PartialLine {
        return PartialLine(cells: cells.reversed())
    }

    subscript(index: Int) -> Bool? {
        return cells[index]
    }

    func newCellValues(newLine: PartialLine,
                       lineNumber: Int,
                       lineHelper: LineHelper) -> [CellValue]? {
        return PartialLine.newCellValues(oldLine: self,
                                         newLine: newLine,
                                         lineNumber: lineNumber,
                                         lineHelper: lineHelper)
    }

    private static func newCellValues(oldLine: PartialLine,
                                      newLine: PartialLine,
                                      lineNumber: Int,
                                      lineHelper: LineHelper) -> [CellValue]? {
        let improvements = zip(newLine.cells, oldLine.cells)
            .enumerated()
            .filter { $1.0 != nil && $1.1 == nil }
            .map { lineHelper.getCellValue(lineNumber, $0, $1.0!) } // ! is safe because of .filter above

        return improvements.isEmpty ? nil : improvements
    }
}
