{
  description = "A collection of flake templates";

  outputs = { self }: {
    templates = {
      rust-bin = {
        path = ./rust-bin;
        description = "Rust bin template, using Naersk";
      };
    };

  };
}
