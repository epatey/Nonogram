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
        let root = puzzle.root(context)

        while (true) {
            Puzzle.findRowColSolutions(context, rows: true)
            Puzzle.findRowColSolutions(context, rows: false)
        }


        
        puzzle.bt(context, candidate: root)
        print("done")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

