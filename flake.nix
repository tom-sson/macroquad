{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
        flake-utils.url = "github:numtide/flake-utils";
        rust-overlay = {
            url = "github:oxalica/rust-overlay";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { nixpkgs, flake-utils, rust-overlay, ... }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                overlays = [ (import rust-overlay) ];
                pkgs = import nixpkgs {
                  inherit system overlays;
                };
            in
        {
            devShells.default = with pkgs; mkShell {
                buildInputs = [
                    # rust-bin.stable.latest.default
                    # rust-bin.beta.latest.default
                    wasm-pack
                    (rust-bin.nightly.latest.default.override {
                      extensions = [ "rust-src" ];
                      targets = [ "wasm32-unknown-unknown" ];
                    })
                ];
                packages = with pkgs; [
                    bacon
                    rust-analyzer

                    cargo-insta
                    cargo-expand
                    cargo-llvm-lines
                    cargo-edit
                    cargo-flamegraph

                    pkg-config
                    udev
                    alsa-lib
                ];
                RUST_SRC_PATH = rustPlatform.rustLibSrc;
                LD_LIBRARY_PATH = 
                    ''${pkgs.lib.makeLibraryPath [ 
                        libxkbcommon
                        xorg.libX11
                        xorg.libXi
                        libGL
                    ]}:$LD_LIBRARY_PATH'';
            };
        }
    );
}
