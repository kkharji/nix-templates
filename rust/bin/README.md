# MYNAME
DESCRIPTION

## Usage
```
MYNAME
```
## Installation

### Cargo

```bash
cargo install --git https://github.com/kkharji/MYNAME
```

### Flakes

```nix
{
  inputs = {
    MYNAME.url = "github:kkharji/MYNAME";
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
      url = https://github.com/kkharji/MYNAME/archive/master.tar.gz;
    }))
  ];
}
```

