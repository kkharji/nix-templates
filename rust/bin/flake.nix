{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    naersk-lib.url =
      "github:nix-community/naersk?rev=2fc8ce9d3c025d59fee349c1f80be9785049d653";
    utils.url =
      "github:numtide/flake-utils?rev=3cecb5b042f7f209c56ffd8371b2711a290ec797";
    devshell.url =
      "github:numtide/devshell?rev=7033f64dd9ef8d9d8644c5030c73913351d2b660";
    flake-compat = {
      url =
        "github:edolstra/flake-compat?rev=b7547d3eed6f32d06102ead8991ec52ab0a4f1a7";
      flake = false;
    };
  };

  # TODO: replace with https://github.com/yusdacra/nix-cargo-integration/pull/56
  outputs = { self, ... }@inputs:
    with inputs.utils.lib;
    eachDefaultSystem (system:
      let
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ inputs.devshell.overlay ];
        };
        common = {
          buildInputs = [ ];
          nativeBuildInputs = [ ];
        };
        naersk = pkgs.callPackage naersk-lib { };
      in {
        devShell = pkgs.devshell.mkShell {
          imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
          packages = common.buildInputs ++ common.nativeBuildInputs;
          env = [
            # { # FAILS with rust-anaylzer
            #   name = "RUST_SRC_PATH";
            #   value = "${pkgs.rustPlatform.rustLibSrc}";
            # }
          ];
        };
        defaultPackage = naersk.buildPackage {
          inherit (common) buildInputs nativeBuildInputs;
          pname = "MYNAME";
          # The command to use for the build. The argument must be a function modifying the default value.
          cargoBuild =
            "cargo $cargo_options build $cargo_build_options >> $cargo_build_output_json";
          # Options passed to cargo build, i.e. cargo build <OPTS>. These
          # options can be accessed during the build through the environment
          # variable cargo_build_options. Note: naersk relies on the --out-dir
          # out option and the --message-format option. The
          # $cargo_message_format variable is set based on the cargo version.
          # Note: these values are not (shell) escaped, meaning that you can
          # use environment variables but must be careful when introducing e.g.
          # spaces. The argument must be a function modifying the default
          # value.
          cargoBuildOptions = [
            "$cargo_release"
            ''-j "$NIX_BUILD_CORES"''
            "--message-format=$cargo_message_format"
          ];
          # When true, rustc remaps the (/nix/store) source paths to /sources to reduce the number of dependencies in the closure.
          remapPathPrefix = true;
          # The commands to run in the checkPhase. Do not forget to set doCheck. The
          # argument must be a function modifying the default value.
          cargoTestCommands =
            [ "cargo $cargo_options test $cargo_test_options" ];
          # Options passed to cargo test, i.e. cargo test <OPTS>. These options can be
          # accessed during the build through the environment variable
          # cargo_test_options. Note: these values are not (shell) escaped, meaning that
          # you can use environment variables but must be careful when introducing e.g.
          # spaces. The argument must be a function modifying the default value.
          cargoTestOptions = [ "$cargo_release" ''-j "$NIX_BUILD_CORES"'' ];

          # Options passed to all cargo commands, i.e. cargo <OPTS> .... These options
          # can be accessed during the build through the environment variable
          # cargo_options. Note: these values are not (shell) escaped, meaning that you
          # can use environment variables but must be careful when introducing e.g.
          # spaces. The argument must be a function modifying the default value.
          cargoOptions = [ ];
          # When true, cargo doc is run and a new output doc is generated. Default: false
          # cargoDocCommands	The commands to run in the docPhase. Do not forget to set
          # doDoc. The argument must be a function modifying the default value.
          doDoc = [ "cargo $cargo_options doc $cargo_doc_options" ];
          # Options passed to cargo doc, i.e. cargo doc <OPTS>. These options
          # can be accessed during the build through the environment variable
          # cargo_doc_options. Note: these values are not (shell) escaped,
          # meaning that you can use environment variables but must be careful
          # when introducing e.g. spaces. The argument must be a function
          # modifying the default value.
          cargoDocOptions =
            [ "--offline" "$cargo_release" ''-j "$NIX_BUILD_CORES"'' ];
          # When true, all cargo builds are run with --release. The environment variable
          # cargo_release is set to --release iff this option is set. Default: true
          release = true;
          # An override for all derivations involved in the build. Default:
          override = x: x;
          # An override for the top-level (last, main) derivation. If both override and
          # overrideMain are specified, both will be applied to the top-level derivation.
          # Default: (x: x)
          overrideMain = x: x;
          # When true, no intermediary (dependency-only) build is run. Enabling
          # singleStep greatly reduces the incrementality of the builds.
          singleStep = false;
          # When true, the resulting binaries are copied to $out/bin.
          # Note: this relies on cargo's --message-format argument, set in the default
          # cargoBuildOptions. Default: true
          copyBins = true;
          # When true, the resulting binaries are copied to $out/lib. Note: this relies
          # on cargo's --message-format argument, set in the default cargoBuildOptions.
          copyLibs = false;
          # A jq filter for selecting which build artifacts to release. This is run on
          # cargo's --message-format JSON output. The value is written to the
          # cargo_bins_jq_filter variable. Default:
          copyBinsFilter = ''
            select(.reason == "compiler-artifact" and .executable != null and .profile.test == false)'';
          # When true, the documentation is generated in a different output, doc.
          copyDocsToSeparateOutput = true;
          # When true, the build fails if the documentation step fails; otherwise the
          # failure is ignored. Default: false
          doDocFail = false;
          # When true, references to the nix store are removed from the generated documentation.
          removeReferencesToSrcFromDocs = true;
          # When true, the build output of intermediary builds is compressed with Zstandard. This reduces the size of closures.
          compressTarget = true;
          # When true, the target/ directory is copied to $out.
          copyTarget = false;
        };
        packages = flattenTree { mnsend = self.defaultPackage."${system}"; };
        overlay = f: p: { mnsend = self.defaultPackage."${system}"; };
        defaultApp = mkApp { drv = self.defaultPackage."${system}"; };

      });
}
