{ buildPythonPackage, fetchurl }:

buildPythonPackage {
  name = "beautiful-soup";
  src  = fetchurl {
    url    = "https://www.crummy.com/software/BeautifulSoup/bs4/download/4.5/beautifulsoup4-4.5.1.tar.gz";
    sha256 = "1qgmhw65ncsgccjhslgkkszif47q6gvxwqv4mim17agxd81p951w";
  };
}
