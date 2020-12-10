//
//  main.swift
//  Nonogram
//
//  Created by Eric Patey on 12/9/20.
//  Copyright © 2020 Boulder Top Software. All rights reserved.
//

import Foundation

private var workQueue:[LineWorkItem] = []

private func rowWorkItem(rowNumber: Int) -> LineWorkItem {
    return LineWorkItem(isRow: true, lineNumber: rowNumber)
}

private func columnWorkItem(columnNumber: Int) -> LineWorkItem {
    return LineWorkItem(isRow: false, lineNumber: columnNumber)
}

private func addUnsolvedLinesToWorkQueue(currentBest: PartialSolution) {
    let context = currentBest.context
    workQueue.append(contentsOf: (0..<context.rowCount)
        .map { ($0, context.rowHelper.getLine(currentBest, $0)) }
        .filter { !$0.1.complete }
        .map { $0.0 }
        .map(rowWorkItem))

    workQueue.append(contentsOf: (0..<context.columnCount)
        .map { ($0, context.columnHelper.getLine(currentBest, $0)) }
        .filter { !$0.1.complete }
        .map { $0.0 }
        .map(columnWorkItem))
}

private func drainWorkQueue(startingSolution: PartialSolution, params:(useBacktracker: Bool, backtrackerLimit: Int?)) -> (solution:PartialSolution, complete:Bool) {
    let context = startingSolution.context
    var currentBest = startingSolution

    print("\nDraining work queue with (bt = \(params.backtrackerLimit)")

    while (!workQueue.isEmpty) {
        let workItem = workQueue.remove(at: 0)
        let lineHelper = workItem.isRow ? context.rowHelper : context.columnHelper
        let oldLine = lineHelper.getLine(currentBest, workItem.lineNumber)
        let rules = lineHelper.getRules(lineNumber: workItem.lineNumber)

        let workItemDescription = "\(workItem.isRow ? "row" : "col") \(workItem.lineNumber)"
        guard let improvedLine = improveLine(line: oldLine, rules: rules, params: params, description:workItemDescription) else { continue }

        if let newCellValues = oldLine.newCellValues(newLine: improvedLine, lineNumber: workItem.lineNumber, lineHelper: lineHelper) {
            addResultingWork(newCellValues: newCellValues, completedWorkItem: workItem, prioritizeNewWork: params.useBacktracker)

            currentBest = currentBest.addCellValues(newValues: newCellValues)
            //            currentBest.dump()
        }
    }

    return (currentBest, currentBest.complete)
}


private func addResultingWork(newCellValues:[CellValue], completedWorkItem:LineWorkItem, prioritizeNewWork: Bool) {
    let workItemFunc = completedWorkItem.isRow ? columnWorkItem : rowWorkItem
    let lineNumberFunc = completedWorkItem.isRow ? {(cellValue:CellValue) in cellValue.col} : {cellValue in cellValue.row}

    for lineNumber in newCellValues.map(lineNumberFunc) {
        let workItem = workItemFunc(lineNumber)
        if let existingIndex = (workQueue.firstIndex() {$0.isRow == workItem.isRow && $0.lineNumber == workItem.lineNumber }) {
            if (!prioritizeNewWork) {
                continue
            }
            workQueue.remove(at: existingIndex)
        }
        if (prioritizeNewWork) {
            workQueue.insert(workItem, at: 0)
        }
        else {
            workQueue.append(workItem)
        }
    }
}

private func improveLine(line: PartialLine, rules:[Int], params:(useBacktracker: Bool, backtrackerLimit: Int?), description: String) -> PartialLine? {
    if (line.complete) {
        return nil
    }

    let lineSolverImprovement = LineSolver.workForLine(oldLine: line, rules: rules, description: description)

//    if (!params.useBacktracker) {
        return lineSolverImprovement
//    }
//
//    guard let backtrackerImprovement = LineBacktracker.execute(lineSolverImprovement ?? line, rules: rules, stopAfter: params.backtrackerLimit, description: description) else {
//        return lineSolverImprovement
//    }
//
//    guard let recurseImprovement = doLine(backtrackerImprovement, rules: rules, params: params, description: description) else {
//        return backtrackerImprovement
//    }
//
//    return recurseImprovement
}

print("Hello, World!")
if let context = PuzzleContext(puzzlePath: "/Users/erpatey/dev/Nonogram/Puzzles/5236.xml") {

    var currentBest = PartialSolution(context: context)

    let paramSets:[(Bool, Int?)] = [
        (useBacktracker: false, backtrackerLimit: nil),
        (useBacktracker: true, backtrackerLimit: 2),
        (useBacktracker: true, backtrackerLimit: 10),
        (useBacktracker: true, backtrackerLimit: 30),
        (useBacktracker: true, backtrackerLimit: 90),
        (useBacktracker: true, backtrackerLimit: 160),
        (useBacktracker: true, backtrackerLimit: nil)
    ]

    for params in paramSets {
        addUnsolvedLinesToWorkQueue(currentBest: currentBest)
        let x = drainWorkQueue(startingSolution: currentBest, params: params)
        currentBest = x.solution

        currentBest.dump()

        if (x.complete) {
            break
        }

    }
}


