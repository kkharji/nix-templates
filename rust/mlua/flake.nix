{
  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/master";
    nixCargoIntegration.url =
      "github:yusdacra/nix-cargo-integration?rev=3c52cba9901095d01bd94848d6231d777d29097e";
  };
  outputs = { nixCargoIntegration, ... }@inputs:
    nixCargoIntegration.lib.makeOutputs {
      root = ./.;
      buildPlatform = "buildRustPackage";
      cargoVendorHash = "sha256-hj/yrqzrre8VNXwYpfCLQ544Q17aCQ/pgq/GFwrfQrM=";
      defaultOutputs = { };
      overrides = with inputs.nixpkgs; {
        sources = common: prev: { };
        pkgs = common: prev: { };
        common = prev: {
          inherit (prev) pkgs;
          runtimeLibs = prev.runtimeLibs
            ++ [ ]; # libraries exported in $LD_LIBRARY_PATH environment variable.
          buildInputs = prev.buildInputs
            ++ [ ]; # build inputs for build derivation and packages for devshell.
          nativeBuildInputs = prev.nativeBuildInputs
            ++ [ ]; # native build inputs for build derivation and packages for development shell.
          env = prev.env
            // { }; # exported as environment variables in build and development shell.
        };
        shell = common: prev:
          let
            luaenv = import ./luaenv.nix {
              inherit lib;
              inherit (common) pkgs;
              path = [ "./result/share/lua/5.4/?.lua" ];
              cpath = [ "./result/lib/?.dylib" ];
              extra = p: [ p.inspect ];
              overrides = p: { luarocks = p.luarocks-3_7; };
            };
          in {
            packages = with common.pkgs; prev.packages ++ [ luaenv.lua ];
            env = prev.env ++ [
              (lib.nameValuePair "LUA_PATH" luaenv.path)
              (lib.nameValuePair "LUA_CPATH" luaenv.cpath)
            ];
            commands = let
              buildcmd = "nix build";
              req = "require('libMYNAME')";
              run = stm: rb:
                ''${if rb then "${buildcmd} &&" else ""} lua -e "${stm}"'';
            in prev.commands ++ [
              {
                name = "brun";
                command = run "${req}$@" true;
                category = "testing";
                help = "build then run within lua: e.g. brun 'version'";
              }
              {
                name = "run";
                command = run "${req}$@" false;
                help = "run within lua: e.g. run 'version'";
                category = "testing";
              }
              {
                name = "inspect";
                command = run "print(require'inspect'(${req}$@))" false;
                help = "print within lua: e.g. print '.version'";
                category = "testing";
              }
              {
                name = "binspect";
                command = run "print(require'inspect'(${req}$@))" true;
                help = "build then print within lua: e.g. bprint '.version'";
                category = "testing";
              }
            ];
          };
      };
    };
}
