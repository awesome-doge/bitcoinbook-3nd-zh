# 構建和發布腳本

本目錄包含用於構建和發布《精通比特幣》第三版繁體中文翻譯的腳本。

## 腳本列表

### 1. `build-local.sh` - 本地構建

在本地構建 HTML、PDF 和 EPUB 版本。

**用法：**
```bash
./scripts/build-local.sh
```

**功能：**
- 檢查必要工具是否安裝
- 構建 HTML（單一文件，包含樣式）
- 構建 PDF（如果 asciidoctor-pdf 已安裝）
- 構建 EPUB（如果 asciidoctor-epub3 已安裝）
- 輸出到 `build/` 目錄

**環境要求：**
```bash
# 必需
gem install asciidoctor rouge

# 可選（用於 PDF）
gem install asciidoctor-pdf

# 可選（用於 EPUB）
gem install asciidoctor-epub3
```

---

### 2. `create-release.sh` - 創建 Release

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

| 格式 | 適用場景 | 檔案大小 | 優點 | 缺點 |
|------|---------|---------|------|------|
| **HTML** | 線上閱讀、分享連結 | ~1 MB | 搜尋方便、可複製代碼 | 需要網路連接 |
| **PDF** | 列印、離線閱讀 | ~15 MB | 格式固定、適合列印 | 檔案較大 |
| **EPUB** | 電子書閱讀器 | ~5 MB | 響應式排版、節省空間 | 格式支援因閱讀器而異 |

---

## 進階配置

### 自定義 PDF 主題

編輯 `theme/pdf-theme.yml` 自定義 PDF 樣式：

```yaml
# 字體
font:
  catalog:
    Noto Sans TC:
      normal: NotoSansTC-Regular.ttf
      bold: NotoSansTC-Bold.ttf

# 顏色
base:
  font-color: #333333
heading:
  font-color: #f7931a  # Bitcoin 橙色
```

### 自定義 HTML 樣式

編輯 `theme/epub.css` 自定義 HTML 樣式。

---

## 相關文檔

- [DEPLOYMENT.md](../DEPLOYMENT.md) - 完整的部署指南
- [.github/workflows/deploy.yml](../.github/workflows/deploy.yml) - GitHub Actions 配置
- [CLAUDE.md](../CLAUDE.md) - 專案開發指南

---

**維護者**：Dr. Awesome Doge
**最後更新**：2025-10-30
