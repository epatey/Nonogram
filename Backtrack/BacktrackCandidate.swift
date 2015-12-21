//
// Created by Eric Patey on 12/23/15.
// Copyright (c) 2015 bouldertop. All rights reserved.
//

import Foundation

protocol BacktrackCandidate {
    func reject() -> Bool

    func accept() -> Bool
    var children: AnyGenerator<BacktrackCandidate> { get }
}

