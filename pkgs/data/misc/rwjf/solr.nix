{ stdenv, requireFile }:
stdenv.mkDerivation {

  name = "rwjf-source-solr";
  src = requireFile (import ./solr-pkg.nix); 

  installPhase =
    ''
      mkdir $out
      mv * $out
    '';

  meta = {
    description = "RWJF project dependency - puppet/modules/rwjf-solr";
    license = stdenv.lib.licenses.unfree;
  };
}
