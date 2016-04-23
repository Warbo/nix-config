{ fftw, gnugrep, latestGit, log4cpp, qt5, stdenv, xvfb_run }:

stdenv.mkDerivation {
  name = "engauge-digitizer";
  src  = latestGit {
    url = "https://github.com/markummitchell/engauge-digitizer.git";
  };

  buildInputs = [ fftw gnugrep log4cpp qt5.qttools xvfb_run ];

  configurePhase = ''
    ENGAUGE_RELEASE=1 qmake engauge.pro
  '';

  buildPhase = ''
    set -e
    echo "Building app" 1>&2
    make
    echo "Finished building app" 1>&2

    echo "Building help" 1>&2
    OLD="$PWD"
    cd help
    ./build
    echo "Finished building help" 1>&2
    cd "$OLD"
  '';

  doCheck = true;
  checkPhase = ''
    set -e
    OLD="$PWD"
    cd src

    for SUITE in cli gui
    do
      echo "Running $SUITE tests" 1>&2
      # The tests require X, so we call with xvfb-run:
      #  - The '-a' option prevents the cli and gui tests trying to use the same
      #    X server.
      #  - xvfb-run sends its own errors to /dev/null by default, so we use '-e'
      #    to send them to our stderr (Nix may restrict access to /dev/stderr)
      TEST_OUTPUT=$(xvfb-run -a -e >(cat 1>&2) -- bash build_and_run_all_"$SUITE"_tests)
      echo "Finished $SUITE tests" 1>&2

      if echo "$TEST_OUTPUT" | grep "PASS" > /dev/null
      then
        echo "Some $SUITE tests PASSed" 1>&2
      else
        echo "No PASS lines found for $SUITE tests" 1>&2
        echo "$TEST_OUTPUT" 1>&2
        exit 1
      fi

      if echo "$TEST_OUTPUT" | grep "FAIL" > /dev/null
      then
        echo "Some $SUITE tests FAILed" 1>&2
        echo "$TEST_OUTPUT" 1>&2
        exit 1
      fi
    done
    echo "Finished testing" 1>&2

    cd "$OLD"
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    echo "Installing $PWD/bin/engauge to $out/bin" 1>&2
    cp ./bin/engauge "$out/bin/"
    chmod +x "$out/bin/engauge"
  '';
}
