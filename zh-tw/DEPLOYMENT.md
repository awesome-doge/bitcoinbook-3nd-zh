# 部署指南

本文檔說明如何配置 GitHub Actions 自動部署《精通比特幣》第三版繁體中文翻譯。

## 目錄

- [GitHub Pages 部署](#github-pages-部署)
- [自定義域名配置](#自定義域名配置)
- [Release 發布](#release-發布)
- [手動觸發部署](#手動觸發部署)

---

## GitHub Pages 部署

### 1. 啟用 GitHub Pages

1. 前往 GitHub 倉庫設置：`Settings` → `Pages`
2. 在 **Source** 下選擇：
   - Source: `GitHub Actions`
3. 保存設置

### 2. 自動部署觸發條件

GitHub Actions 會在以下情況自動部署到 GitHub Pages：

- ✅ 推送到 `develop` 分支
- ✅ 合併 Pull Request 到 `develop` 分支
- ✅ 手動觸發（通過 Actions 頁面）

### 3. 部署流程

部署流程包括以下步驟：

1. **環境設置**
   - 安裝 Ruby 3.2
   - 安裝 AsciiDoctor、rouge 等工具

2. **建置內容**
   - 從 `zh-tw/book.adoc` 生成 HTML
   - 複製圖片到 `docs/images/`
   - 複製代碼範例到 `docs/code/`
   - 生成 PDF（在 `docs/` 目錄）
   - 嘗試生成 EPUB（如果可用）

3. **部署到 GitHub Pages**
   - 上傳 `docs/` 目錄作為 artifact
   - 部署到 GitHub Pages

---

## 自定義域名配置

### 域名：`bitcoinbook-3nd-zh.doge.tg`

### 1. DNS 配置（在域名服務商）

在您的 DNS 服務商（如 Cloudflare、GoDaddy 等）添加以下記錄：

#### 選項 A：使用 CNAME（推薦）

```
類型    名稱                     值
CNAME   bitcoinbook-3nd-zh      awesome-doge.github.io
```

#### 選項 B：使用 A 記錄

```
類型    名稱                     值
A       bitcoinbook-3nd-zh      185.199.108.153
A       bitcoinbook-3nd-zh      185.199.109.153
A       bitcoinbook-3nd-zh      185.199.110.153
A       bitcoinbook-3nd-zh      185.199.111.153
```

### 2. GitHub 設置

1. 前往倉庫設置：`Settings` → `Pages`
2. 在 **Custom domain** 輸入：`bitcoinbook-3nd-zh.doge.tg`
3. ✅ 勾選 **Enforce HTTPS**
4. 等待 DNS 檢查完成（可能需要幾分鐘到幾小時）

### 3. CNAME 文件

CNAME 文件已在 GitHub Actions 中自動生成：

```yaml
- name: Create CNAME file
  run: |
    echo "bitcoinbook-3nd-zh.doge.tg" > docs/CNAME
```

### 4. 驗證部署

部署完成後，訪問以下網址驗證：

- 🌐 主網址：https://bitcoinbook-3nd-zh.doge.tg
- 🌐 GitHub 網址：https://awesome-doge.github.io/bitcoinbook-3nd-zh

---

## Release 發布

### 自動觸發 Release

Release 會在以下條件同時滿足時自動創建：

1. ✅ 推送到 `develop` 分支
2. ✅ Commit message 以 `Release` 開頭

### 創建 Release 的步驟

```bash
# 1. 確保所有翻譯已完成並提交
git add .
git commit -m "完成所有翻譯"
git push origin develop

# 2. 創建 Release commit
git commit --allow-empty -m "Release: 精通比特幣第三版繁體中文翻譯 v2025.10.30"
git push origin develop
```

### Release 內容

每個 Release 會自動包含：

1. **PDF 檔案**：`mastering-bitcoin-3rd-zh-tw.pdf`
   - 適合列印和離線閱讀
   - 包含完整的圖片和代碼

2. **EPUB 檔案**：`mastering-bitcoin-3rd-zh-tw.epub`
   - 適合電子書閱讀器（Kindle、Apple Books 等）
   - 響應式排版

3. **HTML 檔案**：`mastering-bitcoin-3rd-zh-tw.html`
   - 單一 HTML 檔案
   - 包含所有內容和樣式
   - 可在任何瀏覽器中離線閱讀

### Release 版本號

版本號格式：`vYYYY.MM.DD`

範例：
- `v2025.10.30` - 2025 年 10 月 30 日發布
- `v2025.11.15` - 2025 年 11 月 15 日發布

### Release 說明

每個 Release 會自動生成包含以下內容的說明：

- 📅 發布日期
- 👤 譯者信息
- 📚 原作者信息
- 📜 授權信息
- 📥 下載格式說明
- 🌐 線上閱讀連結
- 📝 翻譯進度
- 🙏 致謝

---

## 手動觸發部署

### 通過 GitHub 網頁介面

1. 前往倉庫的 **Actions** 頁面
2. 選擇 **Build and Deploy to GitHub Pages** workflow
3. 點擊 **Run workflow** 按鈕
4. 選擇 `develop` 分支
5. 點擊綠色的 **Run workflow** 按鈕

### 通過 GitHub CLI

```bash
gh workflow run deploy.yml --ref develop
```

### 查看部署狀態

```bash
# 查看最近的 workflow 執行
gh run list --workflow=deploy.yml

# 查看特定 run 的詳細信息
gh run view <run-id>

# 查看 run 的日誌
gh run view <run-id> --log
```

---

## 故障排除

### 問題 1：GitHub Pages 沒有更新

**解決方案：**
1. 檢查 Actions 頁面是否有錯誤
2. 確認 `develop` 分支有新的提交
3. 清除瀏覽器緩存後重試
4. 等待 5-10 分鐘（CDN 緩存刷新）

### 問題 2：自定義域名無法訪問

**解決方案：**
1. 檢查 DNS 記錄是否正確配置
2. 使用 `nslookup` 或 `dig` 命令驗證 DNS 解析
   ```bash
   nslookup bitcoinbook-3nd-zh.doge.tg
   ```
3. 等待 DNS 傳播（可能需要 24-48 小時）
4. 確認 GitHub Pages 設置中已啟用 HTTPS

### 問題 3：PDF 生成失敗

**解決方案：**
1. 檢查 `zh-tw/book.adoc` 語法是否正確
2. 確認所有圖片路徑正確
3. 查看 Actions 日誌中的具體錯誤信息
4. 本地測試 PDF 生成：
   ```bash
   cd zh-tw
   asciidoctor-pdf book.adoc
   ```

### 問題 4：Release 沒有創建

**解決方案：**
1. 確認 commit message 以 `Release` 開頭（大小寫敏感）
2. 檢查 Actions 權限：`Settings` → `Actions` → `General` → `Workflow permissions`
   - 確保選擇了 "Read and write permissions"
3. 查看 Actions 日誌中的錯誤信息

---

## 構建狀態

當前部署狀態可以在倉庫首頁的 Actions 徽章中查看：

[![Deploy](https://github.com/awesome-doge/bitcoinbook-3nd-zh/actions/workflows/deploy.yml/badge.svg)](https://github.com/awesome-doge/bitcoinbook-3nd-zh/actions/workflows/deploy.yml)

---

## 配置文件

### GitHub Actions Workflow

- 文件：`.github/workflows/deploy.yml`
- 觸發條件：Push 到 `develop` 分支
- 主要步驟：
  1. Build（HTML + PDF + EPUB）
  2. Deploy（GitHub Pages）
  3. Release（條件觸發）

### CNAME 配置

- 自動生成於：`docs/CNAME`
- 內容：`bitcoinbook-3nd-zh.doge.tg`

---

## 維護建議

### 定期更新

建議定期創建 Release，特別是在以下情況：

- ✅ 完成重要章節的翻譯
- ✅ 修正重大錯誤
- ✅ 完成審校流程
- ✅ 達到里程碑（如 25%, 50%, 75%, 100%）

### 版本管理

- 使用語義化版本號：`vYYYY.MM.DD`
- 在 Release 說明中記錄變更內容
- 保留所有歷史版本供參考

### 監控

- 定期檢查 Actions 執行狀態
- 監控 GitHub Pages 訪問統計
- 收集讀者反饋並持續改進

---

## 聯繫方式

如有部署相關問題，請：

1. 查看 [GitHub Issues](https://github.com/awesome-doge/bitcoinbook-3nd-zh/issues)
2. 在 [GitHub Discussions](https://github.com/awesome-doge/bitcoinbook-3nd-zh/discussions) 提問
3. 參考 [CLAUDE.md](CLAUDE.md) 了解項目結構

---

**最後更新**：2025-10-30
**維護者**：Dr. Awesome Doge
