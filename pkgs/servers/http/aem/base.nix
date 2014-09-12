{ runmode, port, checkpath }:
{ stdenv, requireFile, oraclejdk7, curl, bash }:

let 
  version = "5.6.1";
  deriveInclude = hotfix: requireFile (hotfix // { url = "sourcecontrol"; });
  hotfixes = map deriveInclude (import ./hotfixes.nix);
  osgiBundles = map deriveInclude (import ./osgi.nix);

in stdenv.mkDerivation rec {
  name = "aem-${version}"; 

  src = requireFile {
    name = "aem-quickstart-${version}.jar";
    url = "gdrive/somewhere";
    sha256 = "cd7f4d02bbbb56b43f41937f4617f4dd2da56b2b6c2d353a504d0cca3284298a";
  };
  jarname = baseNameOf src;

  license = requireFile {
    name = "license.properties";
    url = "gdrive/somewhere";
    sha256 = "59dff6cfc530e3547a1b681badc9f9bc5d6c5d5078f96455568fd9e499402bde";
  };

  builder = ./builder.sh;

  inherit curl bash runmode port checkpath hotfixes osgiBundles;
  java = oraclejdk7;
  
  meta = {
    description = "Adobe Experience Manager CMS - ${runmode} instance";
    license = stdenv.lib.licenses.unfree;
  };
}

