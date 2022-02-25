# MYNAME
DESCRIPTION

## Usage
```
MYNAME
```
## Installation

### Cargo

```bash
cargo install --git https://github.com/tami5/MYNAME
```

### Flakes

```nix
{
  inputs = {
    MYNAME.url = "github:tami5/MYNAME";
    MYNAME.inputs.nixpkgs.follows = "nixpkgs";
  };
  output = { self, ... }@inputs {
    /// ......
    {
      nixpkgs.overlays = [ (_: _: inputs.MYNAME.packages) ];
    };
  };
}
```

### Legacy

```nix
{
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/tami5/MYNAME/archive/master.tar.gz;
    }))
  ];
}
```

