{
  "Ascii85" = {
    version = "1.0.2";
    source = {
      type = "gem";
      sha256 = "0j95sbxd18kc8rhcnvl1w37kflqpax1r12h1x47gh4xxn3mz4m7q";
    };
  };
  "afm" = {
    version = "0.2.2";
    source = {
      type = "gem";
      sha256 = "06kj9hgd0z8pj27bxp2diwqh6fv7qhwwm17z64rhdc4sfn76jgn8";
    };
  };
  "commander" = {
    version = "4.3.5";
    source = {
      type = "gem";
      sha256 = "0pwn2pm7yhgclg2a66rj42brk1kp5g54cnkrr5b576swjx54s8r3";
    };
    dependencies = [
      "highline"
    ];
  };
  "hashery" = {
    version = "2.1.1";
    source = {
      type = "gem";
      sha256 = "0xawbljsjarl9l7700bka672ixwznzwih4s9i38p1y9mp8hyx54g";
    };
  };
  "highline" = {
    version = "1.7.8";
    source = {
      type = "gem";
      sha256 = "1nf5lgdn6ni2lpfdn4gk3gi47fmnca2bdirabbjbz1fk9w4p8lkr";
    };
  };
  "json" = {
    version = "1.8.3";
    source = {
      type = "gem";
      sha256 = "1nsby6ry8l9xg3yw4adlhk2pnc7i0h0rznvcss4vk3v74qg0k8lc";
    };
  };
  "libsvm-ruby-swig" = {
    version = "0.4.0";
    source = {
      type = "gem";
      sha256 = "15cbk5m91mx3gdjp3irs662fmgdkwz0y5iv7d5858mxjd6f72p7z";
    };
  };
  "mini_portile" = {
    version = "0.6.2";
    source = {
      type = "gem";
      sha256 = "0h3xinmacscrnkczq44s6pnhrp4nqma7k056x5wv5xixvf2wsq2w";
    };
  };
  "nokogiri" = {
    version = "1.6.6.2";
    source = {
      type = "gem";
      sha256 = "1j4qv32qjh67dcrc1yy1h8sqjnny8siyy4s44awla8d6jk361h30";
    };
    dependencies = [
      "mini_portile"
    ];
  };
  "pdf-core" = {
    version = "0.6.0";
    source = {
      type = "gem";
      sha256 = "1ks95byqs08vxgf2a7q3spryi467rwimm2awc84fqa2yxf97ikjy";
    };
  };
  "pdf-extract" = {
    version = "0.1.1";
    source = {
      type = "gem";
      sha256 = "1wby433mhqdzkfx9c8vm69r2xdavjbfgqqxxa2z6l2wzhjwr1p2b";
    };
    dependencies = [
      "commander"
      "json"
      "libsvm-ruby-swig"
      "nokogiri"
      "pdf-reader"
      "prawn"
      "sqlite3"
    ];
  };
  "pdf-reader" = {
    version = "1.1.1";
    source = {
      type = "gem";
      sha256 = "0wvr68lyx968lgnzmqsjmd3m2apyfmiacv878pzv52p65kas5aps";
    };
    dependencies = [
      "Ascii85"
      "afm"
      "hashery"
      "ruby-rc4"
      "ttfunk"
    ];
  };
  "prawn" = {
    version = "2.0.2";
    source = {
      type = "gem";
      sha256 = "0z9q3l8l73pvx6rrqz40xz9xd5izziprjnimb572hcah6dh30cnw";
    };
    dependencies = [
      "pdf-core"
      "ttfunk"
    ];
  };
  "ruby-rc4" = {
    version = "0.1.5";
    source = {
      type = "gem";
      sha256 = "00vci475258mmbvsdqkmqadlwn6gj9m01sp7b5a3zd90knil1k00";
    };
  };
  "sqlite3" = {
    version = "1.3.11";
    source = {
      type = "gem";
      sha256 = "19r06wglnm6479ffj9dl0fa4p5j2wi6dj7k6k3d0rbx7036cv3ny";
    };
  };
  "ttfunk" = {
    version = "1.4.0";
    source = {
      type = "gem";
      sha256 = "1k725rji58i0qx5xwf7p9d07cmhmjixqkdvhg1wk3rpp1753cf1j";
    };
  };
}
