{ stdenv, amiga-kickstart, fs-uae, xvfb_run }:

stdenv.mkDerivation {
  name    = "workbench";
  version = "3.1";
  src     = ~/System/Games/Workbench3.1;
  propagatedBuildInputs = [ fs-uae xvfb_run ];
  buildPhase = ''
    mkdir "workbench";
    echo fs-uae --kickstart_file='${amiga-kickstart}' \
                    --floppy_drive_0=./WB-3_1.ADF \
                    --floppy_drive_1=./IN-3_1.ADF \
                    --keep_aspect=1 --line_doubling=0 --scale-x=1 --scale-y=1 \
                    --window_resizable=0 --window_width=642 --window-height=258 --fullscreen=1
  '';
}
