
//  HSoMCodeTranslation.swift
//  FunctionalAlgebraicMusic
//
//  Created by Thom Jordan on 1/27/19.
//  Copyright © 2019 Thom Jordan. All rights reserved.

//  Swift translations of Haskell code from "The Haskell School of Music: From Signals to Symphonies" by Paul Hudak & Donya Quick (2018 Hardcover edition)

//  The progression of the code below reflects the introduction of constructs from the original text,
//  beginning at chapter 2 "Simple Music", and continuing up through subchapter 9.2 "Players",
//  along with the 'player map' and 'context' definitions of 9.3 "Putting it All Together".

//  The main function, "hsomPerform()", wraps the more complex "perf()" function.
//  The other most salient functions are referenced within the default player definition, 'defPlayer'.
//  As of yet, 'defPlayer' is the only brand of player in use below. "fancyPlayer" from the original text still needs to be translated (section 9.3).

//  Dependencies:
//  https://github.com/pointfreeco/swift-overture
//  https://github.com/pointfreeco/swift-prelude
//  Special thanks to Brandon Williams & Stephen Celis @ Point•Free: https://www.pointfree.co/


import Foundation
import Overture
import Prelude

infix operator |+|
infix operator |=|

public enum Primitive<A> {
    case note(Delta, A)
    case rest(Delta)
}

public indirect enum Music<A> {
    case prim(Primitive<A>)
    case annexed(Music<A>, Music<A>)
    case layered(Music<A>, Music<A>)
    case modify(Control, Music<A>)
    
    public static func |+| (lhs: Music<A>, rhs: Music<A>) -> Music<A> { return annexed(lhs, rhs) }
    public static func |=| (lhs: Music<A>, rhs: Music<A>) -> Music<A> { return layered(lhs, rhs) }
    
    public static var unit: Music<A> { return .prim(.rest(0|4)) }
}


public func mFold<A,B>(_ f: @escaping (Primitive<A>) -> B, _ g: @escaping (B,B) -> B, _ h: @escaping (B,B) -> B, _ i: @escaping (Control,B) -> B) -> (Music<A>) -> B {
    return { m in
        switch (m) {
        case let .prim(p)      : return f(p)
        case let .annexed(l,r) : return g( mFold(f,g,h,i)(l), mFold(f,g,h,i)(r) )
        case let .layered(l,r) : return h( mFold(f,g,h,i)(l), mFold(f,g,h,i)(r) )
        case let .modify(c,a)  : return i(c, mFold(f,g,h,i)(a) )
        }
    }
}

public func mMap<A,B>(_ f: @escaping (A) -> B ) -> (Music<A>) -> Music<B> {
    return { m in
        let g: (Primitive<A>) -> Music<B> = { p in
            switch p {
            case let .note(d,x) : return .prim(.note(d, f(x)))
            case let .rest(d)   : return .prim(.rest(d))
            }
        }
        return mFold(g, |+|, |=|, Music.modify)(m) // means: mFold(g, Music.annexed, Music.layered, Music.modify)
    }
}

/// Appends the Music<A> values of the input array serially into a single Music<A> value, by using the |+| operator.
///
/// - Parameter ms: An array of Music<A> values.
/// - Returns: A single Music<A> value, the components of which are chained together serially by placing |+| between each pair of values.
public func line<A>(_ ms: [Music<A>]) -> Music<A> { return ms.reduce(.unit, |+|) }

/// Stacks the Music<A> values of the input array in parallel to produce a single Music<A> value, by using the |=| operator.
///
/// - Parameter ms: An array of Music<A> values.
/// - Returns: A single Music<A> value, the components of which are stacked together in parallel by placing |=| between each pair of values.
public func chord<A>(_ ms: [Music<A>]) -> Music<A> { return ms.reduce(.unit, |=|) }

public func delta<A>(_ m: Music<A>) -> Delta {
    let getDelta: (Primitive<A>) -> Delta = { prim in
        switch prim {
        case let .note(d,_) : return d
        case let .rest(d)   : return d
        }
    }
    let modDelta: (Control, Delta) -> Delta = { (ctrl, d) in
        switch ctrl {
        case let .tempo(r): return d/r
        default: return d
        }
    }
    let process: (Music<A>) -> Delta = mFold(getDelta, +, max, modDelta)
    return process(m)
}

public func note<A>(_ δ: Delta) -> (A) -> Music<A> { return { a in return Music.prim(.note(δ, a)) } }
public func rest<A>(_ δ: Delta) -> Music<A> { return Music.prim(.rest(δ)) }

public func addVolume(_ v: Volume) -> (Music<Pitch>) -> Music<(Pitch, Volume)> { return mMap { p in (p,v) } }

public struct Context<A> {
    public var cTime   : PTime
    public var cPlayer : Player<A>
    public var cDelta  : Delta
    public var cPch    : Pitch
    public var cVol    : Volume
    public var cDur    : Duration
    public var cInst   : MidiChannel
    public var cKey    : (PitchClass,Mode)
    
    public init(cTime: PTime, cPlayer: Player<A>, cDelta: Delta, cPch: Pitch, cVol: Volume, cDur: Duration, cInst: MidiChannel, cKey: (PitchClass, Mode)) {
        self.cTime   = cTime
        self.cPlayer = cPlayer
        self.cDelta  = cDelta
        self.cPch    = cPch
        self.cVol    = cVol
        self.cDur    = cDur
        self.cInst   = cInst
        self.cKey    = cKey
    }
}

public enum NoteAttribute {
    case volume(Int)
    case fingering(Int)
    case dynamics(String)
    case params([Double])
}

public typealias Note1  = (Pitch, [NoteAttribute])
public typealias Music1 = Music<Note1>

public typealias PlayerName = String

public typealias NoteFun<A>    = (Context<A>, Delta, A) -> Performance
public typealias PhraseFun<A>  = (PMap<A>?, Context<A>, [PhraseAttribute], Music<A>) -> (Performance, Δ) // optional used to get around a mandatory use of '@escaping' breaking the compilation

public struct Player<A> {
    public var pName        : PlayerName
    public var playNote     : NoteFun<A>
    public var interpPhrase : PhraseFun<A>
}

public typealias PMap<A> = (PlayerName) -> Player<A>

public func toMusic1(_ v: Volume = 127) -> (Music<Pitch>) -> Music1 {
    return mMap { p in ( p, [.volume(v)] ) }
}

public func merge(_ pL: Performance, _ pR: Performance) -> Performance {
    guard (!pL.isEmpty) else { return pR }
    guard (!pR.isEmpty) else { return pL }
    let eL = pL.first!, esL = Array(pL.dropFirst(1))
    let eR = pR.first!, esR = Array(pR.dropFirst(1))
    if eL.eTime < eR.eTime { return [eL] + merge(esL, pR) }
    else { return [eR] + merge(pL, esR) }
}

public func perf<A>(_ pm: @escaping PMap<A>, _ c: Context<A>, _ m: Music<A>) -> (Performance, Δ) {
    let player = c.cPlayer, dt = c.cDelta
    switch m {
    case let .prim(.note(d, p)) : return (player.playNote(c,d,p), d * dt)
    case let .prim(.rest(d))    : return ([], d * dt)
    case let .annexed(m1, m2):
        let (pf1, d1) = perf(pm, c, m1)
        let cPrime    = c |> (prop(\.cTime)) { t in t+d1 }
        let (pf2, d2) = perf(pm, cPrime, m2)
        return (pf1 + pf2, d1 + d2)
    case let .layered(m1, m2):
        let (pf1, d1) = perf(pm, c, m1)
        let (pf2, d2) = perf(pm, c, m2)
        return (merge(pf1, pf2), max(d1, d2))
    case let .modify(.tempo(r), m):
        let cPrime = c |> (prop(\.cDelta)) { δ in δ/r }
                       |> (prop(\.cDur))   { d in d/r }
        return perf(pm, cPrime, m)
    case let .modify(.transpose(p), m):
        let cPrime = c |> (prop(\.cPch)) { k in k+p }
        return perf(pm, cPrime, m)
    case let .modify(.instrument(i), m):
        let cPrime = c |> (prop(\.cInst)) { _ in i }
        return perf(pm, cPrime, m)
    case let .modify(.key(pc, mo), m):
        let cPrime = c |> (prop(\.cKey)) { _ in (pc, mo) }
        return perf(pm, cPrime, m)
    case let .modify(.phrase(pas), m):
        return player.interpPhrase(pm, c, pas, m)
    case let .modify(.custom(str), m):
        if str[0..<7].lowercased() == "player " {
            let name = str[7..<(str.count)]
            let cPrime = c |> (prop(\.cPlayer)) { _ in pm(name) }
            return perf(pm, cPrime, m)
        }
        else { return perf(pm, c, m) }
    }
}

public func hsomPerform<A>(_ pm: @escaping PMap<A>, _ c: Context<A>, _ m: Music<A>) -> Performance {
    let result = perf(pm, c, m)
    return result.0
}

public func defPlayNote<A>(_ nasHandler: @escaping (Context<(Pitch,[A])>) -> (A) -> (MEvent) -> MEvent) -> NoteFun<(Pitch,[A])> {
    return { (c, d, pNas) in  // "d" is the delta|duration associated with .note
        let (p, nas) = pNas   //  at this level the note's duration is equal to its delta value
        let initEv = MEvent(  //  (i.e. the duration is derived from the delta)
            eTime   : c.cTime,
            ePch    : c.cPch + p,
            eVol    : c.cVol,
            eDelta  : c.cDelta * d, // "cDelta" is the context-defined scalar for deltas
            eDur    : c.cDur   * d, // "cDur" is the context-defined scalar for durations
            eInst   : c.cInst,
            eParams : []
        )
        let handler: (A) -> (MEvent) -> MEvent = nasHandler(c)
        let result = nas.foldr(initEv) { (na, mEv) -> MEvent in handler(na)(mEv) }
        return [result]
    }
}
public func defNasHandler<A>(_ c: Context<A>) -> (NoteAttribute) -> (MEvent) -> MEvent {
    return { na in
        return { ev in
            switch na {
            case let .volume(v):
                let evPrime = ev |> (prop(\.eVol)) { _ in v } // alt. approach: ADD v to cVol (from context) instead of overwriting it..
                return evPrime
            case let .params(pms):
                let evPrime = ev |> (prop(\.eParams)) { _ in pms }
                return evPrime
            default: return ev
            }
        }
    }
}

public func defInterpPhrase<A>(_ pasHandler: @escaping (PhraseAttribute) -> (Performance) -> Performance)
    -> PhraseFun<A> {
        // -> (PMap<A>?, Context<A>, [PhraseAttribute], Music<A>) -> (Performance, Δ) {
        return { (pm, context, pas, m) -> (Performance, Δ) in
            guard let playerMap = pm else { return ([], (0|4)) }
            let (pf, δ) = perf(playerMap, context, m)
            let result = pas.foldr(pf) { (pa,prf) -> Performance in pasHandler(pa)(prf) }
            return (result, δ)
        }
}

public func defPasHandler(_ pa: PhraseAttribute) -> (Performance) -> Performance {
    return { prf in
        switch pa {
        case let .dyn(.accent(x)):
            return prf.map { event in
                event |> (prop(\MEvent.eVol)) { Int(($0 * x).floatValue) } // replace with a dedicated scaling func optimized for MIDI (e.g. 0-127)
            }
        case let .art(.staccato(x)):
            return prf.map { event in
                event |> (prop(\.eDur)) { $0 * x }
            }
        case let .art(.legato(x)):
            return prf.map { event in
                event |> (prop(\.eDur)) { $0 * x }
            }
        default: return prf
        }
    }
}

public let defPlayer: Player<Note1>
    = Player(
        pName: "Default",
        playNote: defPlayNote(defNasHandler),
        interpPhrase: defInterpPhrase(defPasHandler)
)

public let defCon: Context<Note1>
    = Context(
        cTime   : 0|4,
        cPlayer : defPlayer,
        cDelta  : 1|1,
        cPch    : 0,
        cVol    : 127,
        cDur    : 1|2,
        cInst   : .ch1,
        cKey    : (.E, .phrygian)
)

public func defPMap(_ pname: PlayerName = "Default") -> Player<Note1> {
    switch pname {
    //case "Fancy"   : return fancyPlayer
    case "Default" : return defPlayer
    default        :
        let player = defPlayer |> (prop(\.pName)) { _ in pname }
        return player
    }
}

public func myPMap(_ pname: PlayerName = "Default") -> Player<Note1> {
    switch pname {
    //case "NewPlayer" : return newPlayer
    default          : return defPMap(pname)
    }
}

public func render(_ p: Performance) -> [BEvent] { return p.map { $0.rendered } }



/* Example use:
 
               // line (map (note qn) [p1,p2,...,pn]) // <-- in Haskell
let phrygianUp  = line([24, 25, 27, 29, 31, 32, 34, 36].map { .prim(.note(1|4, $0)) })
let phrygianUp1 = phrygianUp |> toMusic1(116)
let perf1       = hsomPerform(defPMap, defCon, phrygianUp1)
perf1 |> render
 
*/
