# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ cabal }:

cabal.mkDerivation (self: {
  pname = "TypeCompose";
  version = "0.9.10";
  sha256 = "1wpldqdf6czl36fs4pvvj2z3kg1487sanqncp4rbmgrrhbfmqxxq";
  meta = {
    homepage = "https://github.com/conal/TypeCompose";
    description = "Type composition classes & instances";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
    maintainers = [ self.stdenv.lib.maintainers.ianwookim ];
  };
})
