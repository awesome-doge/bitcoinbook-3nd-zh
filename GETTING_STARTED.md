# 專案啟動指南

本文檔將幫助您快速開始《精通比特幣》第三版繁體中文翻譯專案。

## 🎯 專案目標

將《Mastering Bitcoin》第三版（約 15 萬字）完整翻譯成台灣繁體中文，並透過 GitHub Pages 發布到 https://bitcoinbook-3nd-zh.doge.tg。

## 📋 前置準備

### 必要條件

1. **GitHub 帳號**
2. **Git 基礎知識**（clone, branch, commit, push, pull request）
3. **AsciiDoc 基礎**（或願意學習）
4. **中文寫作能力**

### 推薦技能（至少具備其一）

- **Bitcoin 技術背景**：理解 Bitcoin 運作原理（適合技術審校）
- **技術翻譯經驗**：有技術文件翻譯經驗（適合翻譯）
- **中文編輯經驗**：擅長中文寫作和潤色（適合語言審校）

## 🚀 快速開始（5 分鐘）

### 步驟 1：Fork 並 Clone 專案

```bash
# 1. 在 GitHub 上 Fork 專案
# 訪問：https://github.com/awesome-doge/bitcoinbook-3nd-zh
# 點擊右上角的 "Fork" 按鈕

# 2. Clone 你的 fork
git clone https://github.com/你的用戶名/bitcoinbook-3nd-zh.git
cd bitcoinbook-3nd-zh

# 3. 添加上游倉庫（用於同步更新）
git remote add upstream https://github.com/awesome-doge/bitcoinbook-3nd-zh.git

# 4. 驗證遠端倉庫
git remote -v
```

### 步驟 2：閱讀關鍵文檔（15 分鐘）

依序快速瀏覽以下文件：

1. **[README_zh-TW.md](README_zh-TW.md)** - 專案概覽（5分鐘）
2. **[TRANSLATION_PLAN.md](TRANSLATION_PLAN.md)** - 翻譯規劃（5分鐘）
3. **[translation/progress.md](translation/progress.md)** - 當前進度（2分鐘）
4. **[translation/terminology.md](translation/terminology.md)** - 術語表（瀏覽，需要時查閱）
5. **[translation/style-guide.md](translation/style-guide.md)** - 風格指南（瀏覽，翻譯時詳讀）

### 步驟 3：選擇您的角色

根據您的背景選擇參與方式：

#### 🔤 翻譯者（Translator）

**適合**：熟悉 Bitcoin、有技術翻譯經驗

**任務**：翻譯章節內容

**下一步**：前往 [認領翻譯任務](#認領翻譯任務)

#### 🔍 技術審校（Technical Reviewer）

**適合**：Bitcoin 專家、開發者

**任務**：審查翻譯的技術準確性

**下一步**：查看待審校的 Pull Requests

#### ✍️ 語言審校（Language Reviewer）

**適合**：中文母語者、編輯

**任務**：潤飾中文表達，確保流暢自然

**下一步**：查看待審校的 Pull Requests

#### 🐛 問題回報（Issue Reporter）

**適合**：所有人

**任務**：閱讀時發現錯誤或有建議

**下一步**：[創建 Issue](https://github.com/awesome-doge/bitcoinbook-3nd-zh/issues/new)

## 📝 認領翻譯任務

### 1. 查看可用章節

訪問 [translation/progress.md](translation/progress.md)，查看狀態為 🔴（未開始）的章節。

### 2. 評估工作量

參考章節文件大小：

| 難度 | 章節示例 | 預估時間 |
|------|----------|----------|
| 簡單 | ch01 (~35KB) | 6-8 小時 |
| 中等 | ch06 (~66KB) | 12-16 小時 |
| 困難 | ch12 (~119KB) | 20-25 小時 |

**建議**：新手從簡單章節開始，如 ch01 或 ch02。

### 3. 創建認領 Issue

在 GitHub 上創建 Issue：

**標題格式**：
```
[認領翻譯] ch01_intro - 介紹
```

**內容模板**：
```markdown
## 認領資訊

- **章節**：ch01_intro.adoc
- **預計開始**：2025-11-01
- **預計完成**：2025-11-15（2 週）
- **翻譯者**：@你的用戶名

## 背景（可選）

簡單介紹您的背景，如：
- Bitcoin 開發經驗 3 年
- 曾翻譯過技術文件
- 等等

## 承諾

- [ ] 我已閱讀翻譯規劃和風格指南
- [ ] 我將遵循術語對照表
- [ ] 我預計在 2 週內完成初稿
```

### 4. 更新進度檔案

Fork 專案後，編輯 `translation/progress.md`：

```markdown
| ch01_intro.adoc | 🟡 | @你的用戶名 | - | 2025-11-01 | - | 翻譯中 |
```

提交 PR 更新進度。

## ✍️ 開始翻譯

### 創建翻譯分支

```bash
# 確保在最新的 develop 分支
git checkout develop
git pull upstream develop

# 創建翻譯分支
git checkout -b translate/ch01-intro
```

### 翻譯流程

1. **創建文件**

```bash
# 在 zh-tw/ 目錄創建文件
touch zh-tw/ch01_intro.adoc
```

2. **參考原文開始翻譯**

```bash
# 打開原文參考
cat ch01_intro.adoc

# 使用你喜歡的編輯器編輯中文版
vim zh-tw/ch01_intro.adoc
# 或
code zh-tw/ch01_intro.adoc
```

3. **翻譯時的重點**

**✅ 必須做的**：
- 保持所有 AsciiDoc 標記不變（`==`、`[[id]]`、`image::` 等）
- 圖片路徑改為相對路徑：`image::../images/xxx.png`
- 查閱 `translation/terminology.md` 確保術語一致
- 遵循 `translation/style-guide.md` 的格式規範
- 中英文之間加空格
- 使用全形標點符號

**❌ 不要做的**：
- 不要翻譯代碼區塊
- 不要翻譯命令和變數名
- 不要改變 ID 和交叉引用
- 不要使用簡體中文或大陸用語

4. **示例對照**

**原文**：
```asciidoc
[[ch01_intro]]
== Introduction

Bitcoin is a collection of concepts and technologies that form the basis
of a digital money ecosystem.

[source,python]
----
print("Hello Bitcoin")
----
```

**譯文**：
```asciidoc
[[ch01_intro]]
== 介紹

比特幣（Bitcoin）是構成數位貨幣生態系統基礎的概念和技術的集合。

[source,python]
----
print("Hello Bitcoin")
----
```

### 定期提交

```bash
# 每翻譯一個段落或小節就提交一次
git add zh-tw/ch01_intro.adoc
git commit -m "翻譯 ch01: 完成介紹段落"
git push origin translate/ch01-intro
```

### 本地測試構建（可選）

```bash
# 安裝 asciidoctor（如果還沒安裝）
gem install asciidoctor

# 測試構建
cd zh-tw
asciidoctor ch01_intro.adoc

# 在瀏覽器中打開 ch01_intro.html 查看效果
```

## 📤 提交翻譯

### 完成翻譯後

1. **最終檢查清單**

- [ ] 所有段落都已翻譯
- [ ] 術語使用符合 terminology.md
- [ ] 標點符號使用正確（全形）
- [ ] 中英文之間有空格
- [ ] AsciiDoc 格式正確
- [ ] 圖片引用路徑正確
- [ ] 程式碼未被翻譯
- [ ] 已在本地構建測試（如果可以）

2. **更新進度**

編輯 `translation/progress.md`：

```markdown
| ch01_intro.adoc | 🟢 | @你的用戶名 | - | 2025-11-01 | - | 初稿完成，待審校 |
```

3. **添加貢獻者資訊**

編輯 `translation/contributors.md`：

```markdown
- **你的GitHub用戶名** (你的姓名，可選) - 翻譯章節：ch01
```

4. **提交 Pull Request**

```bash
# 確保所有更改都已提交
git add .
git commit -m "完成 ch01_intro 翻譯初稿"
git push origin translate/ch01-intro
```

前往 GitHub 創建 Pull Request：

**PR 標題**：
```
[翻譯] ch01_intro - 介紹
```

**PR 描述模板**：
```markdown
## 翻譯資訊

- **章節**：ch01_intro.adoc
- **字數**：約 3,000 字
- **翻譯者**：@你的用戶名

## 檢查清單

- [x] 術語符合 terminology.md
- [x] 風格符合 style-guide.md
- [x] AsciiDoc 格式正確
- [x] 已本地構建測試
- [x] 已更新 progress.md
- [x] 已更新 contributors.md

## 備註

- 這是我的第一次貢獻
- 第 XX 段落的術語翻譯請幫忙確認
```

## 🔍 審校流程

### 審校者須知

審校分為兩類：

#### 技術審校

檢查項目：
- Bitcoin 技術內容是否準確
- 術語翻譯是否正確
- 技術邏輯是否清晰

#### 語言審校

檢查項目：
- 中文表達是否流暢自然
- 標點符號使用是否正確
- 語法是否有錯誤

### 審校步驟

1. **查看 PR**：在 Pull Requests 頁面找到待審校的翻譯
2. **對比原文**：打開原文和譯文對照閱讀
3. **留下評論**：
   - 使用 GitHub 的行內評論功能
   - 明確指出問題所在
   - 提供修改建議
4. **批准或請求修改**：
   - 如果沒有問題：Approve
   - 如果需要修改：Request Changes

## 🛠️ 常見問題

### Q: 我不懂 AsciiDoc 怎麼辦？

**A**: AsciiDoc 比 Markdown 稍複雜但很好學：
- [AsciiDoc 語法快速參考](https://docs.asciidoctor.org/asciidoc/latest/syntax-quick-reference/)
- 最重要的：保持原有標記不變，只翻譯文字內容

### Q: 遇到不確定的術語翻譯怎麼辦？

**A**: 按以下順序處理：
1. 查閱 `translation/terminology.md`
2. 搜尋 Bitcoin 中文社群的慣用譯法
3. 在 PR 中標註，請審校者協助確認
4. 在 GitHub Discussions 發起討論

### Q: 可以使用 AI 翻譯工具嗎？

**A**: 可以，但必須：
- 人工審閱和修改所有 AI 翻譯的內容
- 確保符合風格指南和術語表
- 確保技術內容準確
- AI 只是輔助，最終品質由譯者負責

### Q: 翻譯進度太慢怎麼辦？

**A**:
- 不要有壓力，品質比速度重要
- 可以在 Issue 中更新預計完成時間
- 如果無法繼續，請在 Issue 中說明，其他人可以接手
- 可以只認領一個小節而非整章

### Q: GitHub Pages 什麼時候會更新？

**A**:
- 每次合併 PR 到 develop 分支時
- GitHub Actions 會自動構建並部署
- 通常 5-10 分鐘內生效

## 📞 尋求幫助

如果遇到問題：

1. **查看文檔**：
   - [翻譯規劃](TRANSLATION_PLAN.md)
   - [風格指南](translation/style-guide.md)
   - [術語表](translation/terminology.md)

2. **搜尋 Issues**：可能有人遇到過相同問題

3. **創建 Issue**：
   - 標題清楚描述問題
   - 提供足夠的上下文資訊
   - 貼上相關代碼或截圖

4. **聯繫維護者**：[@awesome-doge](https://github.com/awesome-doge)

## 🎉 完成後

恭喜完成貢獻！您的名字將出現在：

- [translation/contributors.md](translation/contributors.md)
- 未來正式發佈時的致謝名單
- GitHub 貢獻者列表

您也可以：

- 繼續認領其他章節
- 協助審校其他人的翻譯
- 幫助推廣這個專案
- 使用貢獻者徽章

---

**感謝您為開源社群和 Bitcoin 教育做出貢獻！** 🙏
