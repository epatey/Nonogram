//
//  BacktrackTests.swift
//  BacktrackTests
//
//  Created by Eric Patey on 12/14/15.
//  Copyright © 2015 bouldertop. All rights reserved.
//

import XCTest
@testable import Nonogram

class NonogramTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testComputePackedLine() {
        let line:[Bool?] = [nil, nil, false, nil, nil, nil, nil, false, nil]
        let rules = [3, 1]
        let result:[Bool?] = Puzzle.computePackedLine(line, rules: rules)
        let expected:[Bool?] = [false, false, false, true, true, true, false, false, true]
        XCTAssert(result == expected)
    }

    func testComputePackedLine2() {
        let line:[Bool?] = [nil, nil, nil, nil, nil, true]
        let rules = [3, 1]
        let result:[Bool?] = Puzzle.computePackedLine(line, rules: rules)
        let expected:[Bool?] = [true, true, true, false, false, true]
        XCTAssert(result == expected)
    }

    func testComputeLineOverlap() {
        let line:[Bool?] = [nil, nil, nil, nil, nil, true]
        let rules = [3, 1]
        let overlap = Puzzle.computeLineOverlap(line, rules: rules)
        let expected:[Bool?] = [nil, true, true, nil, false, true]
        XCTAssert(overlap == expected)
    }

    func testPotentialLine() {
        let p = Puzzle.PotentialLine(rules: [3, 1], lineLength: 6)
        var x:[Bool] = []
        for i in 0..<6 {
            x.append(p[i])
        }

        XCTAssertEqual(x, [true, true, true, false, true, false])


        XCTAssertEqual(p.runAtOffset(0)!.index, 0)
        XCTAssertEqual(p.runAtOffset(1)!.index, 0)
        XCTAssertEqual(p.runAtOffset(2)!.index, 0)
        XCTAssertNil(p.runAtOffset(3))
        XCTAssertEqual(p.runAtOffset(4)!.index, 1)
        XCTAssertNil(p.runAtOffset(5))
    }

    // computeLineOverlap
}

func ==<T: Equatable>(lhs: [T?], rhs: [T?]) -> Bool {
    if lhs.count != rhs.count { return false }
    for (l,r) in zip(lhs,rhs) {
        if l != r { return false }
    }
    return true
}

