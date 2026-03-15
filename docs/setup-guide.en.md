# NixOS Setup Guide (English)

This guide provides detailed instructions on how to set up NixOS using this starter configuration.

## 1. Preparation

Clone this repository to your local machine.

```bash
git clone https://github.com/fal-114514/nixos-seed.git nixos-config
cd nixos-config
```

## 2. Understanding the Directory Structure

The configuration is structured to support multiple hosts (machines).

- `hosts/`: Host-specific configurations (personal, etc.)
- `flake.nix`: The main entry point where hosts are defined.

## 3. Creating and Configuring a Host

It is recommended to copy `hosts/template` to create a new host configuration.

### Step A: Generate Hardware Configuration

Run the following on the target machine:

```bash
nixos-generate-config --show-hardware-config > hosts/<your-host-name>/hardware-configuration.nix
```

### Step B: Adjust Variables and Settings

Edit **`variables.nix`** to configure the shared flags for desktop environments:

- `enableGnome`, `enableKde`, `enableNiri`: Toggle switches for desktop environments
- `enableMozc`, `fcitx5Layout`: Input method settings

Then edit the local variables in `configuration.nix` (`username`, `hostname`, etc.) and `home.nix` (`gitEmail`, etc.).

### Step C: Host-Specific Settings

- `hosts/<your-host-name>/configuration.nix`: System-wide settings
- `hosts/<your-host-name>/home.nix`: User-specific settings (Home Manager)
- `hosts/<your-host-name>/variables.nix`: Shared flags used by both files above
- `hosts/<your-host-name>/modules/DE/`: Desktop environment-specific settings (e.g., `niri/default.nix`, `niri/config.kdl`)

## 4. Registering in `flake.nix`

Add your new host to the `outputs` section in `flake.nix`.

```nix
nixosConfigurations = {
  "your-host-name" = nixpkgs.lib.nixosSystem {
    # ...
  };
};
```

## 5. Applying the Configuration

```bash
sudo nixos-rebuild switch --flake .#your-host-name
```

## Troubleshooting

- **hardware-configuration.nix missing**: Ensure it is placed inside the correct host directory under `hosts/`.
- **Hostname mismatch**: The hostname in your configuration, the definition in `flake.nix`, and the name used in `nixos-rebuild switch --flake .#name` must all match.
