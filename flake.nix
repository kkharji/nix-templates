{
  description = "A collection of flake templates";

  outputs = { self }: {
    templates = {
      rust.bin = {
        path = ./rust/bin;
        description = "Rust bin template, using Naersk";
      };

      clang.hello = {
        path = ./clang/hello;
        description = "An over-engineered Hello World in C";
      };

  };
}
