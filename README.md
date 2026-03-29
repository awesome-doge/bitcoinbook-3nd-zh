# 精通比特幣：程式設計開放區塊鏈（第三版）- 繁體中文版

> **Mastering Bitcoin: Programming the Open Blockchain (3rd Edition)**
> 原著：Andreas M. Antonopoulos, David A. Harding
> 繁體中文翻譯：Dr. Awesome Doge

[![線上閱讀](https://img.shields.io/badge/線上閱讀-bitcoinbook--3nd--zh.doge.tg-f7931a?style=for-the-badge)](https://bitcoinbook-3nd-zh.doge.tg/)
[![Release](https://img.shields.io/github/v/release/awesome-doge/bitcoinbook-3nd-zh?style=for-the-badge&label=最新版本&color=10b981)](https://github.com/awesome-doge/bitcoinbook-3nd-zh/releases/latest)
[![License](https://img.shields.io/badge/授權-CC--BY--SA%204.0-3b82f6?style=for-the-badge)](LICENSE)

## 閱讀方式

| 方式 | 說明 |
|------|------|
| [**線上閱讀**](https://bitcoinbook-3nd-zh.doge.tg/) | 瀏覽器直接開啟，支援暗色模式、章節導航、閱讀進度記憶 |
| [**EPUB 下載**](https://github.com/awesome-doge/bitcoinbook-3nd-zh/releases/latest) | 適合 Apple Books、Kobo、Kindle 等電子書閱讀器 |
| [**HTML 下載**](https://github.com/awesome-doge/bitcoinbook-3nd-zh/releases/latest) | 含圖片完整包，離線瀏覽 |

## 功能特色

### 閱讀體驗

- **暗色模式** - 自動偵測系統設定 + 手動切換（右上角月亮圖示）
- **字體大小調整** - A+/A- 即時調整，設定自動記憶
- **閱讀進度記憶** - 下次打開自動提示「繼續閱讀」
- **頁內搜尋** - `Ctrl+Shift+F` 開啟，即時高亮 + 上下跳轉
- **PWA 離線閱讀** - 可安裝到手機主畫面

### 導航

- **可收合目錄** - 桌面版左側 TOC 支援展開/收合章節
- **當前章節高亮** - 滾動時自動高亮所在章節
- **拼音搜尋** - 手機版 TOC 輸入拼音首字母即可搜尋（如 `jy` = 交易）
- **閱讀統計** - TOC 底部顯示已讀章節數和預估閱讀時間

### 排版

- **中文字體** - Noto Serif CJK TC（正文）+ Noto Sans CJK TC（標題）
- **程式碼** - JetBrains Mono 字體 + 語言標籤 + 行號 + 複製按鈕
- **全面中文化** - 目錄、提示框、圖表標題全部中文
- **閱讀進度條** - 頂部橙色進度條
- **列印友善** - 完整 `@media print` 樣式

## 目錄

| 章節 | 標題 |
|:----:|------|
| 前言 | 撰寫比特幣這本書 |
| 第 1 章 | 介紹 |
| 第 2 章 | 比特幣如何運作 |
| 第 3 章 | Bitcoin Core：參考實作 |
| 第 4 章 | 金鑰與地址 |
| 第 5 章 | 錢包恢復 |
| 第 6 章 | 交易 |
| 第 7 章 | 授權與認證 |
| 第 8 章 | 數位簽章 |
| 第 9 章 | 交易手續費 |
| 第 10 章 | 比特幣網路 |
| 第 11 章 | 區塊鏈 |
| 第 12 章 | 挖礦與共識 |
| 第 13 章 | 比特幣安全性 |
| 第 14 章 | 第二層應用 |
| 附錄 A | 比特幣白皮書 |
| 附錄 B | 勘誤表 |
| 附錄 C | 比特幣改進提案 |

## 本地建置

```bash
# 安裝依賴
gem install asciidoctor rouge

# 建置 HTML
cd zh-tw
asciidoctor --backend=html5 \
  --out-file=../build/mastering-bitcoin-3rd-zh-tw.html \
  --attribute=source-highlighter=rouge \
  --attribute=toc=left \
  --attribute=toclevels=2 \
  --attribute=icons=font \
  --attribute=sectanchors \
  --attribute=docinfo=shared \
  --attribute=lang=zh-TW \
  --attribute=imagesdir=.. \
  book.adoc

# 建置 EPUB（需額外安裝）
gem install asciidoctor-epub3
asciidoctor-epub3 \
  --out-file=../build/mastering-bitcoin-3rd-zh-tw.epub \
  --attribute=lang=zh-TW \
  --attribute=front-cover-image=../images/cover.png \
  --attribute=epub3-stylesdir=. \
  --attribute=epub3-stylesheet=epub3.scss \
  book.adoc
```

或使用建置腳本：

```bash
./scripts/build-local.sh
```

## CI/CD

| Workflow | 觸發條件 | 輸出 |
|----------|---------|------|
| **Build & Deploy** | Push to `main` | GitHub Pages 自動部署 |
| **PR Preview** | Pull Request | 預覽 HTML artifact |
| **Release** | Git tag `v*` | HTML + EPUB + ZIP + SHA256 checksums |

## 翻譯規範

- 術語對照表：[translation/terminology.md](translation/terminology.md)
- 風格指南：[translation/style-guide.md](translation/style-guide.md)
- 使用台灣正體中文，全形標點（，。！？）
- 中英文之間加空格
- 技術名詞首次出現：「中文（English）」，後續：「中文」
- 程式碼、命令、變數名稱保持英文

## 授權

本翻譯基於 [CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) 授權。

原著 *Mastering Bitcoin: Programming the Open Blockchain (Third Edition)* 由 Andreas M. Antonopoulos 和 David A. Harding 著作，O'Reilly Media 出版。
