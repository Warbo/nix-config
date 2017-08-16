self: super:

with self;

{
  conkeror = stdenv.mkDerivation rec {
    pkgname = "conkeror";
    version = "git";
    name    = "${pkgname}-${version}";

    src = latestGit {
            url = git://repo.or.cz/conkeror.git;
          };

    buildInputs = [ unzip makeWrapper ];

    installPhase = ''
      mkdir -p $out/libexec/conkeror
      cp -r * $out/libexec/conkeror

      makeWrapper ${firefox}/bin/firefox $out/bin/conkeror \
        --add-flags "-app $out/libexec/conkeror/application.ini"
    '';
  };
}
