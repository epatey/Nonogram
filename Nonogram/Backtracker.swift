//
// Created by Eric Patey on 12/23/15.
// Copyright (c) 2015 bouldertop. All rights reserved.
//

import Foundation

public protocol BacktrackCandidate {
    func reject() -> Bool

    func accept() -> Bool
    var children: [BacktrackCandidate] { get }
}

public class Backtracker {
    public static func solve(candidate: BacktrackCandidate) -> [BacktrackCandidate]? {
        return solve(candidate: candidate, stopAfter: nil).0
    }
    
    public static func solve(candidate: BacktrackCandidate, stopAfter:Int?) -> (solutions:[BacktrackCandidate]?, truncated:Bool) {
        if (candidate.reject()) {
            return (nil, false)
        }

        var result: [BacktrackCandidate]? = nil
        if (candidate.accept()) {
            result = [candidate]
        }

        for nextCandidate in candidate.children {
            let childResult = solve(candidate: nextCandidate, stopAfter: stopAfter)
            if (childResult.truncated) {
                return childResult
            }
            if let childsolutions = childResult.solutions {
                if let r = result {
                    result = r + childsolutions
                } else {
                    result = childsolutions
                }
                if let sa = stopAfter {
                    if result!.count >= sa {
                        return (result, true)
                    }
                }
            }
        }

        return (result, false)
    }
}

