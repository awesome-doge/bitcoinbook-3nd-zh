#!/bin/bash
# 創建 Release 的快速腳本
# 用法: ./scripts/create-release.sh [版本信息]

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  精通比特幣第三版繁體中文 - Release${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 檢查是否在 develop 分支
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "develop" ]; then
    echo -e "${RED}❌ 錯誤：必須在 develop 分支上創建 Release${NC}"
    echo -e "${YELLOW}   當前分支：$CURRENT_BRANCH${NC}"
    echo -e "${YELLOW}   請執行：git checkout develop${NC}"
    exit 1
fi

echo -e "${GREEN}✓ 當前分支：develop${NC}"

# 檢查工作區是否乾淨
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}❌ 錯誤：工作區有未提交的更改${NC}"
    echo -e "${YELLOW}   請先提交或暫存所有更改${NC}"
    exit 1
fi

echo -e "${GREEN}✓ 工作區乾淨${NC}"

# 生成版本號
VERSION=$(date +'%Y.%m.%d')
VERSION_TAG="v$VERSION"

# 檢查版本號是否已存在
if git rev-parse "$VERSION_TAG" >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  警告：版本 $VERSION_TAG 已存在${NC}"
    read -p "是否使用時間戳創建新版本？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        VERSION=$(date +'%Y.%m.%d-%H%M')
        VERSION_TAG="v$VERSION"
        echo -e "${GREEN}✓ 新版本號：$VERSION_TAG${NC}"
    else
        echo -e "${RED}❌ 取消創建 Release${NC}"
        exit 1
    fi
fi

# 獲取自定義發布信息（可選）
if [ -n "$1" ]; then
    RELEASE_NOTE="$1"
else
    RELEASE_NOTE="精通比特幣第三版繁體中文翻譯"
fi

echo ""
echo -e "${BLUE}準備創建 Release：${NC}"
echo -e "  版本號：${GREEN}$VERSION_TAG${NC}"
echo -e "  說明：${GREEN}$RELEASE_NOTE${NC}"
echo ""

read -p "確認創建 Release？(y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}取消創建 Release${NC}"
    exit 0
fi

# 創建 Release commit
COMMIT_MESSAGE="Release: $RELEASE_NOTE $VERSION_TAG"

echo ""
echo -e "${BLUE}創建 Release commit...${NC}"
git commit --allow-empty -m "$COMMIT_MESSAGE"

echo -e "${GREEN}✓ Commit 已創建${NC}"
echo -e "  Commit message: $COMMIT_MESSAGE"

# 推送到遠端
echo ""
echo -e "${BLUE}推送到 GitHub...${NC}"
git push origin develop

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Release 創建成功！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "下一步："
echo -e "  1. 前往 GitHub Actions 查看構建進度"
echo -e "     ${BLUE}https://github.com/awesome-doge/bitcoinbook-3nd-zh/actions${NC}"
echo ""
echo -e "  2. 構建完成後，Release 將自動發布到"
echo -e "     ${BLUE}https://github.com/awesome-doge/bitcoinbook-3nd-zh/releases${NC}"
echo ""
echo -e "  3. GitHub Pages 將自動更新到"
echo -e "     ${BLUE}https://bitcoinbook-3nd-zh.doge.tg${NC}"
echo ""
echo -e "${YELLOW}⏳ 預計等待時間：5-10 分鐘${NC}"
echo ""
