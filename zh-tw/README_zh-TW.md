# 精通比特幣（第三版）- 繁體中文翻譯

<p align="center">
  <a href="https://bitcoinbook-3nd-zh.doge.tg">
    <img src="https://img.shields.io/badge/線上閱讀-bitcoinbook--3nd--zh.doge.tg-orange?style=for-the-badge&logo=bitcoin" alt="線上閱讀" />
  </a>
</p>

<p align="center">
  <a href="https://github.com/awesome-doge/bitcoinbook-3nd-zh/actions">
    <img src="https://github.com/awesome-doge/bitcoinbook-3nd-zh/workflows/Build%20and%20Deploy%20to%20GitHub%20Pages/badge.svg" alt="Build Status" />
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/license-CC--BY--SA%204.0-blue.svg" alt="License" />
  </a>
  <a href="translation/progress.md">
    <img src="https://img.shields.io/badge/翻譯進度-0%25-red.svg" alt="Translation Progress" />
  </a>
</p>

---

## 📖 關於本書

《精通比特幣：程式開發開放式區塊鏈》（Mastering Bitcoin: Programming the Open Blockchain）是一本深入介紹比特幣技術的權威指南，由 Andreas M. Antonopoulos 和 David A. Harding 共同撰寫。

**本專案目標**：將第三版完整翻譯成台灣繁體中文，讓華語讀者能更好地理解比特幣技術。

### 原書資訊

- **原作者**：Andreas M. Antonopoulos, David A. Harding
- **出版社**：O'Reilly Media
- **出版時間**：2023年12月（第三版第一印）
- **原書授權**：CC-BY-SA 4.0 International
- **原書倉庫**：[bitcoinbook/bitcoinbook](https://github.com/bitcoinbook/bitcoinbook)

## 🌐 線上閱讀

**正式網址**：[https://bitcoinbook-3nd-zh.doge.tg](https://bitcoinbook-3nd-zh.doge.tg)

## 📊 翻譯進度

當前進度：**0%**（基礎建設階段）

詳細進度請查看：[translation/progress.md](translation/progress.md)

| 類別 | 已完成 | 總數 | 進度 |
|------|--------|------|------|
| 前言 | 0 | 1 | 0% |
| 主要章節 | 0 | 14 | 0% |
| 附錄 | 0 | 3 | 0% |
| 詞彙表 | 0 | 1 | 0% |

## 🎯 專案結構

```
bitcoinbook-3nd-zh/
├── zh-tw/              # 繁體中文翻譯文件
├── translation/        # 翻譯輔助文件
│   ├── terminology.md      # 術語對照表
│   ├── style-guide.md      # 翻譯風格指南
│   ├── progress.md         # 翻譯進度追蹤
│   └── contributors.md     # 貢獻者名單
├── .github/workflows/  # GitHub Actions 自動部署
└── docs/              # 構建輸出（自動生成）
```

## 🤝 如何貢獻

我們誠摯歡迎各種形式的貢獻！

### 翻譯貢獻

1. **查看進度**：閱讀 [translation/progress.md](translation/progress.md) 了解當前進度
2. **認領章節**：在 GitHub Issues 中認領您想翻譯的章節
3. **參考指南**：
   - [翻譯規劃](TRANSLATION_PLAN.md) - 完整的專案規劃
   - [術語對照表](translation/terminology.md) - Bitcoin 技術術語的標準翻譯
   - [風格指南](translation/style-guide.md) - 翻譯風格規範
4. **開始翻譯**：Fork 專案，創建分支，開始翻譯
5. **提交審校**：完成後提交 Pull Request

### 審校貢獻

- **技術審校**：熟悉 Bitcoin 技術，確保技術內容準確
- **語言審校**：中文母語者，確保語言流暢自然

### 其他貢獻

- 報告錯誤或提出建議
- 改進文檔和工具
- 推廣專案

詳細貢獻指南請參考：[CONTRIBUTING.md](CONTRIBUTING.md)

## 📚 文檔資源

### 翻譯指南
- [翻譯規劃](TRANSLATION_PLAN.md) - 完整的專案時間線和工作流程
- [術語對照表](translation/terminology.md) - 標準技術術語翻譯
- [風格指南](translation/style-guide.md) - 中文書寫規範和 AsciiDoc 格式要求

### 專案管理
- [翻譯進度](translation/progress.md) - 實時追蹤翻譯狀態
- [貢獻者名單](translation/contributors.md) - 感謝所有貢獻者

### 開發者
- [CLAUDE.md](CLAUDE.md) - Claude Code AI 助手的專案指引

## 🏗️ 本地構建

### 前置需求

- Ruby 3.x
- AsciiDoctor

### 安裝依賴

```bash
# 安裝 Ruby（如果尚未安裝）
# macOS: brew install ruby
# Ubuntu: sudo apt-get install ruby-full

# 安裝 AsciiDoctor
gem install asciidoctor
gem install asciidoctor-epub3
gem install rouge
```

### 構建中文版

```bash
# 使用建置腳本（推薦）
./scripts/build-local.sh

# 或手動構建 HTML
cd zh-tw
asciidoctor \
  --backend=html5 \
  --out-file=../build/mastering-bitcoin-3rd-zh-tw.html \
  --attribute=source-highlighter=rouge \
  --attribute=toc=left \
  --attribute=lang=zh-TW \
  book.adoc
```

**注意**：本專案僅支援 HTML 和 EPUB 格式。由於中英文混排的技術限制，已停止 PDF 生成。

### 本地預覽

```bash
# 使用 Python 啟動簡單 HTTP 伺服器
cd docs
python -m http.server 8000

# 瀏覽器訪問 http://localhost:8000
```

## 🚀 自動部署

本專案使用 GitHub Actions 自動構建和部署：

- **觸發條件**：推送到 `develop` 分支
- **構建過程**：使用 AsciiDoctor 將 `.adoc` 文件轉換為 HTML
- **部署目標**：GitHub Pages（自定義域名：bitcoinbook-3nd-zh.doge.tg）

查看部署狀態：[Actions](https://github.com/awesome-doge/bitcoinbook-3nd-zh/actions)

## 📋 章節列表

### 主要內容

1. [介紹](zh-tw/ch01_intro.adoc) 🔴
2. [比特幣運作原理](zh-tw/ch02_overview.adoc) 🔴
3. [Bitcoin Core：參考實作](zh-tw/ch03_bitcoin-core.adoc) 🔴
4. [金鑰與地址](zh-tw/ch04_keys.adoc) 🔴
5. [錢包](zh-tw/ch05_wallets.adoc) 🔴
6. [交易](zh-tw/ch06_transactions.adoc) 🔴
7. [授權與認證](zh-tw/ch07_authorization-authentication.adoc) 🔴
8. [數位簽章](zh-tw/ch08_signatures.adoc) 🔴
9. [交易手續費](zh-tw/ch09_fees.adoc) 🔴
10. [比特幣網路](zh-tw/ch10_network.adoc) 🔴
11. [區塊鏈](zh-tw/ch11_blockchain.adoc) 🔴
12. [挖礦與共識](zh-tw/ch12_mining.adoc) 🔴
13. [安全性](zh-tw/ch13_security.adoc) 🔴
14. [第二層應用](zh-tw/ch14_applications.adoc) 🔴

### 附錄

- [附錄 A：比特幣白皮書](zh-tw/appa_whitepaper.adoc) 🔴
- [附錄 B：交易腳本語言運算子、常數和符號](zh-tw/appb_errata.adoc) 🔴
- [附錄 C：比特幣改進提案](zh-tw/appc_bips.adoc) 🔴

🔴 = 未開始 | 🟡 = 翻譯中 | 🟢 = 初稿完成 | 🔵 = 審校中 | ✅ = 已完成

## 📜 版權與授權

### 原書授權

本翻譯基於《Mastering Bitcoin》第三版，遵循原書的授權條款：

<a rel="license" href="https://creativecommons.org/licenses/by-sa/4.0/">
  <img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" />
</a>

**Creative Commons Attribution-ShareAlike 4.0 International License (CC-BY-SA 4.0)**

這意味著：
- ✅ 您可以自由地分享和改編本書
- ✅ 可用於商業目的
- ⚠️ 必須給予適當的署名
- ⚠️ 必須以相同授權分享衍生作品

### 翻譯版權

- **譯者**：所有在 [contributors.md](translation/contributors.md) 中列出的貢獻者
- **授權**：CC-BY-SA 4.0（與原書相同）
- **專案維護者**：[@awesome-doge](https://github.com/awesome-doge)

## 🙏 鳴謝

### 原作者
- **Andreas M. Antonopoulos** - 原書作者
- **David A. Harding** - 第三版共同作者

### 貢獻者
感謝所有為本翻譯專案做出貢獻的譯者、審校者和支持者！

完整名單請見：[translation/contributors.md](translation/contributors.md)

### 社群
- 台灣 Bitcoin 社群
- [原書專案](https://github.com/bitcoinbook/bitcoinbook)的所有貢獻者

## 💬 聯絡與支持

- **GitHub Issues**：[回報問題或建議](https://github.com/awesome-doge/bitcoinbook-3nd-zh/issues)
- **GitHub Discussions**：[參與討論](https://github.com/awesome-doge/bitcoinbook-3nd-zh/discussions)（建議啟用）
- **專案維護者**：[@awesome-doge](https://github.com/awesome-doge)

## 🔗 相關連結

- [線上閱讀（繁中版）](https://bitcoinbook-3nd-zh.doge.tg)
- [原書倉庫](https://github.com/bitcoinbook/bitcoinbook)
- [購買原書](https://www.amazon.com/Mastering-Bitcoin-Programming-Open-Blockchain/dp/1098150090)
- [Bitcoin Developer Documentation](https://developer.bitcoin.org/)
- [Andreas M. Antonopoulos 個人網站](https://aantonop.com/)

## 📈 專案里程碑

- [x] 2025-10-30：專案啟動，完成基礎建設
- [ ] 2025 Q1：完成 Phase 1（前言、第1-2章、詞彙表）
- [ ] 2025 Q2：完成 Phase 2-3（第3-10章）
- [ ] 2025 Q3：完成 Phase 4-5（第11-14章、附錄）
- [ ] 2025 Q3：正式發布完整翻譯

詳細時間線請參考：[TRANSLATION_PLAN.md](TRANSLATION_PLAN.md)

---

<p align="center">
  <strong>讓我們一起將這本經典的比特幣技術書籍帶給更多華語讀者！</strong>
</p>

<p align="center">
  ⭐ 如果這個專案對您有幫助，請給我們一個 Star！
</p>
