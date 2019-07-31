# FunctionalAlgebraicMusic

Swift translations of Haskell code from "The Haskell School of Music: From Signals to Symphonies" by Paul Hudak & Donya Quick (2018 Hardcover edition)

The progression of the code below reflects the introduction of constructs from the original text,
beginning at chapter 2 "Simple Music", and continuing up through subchapter 9.2 "Players",
along with the 'player map' and 'context' definitions of 9.3 "Putting it All Together".

The main function, "hsomPerform()", wraps the more complex "perf()" function.
The other most salient functions are referenced within the default player definition, 'defPlayer'.
As of yet, 'defPlayer' is the only brand of player in use below. "fancyPlayer" from the original text still needs to be translated (section 9.3).

Dependencies:
https://github.com/pointfreeco/swift-overture
https://github.com/pointfreeco/swift-prelude

Special thanks to Brandon Williams & Stephen Celis @ Point•Free: https://www.pointfree.co/
