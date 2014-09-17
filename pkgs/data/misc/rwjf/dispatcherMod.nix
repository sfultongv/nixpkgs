{ stdenv, requireFile }:
stdenv.mkDerivation {

  name = "dispatcher-apache-module";
  src = requireFile (import ./dispatcherMod-pkg.nix);

  phases = [ "installPhase" ]; 
  installPhase =
    ''
      cp $src $out
    '';

  meta = {
    description = "RWJF project dependency - apache dispatcher module";
    license = stdenv.lib.licenses.unfree;
  };
}

