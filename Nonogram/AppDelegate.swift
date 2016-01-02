//
//  AppDelegate.swift
//  Backtrack
//
//  Created by Eric Patey on 12/14/15.
//  Copyright © 2015 bouldertop. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    private let serialQueue = dispatch_queue_create("com.bouldertop.Nonogram.serial", DISPATCH_QUEUE_SERIAL)
    private let concurrentQueue = dispatch_queue_create("com.bouldertop.Nonogram.concurrent", DISPATCH_QUEUE_CONCURRENT)
    private var workQueue:[LineWorkItem] = []

    private func rowWorkItem(rowNumber: Int) -> LineWorkItem {
        return LineWorkItem(isRow: true, lineNumber: rowNumber)
    }
    
    private func columnWorkItem(columnNumber: Int) -> LineWorkItem {
        return LineWorkItem(isRow: false, lineNumber: columnNumber)
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let context = PuzzleContext(puzzlePath: "/Users/Eric/dev/nonogram/Puzzles/5236.xml")

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
            addUnsolvedLinesToWorkQueue(currentBest)
            let x = drainWorkQueue(currentBest, params: params)
            currentBest = x.solution
            
            currentBest.dump()
            
            if (x.complete) {
                break
            }
            
        }
        
        /*
        while (true) {
            currentBest = LineSolver.execute(currentBest)

            currentBest = LineBacktracker.execute(currentBest)
            
            if (currentBest.knownCellCount() == context.rows * context.columns) {
                break;
            }
        }
*/
        
        /*
        var rowSols:[[BacktrackCandidate]] = []
        let colSols:[[BacktrackCandidate]]
        while (true) {
            let r = Puzzle.findLineSolutions(context, rowAspect: true)
            let c = Puzzle.findLineSolutions(context, rowAspect: false)
            let afterKnownCellCount = knownCellCount(context.mustBe)
            if (afterKnownCellCount == knownCount) {
                rowSols = r
                colSols = c
                break;
            }
            print("Line backtrack iteration added \(afterKnownCellCount - knownCount) known cells")

            knownCount = afterKnownCellCount
        }

        let totsols = rowSols.reduce(0) { (tot, this) -> Int in
            return tot + this.count
        }
        print("\(totsols) total row solutions")

        context.rowsSolutions = rowSols
        */
    }
    
    private func addUnsolvedLinesToWorkQueue(currentBest: PartialSolution) {
        let context = currentBest.context
        workQueue.appendContentsOf((0..<context.rows)
            .map { ($0, context.rowHelper.getLine(partialSolution: currentBest, lineNumber: $0)) }
            .filter { !$0.1.complete }
            .map { $0.0 }
            .map(self.rowWorkItem))
        
        workQueue.appendContentsOf((0..<context.columns)
            .map { ($0, context.columnHelper.getLine(partialSolution: currentBest, lineNumber: $0)) }
            .filter { !$0.1.complete }
            .map { $0.0 }
            .map(self.columnWorkItem))
    }
    
    private func drainWorkQueue(startingSolution: PartialSolution, params:(useBacktracker: Bool, backtrackerLimit: Int?)) -> (solution:PartialSolution, complete:Bool) {
        let context = startingSolution.context
        var currentBest = startingSolution
        
        print("\nDraining work queue with (bt = \(params.backtrackerLimit)")
        
        while (!workQueue.isEmpty) {
            let workItem = workQueue.removeAtIndex(0)
            let lineHelper = workItem.isRow ? context.rowHelper : context.columnHelper
            let oldLine = lineHelper.getLine(partialSolution: currentBest, lineNumber: workItem.lineNumber)
            let rules = lineHelper.getRules(lineNumber: workItem.lineNumber)

            let workItemDescription = "\(workItem.isRow ? "row" : "col") \(workItem.lineNumber)"
            guard let newLine = doLine(oldLine, rules: rules, params: params, description:workItemDescription) else {
                continue
            }
            
            let newCellValues = oldLine.newCellValues(newLine, lineNumber: workItem.lineNumber, cellValueBuilder: lineHelper.getCellValue)!
            
            addResultingWork(newCellValues, completedWorkItem: workItem, prioritizeNewWork: params.useBacktracker)
            
            currentBest = currentBest.addCellValues(newCellValues)
//            currentBest.dump()
        }
        
        return (currentBest, currentBest.complete)
    }
    
    private func doLine(line: PartialLine, rules:[Int], params:(useBacktracker: Bool, backtrackerLimit: Int?), description: String) -> PartialLine? {
        if (line.complete) {
            return nil
        }
        
        let lineSolverImprovement = LineSolver.workForLine(line, rules: rules, description: description)
        
        if (!params.useBacktracker) {
            return lineSolverImprovement
        }
        
        guard let backtrackerImprovement = LineBacktracker.execute(lineSolverImprovement ?? line, rules: rules, stopAfter: params.backtrackerLimit, description: description) else {
            return lineSolverImprovement
        }
        
        guard let recurseImprovement = doLine(backtrackerImprovement, rules: rules, params: params, description: description) else {
            return backtrackerImprovement
        }
        
        return recurseImprovement
    }
    
    private func addResultingWork(newCellValues:[CellValue], completedWorkItem:LineWorkItem, prioritizeNewWork: Bool) {
        let workItemFunc = completedWorkItem.isRow ? columnWorkItem : rowWorkItem
        let lineNumberFunc = completedWorkItem.isRow ? {(cellValue:CellValue) in cellValue.col} : {cellValue in cellValue.row}
        
        for lineNumber in newCellValues.map(lineNumberFunc) {
            let workItem = workItemFunc(lineNumber)
            if let existingIndex = (workQueue.indexOf() {$0.isRow == workItem.isRow && $0.lineNumber == workItem.lineNumber }) {
                if (!prioritizeNewWork) {
                    continue
                }
                workQueue.removeAtIndex(existingIndex)
            }
            if (prioritizeNewWork) {
            workQueue.insert(workItem, atIndex: 0)
            }
            else {
                workQueue.append(workItem)
            }
        }
    }

    static func newCellsFromNewLine(oldLine: PartialLine, maybeNewLine:PartialLine?, lineNumber: Int, lineHelper:LineHelper) -> [CellValue]? {
        guard let newLine = maybeNewLine else {
            return nil
        }
        return oldLine.newCellValues(newLine, lineNumber: lineNumber, cellValueBuilder: lineHelper.getCellValue)
    }
    
    /*
    func findRowsAndColumns(context: PuzzleContext) -> (rowSolutions:[[BacktrackCandidate]], columnSolutions:[[BacktrackCandidate]]) {
        let rowSols = Puzzle.findLineSolutions(context, rowAspect: true)
        let columnSols = Puzzle.findLineSolutions(context, rowAspect: false)
        return (rowSols, columnSols)
    }
*/
}

