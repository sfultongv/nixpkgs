{ runmode, port, checkpath }:
{ stdenv, requireFile, oraclejdk7, curl, bash }:

let 
  version = "6.0";
  deriveInclude = hotfix: requireFile (hotfix // { url = "sourcecontrol"; });
  hotfixes = map deriveInclude (import ./hotfixes.nix);
  osgiBundles = map deriveInclude (import ./osgi.nix);

in stdenv.mkDerivation rec {
  name = "aem-${version}"; 

  src = requireFile {
    #name = "aem-quickstart-${version}.jar";
    name = "AEM_${version}_Quickstart.jar";
    url = "gdrive/somewhere";
    sha256 = "f91cd4d7044c03509b253fd5377253081e201460be9de800b9610d51b5836deb";
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

