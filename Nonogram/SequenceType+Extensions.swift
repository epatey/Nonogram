//
//  SequenceType+Extensions.swift
//  Nonogram
//
//  Created by Eric Patey on 12/28/15.
//  Copyright © 2015 Eric Patey. All rights reserved.
//

import Foundation

extension SequenceType {
    func aggregate<T>(initial: T, combine: (accumulator:T, element:Generator.Element) -> T) -> [T] {
        var accumulator = initial
        return map {
            e in
            accumulator = combine(accumulator: accumulator, element: e)
            return accumulator
        }
    }
}

