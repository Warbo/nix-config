{ latestGit, stdenv }:

stdenv.mkDerivation {
  name = "wkhtmltopdf";
  src  = latestGit {
    url = "https://github.com/wkhtmltopdf/wkhtmltopdf.git";
  };
}
