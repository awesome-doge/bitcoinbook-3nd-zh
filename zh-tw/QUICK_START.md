# 快速開始指南

## 🚀 5 分鐘完成設定

### 第一步：啟用 GitHub Actions

1. 前往 https://github.com/awesome-doge/bitcoinbook-3nd-zh/settings/actions
2. 在 **Workflow permissions** 選擇 **Read and write permissions**
3. 點擊 **Save**

### 第二步：啟用 GitHub Pages

1. 前往 https://github.com/awesome-doge/bitcoinbook-3nd-zh/settings/pages
2. 在 **Source** 選擇 **GitHub Actions**
3. 點擊 **Save**

### 第三步：設定 DNS（在 doge.tg 域名管理處）

```
類型: CNAME
主機名稱: bitcoinbook-3nd-zh
值: awesome-doge.github.io
TTL: 3600
```

### 第四步：設定自訂域名

1. 回到 https://github.com/awesome-doge/bitcoinbook-3nd-zh/settings/pages
2. 在 **Custom domain** 輸入: `bitcoinbook-3nd-zh.doge.tg`
3. 等待 DNS 檢查完成
4. 勾選 **Enforce HTTPS**

### 第五步：觸發首次部署

```bash
git push origin main
```

或手動觸發：
1. 前往 https://github.com/awesome-doge/bitcoinbook-3nd-zh/actions
2. 選擇 **Build and Deploy to GitHub Pages**
3. 點擊 **Run workflow**

### 完成！

- **網站**: https://bitcoinbook-3nd-zh.doge.tg
- **狀態**: https://github.com/awesome-doge/bitcoinbook-3nd-zh/actions

---

## 📦 如何發佈 Release

```bash
# 建立版本標籤
git tag -a v3.0.0-zh-tw -m "繁體中文版正式發佈"
git push origin v3.0.0-zh-tw

# 自動建置 HTML + PDF + EPUB
# 查看結果: https://github.com/awesome-doge/bitcoinbook-3nd-zh/releases
```

---

## 📚 詳細文件

- **完整設定指南**: [SETUP_GUIDE.md](./SETUP_GUIDE.md)
- **部署規劃**: [DEPLOYMENT_PLAN.md](./DEPLOYMENT_PLAN.md)

## ⚙️ 已建立的檔案

```
.github/workflows/
├── build-and-deploy.yml  # 自動部署到 GitHub Pages
├── release.yml           # 建置 PDF/EPUB 並發佈 Release
└── pr-preview.yml        # PR 預覽（可選）
```

## 💡 常用命令

```bash
# 推送更新（自動部署）
git add .
git commit -m "docs: 更新翻譯"
git push origin main

# 發佈新版本
git tag -a v3.0.1-zh-tw -m "版本說明"
git push origin v3.0.1-zh-tw

# 檢查 DNS
dig bitcoinbook-3nd-zh.doge.tg CNAME +short
```

## 🎯 下一步

1. [ ] 推送程式碼觸發首次建置
2. [ ] 確認網站可訪問
3. [ ] 建立第一個 release
4. [ ] 在 README 加入狀態徽章

有問題？查看 [SETUP_GUIDE.md](./SETUP_GUIDE.md) 的疑難排解章節。
