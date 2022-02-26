{
  description = "mondrak";
  nixConfig.bash-prompt = "\[mondrak\]$ ";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.nixpkgs-xen.url = "github:chivay/nixpkgs/xen-4.16";

  outputs = { self, nixpkgs, flake-utils, nixpkgs-xen }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      xenpkgs = nixpkgs-xen.legacyPackages.${system};
    in
    {
      packages.${system}."trace" = pkgs.rustPlatform.buildRustPackage.override {
        stdenv = pkgs.llvmPackages_13.stdenv;
      } rec {
        name = "trace";
        src = ./.;
        cargoSha256 = "sha256-jwNOlAAiFk262Zb+EU7oc1ptjCQSU8Ma10ZUVrwASHw=";

        LIBCLANG_PATH = "${pkgs.llvmPackages_13.clang-unwrapped.lib}/lib";
        AR = "llvm-ar";

        buildInputs = with pkgs; [
          xenpkgs.xen_4_16
          rustc
          cargo
          clippy
          rustfmt
          llvmPackages_13.llvm.dev
          llvmPackages_13.clang
        ];
      };
      devShell.${system} = pkgs.mkShell.override { stdenv = pkgs.llvmPackages_13.stdenv; } {
        shellHook = ''
          export LIBCLANG_PATH=${pkgs.llvmPackages_13.clang-unwrapped.lib}/lib
          export AR=llvm-ar
        '';
        buildInputs = with pkgs; [
          nixpkgs-fmt
        ];
      };

      nixosConfigurations = {
        test-vm = nixpkgs-xen.lib.nixosSystem {
          system = system;
          modules = [
            (inputs: {

              environment.systemPackages = [
                self.packages.${system}.trace
              ];
              documentation.enable = false;
              documentation.man.enable = false;
              users.users.root.password = "root";
              virtualisation.xen.enable = true;
              system.stateVersion = "22.05";
            })
          ];
        };
      };
    };
}
