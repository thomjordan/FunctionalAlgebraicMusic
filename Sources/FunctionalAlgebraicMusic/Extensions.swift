
//  Extensions.swift
//  FunctionalAlgebraicMusic
//
//  Created by Thom Jordan on 1/27/19.
//  Copyright © 2019 Thom Jordan. All rights reserved.

import Foundation

public extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}

public extension Collection {
    /// Translated from Haskell version of foldr:
    /// foldr op init ( x1 : x2 : ... : xn : [] )
    /// ==> x1 'op' (x2 'op' (... (xn 'op' init) ...))
    func foldr<B>(_ accm:B, _ f: @escaping (Self.Iterator.Element, B) -> B) -> B {
        var g = self.makeIterator()
        func next() -> B {
            return g.next().flatMap {x in f(x, next())} ?? accm
        }
        return next()
    }
    /// Translated from Haskell version of foldl:
    /// foldl op init ( x1 : x2 : ... : xn : [] )
    /// ==> (... ((init 'op' x1) 'op' x2) ...) 'op' xn
    func foldl<B>(_ accm:B, _ f: (Self.Iterator.Element, B) -> B) -> B {
        var result = accm
        for temp in self {
            result = f(temp, result)
        }
        return result
    }
    // [10,3].foldr(1) { (a,b) -> Int in return 2*b+a } // 2 * (2 * 1 + 3) + 10 = 20
    // [10,3].foldl(1) { (a,b) -> Int in return 2*b+a } // 2 * 3 + (2 * 10 + 1) = 27
}

