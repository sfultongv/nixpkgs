# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ cabal, aeson, async, attoparsec, base64Bytestring, either
, monadLoops, mwcRandom, stm, text, transformers
, unorderedContainers, vector, websockets
}:

cabal.mkDerivation (self: {
  pname = "engine-io";
  version = "1.1.0";
  sha256 = "0l2jwgzi22ky13k9kmqhn15zyxyg5gr167rkywb458n1si4jr3jh";
  buildDepends = [
    aeson async attoparsec base64Bytestring either monadLoops mwcRandom
    stm text transformers unorderedContainers vector websockets
  ];
  meta = {
    homepage = "http://github.com/ocharles/engine.io";
    description = "A Haskell implementation of Engine.IO";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
    maintainers = [ self.stdenv.lib.maintainers.ocharles ];
  };
})
