{ stdenv, rustChannelOf, fetchgit, fetchFromGitHub, recurseIntoAttrs }:

let
  # Taken from rusttoolchain in src
  toolchain = rustChannelOf {date = "2018-06-19"; channel = "nightly";};
  fork = import (fetchFromGitHub {
	  owner = "ljli";
	  repo = "nixpkgs";
	  rev = "170b18f3810913315003a7195c897b2947006b5e";
	  sha256 = "1x3w6jc7rap2vwz2qnam51pyxhfw716ipkbi2bq8a9yrn4bd2pkp";
	}) {};
  rust = recurseIntoAttrs (fork.makeRustPlatform {
  	cargo = toolchain.rust;
  	rustc = toolchain.rust;
  });

in
rust.buildRustPackage rec {
  name = "relibc-${version}";
  version = "2018-10-21";

  # Work around for lack of fetchSubmodules for GitLab
  src = fetchgit {
    url = "https://gitlab.redox-os.org/redox-os/relibc.git";
    rev = "bfa068df8834f3171cc728016bcf9eb9e9ca09bd";
    sha256 = "0qxh5wyl74j8asrc4608dabraa1rmjm1s8wgq2y1rhgqdp14an8h";
  };

  postPatch = "patchShebangs include.sh";

  cargoVendorNoMergeSources = true;
  cargoSha256 = "0gs0hsx6fz48w08ddylyr2398z0as1l35bv282rk12k28z4v1mhb";

  buildPhase = "make CARGOFLAGS=--frozen";
  installPhase = ''
    make DESTDIR=$out install
    cd $out/lib
    ln -s crt0.o crt1.o
  '';

  checkPhase = "make test";

}
