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
    # Make sure ncurses fix propagates through the GHC bootstrapping chain
    ncursesFix haskell.compiler.ghc742Binary haskell.compiler.ghc784 ghc7101C

    # Make sure the resulting Haskell packages/libraries work
    haskell.compiler.ghc7101 haskell.packages.ghc7101.random

    # Make sure our Haskell packages are the default
    haskellPackages.random

    # Dundee Uni projects and their dependencies
    coalp ml4pg quickspec weka

    hs2ast treefeatures

    # Allows testing prior to committing
    hs2ast-unstable treefeatures-unstable

    # Writing infrastructure
    pandoc panpipe panhandle md2pdf

    # Web site infrastructure
    git2html
    #gitSites

    # Agda
    agdaBase haskell.packages.ghc784.Agda emacsMelpa.agda2-mode
)
"${pkg_tests[@]}" # Run the command specified by the array

echo "START PACKAGE-SPECIFIC TESTS"

curses_libs=$(nix-shell -p ncursesFix --pure \
                        --command 'find $(echo $NIX_LDFLAGS |
                                          grep -o "[-]L/nix/store/[^/]*ncurses[^/]*/lib" |
                                          grep -o "/nix/store/.*")')

echo "$curses_libs" | grep -q "libncurses.so.5"
check "ncursesFix creates libncurses.so.5"

nix-shell -p git2html --pure --command 'which git2html'
check "git2html installs its script"

nix-shell -p panpipe --pure --command 'which panpipe'
check "panpipe binary is installed"

nix-shell -p panhandle --pure --command 'which panhandle'
check "panhandle binary is installed"

echo "TESTS END"

test "$exit_code" -eq 0 && echo "ALL TESTS PASSED" || echo "SOME TEST(S) FAILED"

exit $exit_code
