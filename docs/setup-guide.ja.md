# NixOS セットアップガイド (日本語)

このガイドでは、このリポジトリのスターター構成を使用して NixOS をセットアップする手順を詳細に説明します。

## 1. 準備

このリポジトリをローカルに配置します。

```bash
git clone https://github.com/fal-114514/nixos-seed.git nixos-config
cd nixos-config
```

## 2. ディレクトリ構造の理解

現在の構造は「マルチホスト」対応になっています。

- `hosts/`: ホストごとの個別の設定（個人用環境など）
- `flake.nix`: 全体のエントリーポイント。ここでホスト名を定義します。

## 3. ホストの作成と設定

基本的には `hosts/template` をコピーして新しいホストを作成することを推奨します。

### ステップ A: ハードウェア情報の生成

インストール先のマシンで以下を実行します。

```bash
nixos-generate-config --show-hardware-config > hosts/<your-host-name>/hardware-configuration.nix
```

### ステップ B: 変数と設定の調整

`hosts/<your-host-name>/configuration.nix` および `home.nix` を編集します。ファイル冒頭の `let ... in` ブロックで変数を定義しています。

- `username`: ユーザー名
- `hostname`: ホスト名
- `enableGnome`, `enableNiri` など: デスクトップ環境の有効化スイッチ

### ステップ C: ホスト固有の設定

- `hosts/<your-host-name>/configuration.nix`: システム全体の設定
- `hosts/<your-host-name>/home.nix`: ユーザー個別の設定
- `hosts/<your-host-name>/config/DE/`: デスクトップ環境別の設定（`niri/default.nix`, `niri/config.kdl` など）

## 4. `flake.nix` への登録

`flake.nix` の `outputs` セクションに新しいホストを追加します。

```nix
nixosConfigurations = {
  "your-host-name" = nixpkgs.lib.nixosSystem {
    # ...
  };
};
```

## 5. 設定の適用

```bash
sudo nixos-rebuild switch --flake .#your-host-name
```

## トラブルシューティング

- **hardware-configuration.nix がない**: `hosts` ディレクトリ配下の各ホスト用フォルダに配置されていることを確認してください。
- **ホスト名が一致しない**: 管理上のホスト名と `flake.nix` の定義名、および `nixos-rebuild` の `#` 以降の名前を一致させる必要があります。
