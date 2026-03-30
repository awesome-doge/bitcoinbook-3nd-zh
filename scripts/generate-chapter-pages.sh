#!/bin/bash
# 生成獨立章節 landing pages 供 SEO 索引
# 每個章節頁面包含：獨立 title/description/canonical → 連結到主頁對應錨點

set -e

OUTPUT_DIR="${1:-public/chapters}"
BASE_URL="https://bitcoinbook-3nd-zh.doge.tg"

mkdir -p "$OUTPUT_DIR"

# 章節定義：ID|中文標題|英文關鍵字|描述
CHAPTERS=(
  "前言|前言：撰寫比特幣這本書|preface|比特幣技術書籍的寫作背景與本書使用指南"
  "ch01_intro_what_is_bitcoin|第一章：比特幣介紹|bitcoin-introduction|什麼是比特幣？了解比特幣的歷史、運作原理和基本概念。涵蓋去中心化、數位貨幣、P2P 網路等核心知識"
  "ch02_bitcoin_overview|第二章：比特幣如何運作|how-bitcoin-works|比特幣交易的完整流程：從建立錢包、獲取比特幣到發送交易。深入了解 UTXO、交易確認和區塊鏈記錄"
  "ch03_bitcoin_client|第三章：Bitcoin Core 參考實作|bitcoin-core|Bitcoin Core 的安裝、設定和使用。學習編譯原始碼、RPC API 介面和命令列操作"
  "ch04_keys_addresses|第四章：金鑰與地址|keys-addresses|比特幣密碼學基礎：私鑰、公鑰、地址的產生與關係。橢圓曲線密碼學、Base58Check、Bech32 編碼詳解"
  "ch05_wallets|第五章：錢包恢復|wallets-recovery|HD 錢包、BIP39 助記詞、BIP32 衍生路徑。了解如何安全備份和恢復比特幣錢包"
  "ch06_transactions|第六章：交易|transactions|比特幣交易的完整結構：輸入、輸出、腳本、序列化格式。深入 UTXO 模型和交易建構流程"
  "ch07_authorization_authentication|第七章：授權與認證|authorization-authentication|比特幣腳本語言：P2PKH、P2SH、P2WPKH、P2WSH、P2TR 腳本類型詳解"
  "ch08_signatures|第八章：數位簽章|digital-signatures|ECDSA 和 Schnorr 數位簽章演算法。簽章驗證、多重簽章和 Taproot 簽章方案"
  "ch09_fees|第九章：交易手續費|transaction-fees|比特幣手續費計算：費率估算、RBF、CPFP。交易優先級和區塊空間經濟學"
  "ch10_network|第十章：比特幣網路|bitcoin-network|P2P 網路架構：節點發現、區塊傳播、交易中繼。比特幣網路拓撲和通訊協議"
  "ch11_blockchain|第十一章：區塊鏈|blockchain|區塊結構：區塊頭、Merkle 樹、難度目標。區塊鏈作為不可篡改帳本的技術原理"
  "ch12_mining|第十二章：挖礦與共識|mining-consensus|工作量證明挖礦：算力、難度調整、區塊獎勵。湧現共識和最長鏈規則"
  "ch13_security|第十三章：比特幣安全性|bitcoin-security|比特幣安全最佳實踐：冷儲存、多重簽章、安全威脅分析和防護策略"
  "ch14_applications|第十四章：第二層應用|layer2-applications|閃電網路、支付通道、狀態通道。比特幣第二層擴容方案和應用"
  "satoshi_whitepaper|附錄 A：比特幣白皮書|bitcoin-whitepaper|中本聰原始白皮書《比特幣：點對點電子現金系統》繁體中文翻譯"
)

for entry in "${CHAPTERS[@]}"; do
  IFS='|' read -r id title slug desc <<< "$entry"

  cat > "$OUTPUT_DIR/$slug.html" << HTMLEOF
<!DOCTYPE html>
<html lang="zh-TW">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${title}｜精通比特幣繁體中文版｜免費線上閱讀</title>
<meta name="description" content="${desc}">
<meta name="keywords" content="比特幣,Bitcoin,區塊鏈,${title},精通比特幣,繁體中文,免費教學">
<link rel="canonical" href="${BASE_URL}/chapters/${slug}.html">
<meta property="og:title" content="${title}｜精通比特幣繁體中文版">
<meta property="og:description" content="${desc}">
<meta property="og:url" content="${BASE_URL}/chapters/${slug}.html">
<meta property="og:type" content="article">
<meta property="og:locale" content="zh_TW">
<meta property="og:site_name" content="精通比特幣繁體中文版">
<meta name="twitter:card" content="summary">
<meta name="twitter:title" content="${title}｜精通比特幣繁體中文版">
<meta name="twitter:description" content="${desc}">
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Chapter",
  "name": "${title}",
  "description": "${desc}",
  "isPartOf": {
    "@type": "Book",
    "name": "精通比特幣：程式設計開放區塊鏈（第三版）",
    "author": [
      {"@type": "Person", "name": "Andreas M. Antonopoulos"},
      {"@type": "Person", "name": "David A. Harding"}
    ],
    "inLanguage": "zh-TW",
    "url": "${BASE_URL}/"
  },
  "url": "${BASE_URL}/chapters/${slug}.html",
  "inLanguage": "zh-TW"
}
</script>
<style>
body{font-family:-apple-system,BlinkMacSystemFont,"Noto Sans TC","PingFang TC",sans-serif;max-width:680px;margin:2em auto;padding:0 1.5em;line-height:1.8;color:#2c3e50;background:#fff}
h1{font-size:1.6em;color:#1a1a2e;border-bottom:2px solid #f7931a;padding-bottom:0.3em}
.read-btn{display:inline-block;background:#f7931a;color:#fff;padding:12px 28px;border-radius:8px;text-decoration:none;font-size:1.1em;font-weight:600;margin:1.5em 0;transition:background 0.15s}
.read-btn:hover{background:#e07c00}
.meta{color:#666;font-size:0.9em;margin:1em 0}
.desc{font-size:1.05em;line-height:1.9;margin:1.5em 0}
.back{color:#2156a5;text-decoration:none;font-size:0.9em}
.chapters{margin:2em 0;padding:0;list-style:none}
.chapters li{padding:0.4em 0}
.chapters a{color:#2156a5;text-decoration:none}
.chapters a:hover{color:#f7931a}
@media(prefers-color-scheme:dark){body{background:#1a1b26;color:#c9d1d9}h1{color:#e6e8f0}.meta{color:#9ca3af}.back{color:#6ea8fe}.chapters a{color:#6ea8fe}}
</style>
</head>
<body>
<a href="${BASE_URL}/" class="back">&larr; 返回完整書籍</a>
<h1>${title}</h1>
<p class="meta">《精通比特幣：程式設計開放區塊鏈（第三版）》繁體中文版<br>
原著：Andreas M. Antonopoulos, David A. Harding ｜ 翻譯：Dr. Awesome Doge ｜ 授權：CC BY-SA 4.0</p>
<p class="desc">${desc}</p>
<a href="${BASE_URL}/#${id}" class="read-btn">閱讀本章 &rarr;</a>
<h2>本書目錄</h2>
<ul class="chapters">
<li><a href="${BASE_URL}/#前言">前言</a></li>
<li><a href="${BASE_URL}/#ch01_intro_what_is_bitcoin">第一章：比特幣介紹</a></li>
<li><a href="${BASE_URL}/#ch02_bitcoin_overview">第二章：比特幣如何運作</a></li>
<li><a href="${BASE_URL}/#ch03_bitcoin_client">第三章：Bitcoin Core 參考實作</a></li>
<li><a href="${BASE_URL}/#ch04_keys_addresses">第四章：金鑰與地址</a></li>
<li><a href="${BASE_URL}/#ch05_wallets">第五章：錢包恢復</a></li>
<li><a href="${BASE_URL}/#ch06_transactions">第六章：交易</a></li>
<li><a href="${BASE_URL}/#ch07_authorization_authentication">第七章：授權與認證</a></li>
<li><a href="${BASE_URL}/#ch08_signatures">第八章：數位簽章</a></li>
<li><a href="${BASE_URL}/#ch09_fees">第九章：交易手續費</a></li>
<li><a href="${BASE_URL}/#ch10_network">第十章：比特幣網路</a></li>
<li><a href="${BASE_URL}/#ch11_blockchain">第十一章：區塊鏈</a></li>
<li><a href="${BASE_URL}/#ch12_mining">第十二章：挖礦與共識</a></li>
<li><a href="${BASE_URL}/#ch13_security">第十三章：比特幣安全性</a></li>
<li><a href="${BASE_URL}/#ch14_applications">第十四章：第二層應用</a></li>
<li><a href="${BASE_URL}/#satoshi_whitepaper">附錄 A：比特幣白皮書</a></li>
</ul>
<p class="meta"><a href="${BASE_URL}/">線上閱讀完整書籍</a> ｜ <a href="https://github.com/awesome-doge/bitcoinbook-3nd-zh/releases/latest">下載 EPUB 電子書</a></p>
</body>
</html>
HTMLEOF

  echo "  Generated: $slug.html"
done

echo "Generated ${#CHAPTERS[@]} chapter pages in $OUTPUT_DIR/"
