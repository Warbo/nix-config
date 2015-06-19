#!/bin/sh

# Automated tests for custom packages. Also serves to warm up our Nix cache.

# Allow one test to be specified

if [ ! -z "$1" ]
then
    TEST="$1"
fi

# Assume all tests will pass. If a test fails, this will become 1.
exit_code=0

function pass {
    echo "PASS"
}

function fail {
    # Inform scripts that there was a failure by setting exit code to 1
    exit_code=1
    echo "FAIL"
}

function check {
    # Prints information in a consistent form, AFTER the test has been performed
    # $1 should be the test's description
    # $? should contain the pass/fail result of the test
    result=$?
    printf "TEST %s... " "$1"
    test $result -eq 0 && pass || fail
}

function check_install {
    nix-shell -p "$1" --pure --show-trace --command "true"
    check "Package '$1' installs without issue"
}

function check_installs {
    for pkg
    do
        if [ -z "$TEST" ]
        then
            check_install "$pkg"
        else
            test "$TEST" = "$pkg" && check_install "$pkg"
        fi
    done
}

echo "START TESTS"

echo "GENERIC BUILD/INSTALL TESTS"

pkg_tests=(check_installs
    # Make sure Haskell packages work
    haskellPackages.random

    # Dundee Uni projects and their dependencies
    coalp ml4pg quickspec weka hs2ast treefeatures mlspec ArbitraryHaskell

    # Allows testing prior to committing
    te-unstable.ArbitraryHaskell te-unstable.hs2ast te-unstable.treefeatures
    te-unstable.mlspec te-unstable.ml4hs

    # Writing infrastructure
    pandoc panpipe panhandle md2pdf

    # Web site infrastructure
    git2html

    # Agda
    agdaBase haskell.packages.ghc784.Agda emacsMelpa.agda2-mode

    # Other
    get_iplayer
)
"${pkg_tests[@]}" # Run the command specified by the array

echo "START PACKAGE-SPECIFIC TESTS"

nix-shell -p git2html  --pure --command 'which git2html'  > /dev/null
check  "git2html script is installed"

nix-shell -p panpipe   --pure --command 'which panpipe'   > /dev/null
check   "panpipe binary is installed"

nix-shell -p panhandle --pure --command 'which panhandle' > /dev/null
check "panhandle binary is installed"

nix-shell '<nixpkgs>' -A cwNet --command "true"
check "Can make build environment for chriswarbo.net"

nix-shell '<nixpkgs>' -A cwNet \
  --command 'echo "import Hakyll; main = return ()" | runhaskell'
check "Hakyll library is available to chriswarbo.net"

echo "TESTS END"

test "$exit_code" -eq 0 && echo "ALL TESTS PASSED" || echo "SOME TEST(S) FAILED"

exit $exit_code
