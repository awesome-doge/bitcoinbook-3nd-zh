# GitHub Actions 自動化部署設定指南

本指南將逐步引導您完成 GitHub Actions 和 GitHub Pages 的設定，實現自動化建置和部署。

## 📋 目錄

1. [啟用 GitHub Pages](#1-啟用-github-pages)
2. [設定自訂域名](#2-設定自訂域名)
3. [測試自動部署](#3-測試自動部署)
4. [發佈 Release 版本](#4-發佈-release-版本)
5. [疑難排解](#5-疑難排解)

---

## 1. 啟用 GitHub Pages

### 步驟 1.1: 設定 GitHub Pages 來源

1. 前往您的 GitHub repository: https://github.com/awesome-doge/bitcoinbook-3nd-zh
2. 點擊 **Settings** (設定) 標籤
3. 在左側選單找到 **Pages**
4. 在 **Source** (來源) 區塊:
   - 選擇 **GitHub Actions**（這是新的推薦方式）
   - 如果沒有這個選項，選擇 **Deploy from a branch** 並稍後切換

### 步驟 1.2: 檢查 Workflow 權限

1. 在 **Settings** 中，點擊左側的 **Actions** > **General**
2. 滾動到 **Workflow permissions** 區塊
3. 確認選擇 **Read and write permissions**
4. 勾選 **Allow GitHub Actions to create and approve pull requests**
5. 點擊 **Save**

### 步驟 1.3: 檢查 Pages 權限

回到 **Settings** > **Pages**:
- 確認 **Build and deployment** 區塊顯示 **Source: GitHub Actions**
- 應該會看到提示訊息說明 GitHub Actions workflows 可以部署到 Pages

---

## 2. 設定自訂域名

### 步驟 2.1: 設定 DNS 記錄

前往您的 DNS 管理介面（doge.tg 的域名管理處），新增以下記錄：

```
類型: CNAME
主機名稱: bitcoinbook-3nd-zh
值: awesome-doge.github.io
TTL: 3600 (或預設值)
```

**範例**：
- 如果使用 Cloudflare:
  ```
  Type: CNAME
  Name: bitcoinbook-3nd-zh
  Target: awesome-doge.github.io
  Proxy status: DNS only (灰色雲朵)
  ```

- 如果使用其他 DNS 提供商，設定方式類似

### 步驟 2.2: 在 GitHub 設定自訂域名

1. 回到 **Settings** > **Pages**
2. 在 **Custom domain** 欄位輸入: `bitcoinbook-3nd-zh.doge.tg`
3. 點擊 **Save**
4. 等待 DNS 檢查完成（可能需要幾分鐘）
5. 檢查完成後，勾選 **Enforce HTTPS**

### 步驟 2.3: 驗證 DNS 設定

使用以下命令驗證 DNS 設定是否正確：

```bash
# 檢查 CNAME 記錄
dig bitcoinbook-3nd-zh.doge.tg CNAME +short

# 應該顯示: awesome-doge.github.io
```

或使用線上工具：
- https://dnschecker.org/
- 輸入 `bitcoinbook-3nd-zh.doge.tg` 並選擇 CNAME 類型

---

## 3. 測試自動部署

### 步驟 3.1: 觸發首次建置

設定完成後，有兩種方式觸發建置：

**方式 A: 推送變更**
```bash
# 對 zh-tw/ 目錄做任何修改
cd zh-tw
echo "\n// Test deployment" >> book.adoc

# 提交並推送
git add .
git commit -m "test: 測試 GitHub Actions 自動部署"
git push origin main  # 或 develop，視您的主分支而定
```

**方式 B: 手動觸發**
1. 前往 **Actions** 標籤
2. 選擇左側的 **Build and Deploy to GitHub Pages** workflow
3. 點擊右上角的 **Run workflow**
4. 選擇分支並點擊綠色的 **Run workflow** 按鈕

### 步驟 3.2: 監控建置狀態

1. 前往 **Actions** 標籤
2. 您應該會看到一個正在執行的 workflow
3. 點擊進入查看詳細日誌
4. 建置完成後，狀態會顯示綠色勾勾 ✅

### 步驟 3.3: 驗證部署

建置完成後，訪問以下網址確認部署成功：

- GitHub Pages 預設網址: https://awesome-doge.github.io/bitcoinbook-3nd-zh/
- 自訂域名: https://bitcoinbook-3nd-zh.doge.tg/

---

## 4. 發佈 Release 版本

### 步驟 4.1: 準備發佈

在發佈之前，確認：

1. ✅ 所有翻譯內容已完成
2. ✅ 已通過審核和測試
3. ✅ HTML 建置成功無錯誤

### 步驟 4.2: 建立 Git Tag

```bash
# 確認在正確的分支上
git checkout main  # 或 develop

# 確保本地是最新的
git pull origin main

# 建立帶註解的 tag
git tag -a v3.0.0-zh-tw -m "精通比特幣第三版繁體中文正式發佈

- 完成所有 14 章翻譯
- 完成所有附錄翻譯
- 校對和審核完成
"

# 推送 tag 到遠端
git push origin v3.0.0-zh-tw
```

### 步驟 4.3: 監控 Release 建置

1. 推送 tag 後，自動觸發 **Build Release** workflow
2. 前往 **Actions** 標籤查看建置進度
3. Release 建置包含：
   - ✅ HTML 單頁版本
   - ✅ PDF 版本（包含中文字型）
   - ✅ EPUB 電子書版本
   - ✅ 完整 HTML 壓縮包（含圖片）
   - ✅ SHA256 檢查碼

### 步驟 4.4: 驗證 Release

建置完成後：

1. 前往 **Releases** 標籤
2. 應該會看到新的 release（例如 `v3.0.0-zh-tw`）
3. 驗證所有檔案都已上傳：
   - `mastering-bitcoin-3rd-zh-tw.html`
   - `mastering-bitcoin-3rd-zh-tw.pdf`
   - `mastering-bitcoin-3rd-zh-tw.epub`
   - `mastering-bitcoin-3rd-zh-tw-html.zip`
   - `checksums.txt`

4. 下載並測試檔案：
   ```bash
   # 下載 checksums.txt 和任一檔案
   sha256sum mastering-bitcoin-3rd-zh-tw.pdf
   # 對比 checksums.txt 中的值
   ```

### 步驟 4.5: 手動觸發 Release（可選）

如果需要在沒有 tag 的情況下建置 release：

1. 前往 **Actions** 標籤
2. 選擇 **Build Release** workflow
3. 點擊 **Run workflow**
4. 輸入版本號（例如 `v3.0.1-zh-tw`）
5. 點擊綠色的 **Run workflow** 按鈕

---

## 5. 疑難排解

### 問題 1: GitHub Pages 404 錯誤

**症狀**: 訪問網站顯示 404

**解決方案**:
1. 檢查 **Settings** > **Pages** 是否顯示綠色勾勾和網址
2. 確認 workflow 建置成功
3. 檢查 `public/` 目錄下是否有 `index.html`
4. 等待幾分鐘讓 CDN 更新

### 問題 2: 自訂域名無法訪問

**症狀**: GitHub Pages 預設網址可以訪問，但自訂域名無法訪問

**解決方案**:
1. 檢查 DNS 設定:
   ```bash
   dig bitcoinbook-3nd-zh.doge.tg CNAME +short
   ```
2. 確認顯示 `awesome-doge.github.io`
3. 等待 DNS 傳播（可能需要 24-48 小時）
4. 檢查 CNAME 檔案是否存在於部署的檔案中

### 問題 3: PDF 建置失敗（中文字型問題）

**症狀**: PDF 建置時出現字型錯誤

**解決方案**:

在 `.github/workflows/release.yml` 中已經包含 CJK 字型安裝：
```yaml
- name: Install CJK fonts
  run: |
    sudo apt-get install -y fonts-noto-cjk
```

如果仍有問題，可以嘗試：
1. 檢查 workflow 日誌中的字型安裝步驟
2. 使用 `--attribute=pdf-theme=default` 而非 `default-with-fallback-font`

### 問題 4: 圖片無法顯示

**症狀**: HTML 顯示但圖片損壞

**解決方案**:
1. 確認 `images/` 目錄已複製到輸出目錄
2. 檢查 AsciiDoc 中的圖片路徑是否正確
3. 確認圖片檔案確實存在於 repository 中

### 問題 5: Workflow 權限錯誤

**症狀**: Workflow 失敗並顯示 "Permission denied"

**解決方案**:
1. 前往 **Settings** > **Actions** > **General**
2. 在 **Workflow permissions** 選擇 **Read and write permissions**
3. 重新執行失敗的 workflow

### 問題 6: Release 未自動建立

**症狀**: Tag 推送後沒有建立 Release

**解決方案**:
1. 確認 tag 格式正確（以 `v` 開頭）
2. 檢查 workflow 是否觸發（**Actions** 標籤）
3. 查看 workflow 日誌是否有錯誤
4. 確認有 `contents: write` 權限

---

## 6. 維護和更新

### 日常更新流程

```bash
# 1. 修改翻譯內容
cd zh-tw
vim ch01_intro.adoc

# 2. 提交變更
git add .
git commit -m "docs: 更新第一章翻譯"

# 3. 推送到 GitHub（自動觸發部署）
git push origin main
```

### 發佈新版本

```bash
# 1. 確認所有變更已合併到主分支
git checkout main
git pull origin main

# 2. 建立新版本 tag
git tag -a v3.0.1-zh-tw -m "修正第三章翻譯錯誤"

# 3. 推送 tag（自動觸發 release 建置）
git push origin v3.0.1-zh-tw
```

### 監控建置狀態

在 README 中加入狀態徽章：

```markdown
[![Build and Deploy](https://github.com/awesome-doge/bitcoinbook-3nd-zh/actions/workflows/build-and-deploy.yml/badge.svg)](https://github.com/awesome-doge/bitcoinbook-3nd-zh/actions/workflows/build-and-deploy.yml)

[![Release](https://github.com/awesome-doge/bitcoinbook-3nd-zh/actions/workflows/release.yml/badge.svg)](https://github.com/awesome-doge/bitcoinbook-3nd-zh/actions/workflows/release.yml)
```

---

## 7. 進階設定（可選）

### 自訂 CSS 樣式

1. 建立 `styles/asciidoctor.css`
2. 在 workflow 中加入複製步驟
3. 修改 asciidoctor 命令加入 `--attribute=stylesheet`

### 加入 Google Analytics

在 HTML 模板中加入追蹤碼（需要自訂 AsciiDoc backend）

### 設定 PDF 主題

1. 建立 `themes/custom-theme.yml`
2. 使用 `--attribute=pdf-theme=custom-theme`

---

## 8. 資源連結

- [GitHub Actions 文件](https://docs.github.com/en/actions)
- [GitHub Pages 文件](https://docs.github.com/en/pages)
- [AsciiDoctor 使用手冊](https://docs.asciidoctor.org/)
- [本專案 Deployment Plan](./DEPLOYMENT_PLAN.md)

---

## 需要協助？

如果遇到問題：

1. 檢查 **Actions** 標籤的 workflow 日誌
2. 查看本文件的疑難排解章節
3. 在 GitHub Issues 提問
4. 參考 [GitHub Pages 疑難排解文件](https://docs.github.com/en/pages/getting-started-with-github-pages/troubleshooting-404-errors-for-github-pages-sites)

---

**設定完成檢查清單**:

- [ ] ✅ GitHub Pages 已啟用
- [ ] ✅ Workflow 權限設定正確
- [ ] ✅ DNS CNAME 記錄已設定
- [ ] ✅ 自訂域名已在 GitHub 設定
- [ ] ✅ HTTPS 已啟用
- [ ] ✅ 首次部署成功
- [ ] ✅ 網站可正常訪問
- [ ] ✅ 已測試 Release 建置
- [ ] ✅ 狀態徽章已加入 README

祝您部署順利！🚀
