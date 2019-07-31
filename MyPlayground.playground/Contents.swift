import FunctionalAlgebraicMusic
import Prelude


// Example use:

let phrygianUp  = line([24, 25, 27, 29, 31, 32, 34, 36].map { .prim(.note(1|4, $0)) })
let phrygianUp1 = phrygianUp |> toMusic1(116)
let perf1       = hsomPerform(defPMap, defCon, phrygianUp1)

perf1 |> render

