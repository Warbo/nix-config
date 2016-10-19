with builtins;

pkgs:

let mkService = opts: {
        enable   = true;
        wantedBy = [ "default.target"  ];
        after    = [ "local-fs.target" ];
      } // opts // {
        serviceConfig = {
            Type = "simple";
          } // opts.serviceConfig;
        };
in {
  emacs =
    let sudoWrapper = pkgs.stdenv.mkDerivation {
          name = "sudo-wrapper";
          buildCommand = ''
            mkdir -p "$out/bin"
            ln -s /var/setuid-wrappers/sudo "$out/bin/sudo"
          '';
        };
     in mkService {
          description = "Emacs daemon";
          path        = [ pkgs.all sudoWrapper ];
          environment = { SSH_AUTH_SOCK = "%t/ssh-agent"; };
          serviceConfig = {
            User      = "chris";
            Type      = "forking";
            Restart   = "always";
            ExecStart = ''"${pkgs.emacs}/bin/emacs" --daemon'';
            ExecStop  = ''"${pkgs.emacs}/bin/emacsclient" --eval "(kill-emacs)"'';
          };
        };

  inboxen = mkService {
    description   = "Fetch mail inboxes";
    path          = with pkgs; [ bash iputils isync ];
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 600;
      ExecStart  = pkgs.writeScript "inboxen-start" ''
        #!/${pkgs.bash}/bin/bash
        /var/setuid-wrappers/ping -c 1 google.com && mbsync gmail dundee
      '';
    };
  };

  news = mkService {
    enable = false;
    description   = "Fetch news";
    path          = with pkgs; [
                      bash iputils warbo-utilities nix.out
                      python libxslt xmlstarlet xidel wget
                      (haskellPackages.ghcWithPackages (h: [ h.imm ]))
                    ];
    environment   = { LANG = "en_GB.UTF-8"; };
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 1800;
      ExecStart  =
        let iplayer = pkgs.writeScript "iplayer_to_rss" ''
              #!${pkgs.bash}/bin/bash
              set -e

              function fetchProgrammes {
                # Fetch the URLs of programmes found at the given URL, followed by their
                # titles. For example:
                #
                # http://programme-page-for-click
                # http://programme-page-for-springwatch
                #
                # Click - 25th May 2016
                # Springwatch 2016 Episode 3
                echo "Fetching '$1'" 1>&2
                xidel -q \
                      -e '//li[contains(@class,"programme")]/div/a/resolve-uri(@href)' \
                      -e '//li[contains(@class,"programme")]/div/a/@title' \
                      "$1"
              }

              function formattedProgrammes {
                # Fetch the URLs and titles of programmes on the given page. For example:
                #
                # http://programme-page-for-click	Click - 25th May 2016
                # http://programme-page-for-springwatch 	Springwatch 2016 Episode 3

                OUTPUT=$(fetchProgrammes "$1")
                URLS=$(echo "$OUTPUT" | grep "^http")
                TTLS=$(echo "$OUTPUT" | grep -v "^http" | grep "^.")

                assertSameLength "$URLS" "$TTLS"

                paste <(echo "$URLS") <(echo "$TTLS")
              }

              function assertSameLength {
                # Assert that both arguments contain the same number of lines
                COUNT1=$(echo "$1" | wc -l)
                COUNT2=$(echo "$2" | wc -l)

                echo "Got lists of '$COUNT1' and '$COUNT2' elements" 1>&2
                [[ "$COUNT1" -eq "$COUNT2" ]] || {
                    echo -e "Found different length lists. First:\n$1\n\nSecond:\n$2" 1>&2
                    exit 2
                }
              }

              function listToFeed {
                listToFeed2 "$@" | tr -cd '[:print:]\n'
              }

              function listToFeed2 {
                CHANNELURL=$(echo "$2" | xmlEscape)
                echo '<rss version="2.0">'
                echo   '<channel>'
                echo     "<title>$1</title>"
                echo     "<link>$CHANNELURL</link>"

                while read -r LINE
                do
                    THISURL=$(echo "$LINE" | cut -f 1)
                    THISTTL=$(echo "$LINE" | cut -f 2-)
                    writeItem "$THISURL" "$THISTTL"
                done < <(formattedProgrammes "$2")

                echo   '</channel>'
                echo '</rss>'
              }

              function xmlEscape {
                # From http://daemonforums.org/showthread.php?t=4054
                sed -e 's~&~\&amp;~g' -e 's~<~\&lt;~g' -e 's~>~\&gt;~g'
              }

              function firstShown {
                sleep 1
                xidel -e '//span[@class="release"]' "$1"
              }

              function findCached {
                MATCHES=$(grep -rlF "$1" "$CACHEDIR")
                FOUND=$(echo "$MATCHES" | grep -v "\.rss$" | head -n1)
                echo "$FOUND"
              }

              function writeItem {
                CACHED=$(findCached "$1")
                if [[ -n "$CACHED" ]]
                then
                    cat "$CACHED"
                else
                    HASH=$(echo "$1" | md5sum | cut -d ' ' -f 1)
                    NAME=$(echo "$2" | tr '[:upper:]' '[:lower:]' | tr -dc '[:lower:]')
                    FILE="$HASH"_"$NAME".xml
                    writeItemReal "$1" "$2" | tee "$CACHEDIR/$FILE"
                fi
              }

              function writeItemReal {
                echo "Writing item for '$1' '$2'" 1>&2
                SAFEURL=$(echo "$1" | xmlEscape)
                SAFETTL=$(echo "$2" | xmlEscape)
                # Strip off "First shown:" and "HH:MMpm"
                DATE=$(firstShown "$1" | cut -d : -f 2- |
                                         sed -e 's/[0-9][0-9]*:[0-9][0-9].m//g' |
                                         sed -e 's/^[ ]*//g')
                echo "Got date '$DATE'" 1>&2
                if PUBDATE=$(date --date="$DATE" --rfc-2822)
                then
                    # Looks like a complete date
                    true
                else
                    # Probably just a year, e.g. for a film
                    PUBDATE=$(date --date="1 Jan$DATE" --rfc-2822)
                fi
                echo '<item>'
                echo   "<title>$SAFETTL</title>"
                echo   "<link>$SAFEURL</link>"
                echo   "<description><a href=\"$SAFEURL\">link</a></description>"
                echo   "<guid isPermaLink=\"true\">$SAFEURL</guid>"
                echo   "<pubDate>$PUBDATE</pubDate>"
                echo "</item>"
              }

              CACHEDIR="$HOME/.cache/iplayer_feeds"
              mkdir -p "$CACHEDIR"

              listToFeed "iPlayer Comedy" "http://www.bbc.co.uk/iplayer/categories/comedy/all?sort=dateavailable" > "$CACHEDIR/comedy.rss"

              listToFeed "iPlayer Films" "http://www.bbc.co.uk/iplayer/categories/films/all?sort=dateavailable" > "$CACHEDIR/films.rss"

              listToFeed "iPlayer Sci/Nat" "http://www.bbc.co.uk/iplayer/categories/science-and-nature/all?sort=dateavailable" > "$CACHEDIR/scinat.rss"
            '';
            rss = pkgs.writeScript "pull_down_rss" ''
              #!${pkgs.bash}/bin/bash

              # Grabs RSS feeds and dumps them in ~/.cache
              # Used to work around things imm doesn't support (e.g. HTTPS)

              function stripNonAscii {
                tr -cd '[:print:]\n'
              }

              function fixRss {
                # Set the author to $1, to avoid newlines
                xmlstarlet ed -u "//author" -v "$1" |

                # Append today as the pubDate, then remove all but the first
                # pubDate (i.e. append today as the pubDate, if none is given)
                xmlstarlet ed -s //item -t elem -n pubDate             \
                              -v "$(date -d "today 00:00" --rfc-2822)" \
                              -d '//item/author[position() != 1]'
              }

              function atomToRss {
                xsltproc ~/System/Programs/atom2rss-exslt.xsl "$1.atom" |
                  fixRss "$1" > "$1.rss"
              }

              function get {
                timeout 20 wget --no-check-certificate "$@"
              }

              function getAtom {
                get -O - "$2" | stripNonAscii > "$1.atom"
                atomToRss "$1"
              }

              function getYouTube {
                get -O - "http://www.youtube.com/feeds/videos.xml?channel_id=$2" |
                stripNonAscii > "$1.atom"
                atomToRss "$1"
              }

              function getRss {
                get -O - "$2" | stripNonAscii | fixRss "$1" > "$1.rss"
              }

              mkdir -p ~/.cache/rss
              cd ~/.cache/rss || {
                echo "Couldn't cd to ~/.cache/rss" 1>&2
                exit 1
              }

              # Configurable feeds
              while read -r FEED
              do
                TYPE=$(echo "$FEED" | cut -f1)
                NAME=$(echo "$FEED" | cut -f2)
                 URL=$(echo "$FEED" | cut -f3)

                case "$TYPE" in
                  rss)
                    getRss "$NAME" "$URL"
                    ;;
                  atom)
                    getAtom "$NAME" "$URL"
                    ;;
                  youtube)
                    getYouTube "$NAME" "$URL"
                    ;;
                  *)
                    echo "Can't handle '$FEED'" 1>&2
                    ;;
                esac
              done < ~/.feeds

              # Scrape BBC iPlayer
              "${iplayer}"

              # Scrape the Dundee Courier
              # Edit URL http://feed43.com/feed.html?name=dundee_courier
              COURIER="$HOME/.cache/rss/DundeeCourier.rss"
              if [[ -e "$COURIER" ]]
              then
                # Feed43 don't like polling more than every 6 hours
                if test "$(find "$COURIER" -mmin +360)"
                then
                  getRss "DundeeCourier" "http://feed43.com/dundee_courier.xml"
                fi
              else
                getRss "DundeeCourier" "http://feed43.com/dundee_courier.xml"
              fi
            '';
        in pkgs.writeScript "get-news-start" ''
             #!${pkgs.bash}/bin/bash

             if /var/setuid-wrappers/ping -c 1 google.com
             then
               # Run any RSS-generating scripts we might have
               "${rss}"

               pushd ~/.cache
               python -m SimpleHTTPServer 8888 &
               SERVER_PID="$!"
               popd

               # Run imm to send RSS to mailbox
               imm -u

               kill "$SERVER_PID"
             fi
           '';
    };
  };

  mailbackup = mkService {
    description   = "Fetch all mail";
    path          = with pkgs; [ bash iputils isync ];
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 3600;
      ExecStart  = pkgs.writeScript "mail-backup" ''
        #!${pkgs.bash}/bin/bash
        /var/setuid-wrappers/ping -c 1 google.com && mbsync gmail-backup
      '';
    };
  };

  keeptesting = mkService {
    description   = "Run tests";
    path          = with pkgs; [ basic nix.out ];
    environment   = { LOCATE_PATH = /var/cache/locatedb; } //
                    (listToAttrs
                      (map (name: { inherit name;
                        value = builtins.getEnv name; })
                        [ "NIX_PATH" "NIX_REMOTE" ]));
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 300;
      ExecStart  = pkgs.writeScript "keep-testing" ''
        #!${pkgs.bash}/bin/bash
        set -e
        if ! plugged_in
        then
          exit 0
        fi

        if hot
        then
          exit 0
        fi

        cd ~/System/Tests || exit 1

        # Choose one successful script at random
        S=$(find results/pass -type f | shuf | head -n1)

        # Choose one test at random
        #T=$(shuf | head -n1)

        # Choose the oldest test
        O=$(ls -1tr results/pass | head -n1)

        # Force chosen tests to be re-run
        for TST in "$S" "$O"
        do
          NAME=$(basename "$TST")
          touch results/pass/"$NAME"
          mv results/pass/"$NAME" results/check/
        done

        # Run chosen tests, along with any existing failures
        ./run
      '';
    };
  };

  mountpi = mkService {
    description   = "Mount raspberrypi when available";
    path          = with pkgs; [ iputils basic ];
    serviceConfig = {
      User       = "chris";
      Restart    = "always";
      RestartSec = 600;
      ExecStart  = pkgs.writeScript "mount-pi" ''
        #!${pkgs.bash}/bin/bash
        set -e
        if /var/setuid-wrappers/ping -c 1 raspberrypi
        then
          if ! mount | grep raspberrypi
          then
            sshfs pi@raspberrypi:/opt/shared ~/Public \
                  -o follow_symlinks -o allow_other
          fi
        fi
      '';
    };
  };

  unmountpi = mkService {
    description   = "Unmount raspberrypi when unavailable";
    path          = with pkgs; [ basic ];
    serviceConfig = {
      User       = "root";
      Restart    = "always";
      RestartSec = 600;
      ExecStart  = pkgs.writeScript "unmount-pi" ''
        #!${pkgs.bash}/bin/bash
        set -e

        function unmount {
          killall -9 sshfs
          fusermount -u /home/chris/Public
          umount     -l /home/chris/Public
        }

        if mount | grep raspberrypi
        then
          if ! /var/setuid-wrappers/ping -c 1 raspberrypi
          then
            unmount
          elif ! ls /home/chris/Public
          then
            unmount
          fi
        fi
      '';
    };
  };

  # Turn off power saving on WiFi to work around
  # https://bugzilla.kernel.org/show_bug.cgi?id=56301 (or something similar)
  wifiPower = {
    wantedBy      = [ "multi-user.target" ];
    before        = [ "network.target" ];
    path          = with pkgs; [ iw ];
    serviceConfig = {
      Type       = "simple";
      User       = "root";
      Restart    = "always";
      RestartSec = 600;
      ExecStart  = pkgs.writeScript "wifipower" ''
        #!${pkgs.bash}/bin/bash
        iw dev wlp2s0 set power_save off
      '';
    };
  };
}
