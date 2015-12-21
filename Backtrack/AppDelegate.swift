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


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let context = PuzzleContext()
        let puzzle = Puzzle()

        var knownCount = 0
        var currentBest = LineSolver.execute(context)

        currentBest = Puzzle.findLineSolutions(context, partialSolution: currentBest, rowAspect: true)
        currentBest.dump()
        
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

    /*
    func findRowsAndColumns(context: PuzzleContext) -> (rowSolutions:[[BacktrackCandidate]], columnSolutions:[[BacktrackCandidate]]) {
        let rowSols = Puzzle.findLineSolutions(context, rowAspect: true)
        let columnSols = Puzzle.findLineSolutions(context, rowAspect: false)
        return (rowSols, columnSols)
    }
*/
}

