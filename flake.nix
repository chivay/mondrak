{
  description = "mondrak";
  nixConfig.bash-prompt = "\[mondrak\]$ ";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.nixpkgs-xen.url = "github:chivay/nixpkgs/xen-4.16";

  outputs = { self, nixpkgs, flake-utils, nixpkgs-xen }:
  let system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      xenpkgs = nixpkgs-xen.legacyPackages.${system};
  in
  {
    devShell.x86_64-linux = pkgs.mkShell.override { stdenv = pkgs.llvmPackages_13.stdenv; } {
              shellHook = ''
              export LIBCLANG_PATH=${pkgs.llvmPackages_13.clang-unwrapped.lib}/lib
              export AR=llvm-ar
              '';
              buildInputs = with pkgs; [
                xenpkgs.xen_4_16
                rustc
                cargo
                clippy
                rustfmt
                llvmPackages_13.llvm.dev
              ];
    };

    nixosConfigurations = {
      test-vm = nixpkgs-xen.lib.nixosSystem {
        system = system;
        modules = [
          (inputs: {
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
