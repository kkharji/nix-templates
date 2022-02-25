{
  description = "A collection of flake templates";

  outputs = { self }: {
    templates = {
      rust.bin = {
        path = ./rust/bin;
        description = "Rust bin template, using Naersk";
      };

      rust.mlua = {
        path = ./rust/mlua;
        description = "Rust mlua template, using nix-cargo-integration";
      };

      clang.hello = {
        path = ./clang/hello;
        description = "An over-engineered Hello World in C";
      };

      nixos.container = {
        path = ./nixos/container;
        description = "A NixOS container running apache-httpd";
      };

      misc.hercules-ci = {
        path = ./mix/hercules-ci;
        description =
          "An example for Hercules-CI, containing only the necessary attributes for adding to your project.";
      };

      pandoc.report = {
        path = ./pandoc/xelatex;
        description = "A report built with Pandoc, XeLaTex and a custom font";
      };

      go.hello = {
        path = ./go/hello;
        description = "A simple Go package";
      };
    };
  };
}
