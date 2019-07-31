
//  HSoMSupportTypes.swift
//  FunctionalAlgebraicMusic
//
//  Created by Thom Jordan on 1/27/19.
//  Copyright © 2019 Thom Jordan. All rights reserved.

import Foundation

// Sum types

public enum Dynamic {
    case accent(Rational)
    case crescendo(Rational)
    case diminuendo(Rational)
}

public enum Articulation {
    case staccato(Rational)
    case legato(Rational)
}

public enum Tempo { }
public enum Ornament { }

public enum PhraseAttribute {
    case dyn(Dynamic)
    case art(Articulation)
    case tmp(Tempo)
    case orn(Ornament)
}

public typealias Pitch = Int
public typealias Delta = Rational
public typealias Duration = Rational
public typealias Δ = Rational

public enum MidiChannel: Int {
    case ch1 = 1
    case ch2 = 2
    case ch3 = 3
    case ch4 = 4
}

public enum PitchClass: Int {
    case C  =  0
    case Db =  1
    case D  =  2
    case Eb =  3
    case E  =  4
    case F  =  5
    case Gb =  6
    case G  =  7
    case Ab =  8
    case A  =  9
    case Bb = 10
    case B  = 11
}

public enum Mode {
    case major
    case minor
    case ionian
    case dorian
    case phrygian
    case lydian
    case mixolydian
    case aeolian
    case locrian
    case lydianb7
    case bharaivi
    case custom([Pitch])
    
    public var def: [Pitch] {
        switch self {
        case .major      : return [0, 2, 4, 5, 7, 9, 11]
        case .minor      : return [0, 2, 3, 5, 7, 8, 10]
        case .ionian     : return [0, 2, 4, 5, 7, 9, 11]
        case .dorian     : return [0, 2, 3, 5, 7, 9, 10]
        case .phrygian   : return [0, 1, 3, 5, 7, 8, 10]
        case .lydian     : return [0, 2, 4, 6, 7, 9, 11]
        case .mixolydian : return [0, 2, 4, 5, 7, 9, 10]
        case .aeolian    : return [0, 2, 3, 5, 7, 8, 10]
        case .locrian    : return [0, 1, 3, 5, 6, 8, 10]
        case .lydianb7   : return [0, 2, 4, 6, 7, 9, 10]
        case .bharaivi   : return [0, 1, 4, 5, 7, 8, 10]
        case .custom(let vals): return vals
        }
    }
}

public enum Control {
    case tempo(Rational)
    case transpose(Pitch)
    case instrument(MidiChannel)
    case key(PitchClass, Mode)
    case phrase( [PhraseAttribute] )
    case custom(String)
}

// Product types

public typealias PTime  = Rational
public typealias Volume = Int

public struct MEvent {
    public var eTime  : PTime 
    public var ePch   : Pitch
    public var eVol   : Volume
    public var eDelta : Delta
    public var eDur   : Duration
    public var eInst  : MidiChannel
    public var eOn    : Bool
    public var eParams: [Double] // optional other parameters
    
    public init( eTime:PTime = (0|8), ePch:Pitch = 24, eVol:Volume = 100, eDelta:Delta = (1|8), eDur: Duration = (1|8), eInst:MidiChannel = .ch1, eOn:Bool = true, eParams:[Double] = []) {
        self.eTime   = eTime
        self.ePch    = ePch
        self.eVol    = eVol
        self.eDelta  = eDelta
        self.eDur    = eDur
        self.eInst   = eInst
        self.eOn     = eOn
        self.eParams = eParams
    }
    
    public var rendered: BEvent {
        return BEvent(eTime:eTime, ePch:ePch, eVol:eVol, eDelta:eDelta, eDur:eDur, eInst:eInst, eOn:eOn, eParams:eParams)
    }
}

public typealias Performance = [MEvent]

public struct BEvent {
    public var eTime  : Double
    public var ePch   : Pitch
    public var eVol   : Volume
    public var eDelta : Double
    public var eDur   : Double
    public var eInst  : Int
    public var eOn    : Bool
    public var eParams: [Double]
    
    public init( eTime:PTime, ePch:Pitch, eVol:Volume, eDelta:Delta, eDur:Duration, eInst:MidiChannel, eOn:Bool, eParams:[Double]) {
        self.eTime   = eTime.floatValue
        self.ePch    = ePch
        self.eVol    = eVol
        self.eDelta  = eDelta.floatValue
        self.eDur    = eDur.floatValue
        self.eInst   = eInst.rawValue
        self.eOn     = eOn
        self.eParams = eParams
    }
}

