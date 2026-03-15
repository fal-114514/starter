# =============================================================================
# Nix Flake Configuration / Nix Flake設定
# =============================================================================

{
  description = "Personal NixOS Configuration / 個人的なNixOS設定";

  inputs = {
    # NixOS Package Repository / NixOSパッケージリポジトリ
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager (User configuration management) / Home Manager（ユーザー設定管理）
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flatpak support
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
  };

  outputs = { self, nixpkgs, home-manager, nix-flatpak, ... }@inputs:
  let
    # デスクトップ共通変数を読み込み、両モジュールに渡す
    desktopVars = import ./hosts/desktop/variables.nix;
  in
  {
    nixosConfigurations = {
      # Desktop Configuration / デスクトップ設定 (Personal / 個人用)
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        # Pass arguments to modules / モジュールに引数を渡す
        specialArgs = { inherit inputs; } // desktopVars;

        modules = [
          ./hosts/desktop/configuration.nix
          nix-flatpak.nixosModules.nix-flatpak

          # Home Manager Integration / Home Manager統合
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.fal = import ./hosts/desktop/home.nix;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs; } // desktopVars;
          }
        ];
      };
    };
  };
}
