<p align="center">
    <img src=".github/assets/header.png" alt="Xinux'es {HS}">
</p>

<p align="center">
    <h3 align="center">Hotpot Shield VPN packaing effort for NixOS (only x86_64).</h3>
</p>

<p align="center">
    <img align="center" src="https://img.shields.io/github/languages/top/xinux-org/hotspot-shield?style=flat&logo=nixos&logoColor=5277C3&labelColor=ffffff&color=ffffff" alt="Top Used Language">
    <a href="https://t.me/xinux"><img align="center" src="https://img.shields.io/badge/Chat-grey?style=flat&logo=telegram&logoColor=5277C3&labelColor=ffffff&color=ffffff" alt="Telegram Community"></a>
</p>

## About

This is Uzbek Xinux community (nix users mostly) member's effort on packaging & patching Hotspot Shield VPN & providing ready to use modules for NixOS users.

## Guides & Use

This project effort provides you both Hotspot Shield VPN as a package and ready to use nix modules. In order to get started, you need to add this flake to your own config:

### Package

If you want to use the package one time, you can easily call the package via `nix run`:

```shell
# Start the hotspot shield vpn service binary
nix run github:xinux-org/hotspot-shield
```

If you're going to add this package to your own configuration, we provide `hotspotshield` binary for only x86_64 arch as Hotspot Shield only supports it:

```
inputs.hotspot-shield.packages.x86-64-linux.default
```

### Service Module (configuration use)

In order to make use of this project's modules, you **must have** your own nix configuration flake! Afterwards, you can get started by adding this project to your own configuration flake like this:

```nix
# In your configuration repo flake.nix
{
  inputs.hotspot-shield.url = "github:xinux-org/hotspot-shield";

  # Or

  inputs = {
    ...

    # Hotspot Shield project flake
    hotspot-shield.url = "github:xinux-org/hotspot-shield";

    ...
  };
}
```

Afterwards, you need to import the module and use it! You can import the module literally anywhere of your configuration as shown in example below:

```nix
# flake.nix -> nixosConfigurations as an example:
{
  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , hotspot-shield # <-- don't forget
    , ...
    } @ inputs:
    {
      nixosConfigurations = {
        "Example" = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            inputs.hotspot-shield.nixosModules.hotspot-shield
            ./nixos/example/configuration.nix
          ];
        };
      };
    };
}

# ./nixos/example/configuration.nix anywhere of your configuration
{
  services.hotspot-shield = {
    enable = true;
    config = {
      domain = "uic-gw.example.com";
      user = "example";
      password = "/path/to/pass/file"; # file should contain only password
      fingerprint.auto = true;
    };
  };

  # or

  services.hotspot-shield = {
    enable = true;
    config = {
      domain = "uic-gw.example.com";
      port = 666;
      user = "example";
      password = "/path/to/pass/file"; # file should contain only password
      fingerprint = {
        auto = false;
        data = "/path/to/fprint/file"; # file should contain only fingerprint
      }
    };
  };

  # or... if you have secrets manager in your machine

  sops.secrets = {
    # let's say, you stored secret for kerio at kerio/*
    "kerio/password" = {
      owner = config.services.kerio-kvc.user;
    };
    "kerio/fingerprint" = {
      owner = config.services.kerio-kvc.user;
    };
  };

  services.kerio-kvc = {
    enable = true;
    config = {
      domain = "uic-gw.example.com";
      user = "example";
      password = config.sops.secrets."kerio/password".path;
      fingerprint = {
        auto = false;
        data = config.sops.secrets."kerio/fingerprint".path;
      }
    };
  };
}
```

or if you broke your configurations into parts (modules), you can write your own mini-module like this:

```nix
# ./anywhere/modules/nixos/e-imzo.nix
{ inputs, ... }: {
{
  imports = [inputs.kerio.nixosModules.kerio];

  services.kerio-kvc = {
    ...
  };
}
```

You can refer to [available options](#available-options) section for more available features/options/settings~!

### Available Options

Please, refer to the example nix showcase below for more information:

```nix
{
  # Here are available options
  services.e-imzo = {
    # Enable Toggle
    # => Mandatory
    enable = true;

    config = {
      # Domain or IP pointing to Kerio server
      # => Mandatory
      domain = "";

      # Port of Kerio server
      # => Optional (default: 4090)
      port = 1234;

      # User registerd in Kerio system
      # => Mandatory
      user = "";

      # Password file containing only password
      # of registered user in Kerio system
      # => Mandatory
      password = "/path/to/pass/file";


      fingerprint = {
        # Enable auto fingerprint detection
        # from Kerio server system
        # => Mandatory
        auto = true;

        # Path to file containing only Fingerprint
        # data provided by Kerio system
        # => Optional if auto is true!
        data = "/path/to/file";
      };
    };

    # User for launching service
    # => Optional
    user = "negir";

    # Group of user for launching service
    # => Optional
    group = "negirlar";

    # Kerio custom package
    # => Optional
    package = pkgs.<?>;
  };
}
```

## Thanks

To whoever participated in packaging this software.

- [Orzklv](https://github.com/orzklv) - Maintainer

## License

This project is licensed under the MIT license - see the [LICENSE](LICENSE) file for details.

<p align="center">
    <img src=".github/assets/footer.png" alt="Xinux'es {HS}">
</p>
