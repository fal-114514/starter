# =============================================================================
# Home Manager Configuration / Home Manager設定
# =============================================================================

{ pkgs, lib, ... }:

let
  username = "fal";
  gitUsername = "Fal";
  gitEmail = "fal@example.com";
  stateVersion = "25.11";

  # ---------------------------------------------------------------------------
  # Desktop Settings / デスクトップ環境設定
  # ---------------------------------------------------------------------------
  enableGnome = true;
  enableKde = true;
  enableNiri = true;

  # ---------------------------------------------------------------------------
  # Input Method Settings / 入力メソッド設定
  # ---------------------------------------------------------------------------
  enableMozc = true;
  fcitx5Layout = "us";
in
{
  # ===========================================================================
  # Imports / 外部ファイルインポート
  # ===========================================================================
  imports = [ ./modules/vscode/vscode.nix ]
          ++ lib.optionals enableGnome [ ./modules/DE/gnome/default.nix ]
          ++ lib.optionals enableKde [ ./modules/DE/kde/default.nix ]
          ++ lib.optionals enableNiri [ ./modules/DE/niri/default.nix ];

  # ===========================================================================
  # Basic Settings / 基本設定
  # ===========================================================================
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;


  # ===========================================================================
  # Tool Configurations / ツール設定
  # ===========================================================================
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = gitUsername;
        email = gitEmail;
      };
    };
  };

  programs.starship.enable = true;
  programs.ghostty.enable = true;
  programs.atuin = {
    enable = true;
    enableNushellIntegration = true;
    settings = {
      auto_sync = true;
      update_check = false;
      filter_mode_shell_up_key_binding = "directory";
    };
  };

  # ===========================================================================
  # User Packages / ユーザーパッケージ
  # ===========================================================================
  home.packages = with pkgs; [
    # System Utilities / システムユーティリティ
    wget curl zip unzip p7zip rar gnutar iproute2 unixtools.ping

    # Development / 開発
    gcc pkg-config glib glib.dev gtk3.dev pango.dev cairo.dev gdk-pixbuf

    # Hardware Tools / ハードウェアツール
    brightnessctl parted

    # Desktop Tools / デスクトップツール
    mangohud xdg-utils nnn pcmanfm

    # Applications / アプリケーション
    firefox vivaldi vesktop motrix aria2

    # Wine
    wineWow64Packages.full
  ];
}
