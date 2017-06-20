{ fetchFromGitHub, git, pythonPackages, shouldFail }:

with {
  plain = pythonPackages.buildPythonPackage {
    name = "airspeed-velocity";
    src  = fetchFromGitHub {
      owner  = "spacetelescope";
      repo   = "asv";
      rev    = "953c960";
      sha256 = "10fissqb3fzqs94c9b0rzd9gk1kxccn13bfh22rjih4z9jdfh113";
    };

    postPatch = ''
      substituteInPlace asv/commands/publish.py \
        --replace 'shutil.copytree(template_dir, conf.html_dir)' \
                  'shutil.copytree(template_dir, conf.html_dir)
              os.chmod(conf.html_dir, 0755)
              [[os.chmod(pre+"/"+x, 0755) for x in (fs+ds)] for (pre, ds, fs) in os.walk(conf.html_dir)]'
    '';

    # For tests
    buildInputs = [
      git
      pythonPackages.virtualenv
      pythonPackages.pip
      pythonPackages.wheel
    ];

    # For resulting scripts
    propagatedBuildInputs = with pythonPackages; [ six ];
  };
};
plain.override (old: {
  stillNeedToDisableTests = shouldFail plain;
  doCheck = false;
})
