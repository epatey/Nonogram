//
//  Puzzle.swift
//  Backtrack
//
//  Created by Eric Patey on 12/14/15.
//  Copyright © 2015 bouldertop. All rights reserved.
//

import Foundation
import SWXMLHash

struct CellValue {
    let col: Int
    let row: Int
    let value: Bool
}
typealias LineWorkItemFunc = (_ currentSolution:PartialSolution) -> [CellValue]?

struct LineWorkItem {
    let isRow:Bool
    let lineNumber:Int
}

struct LineHelper {
    let lineConstraints: [[Int]]
    let getLine: (_ partialSolution:PartialSolution, _ lineNumber:Int) -> PartialLine
    let getCellValue: (_ lineNumber:Int, _ lineOffset:Int, _ value:Bool) -> CellValue
    let description: String
    func getRules(lineNumber:Int) -> [Int] {
        return lineConstraints[lineNumber]
    }
    var lineCount: Int { get { lineConstraints.count } }
}

class PuzzleContext {
    let rowHelper: LineHelper
    let columnHelper: LineHelper
    let knownCells: [(col:Int, row:Int)] = []
    var rowCount:Int { get { rowHelper.lineCount} }
    var columnCount:Int { get { columnHelper.lineCount} }

    init?(puzzlePath: String) {
        guard let (rowConstraints, columnConstraints) = try? parseXml(xmlPath: puzzlePath) else { return nil }
        rowHelper = LineHelper(lineConstraints: rowConstraints,
                               getLine: { $0.row(row: $1) },
                               getCellValue: { CellValue(col: $1, row: $0, value: $2) },
                               description: "Row")
        columnHelper = LineHelper(lineConstraints: columnConstraints,
                                  getLine: { $0.column(column: $1) },
                                  getCellValue: { CellValue(col: $0, row: $1, value: $2) },
                                  description: "Column")
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

    /*
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
*/
    
}

private func parseXml(xmlPath: String) throws -> (rowConstraints: [[Int]], columnConstraints: [[Int]]) {
    let x = try String(contentsOfFile: xmlPath)
    let xml = SWXMLHash.parse(x)
    let puzzle = xml["puzzleset"]["puzzle"][0]
    let rowRulesXml = try puzzle["clues"].withAttribute("type", "rows").children
    let rowConstraints = rowRulesXml.map() {$0.children.map() {Int($0.element!.text)!}}
    let colRulesXml = try puzzle["clues"].withAttribute("type", "columns").children
    let columnConstraints = colRulesXml.map() {$0.children.map() {Int($0.element!.text)!}}

    return (rowConstraints: rowConstraints, columnConstraints: columnConstraints);
}

