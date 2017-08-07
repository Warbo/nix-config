{ coreutils, fetchFromGitHub, makeWrapper, perl, procps, stdenv, writeScript }:

stdenv.mkDerivation rec {
  name = "timeout";
  src  = fetchFromGitHub {
    owner  = "pshved";
    repo   = "timeout";
    rev    = "1ce1006";
    sha256 = "0nsv05kg22l6w0v885nli2hc7r6vi0jrfhb98jyfq38qaad5y78c";
  };

  # Wrapper for timeout, which provides sensible defaults
  withTimeout = writeScript "with-timeout" ''
    #!/usr/bin/env bash
    TIME_OPT=""
     MEM_OPT=""
    [[ -z "$MAX_SECS" ]] || TIME_OPT="-t $MAX_SECS"
    [[ -z "$MAX_KB"   ]] ||  MEM_OPT="-m $MAX_KB"
    timeout -c --no-info-on-success $TIME_OPT $MEM_OPT "$@"
  '';

  buildInputs  = [ makeWrapper ];
  patchPhase   = ''
    sed -e 's@/usr/bin/perl@${perl}/bin/perl@g' -i timeout
  '';
  installPhase = ''
    mkdir -p "$out/bin"
    cp timeout "$out/bin"
    cp "$withTimeout" "$out/bin/withTimeout"
    wrapProgram "$out/bin/timeout"     --prefix PATH : "${perl}/bin"   \
                                       --prefix PATH : "${procps}/bin" \
                                       --prefix PATH : "${coreutils}/bin"
    wrapProgram "$out/bin/withTimeout" --prefix PATH : "$out/bin"
  '';
}
