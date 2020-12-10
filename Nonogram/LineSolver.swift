//
// Created by Eric Patey on 12/23/15.
// Copyright (c) 2015 bouldertop. All rights reserved.
//

import Foundation

class LineSolver {
    static func workForLine(oldLine: PartialLine, rules: [Int], description: String) -> PartialLine? {
        let algos = [OverlapAlgorithm, MinMaxRangeAlgorithm]
        
        var improvedLine:PartialLine?
        while (true) {
            var mustRepeat = false
            for (index, algo) in algos.enumerated() {
                if let thisImprovement = algo(improvedLine ?? oldLine, rules, description) {
                    improvedLine = thisImprovement
                    if (index != 0) {
                        mustRepeat = true
                    }
                }
            }
            
            if (!mustRepeat) {
                break
            }
        }
        
        return improvedLine
    }

    /*
     static func execute(partialSolution: PartialSolution) -> PartialSolution {
     var currentBestSolution = partialSolution
     let context = partialSolution.context

     currentBestSolution.dump()

     var knownCount = 0
     while (true) {
     let beforeCount = currentBestSolution.knownCellCount()
     for rowNumber in 0 ..< context.rows {
     currentBestSolution = applyAlgorithm(OperlapAlgorithm.execute,
     lineNumber: rowNumber,
     currentBestSolution: currentBestSolution,
     lineGetter: context.rowHelper)
     currentBestSolution = applyAlgorithm(MinMaxRangeAlgorithm.execute,
     lineNumber: rowNumber,
     currentBestSolution: currentBestSolution,
     lineGetter: context.rowHelper)
     }

     for colNumber in 0 ..< context.columns {
     currentBestSolution = applyAlgorithm(OperlapAlgorithm.execute,
     lineNumber: colNumber,
     currentBestSolution: currentBestSolution,
     lineGetter: context.columnHelper
     )
     currentBestSolution = applyAlgorithm(MinMaxRangeAlgorithm.execute,
     lineNumber: colNumber,
     currentBestSolution: currentBestSolution,
     lineGetter: context.columnHelper)
     }

     // knownCount = self.knownCellCount(context.mustBe)
     knownCount = currentBestSolution.knownCellCount()

     print("Line Solver computed \(knownCount - beforeCount) known cells. (\(knownCount) out of \(context.rows * context.columns))")
     currentBestSolution.dump()

     if (knownCount - beforeCount == 0) {
     break;
     }
     }

     return currentBestSolution
     }

     private static func applyAlgorithm(algorithm: LineSolverAlgorithm,
     lineNumber: Int,
     currentBestSolution: PartialSolution,
     lineGetter: LineHelper) -> PartialLine? {
     let oldLine = lineGetter.getLine(partialSolution: currentBestSolution, lineNumber: lineNumber)
     if oldLine.complete {
     return nil
     }
     let rules = lineGetter.getRules(lineNumber: lineNumber)
     return algorithm(line: oldLine, rules: rules)
     }
     */
}
