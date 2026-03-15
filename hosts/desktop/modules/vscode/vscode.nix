# ============================================================================
# VSCode / Antigravity 設定モジュール
# ============================================================================
# このファイルは vscode-settings.json を Nix で宣言的に管理するための
# Home Manager モジュールです。
# ============================================================================
#
# ============================================================================
#  VSCode Settings 設計ルール（運用指針）
# ============================================================================
#
# 【基本思想】
# この settings は「見た目」ではなく
# 「責務（いつ・何を制御するか）」で分類すること。
# API名（files/editor/workbench）では絶対に分けない。
#
# 迷ったら「その設定は "いつ効くのか"」で考える。
#
# ----------------------------------------------------------------------------
# 【セクション分類ルール】
# ----------------------------------------------------------------------------
#
# 1. APPEARANCE & VISUAL
#    画面の見た目・装飾のみ。
#    テーマ / 色 / フォント / ミニマップ / アニメーション / アイコン など
#    ✦ いつ効くか: VSCode 起動時・テーマ切替時・ウィンドウ再描画時
#    例) colorTheme → ウィンドウを開いた瞬間に適用
#        fontFamily → エディタペインが表示されるたびに適用
#
# 2. EDITOR & UX
#    タイピング中・操作中の体験。
#    カーソル / スクロール / ガイド / ハイライト / 補完 / inlayHints など
#    ✦ いつ効くか: キー入力・マウス操作・文字選択・補完ポップアップ表示時
#    例) cursorBlinking → カーソルが画面に表示されているあいだ常時
#        quickSuggestions → 文字を打ち始めた直後にリアルタイムで
#
# 3. FILES & EXPLORER CONTROL
#    ファイル管理・監視・表示制御。
#    exclude / watcherExclude / nesting / breadcrumbs / title / associations など
#    ※「保存時整形」はここに入れないこと
#    ✦ いつ効くか: ワークスペースを開いた時・ファイルツリー描画時・ファイル監視開始時
#    例) files.exclude → エクスプローラーを開いた瞬間に非表示対象を決定
#        watcherExclude → プロジェクト読み込み時にファイル監視の対象外を登録
#
# 4. FORMATTING & LINTING
#    保存・貼り付け時に発動する自動整形・修正はすべてここ。
#    formatOnSave / codeActionsOnSave / prettier / eslint / trim系 / newline系
#    ✦ いつ効くか: Ctrl+S 保存時 / Ctrl+V 貼り付け時
#    例) formatOnSave → 保存のたびに Prettier が走る
#        trimTrailingWhitespace → 保存時に行末スペースを自動削除
#        organizeImports → 保存時に import を自動ソート・削除
#
#    ↓ 重要 ↓
#    files.insertFinalNewline
#    files.trimFinalNewlines
#    files.trimTrailingWhitespace
#    これらは「ファイル管理」ではなく「整形」であるため必ずこのセクション。
#
# 5. LANGUAGES & DEV TOOLS
#    言語別設定や LSP・ランタイム系。
#    TypeScript / Python / Svelte / formatter 個別指定 など
#    ✦ いつ効くか: 対象言語のファイルを開いた時・LSP 起動時・言語サーバー通信時
#    例) [nix].defaultFormatter → .nix ファイルを保存した時だけ nixfmt が動く
#        dart.flutterSdkPath → Flutter プロジェクトを開いた時に SDK を解決
#
# 6. GIT / AI / EXTERNAL
#    Git・Copilot・翻訳・Remote など外部連携。
#    ✦ いつ効くか: Git 操作時・Copilot/AI 呼び出し時・リモート接続時
#    例) git.autofetch → バックグラウンドで定期的にリモートを取得
#        gitlens.ai.model → GitLens のコミットメッセージ生成時に使用するモデルを決定
#
# 7. EXTENSIONS & CUSTOMIZATION
#    拡張機能固有設定・CSS注入など。
#    ✦ いつ効くか: 対応拡張機能が有効化された時・VSCode 再起動時
#    例) vscode_custom_css.imports → Custom CSS 拡張が起動時に CSS/JS を読み込む
#        multiCommand.commands → コマンドパレット or キーバインドで呼び出した時
#
# 8. CORE & PERFORMANCE
#    検索・デバッグ・大規模最適化・パフォーマンス制御。
#    ✦ いつ効くか: 検索実行時・デバッグセッション開始時・大容量ファイルを開いた時
#    例) search.exclude → Ctrl+Shift+F の全文検索から対象外にする
#        largeFileOptimizations → 数 MB を超えるファイルを開いた瞬間に適用
#
#
# ----------------------------------------------------------------------------
# 【追加ルール】
# ----------------------------------------------------------------------------
#
# ・設定は「機能単位」でまとめ、同種のものは必ず近くに置く
# ・新規設定は必ず適切なセクションへ入れる（末尾に直置きしない）
# ・各ブロックには目的コメントを書く（未来の自分のため）
# ・保存時に効く設定はすべて Formatting セクションへ集約する
# ・体験(UX) と 見た目(Visual) を混在させない
# ・言語別の個別最適化（[language]ブロック）は、内容に関わらずすべて 5. LANGUAGES に集約する。
# ============================================================================

{ lib, ... }:

let
  appearance = {
    # =======================================================================
    #  1. 外観・視覚 (APPEARANCE & VISUAL)
    # =======================================================================

    # テーマ・アイコン
    "workbench.colorTheme" = "R Dark Pro (Filter Night Late)";
    "workbench.iconTheme" = "flow-dim";
    "workbench.productIconTheme" = "tara-product-icons";

    # カラーカスタマイズ（テーマ固有の調整）
    "workbench.colorCustomizations" = {
      "editorBracketHighlight.foreground1" = "#84a2d4";
      "editorBracketHighlight.foreground2" = "#b683d4";
      "editorBracketHighlight.foreground3" = "#d483a1";
      "editorBracketHighlight.foreground4" = "#d4b683";
      "editorBracketHighlight.foreground5" = "#a1d483";
      "editorBracketHighlight.foreground6" = "#83d4b6";
      "editorBracketPairGuide.activeBackground1" = "#84a2d4";
      "editorBracketPairGuide.activeBackground2" = "#b683d4";
      "editorBracketPairGuide.activeBackground3" = "#d483a1";
      "editorBracketPairGuide.activeBackground4" = "#d4b683";
      "editorBracketPairGuide.activeBackground5" = "#a1d483";
      "editorBracketPairGuide.activeBackground6" = "#83d4b6";
      "editorBracketPairGuide.background1" = "#84a2d440";
      "editorBracketPairGuide.background2" = "#b683d440";
      "editorBracketPairGuide.background3" = "#d483a140";
      "editorBracketPairGuide.background4" = "#d4b68340";
      "editorBracketPairGuide.background5" = "#a1d48340";
      "editorBracketPairGuide.background6" = "#83d4b640";
      "editorIndentGuide.activeBackground1" = "#84a2d4";
      "editorIndentGuide.activeBackground2" = "#b683d4";
      "editorIndentGuide.activeBackground3" = "#d483a1";
      "editorIndentGuide.activeBackground4" = "#d4b683";
      "editorIndentGuide.activeBackground5" = "#a1d483";
      "editorIndentGuide.activeBackground6" = "#83d4b6";
      "editorIndentGuide.background1" = "#84a2d440";
      "editorIndentGuide.background2" = "#b683d440";
      "editorIndentGuide.background3" = "#d483a140";
      "editorIndentGuide.background4" = "#d4b68340";
      "editorIndentGuide.background5" = "#a1d48340";
      "editorIndentGuide.background6" = "#83d4b640";
      "[Pink as Fox (blackest)]" = {
        "window.activeBorder" = "#555555";
        "window.inactiveBorder" = "#555555";
        "editorGroup.border" = "#555555";
        "editorGroupHeader.tabsBorder" = "#555555";
        "tab.border" = "#555555";
        "tab.activeBorder" = "#555555";
        "tab.unfocusedActiveBorder" = "#555555";
        "sideBar.border" = "#555555";
        "sideBarSectionHeader.border" = "#555555";
        "panel.border" = "#555555";
        "panelSection.border" = "#555555";
        "statusBar.border" = "#555555";
        "activityBar.border" = "#555555";
        "editorWidget.border" = "#555555";
        "settings.headerBorder" = "#555555";
        "titleBar.border" = "#555555";
        "menubar.selectionBorder" = "#555555";
        "input.border" = "#555555";
        "dropdown.border" = "#555555";
      };
      "[Tara*]" = {
        "statusBar.background" = "#FFFFFF14";
        "statusBar.foreground" = "#FFFFFF";
        "statusBarItem.prominentBackground" = "#FFFFFF26";
        "statusBarItem.prominentForeground" = "#FFFFFF";
        "statusBar.debuggingBackground" = "#FFFFFF33";
        "statusBar.debuggingForeground" = "#FFFFFF";
        "toolbar.activeBackground" = "#FFFFFF26";
        "button.background" = "#FFFFFF";
        "button.hoverBackground" = "#FFFFFFcc";
        "extensionButton.separator" = "#FFFFFF33";
        "extensionButton.background" = "#FFFFFF14";
        "extensionButton.foreground" = "#FFFFFF";
        "extensionButton.hoverBackground" = "#FFFFFF33";
        "extensionButton.prominentForeground" = "#FFFFFF";
        "extensionButton.prominentBackground" = "#FFFFFF14";
        "extensionButton.prominentHoverBackground" = "#FFFFFF33";
        "activityBarBadge.background" = "#FFFFFF";
        "activityBar.activeBorder" = "#FFFFFF";
        "activityBarTop.activeBorder" = "#FFFFFF";
        "list.inactiveSelectionIconForeground" = "#FFFFFF";
        "list.activeSelectionForeground" = "#FFFFFF";
        "list.inactiveSelectionForeground" = "#FFFFFF";
        "list.highlightForeground" = "#FFFFFF";
        "sash.hoverBorder" = "#FFFFFF80";
        "list.activeSelectionIconForeground" = "#FFFFFF";
        "scrollbarSlider.activeBackground" = "#FFFFFF80";
        "editorSuggestWidget.highlightForeground" = "#FFFFFF";
        "textLink.foreground" = "#FFFFFF";
        "progressBar.background" = "#FFFFFF";
        "pickerGroup.foreground" = "#FFFFFF";
        "tab.activeBorder" = "#FFFFFF";
        "tab.activeBorderTop" = "#FFFFFF00";
        "tab.unfocusedActiveBorder" = "#FFFFFF";
        "tab.unfocusedActiveBorderTop" = "#FFFFFF00";
        "tab.activeModifiedBorder" = "#FFFFFF00";
        "notificationLink.foreground" = "#FFFFFF";
        "editorWidget.resizeBorder" = "#FFFFFF";
        "editorWidget.border" = "#FFFFFF";
        "settings.modifiedItemIndicator" = "#FFFFFF";
        "panelTitle.activeBorder" = "#FFFFFF";
        "breadcrumb.activeSelectionForeground" = "#FFFFFF";
        "menu.selectionForeground" = "#FFFFFF";
        "menubar.selectionForeground" = "#FFFFFF";
        "editor.findMatchBorder" = "#FFFFFF";
        "selection.background" = "#FFFFFF40";
        "statusBarItem.remoteBackground" = "#FFFFFF14";
        "statusBarItem.remoteHoverBackground" = "#FFFFFF";
        "statusBarItem.remoteForeground" = "#FFFFFF";
        "notebook.inactiveFocusedCellBorder" = "#FFFFFF80";
        "commandCenter.activeBorder" = "#FFFFFF80";
        "chat.slashCommandForeground" = "#FFFFFF";
        "chat.avatarForeground" = "#FFFFFF";
        "activityBarBadge.foreground" = "#FFFFFF";
        "button.foreground" = "#FFFFFF";
        "statusBarItem.remoteHoverForeground" = "#FFFFFF";
      };
    };
    "nishuuu.accentColor" = "white";

    # フォント設定
    "editor.fontFamily" = "'Monaspace Argon', 'Maple Mono NF CN', 'PlemolJP Console NF', 'Cascadia Code'";
    "editor.fontLigatures" = "'calt', 'liga', 'dlig', 'ss01', 'ss02', 'ss03'";
    "editor.fontSize" = 14;
    "editor.fontWeight" = "400";
    "editor.lineHeight" = 1.4;

    # UIコンポーネント
    "explorer.compactFolders" = false;
    "workbench.editor.showTabs" = "multiple";
    "workbench.tree.indent" = 18;

    # ミニマップ設定
    "editor.minimap.autohide" = "mouseover";
    "editor.minimap.enabled" = true;
    "editor.minimap.maxColumn" = 100;
    "editor.minimap.renderCharacters" = false;
    "editor.minimap.showSlider" = "mouseover";
    "editor.minimap.side" = "right";
    "editor.minimap.size" = "proportional";

    # スクロールバー
    "editor.scrollbar.vertical" = "visible";
    "editor.scrollbar.horizontal" = "auto";

    # 視覚効果（拡張機能依存）
    "glowrays.advancedMode" = true;
    "glowrays.enable" = false;
    "glowrays.intensity" = 1.6;
    "material-icon-theme.activeIconPack" = "angular_ngrx";
    "material-icon-theme.folders.theme" = "classic";
    "nyanMode.nyanAlign" = "left";
    "nyanMode.nyanDiagnostics" = true;
    "nyanMode.nyanDisplayPercent" = false;
    "powermode.combo.location" = "off";
    "powermode.combo.threshold" = 1;
    "powermode.combo.timeout" = 10;
    "powermode.enabled" = true;
    "powermode.presets" = "particles";
    "powermode.shake.enabled" = false;
    "resmon.show.cpufreq" = false;
    "resmon.show.cputemp" = false;
    "resmon.show.cpuusage" = false;
    "resmon.show.disk" = false;
    "resmon.show.mem" = false;

  };

  editorUX = {
    # =======================================================================
    #  2. 操作・編集体験 (EDITOR & UX)
    # =======================================================================

    # カーソル
    "editor.cursorBlinking" = "phase";
    "editor.cursorSmoothCaretAnimation" = "on";
    "editor.cursorStyle" = "block";

    # スクロール
    "editor.mouseWheelZoom" = true;
    "editor.smoothScrolling" = true;
    "workbench.list.smoothScrolling" = true;

    # コード表示
    "editor.bracketPairColorization.enabled" = true;
    "editor.renderWhitespace" = "trailing";
    "editor.semanticHighlighting.enabled" = true;
    "editor.stickyScroll.enabled" = true;
    "editor.stickyScroll.maxLineCount" = 5;
    "editor.unicodeHighlight.nonBasicASCII" = false;

    # エディターガイド
    "blockhighlight.accentCurrentLine" = true;
    "blockhighlight.background" = [ "255" "255" "255" ".00" ]; # "80", "180", "255", ".015"
    "blockhighlight.isWholeLine" = false;
    "dimmer.enabled" = false;
    "editor.guides.bracketPairs" = true;
    "editor.guides.bracketPairsHorizontal" = true;
    "editor.guides.highlightActiveIndentation" = true;
    "editor.guides.indentation" = true;
    "editor.renderLineHighlight" = "all";
    "indentRainbow.colors" = [
      "#84a2d430" # #84a2d4
      "#b683d430" # #b683d4
      "#d483a130" # #d483a1
      "#d4b68330" # #d4b683
      "#a1d48330" # #a1d483
      "#83d4b630" # #83d4b6
    ];
    "indentRainbow.indicatorStyle" = "light";
    "indentRainbow.lightIndicatorStyleLineWidth" = 1;
    "textIndentHighlighter.colors" = [
      "#84a2d4"
      "#b683d4"
      "#d483a1"
      "#d4b683"
      "#a1d483"
      "#83d4b6"
    ];

    # 補完・提案
    "editor.inlayHints.enabled" = "onUnlessPressed";
    "editor.inlineSuggest.edits.allowCodeShifting" = "horizontal";
    "editor.linkedEditing" = true;
    "editor.quickSuggestions" = {
      "strings" = true;
    };

    # 安全性・信頼性
    "editor.accessibilitySupport" = "auto";
    "editor.rename.enablePreview" = false;

    # エラー表示
    "errorLens.excludeByMessage" = [ "Unknown word" ];
    "errorLens.gutterIconsEnabled" = true;

    # タブ
    "editor.tabSize" = 2;

    # Diffエディタ
    "diffEditor.codeLens" = true;
    "diffEditor.maxComputationTime" = 0;

    # ModalEdit
    "modaledit.keybindings" = {
      "i" = "modaledit.enterInsert";
      "escape" = "modaledit.enterNormal";
    };

  };

  filesAndEditor = {
    # =======================================================================
    #  3. ファイル・エディタ制御 (FILES & EDITOR CONTROL)
    # =======================================================================

    # ファイル管理
    "files.eol" = "\n";
    "files.exclude" = {
      "**/.git" = true;
      "**/.vscode" = true;
      "**/dist" = true;
      "**/node_modules" = true;
    };
    "files.watcherExclude" = {
      "**/build/**" = true;
      "**/coverage/**" = true;
      "**/dist/**" = true;
      "**/node_modules/**" = true;
    };

    # ファイルネスティング（関連ファイルのグループ化）
    "explorer.fileNesting.patterns" = {
      "*.db" = "\${capture}.\${extname}-*";
      "*.db3" = "\${capture}.\${extname}-*";
      "*.js" = "\${capture}.js.map, \${capture}.min.js, \${capture}.d.ts";
      "*.jsx" = "\${capture}.js";
      "*.s3db" = "\${capture}.\${extname}-*";
      "*.sdb" = "\${capture}.\${extname}-*";
      "*.sqlite" = "\${capture}.\${extname}-*";
      "*.sqlite3" = "\${capture}.\${extname}-*";
      "*.ts" = "\${capture}.js";
      "*.tsx" = "\${capture}.ts";
      "package.json" = "package-lock.json, yarn.lock, pnpm-lock.yaml, bun.lockb, bun.lock";
      "tsconfig.json" = "tsconfig.*.json";
    };

    # 情報表示
    "breadcrumbs.filePath" = "off";
    "breadcrumbs.symbolPath" = "on";
    "window.title" = "\${activeEditorShort} - \${rootName}";

    # エディタ関連付け
    "workbench.editorAssociations" = {
      "*.copilotmd" = "vscode.markdown.preview.editor";
      "*.db" = "default";
      "*.svg" = "default";
    };

  };

  formatting = {
    # =======================================================================
    #  4. フォーマット・Lint (FORMATTING & LINTING)
    # =======================================================================

    # 自動フォーマット
    "editor.codeActionsOnSave" = {
      "source.fixAll.eslint" = "explicit";
      "source.organizeImports" = "explicit";
    };
    "editor.formatOnPaste" = true;
    "editor.formatOnSave" = true;

    # フォーマッター設定
    "editor.defaultFormatter" = "esbenp.prettier-vscode";

    # 自動整形
    # ↓ 重要: files.insertFinalNewline / trimFinalNewlines / trimTrailingWhitespace は
    #         「ファイル管理」ではなく「整形」のためここに集約
    "editor.autoIndentOnPaste" = true;
    "files.insertFinalNewline" = true;
    "files.trimFinalNewlines" = true;
    "files.trimTrailingWhitespace" = true;

  };

  languages = {
    # =======================================================================
    #  5. 言語・開発ツール (LANGUAGES & DEV TOOLS)
    # =======================================================================

    # JavaScript/TypeScript
    "javascript.updateImportsOnFileMove.enabled" = "never";

    # Svelte
    "svelte.enable-ts-plugin" = true;

    # Python
    "python.languageServer" = "Default";

    # Nix
    "[nix]" = {
      "editor.defaultFormatter" = "jnoortheen.nix-ide";
    };

    # Flutter

    # C

  };

  external = {
    # =======================================================================
    #  6. Git・AI・外部連携 (GIT, AI & EXTERNAL)
    # =======================================================================

    # Git
    "git.autofetch" = true;
    "git.confirmSync" = false;
    "gitlens.currentLine.enabled" = false;

    # AI
    "gitlens.ai.model" = "gemini:gemini-3-flash-preview";
    "gitlens.ai.vscode.model" = "copilot:gpt-4.1";

    # 翻訳
    "vscodeGoogleTranslate.preferredLanguage" = "Japanese";

    # リモート開発
    "remote.autoForwardPortsSource" = "hybrid";

  };

  extensions = {
    # =======================================================================
    #  7. 拡張機能・カスタマイズ (EXTENSIONS & CUSTOMIZATION)
    # =======================================================================

    # カスタムCSS（環境依存パスに注意）
    "vscode_custom_css.imports" = [
      "https://gist.githubusercontent.com/Crysta1221/24c724fd9f475ef473dcf2c3d551b8c3/raw/a9e6920e39d78eeb43ea448d36a8eb215bbbbf35/style.css"
    ];

    # マルチコマンド
    "multiCommand.commands" = [
      {
        "command" = "multiCommand.pasteAndNewline";
        "sequence" = [
          "editor.action.clipboardPasteAction"
          "type"
          { "text" = "\n"; }
        ];
      }
    ];

    # 拡張機能マーケットプレイス（antigravity用）
    "antigravity.marketplaceExtensionGalleryServiceURL" = "https://marketplace.visualstudio.com/_apis/public/gallery";
    "antigravity.marketplaceGalleryItemURL" = "https://marketplace.visualstudio.com/items";

    # 拡張機能テレメトリ
    "redhat.telemetry.enabled" = false;

    "modaledit.insertStatusText" = "Insert";
    "modaledit.normalStatusText" = "Command";
    "modaledit.selectStatusText" = "$(paintcan) VISUAL";

  };

  coreAndDebug = {
    # =======================================================================
    #  8. パフォーマンス・検索・デバッグ (CORE & DEBUG)
    # =======================================================================

    # パフォーマンス最適化
    "editor.largeFileOptimizations" = true;

    # 検索設定
    "search.exclude" = {
      "**/*.map" = true;
      "**/dist" = true;
      "**/node_modules" = true;
    };
    "search.maxResults" = 2000;

    # デバッグ
    "debug.console.fontSize" = 13;
    "debug.console.lineHeight" = 1.2;
    "debug.toolBarLocation" = "floating";
  };

in
{
  programs.vscode = {
    enable = true;

    userSettings = lib.mkMerge [ appearance editorUX filesAndEditor formatting languages external extensions coreAndDebug ];
  };
}
