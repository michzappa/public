{
  description = "michzappa's publicized information";

  inputs = {
    emacs.url = "github:nix-community/emacs-overlay";
    kmonad.url = "github:kmonad/kmonad?dir=nix";
    knock.url = "gitlab:michzappa/knock";

    darwin.url = "github:lnl7/nix-darwin/master";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-22.11";
  };

  outputs = { self, ... }@inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs { inherit system; });
        tangler = pkgs.emacs.pkgs.withPackages (epkgs: [ epkgs.ox-hugo ]);
      in rec {
        devShell =
          pkgs.mkShell { buildInputs = with pkgs; [ go hugo tangler ]; };

        packages = rec {
          site = pkgs.stdenv.mkDerivation {
            name = "site";
            src = self;
            buildInputs = with pkgs; [ hugo go tangler ];
            buildPhase = ''
              emacs --batch --script export.el
              hugo
            '';
            installPhase = ''
              cp -r public $out
            '';
          };
          nix-configurations = pkgs.stdenv.mkDerivation {
            name = "nix-configurations";
            src = ./org;
            buildInputs = [ tangler ];
            buildPhase = ''
              emacs ./etc_nixos.org --batch --funcall org-babel-tangle
            '';
            installPhase = ''
              mkdir $out
              cp * $out
            '';
          };
          homeConfigurations =
            (import "${nix-configurations}/etrange.nix" inputs);
          nixosConfigurations =
            (import "${nix-configurations}/rorohiko.nix" inputs)
            // (import "${nix-configurations}/vm.nix" inputs);

        };

        defaultPackage = packages.site;
      });
}
