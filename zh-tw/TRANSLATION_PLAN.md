# Mastering Bitcoin 第三版 - 繁體中文翻譯專案規劃

## 專案概述

**目標**：將《精通比特幣》（Mastering Bitcoin）第三版完整翻譯成台灣繁體中文版本

**發佈方式**：使用 GitHub Actions 自動構建並部署到 GitHub Pages

**正式網址**：https://bitcoinbook-3nd-zh.doge.tg

## 專案結構設計

### 目錄組織方案

```
bitcoinbook-3nd-zh/
├── zh-tw/                          # 繁體中文翻譯文件
│   ├── book.adoc                   # 主書籍文件（中文版）
│   ├── preface.adoc               # 前言
│   ├── ch01_intro.adoc            # 第1章：介紹
│   ├── ch02_overview.adoc         # 第2章：概覽
│   ├── ...                        # 其他章節
│   ├── ch14_applications.adoc     # 第14章：應用
│   ├── appa_whitepaper.adoc       # 附錄A：白皮書
│   ├── appb_errata.adoc           # 附錄B：勘誤
│   ├── appc_bips.adoc             # 附錄C：BIP列表
│   └── glossary.asciidoc          # 詞彙表
│
├── translation/                    # 翻譯輔助文件
│   ├── terminology.md             # 術語對照表
│   ├── style-guide.md             # 翻譯風格指南
│   ├── progress.md                # 翻譯進度追蹤
│   └── contributors.md            # 翻譯貢獻者名單
│
├── .github/
│   └── workflows/
│       └── deploy.yml             # GitHub Actions 部署流程
│
├── docs/                          # GitHub Pages 輸出目錄
│   └── (自動生成的 HTML 文件)
│
└── (原始英文文件保持不變)
```

### 優點說明

1. **保留原文**：英文原文件保持不變，便於對照和更新
2. **清晰分離**：翻譯文件集中在 `zh-tw/` 目錄
3. **易於維護**：當原書更新時，可以輕鬆比對差異
4. **支援多語言**：未來可添加其他語言版本（如 zh-cn/）

## 翻譯工作流程

### 第一階段：基礎建設（第1-2週）

1. ✅ 創建目錄結構
2. ✅ 建立術語對照表
3. ✅ 撰寫翻譯風格指南
4. ✅ 設置 GitHub Actions
5. ✅ 配置 GitHub Pages 和自定義域名

### 第二階段：核心內容翻譯（第3-16週）

**優先順序排序**：

1. **Phase 1 - 基礎概念**（3-4週）
   - preface.adoc（前言）
   - ch01_intro.adoc（介紹）
   - ch02_overview.adoc（比特幣概覽）
   - glossary.asciidoc（詞彙表）

2. **Phase 2 - 技術核心**（5-8週）
   - ch03_bitcoin-core.adoc（Bitcoin Core）
   - ch04_keys.adoc（金鑰與地址）
   - ch05_wallets.adoc（錢包）
   - ch06_transactions.adoc（交易）

3. **Phase 3 - 進階技術**（4-5週）
   - ch07_authorization-authentication.adoc（授權與認證）
   - ch08_signatures.adoc（數位簽章）
   - ch09_fees.adoc（交易手續費）
   - ch10_network.adoc（比特幣網路）

4. **Phase 4 - 系統運作**（3-4週）
   - ch11_blockchain.adoc（區塊鏈）
   - ch12_mining.adoc（挖礦）
   - ch13_security.adoc（安全）
   - ch14_applications.adoc（應用）

5. **Phase 5 - 附錄**（1-2週）
   - appa_whitepaper.adoc（比特幣白皮書）
   - appb_errata.adoc（勘誤表）
   - appc_bips.adoc（BIP 列表）

### 第三階段：審校與優化（第17-20週）

1. **技術審校**：由 Bitcoin 專家審閱技術準確性
2. **語言潤色**：由中文編輯潤飾文字流暢度
3. **交叉檢查**：確保術語一致性
4. **測試發佈**：測試網站構建和顯示

## 翻譯標準與規範

### 術語翻譯原則

1. **保持一致性**：相同術語在全書中使用統一翻譯
2. **專有名詞**：某些術語保留英文或中英並列
   - Bitcoin（比特幣/Bitcoin）
   - blockchain（區塊鏈）
   - Satoshi Nakamoto（中本聰）

3. **技術術語**：首次出現時中英並列，後續使用中文
   - 例：「數位簽章（digital signature）」

### AsciiDoc 格式要求

1. **保持原有標記**：所有 AsciiDoc 標記必須保持不變
2. **交叉引用**：保留所有章節 ID 和內部連結
3. **代碼區塊**：代碼和命令保持英文，註解可翻譯
4. **圖片引用**：圖片路徑保持不變（使用相對路徑 `../images/`）

### 文字風格

1. **使用台灣繁體中文**：採用台灣用語和標點符號
2. **技術準確性優先**：確保技術內容正確無誤
3. **可讀性**：避免過度直譯，注重中文語感
4. **保持原意**：忠實傳達原文含義

## GitHub Actions 自動化流程

### 部署流程設計

```yaml
觸發條件：
  - push 到 develop 分支
  - pull request 到 develop 分支

構建步驟：
  1. 檢出代碼
  2. 安裝 Ruby 和 AsciiDoctor
  3. 構建中文版 HTML
     - 輸入：zh-tw/book.adoc
     - 輸出：docs/index.html
  4. 複製資源文件（images、CSS）
  5. 部署到 GitHub Pages（gh-pages 分支）

環境需求：
  - Ruby 3.x
  - asciidoctor gem
  - asciidoctor-pdf gem（如需 PDF）
```

### 自定義域名設置

1. 在 `docs/` 目錄創建 `CNAME` 文件
2. 內容：`bitcoinbook-3nd-zh.doge.tg`
3. DNS 設置：
   - CNAME 記錄：`bitcoinbook-3nd-zh.doge.tg` → `awesome-doge.github.io`
   - 或 A 記錄指向 GitHub Pages IP

## 協作與貢獻

### 翻譯認領制度

1. 在 `translation/progress.md` 中認領章節
2. 創建分支：`translate/chXX-章節名稱`
3. 完成後提交 Pull Request
4. 經審核後合併到 develop 分支

### 程式碼審查標準

每個 Pull Request 需要：
- [ ] 術語使用符合對照表
- [ ] AsciiDoc 格式正確
- [ ] 中文語句通順
- [ ] 技術內容準確
- [ ] 通過自動化構建測試

## 品質控制

### 自動化檢查

1. **構建測試**：確保 AsciiDoc 能正確編譯
2. **連結檢查**：驗證內部連結有效性
3. **術語一致性**：腳本檢查術語使用

### 人工審查

1. **技術審查**：Bitcoin 技術專家審閱
2. **語言審查**：中文編輯審閱文字品質
3. **交叉審閱**：多位譯者相互審閱

## 時間線與里程碑

### 2025 Q1-Q2（第1-12週）
- 完成基礎建設
- 完成 Phase 1-2 翻譯（前6章）
- 里程碑：基礎概念和核心技術完成

### 2025 Q2-Q3（第13-20週）
- 完成 Phase 3-4 翻譯（第7-14章）
- 完成 Phase 5 翻譯（附錄）
- 完成審校與優化

### 2025 Q3（第21-24週）
- 正式發佈
- 社群推廣
- 收集回饋並持續改進

## 版權與授權

- 原書授權：CC-BY-SA 4.0 International
- 翻譯版本：遵循相同授權（CC-BY-SA 4.0）
- 貢獻者：需在 `translation/contributors.md` 中署名

## 參考資源

1. **原書倉庫**：https://github.com/bitcoinbook/bitcoinbook
2. **AsciiDoc 文檔**：https://docs.asciidoctor.org/
3. **Bitcoin 技術詞彙**：https://developer.bitcoin.org/glossary.html
4. **台灣 Bitcoin 社群**：相關論壇和討論群組

## 聯絡方式

- **專案維護者**：awesome-doge
- **問題回報**：使用 GitHub Issues
- **討論區**：GitHub Discussions（建議啟用）

---

**最後更新**：2025-10-30
**狀態**：規劃階段
