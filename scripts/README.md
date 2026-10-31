# 構建和發布腳本

本目錄包含用於構建和發布《精通比特幣》第三版繁體中文翻譯的腳本。

## 腳本列表

### 1. `build-site.rb` - 線上閱讀網站

把 `zh-tw/book.adoc` 建置成多頁網站：每章一個獨立頁面（`/chapters/<slug>.html`），加上首頁、404、sitemap、全書搜尋索引與 `llms.txt`。
章節網址與 SEO 描述設定在 `web/chapters.yml`，版型與樣式在 `web/templates/`、`web/assets/`，其餘原樣複製的檔案在 `web/static/`。

```bash
ruby scripts/build-site.rb public                  # 輸出到 public/
ruby scripts/check-site.rb public                  # 檢查連結、錨點、sitemap 與 SEO 欄位
python3 -m http.server 8000 -d public              # 本機預覽 http://localhost:8000/
```

- 需要：`gem install asciidoctor rouge nokogiri`；若有 `cwebp`（`brew install webp`）會同時輸出 WebP 圖片
- `STRICT_LINKS=1`：有找不到目標的站內連結時中止建置（CI 預設開啟）
- `WRITE_CNAME=1`：輸出 GitHub Pages 的 `CNAME`

### 2. `build-local.sh` - 本地完整構建

建置線上閱讀網站與 EPUB，輸出到 `build/`。

```bash
./scripts/build-local.sh
```

需要 `asciidoctor`、`rouge`、`nokogiri`；EPUB 另需 `asciidoctor-epub3`。

---

### 3. `create-release.sh` - 創建 Release

創建新的 GitHub Release，自動觸發 CI/CD 流程。

**用法：**
```bash
# 使用默認描述
./scripts/create-release.sh

# 使用自定義描述
./scripts/create-release.sh "完成全部翻譯"
```

**功能：**
- 檢查當前分支（必須在 `develop` 分支）
- 檢查工作區狀態（必須乾淨）
- 生成版本號（格式：vYYYY.MM.DD）
- 創建 Release commit
- 推送到 GitHub
- 自動觸發 GitHub Actions

**自動觸發的流程：**
1. **GitHub Pages 部署**
   - 構建 HTML 版本
   - 部署到 https://bitcoinbook-3nd-zh.doge.tg

2. **Release 發布**
   - 構建 PDF、EPUB、HTML
   - 創建 GitHub Release
   - 上傳所有格式的文件

**注意事項：**
- Commit message 必須以 `Release:` 開頭
- 確保所有更改已提交
- 推送後等待 5-10 分鐘完成構建

---

## 常見使用場景

### 場景 1：本地測試構建

在提交之前，先在本地測試構建是否正常：

```bash
# 1. 構建
./scripts/build-local.sh

# 2. 檢查輸出
open build/mastering-bitcoin-3rd-zh-tw.html
open build/mastering-bitcoin-3rd-zh-tw.pdf

# 3. 如果有問題，修改後重新構建
```

### 場景 2：完成翻譯後發布

```bash
# 1. 確認所有更改已提交
git status

# 2. 推送到 GitHub
git push origin develop

# 3. 創建 Release
./scripts/create-release.sh "完成第 14 章翻譯"

# 4. 前往 GitHub 查看部署進度
# https://github.com/awesome-doge/bitcoinbook-3nd-zh/actions
```

### 場景 3：僅更新 GitHub Pages（不創建 Release）

如果只想更新網站，不想創建新的 Release：

```bash
# 確保 commit message 不以 "Release" 開頭
git commit -m "修正錯別字"
git push origin develop

# 這將只觸發 GitHub Pages 部署
```

---

## 故障排除

### 問題 1：`asciidoctor: command not found`

**解決方案：**
```bash
gem install asciidoctor rouge
```

### 問題 2：PDF 生成失敗

**解決方案：**
```bash
gem install asciidoctor-pdf
```

### 問題 3：`Permission denied`

**解決方案：**
```bash
chmod +x scripts/*.sh
```

### 問題 4：Release 沒有創建

**可能原因：**
1. Commit message 沒有以 `Release` 開頭
2. GitHub Actions 權限不足
3. 構建過程出錯

**檢查方法：**
```bash
# 查看 GitHub Actions 日誌
gh run list --workflow=deploy.yml
gh run view <run-id> --log
```

---

## 輸出格式對比

| 格式 | 適用場景 | 說明 |
|------|---------|------|
| **線上網站** | 線上閱讀、分享連結、搜尋引擎索引 | 每章一頁，含全書搜尋、深色／護眼模式、字級調整 |
| **HTML 單頁版** | 離線閱讀 | Release 附件，整本書一個檔案 |
| **EPUB** | 電子書閱讀器 | Release 附件，含封面與所有圖片 |

---

## 自訂網站樣式

- 版面與排版：`web/assets/site.css`
- 互動功能（目錄、搜尋、閱讀設定、進度記憶）：`web/assets/site.js`
- 頁面版型：`web/templates/*.html.erb`
- 章節網址代稱與搜尋引擎描述：`web/chapters.yml`
- 搜尋同義詞（例如輸入「助記詞」也找得到「恢復碼」）：`web/search-synonyms.yml`；簡體字查詢使用 `web/data/` 的 OpenCC 繁簡對照表

---

## 相關文檔

- [DEPLOYMENT.md](../DEPLOYMENT.md) - 完整的部署指南
- [.github/workflows/build-and-deploy.yml](../.github/workflows/build-and-deploy.yml) - GitHub Pages 建置與部署
- [CLAUDE.md](../CLAUDE.md) - 專案開發指南

---

**維護者**：Dr. Awesome Doge
**最後更新**：2025-10-30
