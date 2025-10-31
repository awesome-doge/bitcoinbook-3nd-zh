# 精通比特幣繁體中文版 - 自動化部署規劃

## 專案資訊

- **GitHub Repository**: https://github.com/awesome-doge/bitcoinbook-3nd-zh
- **GitHub Pages URL**: https://awesome-doge.github.io/bitcoinbook-3nd-zh/
- **自訂域名**: bitcoinbook-3nd-zh.doge.tg
- **來源目錄**: `zh-tw/`
- **主要檔案**: `zh-tw/book.adoc`

## 架構概覽

```
GitHub Actions Workflows
├── build-and-deploy.yml    # 主要建置和部署 (推送時觸發)
├── release.yml             # 版本發佈 (建立 tag 時觸發)
└── pr-preview.yml          # PR 預覽 (可選)
```

## Workflow 1: 建置和部署 HTML 到 GitHub Pages

### 觸發條件
- 推送到 `main` 或 `develop` 分支
- 修改 `zh-tw/**` 目錄下的檔案
- 手動觸發 (workflow_dispatch)

### 建置步驟

1. **環境準備**
   - Ubuntu latest runner
   - 安裝 Ruby 3.2
   - 安裝 asciidoctor 和相關套件

2. **建置 HTML**
   ```bash
   cd zh-tw
   asciidoctor \
     --backend=html5 \
     --out-file=../public/index.html \
     --attribute=source-highlighter=rouge \
     --attribute=toc=left \
     --attribute=toclevels=2 \
     --attribute=icons=font \
     --attribute=sectanchors \
     --attribute=idprefix= \
     --attribute=idseparator=- \
     --attribute=stylesheet=../styles/asciidoctor.css \
     book.adoc
   ```

3. **複製資源檔案**
   - 複製 `images/` 目錄到輸出目錄
   - 複製自訂 CSS（如果有）
   - 生成 CNAME 檔案（自訂域名）

4. **部署到 GitHub Pages**
   - 使用 `actions/deploy-pages@v2`
   - 部署 `public/` 目錄內容

### 檔案位置
`.github/workflows/build-and-deploy.yml`

---

## Workflow 2: 建置 Release 版本（HTML + PDF + EPUB）

### 觸發條件
- 建立新的 git tag（格式：`v*`，例如 `v3.0.0-zh-tw`）
- 手動觸發 (workflow_dispatch)

### 建置步驟

1. **環境準備**
   - Ubuntu latest runner
   - 安裝 Ruby 3.2
   - 安裝完整 AsciiDoctor 工具鏈：
     - `asciidoctor`
     - `asciidoctor-pdf`
     - `asciidoctor-epub3`
     - `rouge` (語法高亮)

2. **建置 HTML**（獨立版本）
   ```bash
   cd zh-tw
   asciidoctor \
     --backend=html5 \
     --out-file=../release/mastering-bitcoin-3rd-zh-tw.html \
     --attribute=source-highlighter=rouge \
     --attribute=toc=left \
     --attribute=toclevels=3 \
     --attribute=icons=font \
     book.adoc
   ```

3. **建置 PDF**
   ```bash
   cd zh-tw
   asciidoctor-pdf \
     --out-file=../release/mastering-bitcoin-3rd-zh-tw.pdf \
     --attribute=source-highlighter=rouge \
     --attribute=pdf-theme=default-with-fallback-font \
     --attribute=scripts=cjk \
     --attribute=pdf-fontsdir=../fonts \
     book.adoc
   ```

4. **建置 EPUB**
   ```bash
   cd zh-tw
   asciidoctor-epub3 \
     --out-file=../release/mastering-bitcoin-3rd-zh-tw.epub \
     --attribute=source-highlighter=rouge \
     --attribute=ebook-format=kf8 \
     book.adoc
   ```

5. **打包資源**
   - 建立包含 images 的完整 HTML 壓縮包
   - 驗證 PDF 和 EPUB 檔案完整性

6. **建立 GitHub Release**
   - 使用 tag 名稱作為 release 版本
   - 自動生成 release notes
   - 上傳以下檔案：
     - `mastering-bitcoin-3rd-zh-tw.html`
     - `mastering-bitcoin-3rd-zh-tw-with-images.zip`
     - `mastering-bitcoin-3rd-zh-tw.pdf`
     - `mastering-bitcoin-3rd-zh-tw.epub`

### 檔案位置
`.github/workflows/release.yml`

---

## Workflow 3: Pull Request 預覽（可選）

### 觸發條件
- Pull Request 建立或更新
- 修改 `zh-tw/**` 目錄下的檔案

### 功能
- 建置 HTML 預覽版本
- 上傳為 workflow artifact
- 在 PR 中留言提供下載連結

### 檔案位置
`.github/workflows/pr-preview.yml`

---

## 目錄結構

建置完成後的目錄結構：

```
bitcoinbook-3nd-zh/
├── .github/
│   └── workflows/
│       ├── build-and-deploy.yml
│       ├── release.yml
│       └── pr-preview.yml
├── zh-tw/                    # 來源檔案
│   ├── book.adoc
│   ├── ch*.adoc
│   └── ...
├── images/                   # 圖片資源
├── fonts/                    # 字型檔案（CJK 支援）
├── styles/                   # 自訂 CSS（可選）
│   └── asciidoctor.css
├── public/                   # GitHub Pages 輸出（gitignore）
└── release/                  # Release 產物（gitignore）
```

---

## 自訂域名設定

### 1. DNS 設定（在 doge.tg 域名管理處）

新增 CNAME 記錄：
```
類型: CNAME
主機名稱: bitcoinbook-3nd-zh
目標: awesome-doge.github.io
TTL: 3600
```

### 2. GitHub Repository 設定

在 GitHub repository 的 Settings > Pages 中：
- Source: Deploy from a branch 或 GitHub Actions
- Custom domain: `bitcoinbook-3nd-zh.doge.tg`
- 勾選 "Enforce HTTPS"

### 3. CNAME 檔案

在 workflow 中自動建立 `public/CNAME` 檔案：
```
bitcoinbook-3nd-zh.doge.tg
```

---

## CJK 字型支援

### PDF 建置的字型需求

中文 PDF 需要 CJK 字型支援，有兩種方案：

#### 方案 A：使用系統字型
```bash
# 在 Ubuntu runner 中安裝字型
sudo apt-get update
sudo apt-get install -y fonts-noto-cjk fonts-noto-cjk-extra
```

#### 方案 B：自訂字型（建議）
1. 在 repository 中建立 `fonts/` 目錄
2. 放置開源字型（如 Noto Sans CJK TC）
3. 建立 PDF theme 設定檔指定字型路徑

推薦字型：
- **Noto Sans CJK TC** (思源黑體繁體中文)
- **Noto Serif CJK TC** (思源宋體繁體中文)
- 授權: SIL Open Font License 1.1

---

## 版本發佈流程

### 發佈新版本的步驟

1. **完成翻譯和審核**
   ```bash
   git checkout develop
   # 完成所有修改和測試
   ```

2. **更新版本資訊**
   - 更新 `zh-tw/book.adoc` 中的版本號
   - 更新 `CHANGELOG.md`（如果有）

3. **建立並推送 tag**
   ```bash
   git tag -a v3.0.0-zh-tw -m "正體中文版 3.0.0 正式發佈"
   git push origin v3.0.0-zh-tw
   ```

4. **自動觸發 Release workflow**
   - GitHub Actions 自動建置所有格式
   - 自動建立 Release 並上傳檔案

5. **驗證 Release**
   - 檢查 https://github.com/awesome-doge/bitcoinbook-3nd-zh/releases
   - 下載並驗證 PDF 和 EPUB 檔案
   - 確認 GitHub Pages 已更新

---

## 效能最佳化

### 快取策略

1. **Ruby gems 快取**
   ```yaml
   - uses: actions/cache@v3
     with:
       path: vendor/bundle
       key: ${{ runner.os }}-gems-${{ hashFiles('**/Gemfile.lock') }}
   ```

2. **字型檔案快取**
   ```yaml
   - uses: actions/cache@v3
     with:
       path: ~/.fonts
       key: ${{ runner.os }}-fonts
   ```

### 條件建置

- HTML 每次推送都建置（快速）
- PDF/EPUB 僅在 tag 或手動觸發時建置（耗時）

---

## 安全性考量

### Secrets 設定

在 GitHub repository Settings > Secrets and variables > Actions 中設定：

1. **GITHUB_TOKEN**（自動提供，無需設定）
   - 用於 GitHub Pages 部署
   - 用於建立 Release

2. **GPG_PRIVATE_KEY**（可選）
   - 用於簽署 Release 檔案
   - 確保檔案完整性

### Permissions

Workflow 需要的權限：
```yaml
permissions:
  contents: write      # 建立 release
  pages: write        # 部署 GitHub Pages
  id-token: write     # GitHub Pages 認證
```

---

## 監控和除錯

### 建置狀態徽章

在 `README.md` 中加入：

```markdown
[![Build and Deploy](https://github.com/awesome-doge/bitcoinbook-3nd-zh/actions/workflows/build-and-deploy.yml/badge.svg)](https://github.com/awesome-doge/bitcoinbook-3nd-zh/actions/workflows/build-and-deploy.yml)

[![Release](https://github.com/awesome-doge/bitcoinbook-3nd-zh/actions/workflows/release.yml/badge.svg)](https://github.com/awesome-doge/bitcoinbook-3nd-zh/actions/workflows/release.yml)
```

### 日誌檢查

- 在 GitHub Actions 頁面查看詳細建置日誌
- 檢查 asciidoctor 警告和錯誤訊息
- 驗證圖片路徑和連結正確性

---

## 成本估算

### GitHub Actions 免費額度

- Public repository: 無限制
- Private repository: 2000 分鐘/月（免費）

### 預估使用量

- HTML 建置: ~2-3 分鐘/次
- PDF 建置: ~5-8 分鐘/次
- EPUB 建置: ~3-5 分鐘/次
- 每月推送約 20 次: ~100 分鐘

**結論**: 對於 public repository 完全免費且充足。

---

## 下一步行動

1. ✅ 建立 `.github/workflows/` 目錄結構
2. ✅ 撰寫三個 workflow 檔案
3. ✅ 設定 GitHub Pages
4. ✅ 設定自訂域名 DNS
5. ✅ 測試首次建置和部署
6. ✅ 建立第一個 release tag
7. ✅ 驗證所有格式檔案
8. ✅ 更新 README 文件

---

## 參考資源

- [GitHub Actions 文件](https://docs.github.com/en/actions)
- [GitHub Pages 文件](https://docs.github.com/en/pages)
- [AsciiDoctor 文件](https://docs.asciidoctor.org/)
- [AsciiDoctor PDF 文件](https://docs.asciidoctor.org/pdf-converter/latest/)
- [AsciiDoctor EPUB3 文件](https://docs.asciidoctor.org/epub3-converter/latest/)

---

**規劃完成日期**: 2025-10-31
**規劃作者**: Claude Code
**版本**: 1.0
