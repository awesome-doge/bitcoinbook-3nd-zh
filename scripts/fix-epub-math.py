#!/usr/bin/env python3
"""將 EPUB 中的 LaTeX 數學公式轉換為 Unicode 數學文字"""

import re
import sys
import zipfile
import tempfile
import shutil
import os

# LaTeX → Unicode 映射
REPLACEMENTS = [
    # 希臘字母
    (r'\\alpha', 'α'), (r'\\beta', 'β'), (r'\\gamma', 'γ'),
    (r'\\delta', 'δ'), (r'\\sigma', 'σ'), (r'\\pi', 'π'),
    # 數學符號
    (r'\\times', '×'), (r'\\cdot', '·'), (r'\\div', '÷'),
    (r'\\pm', '±'), (r'\\leq', '≤'), (r'\\geq', '≥'),
    (r'\\neq', '≠'), (r'\\approx', '≈'), (r'\\infty', '∞'),
    (r'\\sum', '∑'), (r'\\prod', '∏'), (r'\\sqrt', '√'),
    # 箭頭
    (r'\\rightarrow', '→'), (r'\\leftarrow', '←'),
    # 集合
    (r'\\in', '∈'), (r'\\mathbb\{F\}', '𝔽'), (r'\\mathbb\{Z\}', 'ℤ'),
    (r'\\mathbb\{R\}', 'ℝ'), (r'\\mathbb\{N\}', 'ℕ'),
    # 文字命令
    (r'\\text\{over\}', 'over'), (r'\\text\{mod\}', 'mod'),
    (r'\\mod', 'mod'),
    # 上下標
    (r'\^2', '²'), (r'\^3', '³'), (r'\^{-1}', '⁻¹'),
    # 花括號和環境
    (r'\\begin\{equation\}', ''), (r'\\end\{equation\}', ''),
    (r'\\\[', ''), (r'\\\]', ''),
    # 空格控制
    (r'~', ' '), (r'\\:', ' '), (r'\\;', ' '), (r'\\,', ''),
    # 清理剩餘的花括號（最後處理）
]

def latex_to_unicode(latex_str):
    """將 LaTeX 公式轉換為 Unicode 文字"""
    result = latex_str.strip()
    for pattern, replacement in REPLACEMENTS:
        result = re.sub(pattern, replacement, result)
    # 清理多餘的花括號
    result = result.replace('{', '').replace('}', '')
    # 清理多餘空白
    result = re.sub(r'\s+', ' ', result).strip()
    return result

def fix_math_in_xhtml(content):
    """替換 XHTML 中的 LaTeX pre 區塊為 Unicode 文字"""
    def replace_math(match):
        latex = match.group(1)
        unicode_text = latex_to_unicode(latex)
        return f'<p class="math-formula" style="text-align:center;font-size:1.15em;margin:1em 0;font-style:italic;">{unicode_text}</p>'

    # 替換 <pre>\begin{equation}...\end{equation}</pre>
    pattern = r'<pre>\\begin\{equation\}(.*?)\\end\{equation\}</pre>'
    content = re.sub(pattern, replace_math, content, flags=re.DOTALL)

    # 替換 <figure class="listing"> 包裹的數學區塊
    pattern2 = r'<figure class="listing">\s*<pre>\\begin\{equation\}(.*?)\\end\{equation\}</pre>\s*</figure>'
    content = re.sub(pattern2, replace_math, content, flags=re.DOTALL)

    return content

def fix_epub(epub_path):
    """修復 EPUB 中的數學公式"""
    temp_dir = tempfile.mkdtemp()
    temp_epub = epub_path + '.tmp'

    try:
        with zipfile.ZipFile(epub_path, 'r') as zin:
            with zipfile.ZipFile(temp_epub, 'w') as zout:
                for item in zin.infolist():
                    data = zin.read(item.filename)
                    if item.filename.endswith('.xhtml'):
                        content = data.decode('utf-8')
                        if '\\begin{equation}' in content:
                            original = content
                            content = fix_math_in_xhtml(content)
                            if content != original:
                                count = original.count('\\begin{equation}')
                                print(f'  Fixed {count} formulas in {item.filename}')
                            data = content.encode('utf-8')
                    zout.writestr(item, data)

        shutil.move(temp_epub, epub_path)
        print(f'EPUB math formulas fixed: {epub_path}')
    finally:
        shutil.rmtree(temp_dir, ignore_errors=True)
        if os.path.exists(temp_epub):
            os.remove(temp_epub)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(f'Usage: {sys.argv[0]} <epub_file>')
        sys.exit(1)
    fix_epub(sys.argv[1])
