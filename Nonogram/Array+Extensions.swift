//
//  Array+Extensions.swift
//  Nonogram
//
//  Created by Eric Patey on 12/28/15.
//  Copyright © 2015 Eric Patey. All rights reserved.
//

import Foundation

extension Array {
    func groupBy<U>(groupingFunction group: (Element) -> U) -> [U:Array] {
        var result = [U: Array]()
        
        for item in self {
            let groupKey = group(item)
            var dictValue = result[groupKey] ?? []
            
            // TODO: I still don't quite get the immutability rules of nested collections.
            // when I simply mutated the dictValue in place and didn't re-assign it, it was hosed
            dictValue.append(item)
            result[groupKey] = dictValue
        }
        
        return result
    }
}
