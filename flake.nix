{
  description = "ML environment";

  inputs = {
    nixpkgs.url = "nixpkgs";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          uv
          python312
          git
        ];

        # Force uv to use the Nix-native Python interpreter
        UV_PYTHON_DOWNLOADS = "never";
        UV_PYTHON = "${pkgs.python312.interpreter}";

        # Pass standard C libs and the host GPU driver to PyPI wheels
        LD_LIBRARY_PATH =
          pkgs.lib.makeLibraryPath (
            with pkgs;
            [
              stdenv.cc.cc.lib
              zlib
              glib
            ]
          )
          + ":/run/opengl-driver/lib:/run/opengl-driver-devel/lib";

        shellHook = ''
          echo "[ok]: ML Environment Active"
          echo "[i]: Run 'nix develop'"
        '';
      };
    };
}
