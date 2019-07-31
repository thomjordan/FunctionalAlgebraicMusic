
//  RationalNumbers.swift
//  FunctionalAlgebraicMusic
//
//  Created by Thom Jordan on 1/27/19.
//  Copyright © 2019 Thom Jordan. All rights reserved.

import Foundation

public struct Rational {
    public let numer: Int
    public let denom: Int
    public var floatValue: Double { return Double(numer) / Double(denom) }
    public init(numer: Int, denom: Int) {
        self.numer = numer; self.denom = denom 
    }
}

public func | (numer: Int, denom: Int) -> Rational {
    return Rational(numer: numer, denom: denom)
}

extension Rational: Comparable {
    public static func < (lhs: Rational, rhs: Rational) -> Bool {
        return lhs.floatValue < rhs.floatValue
    }
}

extension Rational: CustomStringConvertible { public var description: String { return "\(numer)|\(denom)" } }

public func gcd(_ l: Int, _ r: Int) -> Int {
    var minnum = min(l,r); var maxnum = max(l,r)
    while minnum != 0 {
        let remainder = maxnum % minnum
        maxnum = minnum; minnum = remainder
    }
    return maxnum
}

public func lcm(_ l: Int, _ r: Int) -> Int { return (l*r) / gcd(l,r) }

public func reduced(_ numer: Int, _ denom: Int) -> Rational {
    let divisor = gcd(numer,denom)
    return (numer/divisor) | (denom/divisor)
}

public func / (_ l: Rational, _ r: Rational) -> Rational {
    let numer = l.numer * r.denom
    let denom = l.denom * r.numer
    return reduced(numer, denom)
}

public func * (_ l: Rational, _ r: Rational) -> Rational {
    let numer = l.numer * r.numer
    let denom = l.denom * r.denom
    return reduced(numer, denom)
}

public func * (_ scalar: Int, _ ratio: Rational) -> Rational {
    return reduced(scalar * ratio.numer, ratio.denom)
}

public func * (_ ratio: Rational, _ scalar: Int) -> Rational {
    return reduced(scalar * ratio.numer, ratio.denom)
}

public func + (_ l: Rational, _ r: Rational) -> Rational {
    let theLCM = lcm(l.denom, r.denom)
    let valnum = ((l.numer*(theLCM/l.denom))+(r.numer*(theLCM/r.denom)))
    return reduced(valnum, theLCM)
}

