//
//  ColumnSequence.swift
//  Nonogram
//
//  Created by Eric Patey on 12/27/15.
//  Copyright © 2015 Eric Patey. All rights reserved.
//

import Foundation

struct ColumnSequence: SequenceType {
    typealias Generator = AnyGenerator<Bool>
    let cells: [Bool]
    //        let rowsInThisColumn: Int
    let firstIndex: Int
    let columns: Int

    init(cells: [Bool], columnCount: Int, columnNum: Int) {
        self.cells = cells
        self.columns = columnCount
        self.firstIndex = columnNum
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
