# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ cabal, mtl, network, parsec, xhtml }:

cabal.mkDerivation (self: {
  pname = "cgi";
  version = "3001.1.7.2";
  sha256 = "ad35971388fa1809a5cd71bb2f051d69d753e4153b43d843b431674cf79a1c39";
  buildDepends = [ mtl network parsec xhtml ];
  meta = {
    description = "A library for writing CGI programs";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
    maintainers = [ self.stdenv.lib.maintainers.andres ];
  };
})
