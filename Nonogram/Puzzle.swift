//
//  Puzzle.swift
//  Backtrack
//
//  Created by Eric Patey on 12/14/15.
//  Copyright © 2015 bouldertop. All rights reserved.
//

import Foundation

typealias CellValue = (col:Int, row:Int, value:Bool)
typealias CellValueBuilder = (lineNumber:Int, lineOffset:Int, value:Bool) -> CellValue

struct LineHelper {
    let getLine: (partialSolution:PartialSolution, lineNumber:Int) -> PartialLine
    let getRules: (lineNumber:Int) -> [Int]
    let getCellValue: CellValueBuilder
    let getLineCount: () -> Int
    let getDescription: () -> String
}

class PuzzleContext {
    // TODO: Seems like I'm trying too hard here. Just trying to use the strategy pattern. I don't
    // think I've got it clean enough yet. Struggled trying to make these let's rather than var lazy's
    var rowHelper: LineHelper {
        get {
            return LineHelper(getLine: { $0.row($1) },
                getRules: { self.rowConstraints[$0] },
                getCellValue: { (col: $1, row: $0, value: $2) },
                getLineCount: { self.rows },
                getDescription: { "Row" })
        }
    }
    
    var columnHelper: LineHelper {
        get {
            return LineHelper(getLine: { $0.column($1) },
                getRules: { self.columnConstraints[$0] },
                getCellValue: { (col: $0, row: $1, value: $2) },
                getLineCount: { self.columns },
                getDescription: { "Column" })
        }
    }
    
    /*
    let rows = 10
    let columns = 5
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
            [2, 1],
            [2, 1, 3],
            [7],
            [1, 3],
            [2, 1],
    ]

    let knownCells: [(col:Int, row:Int)] = [
    ]
    */

    var rowsSolutions: [[BacktrackCandidate]] = []

    let rows = 25
    let columns = 25
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
    
}

