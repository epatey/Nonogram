//
//  MinMaxRangeAlgorithm.swift
//  Nonogram
//
//  Created by Eric Patey on 12/9/20.
//  Copyright © 2020 Boulder Top Software. All rights reserved.
//

import Foundation

func MinMaxRangeAlgorithm(line: PartialLine, rules: [Int], description: String) -> PartialLine? {
    if (line.complete) {
        return nil
    }
    let ltrResults = xworkTheEdges(cells: line.cells, rules: rules)
    let rtlResults = xworkTheEdges(cells: (ltrResults ?? line.cells).reversed(), rules: rules.reversed())

    guard let totalResults = rtlResults?.reversed() ?? ltrResults else {
        return nil
    }

    let result = PartialLine(input: totalResults)

    print("MinMax(\(description)) discovered \(line.unknownCount - result.unknownCount) cells")

    return result
}


private func xworkTheEdges(cells: [Bool?], rules: [Int]) -> [Bool?]? {
    let offsetsChanged = intWorkTheEdges(cells: cells, rules: rules)
    if offsetsChanged.count > 0 {
        var newCells = cells
        for x in offsetsChanged {
            newCells[x.0] = x.1
        }
        return newCells
    }

    return nil
}

private func intWorkTheEdges(cells: [Bool?], rules: [Int]) -> [(Int, Bool)] {
    let rule = rules[0]
    let lastRun = rules.count == 1

    var leadingFalses = 0
    for x in cells {
        if x == false {
            leadingFalses += 1
        }
        else {
            break
        }
    }

    let maxRunOffsetFromEdge = leadingFalses + rule - 1
    var maybeFirstTrueOffset: Int? = nil
    for i in leadingFalses ... maxRunOffsetFromEdge {
        if cells[i] == true {
            maybeFirstTrueOffset = i
            break
        }
    }


    var newCells: [(Int, Bool)] = []
    guard let firstTrueOffset = maybeFirstTrueOffset else {
        // If we get here, and the next cell is true, we can set the first nil to false
        if (cells[maxRunOffsetFromEdge + 1] == true) {
            newCells.append((leadingFalses, false))
        }
        return newCells
    }

    if (firstTrueOffset < maxRunOffsetFromEdge) {
        for i in firstTrueOffset + 1 ... maxRunOffsetFromEdge {
            if cells[i] == nil {
                newCells.append((i, true))
            }
        }
    }

    if (firstTrueOffset == leadingFalses + 0) {
        let trailingFalseOffset = maxRunOffsetFromEdge + 1
        if (lastRun) {
            // All cells after the run must be false
            for i in trailingFalseOffset ..< cells.count {
                if (cells[i] != false) {
                    newCells.append((i, false))
                }
            }
        } else {
            // The single cell after the run must be false
            // Add the trailing false if we can
            if (cells[trailingFalseOffset] != false) {
                newCells.append((trailingFalseOffset, false))
            }

            // Recurse for the next run
            let rec = intWorkTheEdges(cells: Array(cells.suffix(from: trailingFalseOffset + 1)), rules: Array(rules.suffix(from: 1)))
            let x = rec.map() {
                ($0.0 + trailingFalseOffset + 1, $0.1)
            }
            newCells.append(contentsOf: x)
        }
    }

    return newCells
}
