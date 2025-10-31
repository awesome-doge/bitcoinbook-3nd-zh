# 發佈指南 (Release Guide)

本文檔說明如何使用 GitHub Actions 自動建置和發佈《精通比特幣第三版》繁體中文版。

## 發佈格式

每次發佈會自動生成以下檔案：

- **HTML 單頁版** (`mastering-bitcoin-3rd-zh-tw.html`) - 可在瀏覽器直接開啟，不含圖片
- **HTML 完整包** (`mastering-bitcoin-3rd-zh-tw-html.zip`) - 包含 HTML 和所有圖片的壓縮檔
- **EPUB 版** (`mastering-bitcoin-3rd-zh-tw.epub`) - 電子書格式，包含封面和所有圖片
- **校驗和** (`checksums.txt`) - SHA256 校驗和，用於驗證檔案完整性

> **注意**：本專案因中英文混排技術限制，已停止 PDF 版本開發。如需 PDF，建議使用瀏覽器的「列印為 PDF」功能從 HTML 版本轉換。

## 發佈方法

有兩種方式可以觸發自動建置和發佈：

### 方法 1：使用 Git Tag（推薦）

這是標準的版本發佈方式，適合正式版本。

```bash
# 1. 確保所有變更已提交
git status

# 2. 創建帶註解的標籤（推薦格式：v主版本.次版本.修訂版本-zh-tw）
git tag -a v3.0.0-zh-tw -m "第三版繁體中文完整翻譯"

# 3. 推送標籤到 GitHub
git push origin v3.0.0-zh-tw
```

**版本號建議格式：**
- `v3.0.0-zh-tw` - 第三版第一次正式發佈
- `v3.0.1-zh-tw` - 第三版第一次更新（修正錯誤）
- `v3.1.0-zh-tw` - 第三版第二次發佈（新增內容）

推送標籤後，GitHub Actions 會自動：
1. 建置 HTML 和 EPUB
2. 生成校驗和
3. 創建 GitHub Release
4. 上傳所有檔案

### 方法 2：手動觸發工作流程

這種方式適合測試或快速發佈，不需要創建 Git tag。

**步驟：**

1. 前往 GitHub 倉庫頁面
2. 點擊 **Actions** 標籤
3. 在左側選擇 **Build Release (HTML + EPUB)** 工作流程
4. 點擊右上角的 **Run workflow** 按鈕
5. 在彈出的對話框中：
   - Branch: 選擇 `main`（或您的工作分支）
   - Release version: 輸入版本號，例如 `v3.0.0-zh-tw`
6. 點擊綠色的 **Run workflow** 按鈕

工作流程會開始執行，完成後會自動創建 Release。

## 發佈後的檢查

### 1. 查看建置狀態

- 前往 **Actions** 標籤查看工作流程執行狀態
- 綠色勾號 ✓ 表示建置成功
- 紅色叉號 ✗ 表示建置失敗，點擊查看詳細錯誤

### 2. 檢查 Release

發佈成功後：

1. 前往倉庫的 **Releases** 頁面
2. 應該能看到新的 Release，標題為「精通比特幣第三版繁體中文 v版本號」
3. 確認以下檔案都已上傳：
   - ✓ `mastering-bitcoin-3rd-zh-tw.html`
   - ✓ `mastering-bitcoin-3rd-zh-tw-html.zip`
   - ✓ `mastering-bitcoin-3rd-zh-tw.epub`
   - ✓ `checksums.txt`

### 3. 驗證檔案完整性

下載發佈的檔案後，可以使用校驗和驗證：

```bash
# 下載所有檔案到同一目錄後執行
sha256sum -c checksums.txt
```

正確的輸出應該是：
```
mastering-bitcoin-3rd-zh-tw.html: OK
mastering-bitcoin-3rd-zh-tw.epub: OK
mastering-bitcoin-3rd-zh-tw-html.zip: OK
```

### 4. 測試檔案

**HTML 測試：**
```bash
# 解壓完整包
unzip mastering-bitcoin-3rd-zh-tw-html.zip

# 在瀏覽器開啟
open html-package/mastering-bitcoin-3rd-zh-tw.html
```

檢查項目：
- ✓ 目錄顯示正常
- ✓ 圖片能正確顯示
- ✓ 中文字體渲染正確
- ✓ 程式碼區塊語法高亮正常

**EPUB 測試：**

使用電子書閱讀器開啟 `mastering-bitcoin-3rd-zh-tw.epub`，檢查：
- ✓ 封面顯示正常
- ✓ 作者資訊正確（Andreas M. Antonopoulos, David A. Harding）
- ✓ 目錄可用
- ✓ 所有圖片顯示正常
- ✓ 中文字體渲染正確

## 修改 Release 內容

如果需要修改 Release 的說明文字：

1. 編輯 `.github/workflows/release.yml` 檔案
2. 找到 `body:` 部分（約在第 97 行）
3. 修改 Markdown 格式的發佈說明
4. 提交變更後，下次發佈會使用新的說明文字

## 刪除錯誤的 Release

如果發佈有問題需要重新發佈：

```bash
# 1. 在 GitHub 網頁上刪除 Release
# 前往 Releases → 點擊要刪除的 Release → Delete

# 2. 刪除本地標籤
git tag -d v3.0.0-zh-tw

# 3. 刪除遠端標籤
git push origin --delete v3.0.0-zh-tw

# 4. 重新創建並推送標籤
git tag -a v3.0.0-zh-tw -m "第三版繁體中文完整翻譯"
git push origin v3.0.0-zh-tw
```

## 本地測試建置

在正式發佈前，建議先在本地測試建置：

```bash
# 執行本地建置腳本
./scripts/build-local.sh
```

這會在 `build/` 目錄生成檔案，可以先檢查是否有問題。

## 常見問題

### Q: 為什麼沒有 PDF？

A: 本專案因中英文混排在 asciidoctor-pdf 中存在嚴重的詞間空白問題，經多次嘗試無法解決，因此停止 PDF 開發。建議使用瀏覽器的「列印為 PDF」功能從 HTML 轉換。

### Q: EPUB 圖片不顯示怎麼辦？

A: 確保 `zh-tw/book.adoc` 中的 `include` 語句使用相對路徑，且建置命令中沒有多餘的 `imagesdir` 屬性。目前的配置已正確處理圖片路徑。

### Q: 建置失敗怎麼辦？

A:
1. 查看 Actions 頁面的詳細錯誤日誌
2. 常見問題：
   - AsciiDoc 語法錯誤：檢查 `.adoc` 檔案格式
   - 交叉引用錯誤：確保 `<<anchor>>` 語法正確且目標存在
   - 圖片路徑錯誤：確保圖片檔案存在於 `images/` 目錄
3. 在本地執行 `./scripts/build-local.sh` 測試

### Q: 如何更新線上閱讀版本？

A: 線上閱讀版本（https://bitcoinbook-3nd-zh.doge.tg）需要單獨部署，與 GitHub Release 是獨立的。請參考部署文檔。

## 技術細節

### GitHub Actions 工作流程

工作流程定義在 `.github/workflows/release.yml`：

- **觸發條件**：
  - 推送標籤：`v*`
  - 手動觸發：`workflow_dispatch`

- **執行環境**：Ubuntu Latest

- **主要步驟**：
  1. Checkout 倉庫
  2. 安裝 Ruby 3.2
  3. 安裝 AsciiDoctor 工具鏈（asciidoctor, asciidoctor-epub3, rouge）
  4. 建置 HTML
  5. 建置 EPUB
  6. 打包 HTML + 圖片
  7. 生成 SHA256 校驗和
  8. 創建 GitHub Release
  9. 上傳建置產物（保留 30 天）

### 建置命令

**HTML：**
```bash
asciidoctor \
  --backend=html5 \
  --out-file=../release/mastering-bitcoin-3rd-zh-tw.html \
  --attribute=source-highlighter=rouge \
  --attribute=toc=left \
  --attribute=toclevels=3 \
  --attribute=icons=font \
  --attribute=sectanchors \
  --attribute=idprefix= \
  --attribute=idseparator=- \
  --attribute=lang=zh-TW \
  --attribute=imagesdir=.. \
  book.adoc
```

**EPUB：**
```bash
asciidoctor-epub3 \
  --out-file=../release/mastering-bitcoin-3rd-zh-tw.epub \
  --attribute=lang=zh-TW \
  --attribute=front-cover-image=images/cover.png \
  --attribute=producer="繁體中文翻譯：Dr. Awesome Doge" \
  book.adoc
```

## 相關文檔

- [PDF_DEPRECATED.md](PDF_DEPRECATED.md) - PDF 格式停止支援說明
- [README_zh-TW.md](README_zh-TW.md) - 專案說明
- [CLAUDE.md](../CLAUDE.md) - 開發指南

---

📝 最後更新：2025-10-31
