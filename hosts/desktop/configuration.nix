# =============================================================================
# NixOS System Configuration / NixOSシステム設定
# =============================================================================

{ config, pkgs, lib, ... }:

let
  # ---------------------------------------------------------------------------
  # Basic Settings / 基本設定
  # ---------------------------------------------------------------------------
  username = "fal";
  userDescription = "Fal";
  hostname = "desktop";
  timeZone = "Asia/Tokyo";
  defaultLocale = "en_US.UTF-8";
  extraLocale = "ja_JP.UTF-8";

  # VMware環境等（vmwgfxドライバが必要な環境）にインストールする場合はtrueに設定してください
  # 注意: VirtualBoxの場合は virtualisation.virtualbox.guest が自動的に処理するため不要
  isVM = false;

  # ---------------------------------------------------------------------------
  # Desktop Environment / デスクトップ環境
  # ---------------------------------------------------------------------------
  enableGnome = true;
  enableKde = true;
  enableNiri = true;

  # Display Manager: "tuigreet", "gdm", "sddm", "regreet", "lemurs"
  displayManager = "tuigreet";

  # ---------------------------------------------------------------------------
  # Input Method / 入力メソッド
  # ---------------------------------------------------------------------------
  enableMozc = true;
  fcitx5Layout = "us";
in
{
  imports = [
    # hardware-configuration.nix が見つからない場合は、
    # 'nixos-generate-config --show-hardware-config' を実行して生成してください。
    ./hardware-configuration.nix
  ];

  # ===========================================================================
  # Boot Configuration / ブート設定
  # ===========================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = lib.mkIf isVM [ "vmwgfx" ];
  boot.plymouth.enable = true;

  # ===========================================================================
  # Network & SSH / ネットワークとSSH
  # ===========================================================================
  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  security.pam.loginLimits = [
    { domain = "*"; type = "soft"; item = "nofile"; value = "1048576"; }
    { domain = "*"; type = "hard"; item = "nofile"; value = "1048576"; }
  ];

  # ===========================================================================
  # Localization / ローカライゼーション
  # ===========================================================================
  time.timeZone = timeZone;
  time.hardwareClockInLocalTime = true;

  i18n = {
    defaultLocale = defaultLocale;
    extraLocaleSettings = {
      LC_ADDRESS = extraLocale;
      LC_IDENTIFICATION = extraLocale;
      LC_MEASUREMENT = extraLocale;
      LC_MONETARY = extraLocale;
      LC_NAME = extraLocale;
      LC_NUMERIC = extraLocale;
      LC_PAPER = extraLocale;
      LC_TELEPHONE = extraLocale;
      LC_TIME = extraLocale;
    };

    inputMethod = lib.mkIf enableMozc {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [ fcitx5-mozc fcitx5-gtk ];
      fcitx5.waylandFrontend = true;
      fcitx5.settings.inputMethod = {
        "GroupOrder" = { "0" = "Default"; };
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = fcitx5Layout;
          DefaultIM = "mozc";
        };
        "Groups/0/Items/0" = { Name = "keyboard-${fcitx5Layout}"; };
        "Groups/0/Items/1" = { Name = "mozc"; };
      };
    };
  };

  services.xserver.xkb = {
    layout = fcitx5Layout;
    variant = "";
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  # ===========================================================================
  # Audio / オーディオ
  # ===========================================================================
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ===========================================================================
  # Desktop Environment / デスクトップ環境
  # ===========================================================================
  services.xserver.enable = enableGnome || enableKde;
  services.desktopManager.gnome.enable = enableGnome;
  services.desktopManager.plasma6.enable = enableKde;
  programs.niri.enable = enableNiri;

  # Display Manager / ログインマネージャー
  services.displayManager.gdm.enable = displayManager == "gdm";
  services.displayManager.sddm.enable = displayManager == "sddm";
  programs.regreet.enable = displayManager == "regreet";

  services.greetd = {
    enable = displayManager == "tuigreet" || displayManager == "regreet";
    settings = {
      default_session = {
        command =
          if displayManager == "regreet" then
            "${pkgs.dbus}/bin/dbus-run-session ${pkgs.cage}/bin/cage -s -- ${pkgs.greetd.regreet}/bin/regreet"
          else
            "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --remember --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions:${config.services.displayManager.sessionData.desktops}/share/xsessions";
        user = "greeter";
      };
    };
  };

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
    VTNr = 1;
  };

  programs.ssh.askPassword = lib.mkIf (enableGnome && enableKde)
    (lib.mkForce "${pkgs.gnome-keyring}/libexec/seahorse/ssh-askpass");

  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    XMODIFIERS = if enableMozc then "@im=fcitx" else "";
  };

  # ===========================================================================
  # User Account / ユーザーアカウント
  # ===========================================================================
  users.users.${username} = {
    isNormalUser = true;
    description = userDescription;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    shell = pkgs.nushell;
  };

  # ===========================================================================
  # System Packages & Services / システムパッケージとサービス
  # ===========================================================================
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    git
    vim
    adwaita-icon-theme
    qt6Packages.fcitx5-configtool
  ];

  services.flatpak.enable = true;
  virtualisation.libvirtd.enable = false;
  virtualisation.virtualbox.guest.enable = isVM;
  programs.nix-ld.enable = true;

  # System State / システムステート
  system.stateVersion = "25.11";

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
