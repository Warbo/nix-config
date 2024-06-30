{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    (import ../modules/fetch-youtube.nix)
    (import ../modules/warbo.nix)
  ];
  home.username = "pi";
  home.homeDirectory = "/home/pi";
  warbo.enable = true;

  fetch-youtube = {
    enable = true;
    timer = {
      OnBootSec = "15min";
      OnUnitActiveSec = "1d";
    };
  };

  programs.git = {
    userName = "Chris Warburton";
    userEmail = "chriswarbo@gmail.com";
  };

  systemd.user = with { yt-dir = builtins.toString ~/youtube; }; {
    systemctlPath = "/bin/systemctl"; # Use native, since Nix one hangs
    services = {
      # TODO: Trigger on path, pointing at pending URL dir:
      #  - We only want one copy running; but triggered whenever new URLs appear
      #  - Loop through pending URLs in random order, one at a time
      #  - Try downloading with yt-dlp, into an unfinished downloads dir
      #  - Wait until finished, ignoring common failures (shorts, etc.)
      #  - Once finished, mv resulting file to sub-folder of TODO
      #  - If successful, or known failure, delete URL from pending dir
      fetch-youtube-files = {
        Unit.Description = "Fetch all Youtube videos identified in todo";
        Service = {
          Type = "oneshot";
          RemainAfterExit = "no";
          ExecStart = "${pkgs.writeShellScript "fetch-youtube-files" ''
            set -e
            mkdir -p ${yt-dir}/fetched

            while true
            do
              # Run find to completion before changing anything in todo
              FILES=$(find ${yt-dir}/todo -type f | shuf)

              # Stop if nothing more was found
              echo "$FILES" | grep -q '^.' || break

              while read -r F
              do
                # Extract details
                URL=$(cat "$F")
                NAME=$(basename "$F")
                VID=$(basename "$(dirname "$F")")

                # Set up a temp dir to work in. The name is based on the VID; so
                # we can tell if this entry has been attempted before.
                T=${yt-dir}/temp/fetch-"$VID"
                if [[ -e "$T" ]]
                then
                  echo "Skipping $VID as $T already exists (prev. failure?)" >&2
                  continue
                fi

                # If this hasn't been attempted yet, make a working dir inside
                # the temp dir, named after the destination directory (making it
                # easier to move atomically without overlaps). Metadata is kept
                # in the temp dir, so we can tell what happened.
                mkdir -p "$T/$NAME"
                pushd "$T/$NAME"
                  if ${pkgs.yt-dlp}/bin/yt-dlp -f 'b[height<600]' "$URL" \
                       1> >(tee ../stdout)
                       2> >(tee ../stderr 1>&2)
                  then
                    touch ../success
                  fi
                popd

                # If the fetch succeeded, move the result atomically to fetched
                # and move the VID from todo to done
                if [[ -e "$T/success" ]]
                then
                  mv "$T" ${yt-dir}/fetched/
                  mkdir -p ${yt-dir}/done/"$NAME"
                  mv "$F" ${yt-dir}/done/"$NAME"/"$VID"
                  rmdir "$(dirname "$F")"
                fi

                sleep 10 # Slight delay to cut down on spam
              done < <(echo "$FILES")

              sleep 10  # Slight delay to cut down on spam
            done
          ''}";
        };
      };
    };
  };
}
