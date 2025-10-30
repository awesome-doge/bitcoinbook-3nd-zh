#!/bin/bash
# 本地構建腳本
# 用於測試 HTML、PDF 和 EPUB 生成

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  精通比特幣第三版 - 本地構建${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 檢查必要工具
echo -e "${BLUE}檢查必要工具...${NC}"

if ! command -v asciidoctor &> /dev/null; then
    echo -e "${RED}❌ 錯誤：asciidoctor 未安裝${NC}"
    echo -e "${YELLOW}   請執行：gem install asciidoctor${NC}"
    exit 1
fi
echo -e "${GREEN}✓ asciidoctor 已安裝 ($(asciidoctor --version | head -1))${NC}"

if ! command -v asciidoctor-pdf &> /dev/null; then
    echo -e "${YELLOW}⚠️  警告：asciidoctor-pdf 未安裝${NC}"
    echo -e "${YELLOW}   無法生成 PDF。安裝方法：gem install asciidoctor-pdf${NC}"
    PDF_AVAILABLE=false
else
    echo -e "${GREEN}✓ asciidoctor-pdf 已安裝${NC}"
    PDF_AVAILABLE=true
fi

if ! command -v asciidoctor-epub3 &> /dev/null; then
    echo -e "${YELLOW}⚠️  警告：asciidoctor-epub3 未安裝${NC}"
    echo -e "${YELLOW}   無法生成 EPUB。安裝方法：gem install asciidoctor-epub3${NC}"
    EPUB_AVAILABLE=false
else
    echo -e "${GREEN}✓ asciidoctor-epub3 已安裝${NC}"
    EPUB_AVAILABLE=true
fi

# 檢查源文件
echo ""
echo -e "${BLUE}檢查源文件...${NC}"

if [ ! -f "zh-tw/book.adoc" ]; then
    echo -e "${RED}❌ 錯誤：zh-tw/book.adoc 不存在${NC}"
    exit 1
fi
echo -e "${GREEN}✓ zh-tw/book.adoc 存在${NC}"

# 創建輸出目錄
OUTPUT_DIR="build"
mkdir -p "$OUTPUT_DIR"
echo -e "${GREEN}✓ 輸出目錄：$OUTPUT_DIR${NC}"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}開始構建...${NC}"
echo -e "${BLUE}========================================${NC}"

# 構建 HTML
echo ""
echo -e "${BLUE}1/3 構建 HTML...${NC}"
cd zh-tw
asciidoctor \
  --backend=html5 \
  --out-file="../$OUTPUT_DIR/mastering-bitcoin-3rd-zh-tw.html" \
  --attribute=source-highlighter=rouge \
  --attribute=toc=left \
  --attribute=toclevels=2 \
  --attribute=lang=zh-TW \
  --attribute=imagesdir=.. \
  book.adoc
cd ..
echo -e "${GREEN}✓ HTML 已生成：$OUTPUT_DIR/mastering-bitcoin-3rd-zh-tw.html${NC}"

# 構建 PDF
echo ""
if [ "$PDF_AVAILABLE" = true ]; then
    echo -e "${BLUE}2/3 構建 PDF...${NC}"
    cd zh-tw
    asciidoctor-pdf \
      --out-file="../$OUTPUT_DIR/mastering-bitcoin-3rd-zh-tw.pdf" \
      --attribute=source-highlighter=rouge \
      --attribute=imagesdir=.. \
      book.adoc
    cd ..
    echo -e "${GREEN}✓ PDF 已生成：$OUTPUT_DIR/mastering-bitcoin-3rd-zh-tw.pdf${NC}"
else
    echo -e "${YELLOW}2/3 跳過 PDF 構建（工具未安裝）${NC}"
fi

# 構建 EPUB
echo ""
if [ "$EPUB_AVAILABLE" = true ]; then
    echo -e "${BLUE}3/3 構建 EPUB...${NC}"
    cd zh-tw
    asciidoctor-epub3 \
      --out-file="../$OUTPUT_DIR/mastering-bitcoin-3rd-zh-tw.epub" \
      --attribute=imagesdir=.. \
      book.adoc
    cd ..
    echo -e "${GREEN}✓ EPUB 已生成：$OUTPUT_DIR/mastering-bitcoin-3rd-zh-tw.epub${NC}"
else
    echo -e "${YELLOW}3/3 跳過 EPUB 構建（工具未安裝）${NC}"
fi

# 顯示結果
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ 構建完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}生成的文件：${NC}"
ls -lh "$OUTPUT_DIR"
echo ""

# 計算文件大小
TOTAL_SIZE=$(du -sh "$OUTPUT_DIR" | cut -f1)
echo -e "總大小：${GREEN}$TOTAL_SIZE${NC}"
echo ""

# 提供快速訪問建議
echo -e "${BLUE}快速訪問：${NC}"
echo -e "  HTML：open $OUTPUT_DIR/mastering-bitcoin-3rd-zh-tw.html"
if [ "$PDF_AVAILABLE" = true ]; then
    echo -e "  PDF： open $OUTPUT_DIR/mastering-bitcoin-3rd-zh-tw.pdf"
fi
if [ "$EPUB_AVAILABLE" = true ]; then
    echo -e "  EPUB：open $OUTPUT_DIR/mastering-bitcoin-3rd-zh-tw.epub"
fi
echo ""
