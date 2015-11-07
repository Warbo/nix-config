{ stdenv, latestGit, python3Packages, utillinux }:

stdenv.mkDerivation {
#python3Packages.buildPythonPackage {
  name = "dupeguru";
  version = "2015-04-05";

  src = latestGit { url = https://github.com/hsoft/dupeguru.git; };

  propagatedBuildInputs = [
    python3Packages.python
    python3Packages.pyqt5
    python3Packages.alabaster
    python3Packages.snowballstemmer
    python3Packages.markupsafe
    python3Packages.pytz
    python3Packages.jinja2
    python3Packages.six
    python3Packages.docutils
    python3Packages.Babel
    python3Packages.pygments
    python3Packages.polib
    python3Packages.sphinx
    utillinux
  ];

#  DISPLAY=":0";

  configurePhase = ''
    bash bootstrap.sh
#    PYTHON=python3
#    command -v python3 -m venv >/dev/null 2>&1 || { echo >&2 "Python 3.3 required. Install it and try again. Aborting"; exit 1; }
#
#    if [ -d "deps" ]; then
#        # We have a collection of dependencies in our source package. We might as well use it instead
#        # of downloading it from PyPI.
#        PIPARGS="--no-index --find-links=deps"
#    fi
#
#    if [ ! -d "env" ]; then
#        echo "No virtualenv. Creating one"
#        # We need a "system-site-packages" env to have PyQt, but we also need to ensure a local pip
#        # install. To achieve our latter goal, we start with a normal venv, which we later upgrade to
#        # a system-site-packages once pip is installed.
#        if ! python3 -m venv env ; then
#            # We're probably under braindead Ubuntu 14.04 which completely messed up ensurepip.
#            # Work around it :(
#            echo "Ubuntu 14.04's version of Python 3.4 is braindead stupid, but we work around it anyway..."
#            python3 -m venv --without-pip env
#        fi
#        echo "START"
#        cat env/bin/activate
#        echo "END"
#        source env/bin/activate
#        if python3 -m ensurepip; then
#            echo "We're under Python 3.4+, no need to try to install pip!"
#        else
#            python3 get-pip.py $PIPARGS --force-reinstall
#        fi
#        deactivate
#        if [ "$(uname)" != "Darwin" ]; then
#            # We only need system site packages for PyQt, so under OS X, we don't enable it
#            if ! python3 -m venv env --upgrade --system-site-packages ; then
#                # We're probably under v3.4.1 and experiencing http://bugs.python.org/issue21643
#                # Work around it.
#                echo "Oops, can't upgrade our venv. Trying to work around it."
#                rm env/lib64
#                python3 -m venv env --upgrade --system-site-packages
#            fi
#        fi
#    fi
#
#    source env/bin/activate
#
#    echo "Installing pip requirements"
#    if [ "$(uname)" == "Darwin" ]; then
#        pip install $PIPARGS -r requirements-osx.txt
#    else
#        python3 -c "import PyQt5" >/dev/null 2>&1 || { echo >&2 "PyQt 5.1+ required. Install it and try again. Aborting"; exit 1; }
#        pip install $PIPARGS -r requirements.txt
#    fi
#
#    echo "Bootstrapping complete! You can now configure, build and run dupeGuru with:"
#    echo ". env/bin/activate && python configure.py && python build.py && python run.py"
  '';

  buildPhase = ''
    . env/bin/activate
    python3 configure.py
    python3 build.py
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    mkdir -p "$out/lib"
    cp -r .  "$out/lib/dupeguru"
    pushd "$out/bin"
    ln -s ../lib/dupeguru/run.py dupeguru
    popd
  '';
}
