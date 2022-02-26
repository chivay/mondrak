{
  description = "mondrak";
  nixConfig.bash-prompt = "\[mondrak\]$ ";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.nixpkgs-xen.url = "github:chivay/nixpkgs/xen-4.16";

  outputs = { self, nixpkgs, flake-utils, nixpkgs-xen }:
    flake-utils.lib.eachDefaultSystem
    (system:
        let pkgs = nixpkgs.legacyPackages.${system};
            xenpkgs = nixpkgs-xen.legacyPackages.${system};
        in
        {
            devShell = pkgs.mkShell.override { stdenv = pkgs.llvmPackages_13.stdenv; } {
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
        }
    );
}
