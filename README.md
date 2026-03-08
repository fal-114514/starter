# NixOS Starter Configuration

このリポジトリは、モジュール性とカスタマイズ性を重視したNixOSのスターター設定です。
マルチホスト（複数マシン）対応の構造になっており、各ホストごとの設定を独立して管理できます。

## 目次 / Table of Contents

- [NixOS Starter Configuration](#nixos-starter-configuration)
  - [目次 / Table of Contents](#目次--table-of-contents)
  - [ディレクトリ構造 / Directory Structure](#ディレクトリ構造--directory-structure)
  - [仕組み / Mechanism](#仕組み--mechanism)
  - [セットアップ手順 / Getting Started](#セットアップ手順--getting-started)
    - [クイックスタート (既設ホストの適用)](#クイックスタート-既設ホストの適用)
  - [主要なコマンド / Key Commands](#主要なコマンド--key-commands)
  - [ライセンス / License](#ライセンス--license)

## ディレクトリ構造 / Directory Structure

```plaintext
.
├── flake.nix               # エントリーポイント / Entry Point (ホスト定義)
├── hosts/                  # ホスト別の設定 / Host-specific configurations
│   └── desktop/            # 個人用環境
│       ├── configuration.nix # システム設定
│       ├── home.nix          # ユーザー設定
│       └── config/         # アプリ別の設定ファイル
│           └── DE/         # デスクトップ環境別設定
│               ├── gnome/  # GNOME固有設定 (default.nix等)
│               ├── kde/    # KDE固有設定 (default.nix等)
│               └── niri/   # Niri固有設定 (default.nix, config.kdl等)
└── docs/                   # ドキュメント / Documentation
    ├── setup-guide.ja.md   # セットアップガイド (日本語)
    ├── setup-guide.en.md   # Setup Guide (English)
    └── architecture.ja.md  # 構成説明書 (日本語)
```

## 仕組み / Mechanism

1.  **直接的な設定**: `variables.nix` のような独自の抽象化レイヤーを廃止し、`configuration.nix` や `home.nix` の冒頭にある `let ... in` ブロックで直接設定（ユーザー名やデスクトップ環境の有効化など）を定義します。
2.  **標準的な Flake 構成**: NixOS の標準的な Flake の書き方に準拠しており、外部ドキュメントや例をそのまま参考にしやすくなっています。
3.  **モジュールの整理**: デスクトップ固有の設定（シンボリックリンクや固有パッケージ）を `config/DE/{env}/default.nix` に集約しました。`home.nix` でこれらをインポートすることで、各環境の設定が独立し、パス指定も簡潔（相対パス）になっています。

詳細な構造と仕組みについては、[**構成説明書 (日本語)**](./docs/architecture.ja.md) を参照してください。

## セットアップ手順 / Getting Started

詳細なセットアップ手順については、以下のガイドを参照してください。

- [**セットアップガイド (日本語)**](./docs/setup-guide.ja.md)
- [**Setup Guide (English)**](./docs/setup-guide.en.md)

### クイックスタート (既設ホストの適用)

```bash
sudo nixos-rebuild switch --flake .#desktop
```

## 主要なコマンド / Key Commands

- **設定の適用**: `sudo nixos-rebuild switch --flake .#<hostname>`
- **パッケージ更新**: `nix flake update`

## ライセンス / License

このプロジェクトは **MIT License** の下で公開されています。
