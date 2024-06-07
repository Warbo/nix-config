self: super:

with builtins;
with {
  # GTK crashes if X restarts, plus GTK3 is horrible and it's slow. Setting
  # both GTK versions to false will forces the "lucid" GUI instead (AKA Xaw3D)
  elucidate =
    emacs:
    emacs.override {
      withGTK2 = false;
      withGTK3 = false;
    };
};
{
  overrides = {
    emacs = elucidate (trace "FIXME: Emacs from 19.03 has a broken display" self.nixpkgs1809)
    .emacs;
  };

  tests =
    with {
      checkDisplay =
        emacs: label:
        self.runCommand "test-emacs-${label}"
          {
            buildInputs = [
              self.fail
              emacs
              self.xvfb-run-safe
            ];
          }
          ''
            if GOT=$(timeout 10 xvfb-run-safe emacs 2>&1)
            then
              fail "Should have timed out: $GOT"
            else
              CODE="$?"
            fi
            echo "Got exit code '$CODE'" 1>&2

            if echo "$GOT" | grep "Segmentation fault" > /dev/null
            then
              echo "$GOT" 1>&2
              fail "Emacs segfaulted"
            fi

            [[ "$CODE" -eq 124 ]] || fail "Didn't time out (got code '$CODE')"

            mkdir "$out"
          '';
    }; {
      have-binary = self.hasBinary self.emacs "emacs";

      warbo-tests =
        self.runCommand "emacs-test-runner"
          {
            config = self.patchShebang {
              dir = self.latestGit { url = "http://chriswarbo.net/git/warbo-emacs-d.git"; };
            };
            __noChroot = true;
            buildInputs = [
              (self.aspellWithDicts (dicts: [ dicts.en ]))
              self.emacs
              self.git
            ];
            GIT_SSL_CAINFO = "${self.cacert}/etc/ssl/certs/ca-bundle.crt";
            LANG = "en_GB.UTF-8";
          }
          ''
            export HOME="$PWD/home"
            mkdir -p "$HOME"
            cp -r "$config" "$HOME/.emacs.d"
            chmod -R +w "$HOME/.emacs.d"
            cd "$HOME/.emacs.d"
            ./test-runner.sh
            mkdir "$out"
          '';

      # Make sure that our chosen Emacs version doesn't segfault on X
      display-works = checkDisplay self.emacs "display-works";

      # See if we still need to pin an old version
      need-override = self.isBroken (
        checkDisplay (elucidate super.emacs) "latest-display-broken"
      );
    };
}
