{ indexState, pkgs, ... }:

let
  shell = { pkgs, ... }: {
    tools = {
      cabal = { index-state = indexState; };
      cabal-fmt = { index-state = indexState; };
      haskell-language-server = { index-state = indexState; };
      hoogle = { index-state = indexState; };
      fourmolu = { index-state = indexState; };
      hlint = { index-state = indexState; };
    };
    withHoogle = true;
    buildInputs = [
      pkgs.just
      pkgs.nixfmt-classic
      pkgs.shellcheck
      pkgs.pkg-config
      pkgs.libvterm-neovim
    ];
  };

  mkProject = { lib, pkgs, ... }: {
    name = "libvterm-haskell";
    src = ./..;
    compiler-nix-name = "ghc984";
    shell = shell { inherit pkgs; };
    modules = [{
      packages.libvterm-haskell.flags.werror = true;
      packages.libvterm-haskell.components.library = {
        libs = pkgs.lib.mkForce [ pkgs.libvterm-neovim ];
        build-tools = [ pkgs.pkg-config ];
        configureFlags = [
          "--extra-lib-dirs=${pkgs.libvterm-neovim}/lib"
          "--extra-include-dirs=${pkgs.libvterm-neovim}/include"
        ];
      };
      packages.libvterm-haskell.components.tests.unit-tests = {
        libs = pkgs.lib.mkForce [ pkgs.libvterm-neovim ];
        build-tools = [ pkgs.pkg-config ];
        configureFlags = [
          "--extra-lib-dirs=${pkgs.libvterm-neovim}/lib"
          "--extra-include-dirs=${pkgs.libvterm-neovim}/include"
        ];
      };
    }];
  };

  project = pkgs.haskell-nix.cabalProject' mkProject;

in {
  devShells.default = project.shell;
  inherit project;
  packages.libvterm-haskell =
    project.hsPkgs.libvterm-haskell.components.library;
  packages.unit-tests =
    project.hsPkgs.libvterm-haskell.components.tests.unit-tests;
}
