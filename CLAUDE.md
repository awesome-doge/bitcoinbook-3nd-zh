# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains "Mastering Bitcoin" (Third Edition) by Andreas M. Antonopoulos and David A. Harding. It's a technical book published by O'Reilly Media that explains Bitcoin technology in depth. The repository is named `bitcoinbook-3nd-zh` suggesting this is intended for a Chinese translation of the third edition.

**Current Status**: Third Edition published (December 2023)
**License**: CC-BY-SA 4.0 International (Third Edition)
**Main Branch**: `develop` (not `main` or `master`)

## Book Structure

The book is written in AsciiDoc format (.adoc/.asciidoc files) and follows O'Reilly's Atlas publishing system.

### Core Book Files

- `book.adoc` - Main book file that includes all chapters
- `preface.adoc` - Preface
- `ch01_intro.adoc` through `ch14_applications.adoc` - 14 main chapters
- `appa_whitepaper.adoc`, `appb_errata.adoc`, `appc_bips.adoc` - Appendices
- `glossary.asciidoc` - Glossary terms
- `atlas.json` - O'Reilly Atlas build configuration

### Supporting Files

- `meta/github_contrib.adoc` - List of GitHub contributors (edit here when contributing)
- `meta/third_edition_changes.asciidoc` - Changes in third edition
- `images/` - Book figures and diagrams (PNG format)
- `code/` - Python example code showing Bitcoin Core RPC usage
- `tools/` - Build and validation scripts

## Building and Validating the Book

### Build the Book Locally

```bash
# Install asciidoctor first if needed
# Then build the book:
tools/check
```

This will:
1. Compile `book.adoc` to HTML using asciidoctor
2. Validate links with htmlproofer (external links disabled)

### Check for Discouraged Words

The book has style guidelines for terminology consistency:

```bash
tools/discouraged.sh
```

This checks for discouraged terms like:
- Incorrect BIP formatting (should be "BIP21" not "BIP-21" or "BIP 21")
- Raw field names without proper formatting (should use proper AsciiDoc markup)
- "off-chain"/"on-chain" with hyphens (should be "offchain"/"onchain")
- "blockchain.info" or "blockchain.com" (outdated references)
- Triple-dash em-dashes (should use proper AsciiDoc markup)
- "block chain" as two words (should be "blockchain")

## Contributing

### Pull Request Workflow

1. Work on the `develop` branch (this is the main branch, not `master`)
2. **One PR per .adoc file** - Do not bundle changes to multiple chapters
3. Only submit PRs for technical/domain errors, not typos or grammar (those are handled by copy editors)
4. Add your name to `meta/github_contrib.adoc` for attribution
5. Use Unix-style line endings (LF, not CRLF)

### License and Attribution

All contributions must be properly licensed:
- Your own work: CC-BY (Creative Commons Attribution)
- Sourced material: Must have compatible open license (MIT, CC0, CC-BY, etc.)

For sourced material, add attribution in AsciiDoc comment:
```asciidoc
////
Source: https://example.com/originaltext
License: CC0
Added by: @username
////
```

### Commit Messages

Follow the existing commit style visible in git log. The repository uses conventional commit practices for clarity.

## AsciiDoc Conventions

### Terminology

- "bitcoin" (lowercase b) = the unit of currency
- "Bitcoin" (capital B) = the system/network/protocol
- Use "blockchain" as one word
- BIP references: "BIP21" (no hyphens, no spaces, no leading zeros)

### Cross-References

When referencing code or specific sections, use AsciiDoc's cross-reference syntax. The book uses chapter IDs like `[[ch01_intro_what_is_bitcoin]]` for linking.

### Images

Images are stored in `images/` directory with naming convention `mbc3_CCFF.png` where:
- `mbc3` = Mastering Bitcoin 3rd edition
- `CC` = chapter number
- `FF` = figure number

## Code Examples

The `code/` directory contains Python examples demonstrating Bitcoin Core RPC usage:
- `rpc_example.py` - Basic RPC connection example
- `rpc_block.py` - Block-related RPC calls
- `rpc_transaction.py` - Transaction-related RPC calls
- `max_money.py` - Calculate maximum Bitcoin supply

These examples assume Bitcoin Core is running locally with RPC enabled.

## Translation Project (繁體中文翻譯專案)

This repository is actively translating "Mastering Bitcoin" Third Edition into Traditional Chinese (Taiwan). **This is the primary focus of this repository.**

### Translation Directory Structure

```
zh-tw/                    # Traditional Chinese translations
  ├── book.adoc          # Main book file (Chinese)
  ├── preface.adoc       # Preface
  ├── ch01_intro.adoc    # Chapter 1
  └── ...                # Other chapters

translation/             # Translation resources
  ├── terminology.md     # Term glossary (EN→ZH-TW)
  ├── style-guide.md     # Translation style guide
  ├── progress.md        # Translation progress tracker
  └── contributors.md    # Translator credits
```

### Working with Translations

**When translating content:**

1. **Always check terminology first**: Refer to `translation/terminology.md` for standard translations
2. **Follow style guide**: All translations must follow `translation/style-guide.md`
3. **Preserve AsciiDoc markup**: All markup, cross-references, and IDs must remain unchanged
4. **Update image paths**: Use relative paths like `../images/` in zh-tw/ files
5. **Don't translate code**: Keep code blocks, commands, and variable names in English
6. **Update progress**: Mark chapters as in-progress/completed in `translation/progress.md`

**Important translation rules:**
- Use Taiwan Traditional Chinese (正體中文), not Simplified or Hong Kong variants
- Use full-width punctuation (，。！？) for Chinese text
- Add spaces between Chinese and English/numbers
- Keep technical terms consistent with terminology.md
- First occurrence: "中文（English）", subsequent: "中文"

### Building the Chinese Version

```bash
# Build Chinese HTML (when zh-tw/book.adoc exists)
cd zh-tw
asciidoctor \
  --backend=html5 \
  --out-file=../docs/index.html \
  --attribute=source-highlighter=rouge \
  --attribute=toc=left \
  book.adoc
```

### Translation Workflow

1. **Claim a chapter**: Create an issue to claim a chapter from `translation/progress.md`
2. **Create branch**: `git checkout -b translate/chXX-chapter-name`
3. **Translate**: Create the .adoc file in `zh-tw/` directory
4. **Test build**: Ensure the file builds without errors
5. **Submit PR**: Request review from technical + language reviewers
6. **Update credits**: Add your name to `translation/contributors.md`

### Key Resources for Translation

- [TRANSLATION_PLAN.md](TRANSLATION_PLAN.md) - Complete project plan and timeline
- [translation/terminology.md](translation/terminology.md) - Standard term translations
- [translation/style-guide.md](translation/style-guide.md) - Style guidelines
- [translation/progress.md](translation/progress.md) - Current progress
- [README_zh-TW.md](README_zh-TW.md) - Chinese project README

## Important Notes

- **Do not create PDFs** or derivatives until verifying license terms allow it
- The book is technical content requiring domain expertise in Bitcoin/cryptography
- Many cross-references only work when the full book is rendered together
- O'Reilly's Atlas system has specific formatting requirements defined in `atlas.json`
