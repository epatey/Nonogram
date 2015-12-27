//
// Created by Eric Patey on 12/23/15.
// Copyright (c) 2015 bouldertop. All rights reserved.
//

import Foundation

public protocol BacktrackCandidate {
    func reject() -> Bool

    func accept() -> Bool
    var children: AnyGenerator<BacktrackCandidate> { get }
}

public class Backtracker {
    public static func solve(candidate: BacktrackCandidate) -> [BacktrackCandidate]? {
        if (candidate.reject()) {
            return nil
        }

        var result: [BacktrackCandidate]? = nil
        if (candidate.accept()) {
            result = [candidate]
        }

        for nextCandidate in candidate.children {
            if let childsolutions = solve(nextCandidate) {
                if let r = result {
                    result = r + childsolutions
                } else {
                    result = childsolutions
                }
            }
        }

        return result
    }
}

