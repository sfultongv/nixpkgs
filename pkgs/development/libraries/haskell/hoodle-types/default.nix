# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ cabal, cereal, lens, mtl, strict, text, uuid }:

cabal.mkDerivation (self: {
  pname = "hoodle-types";
  version = "0.3";
  sha256 = "0n9plj6hhsc5482pl7sw4gw7py8r6cn0cl7hg35g2qxdxnzapifm";
  buildDepends = [ cereal lens mtl strict text uuid ];
  meta = {
    description = "Data types for programs for hoodle file format";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
    maintainers = [ self.stdenv.lib.maintainers.ianwookim ];
  };
})
