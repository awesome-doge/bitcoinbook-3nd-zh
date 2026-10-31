#!/usr/bin/env ruby
# frozen_string_literal: true

# 建置線上閱讀網站：每章一個獨立頁面，加上首頁、404、sitemap 與全書搜尋索引。
#
# 用法：ruby scripts/build-site.rb [輸出目錄，預設 public]
#
# 流程：
#   1. 以 Asciidoctor 載入整本 zh-tw/book.adoc（交叉引用因此能在全書範圍解析）
#   2. 逐章轉成 HTML 片段，記錄每章用到的註腳
#   3. 收集每頁的所有 id，將跨章的 #錨點 連結改寫為 /chapters/<slug>.html#錨點
#   4. 套用 web/templates 的版型輸出頁面，並產生 sitemap、搜尋索引與靜態檔

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'asciidoctor'
require 'nokogiri'
require 'erb'
require 'json'
require 'yaml'
require 'fileutils'
require 'digest'
require 'time'
require 'cgi'

ROOT = File.expand_path('..', __dir__)
OUT = File.expand_path(ARGV[0] || 'public', ROOT)
WEB = File.join(ROOT, 'web')

SITE_URL = 'https://bitcoinbook-3nd-zh.doge.tg'
SITE_NAME = '精通比特幣繁體中文版'
BOOK_TITLE = '精通比特幣（第三版）'
BOOK_FULL_TITLE = '精通比特幣：程式設計開放區塊鏈（第三版）'
REPO_URL = 'https://github.com/awesome-doge/bitcoinbook-3nd-zh'
EPUB_URL = "#{REPO_URL}/releases/latest"
ORIGINAL_URL = 'https://github.com/bitcoinbook/bitcoinbook'
GA_ID = 'G-6ZDJ9YC816'
OG_IMAGE = '/assets/og-cover.png'

def h(str) = CGI.escapeHTML(str.to_s)
def plain(html) = Nokogiri::HTML5.fragment(html.to_s).text.gsub(/\s+/, ' ').strip

def git_date(*paths)
  out = `git -C #{ROOT} log -1 --format=%cI -- #{paths.map { |p| "'#{p}'" }.join(' ')} 2>/dev/null`.strip
  out.empty? ? Time.now.iso8601 : out
end

# 粗估閱讀時間：中文每分鐘約 400 字，英文每分鐘約 200 詞
def reading_minutes(text)
  cjk = text.scan(/\p{Han}/).size
  words = text.gsub(/\p{Han}/, ' ').scan(/[A-Za-z0-9]+/).size
  [(cjk / 400.0 + words / 200.0).ceil, 1].max
end

def png_size(path)
  data = File.binread(path, 24)
  return nil unless data && data[0, 8] == "\x89PNG\r\n\x1a\n".b

  data[16, 8].unpack('NN')
end

# ---------------------------------------------------------------------------
# 1. 載入全書
# ---------------------------------------------------------------------------

doc = Asciidoctor.load_file(
  File.join(ROOT, 'zh-tw/book.adoc'),
  safe: :unsafe,
  standalone: false,
  sourcemap: true,
  attributes: {
    'idprefix' => '',
    'idseparator' => '-',
    'imagesdir' => '/',
    'source-highlighter' => 'rouge',
    'rouge-css' => 'class',
    'sectanchors' => '',
    'experimental' => '',
    'lang' => 'zh-TW'
  }
)

config = YAML.load_file(File.join(WEB, 'chapters.yml'))
config_by_id = config.to_h { |c| [c['id'], c] }
sections = doc.sections.reject { |s| s.sectname == 'index' }

unknown = sections.map(&:id) - config_by_id.keys
missing = config_by_id.keys - sections.map(&:id)
abort "chapters.yml 缺少章節 ID：#{unknown.join(', ')}" unless unknown.empty?
abort "chapters.yml 有不存在的章節 ID：#{missing.join(', ')}" unless missing.empty?

Page = Struct.new(:id, :slug, :label, :title, :title_html, :description, :source, :html,
                  :toc, :footnotes, :ids, :minutes, :search, :lastmod, :prev, :next, :has_math,
                  keyword_init: true) do
  def path = "/chapters/#{slug}.html"
  def url = SITE_URL + path
  def full_title = label == title ? title : "#{label}　#{title}"
end

chapter_no = 0
pages = sections.map do |sec|
  cfg = config_by_id.fetch(sec.id)
  label =
    case sec.sectname
    when 'preface' then '前言'
    when 'appendix' then "附錄 #{sec.numeral}"
    else "第 #{chapter_no += 1} 章"
    end

  before = doc.footnotes.size
  html = sec.convert
  footnotes = doc.footnotes[before..] || []

  source = sec.source_location&.file
  Page.new(
    id: sec.id, slug: cfg['slug'], label: cfg['label'] || label,
    title: cfg['title'] || plain(sec.title), title_html: cfg['title'] || sec.title,
    description: cfg['description'], source: source && File.join('zh-tw', File.basename(source)),
    html: html, footnotes: footnotes
  )
end
pages.each_cons(2) { |a, b| a.next = b; b.prev = a }

# ---------------------------------------------------------------------------
# 2. 解析每章片段：移除章標題、調整標題層級、收集 id
# ---------------------------------------------------------------------------

frags = {}
id_to_page = {}

pages.each do |page|
  frag = Nokogiri::HTML5.fragment(page.html)
  sect1 = frag.at_css('div.sect1') or abort "#{page.id}: 找不到 div.sect1"
  sect1.at_css('> h2')&.remove

  # 每頁只保留一個 h1（章標題由版型輸出），內文標題整體升一級
  frag.css('h3, h4, h5, h6').each { |hd| hd.name = "h#{hd.name[1].to_i - 1}" }

  frag.css('[id]').each do |el|
    id = el['id']

    warn "重複的 id：#{id}（#{page.slug} 與 #{id_to_page[id].slug}）" if id_to_page[id] && id_to_page[id] != page
    id_to_page[id] = page
  end
  id_to_page[page.id] = page

  # 註腳放在各章結尾（Asciidoctor 預設集中在整本書最後）
  unless page.footnotes.empty?
    items = page.footnotes.map do |fn|
      id_to_page["_footnotedef_#{fn.index}"] = page
      %(<li id="_footnotedef_#{fn.index}" value="#{fn.index}">#{fn.text} ) +
        %(<a class="fn-back" href="#_footnoteref_#{fn.index}" aria-label="返回內文">↩</a></li>)
    end
    frag.add_child(%(<section class="footnotes" aria-labelledby="footnotes-title">) +
                   %(<h2 id="footnotes-title">註腳</h2><ol>#{items.join}</ol></section>))
  end
  frags[page] = frag
end

# ---------------------------------------------------------------------------
# 3. 改寫連結、圖片與表格，產生本章目錄與搜尋資料
# ---------------------------------------------------------------------------

FileUtils.rm_rf(OUT)
FileUtils.mkdir_p(File.join(OUT, 'chapters'))
FileUtils.mkdir_p(File.join(OUT, 'images'))
FileUtils.mkdir_p(File.join(OUT, 'assets'))

webp = system('command -v cwebp >/dev/null 2>&1')
warn '找不到 cwebp，圖片將只輸出 PNG' unless webp
used_images = {}
broken_links = []

pages.each do |page|
  frag = frags[page]

  frag.css('a[href^="#"]').each do |a|
    target = CGI.unescape(a['href'][1..])
    next if target.empty?

    dest = id_to_page[target]
    if dest.nil?
      broken_links << "#{page.slug} → ##{target}"
    elsif dest != page
      a['href'] = dest.id == target ? dest.path : "#{dest.path}##{target}"
    end
  end

  frag.css('a.anchor').each { |a| a['aria-label'] = '本節連結' }
  frag.css('a.footnote').each { |a| a['title'] = '查看註腳' }

  frag.css('a[href^="http"]').each do |a|
    next if a['href'].start_with?(SITE_URL)

    a['rel'] = 'noopener'
    a['target'] = '_blank'
  end

  frag.css('img').each do |img|
    src = img['src'].to_s
    next unless src.start_with?('/images/')

    file = File.join(ROOT, src)
    abort "#{page.slug}: 圖片不存在 #{src}" unless File.exist?(file)
    used_images[src] = file
    if (dims = png_size(file))
      img['width'], img['height'] = dims.map(&:to_s)
    end
    img['loading'] = 'lazy'
    img['decoding'] = 'async'
    next unless webp

    picture = Nokogiri::XML::Node.new('picture', frag.document)
    source = Nokogiri::XML::Node.new('source', frag.document)
    source['type'] = 'image/webp'
    source['srcset'] = src.sub(/\.png\z/, '.webp')
    img.replace(picture)
    picture.add_child(source)
    picture.add_child(img)
  end

  frag.css('table').each do |table|
    next if table.parent['class'].to_s.include?('admonitionblock')

    wrap = Nokogiri::XML::Node.new('div', frag.document)
    wrap['class'] = 'table-wrap'
    wrap['tabindex'] = '0'
    table.replace(wrap)
    wrap.add_child(table)
  end

  frag.css('math[display="block"]').each do |math|
    wrap = Nokogiri::XML::Node.new('div', frag.document)
    wrap['class'] = 'math-wrap'
    math.replace(wrap)
    wrap.add_child(math)
  end

  # 圖、表、範例改為各章獨立編號（例如「圖 4-1」），與印刷版一致；內文的交叉引用使用標題文字，不受影響
  if (num = page.label[/\A第 (\d+) 章\z/, 1] || page.label[/\A附錄 (\w+)\z/, 1])
    counters = Hash.new(0)
    frag.css('.imageblock > .title, .exampleblock > .title, table.tableblock > caption.title').each do |t|
      t.inner_html = t.inner_html.sub(/\A(圖|表|範例) \d+\./) { "#{$1} #{num}-#{counters[$1] += 1}." }
    end
  end

  page.has_math = frag.at_css('.stemblock') || frag.to_html.include?('\\(')

  # 本章目錄（第二層標題）
  page.toc = frag.css('div.sect2 > h2').map do |hd|
    { id: hd['id'], title: hd.children.reject { |c| c['class'] == 'anchor' }.map(&:text).join.strip }
  end

  # 搜尋索引：章首段落、每個小節的開頭，以及每個次小節各一筆，搜尋結果可直接跳到最接近的標題
  own_text = lambda do |node, skip|
    node.children.reject { |c| c.element? && c['class'].to_s.split.include?(skip) }
        .map(&:text).join(' ').gsub(/\s+/, ' ').strip
  end
  heading_text = ->(hd) { hd.children.reject { |c| c['class'] == 'anchor' }.map(&:text).join.strip }
  entries = []
  body = frag.at_css('div.sectionbody')
  entries << { t: page.title, u: page.path, x: body ? own_text.call(body, 'sect2') : '' }
  frag.css('div.sect2').each do |s2|
    hd = s2.at_css('> h2') or next
    s2_title = heading_text.call(hd)
    entries << { t: s2_title, u: "#{page.path}##{hd['id']}", x: own_text.call(s2, 'sect3').sub(s2_title, '').strip }
    s2.css('> div.sect3').each do |s3|
      h3 = s3.at_css('> h3') or next
      s3_title = heading_text.call(h3)
      entries << { t: "#{s2_title} › #{s3_title}", u: "#{page.path}##{h3['id']}",
                   x: s3.text.gsub(/\s+/, ' ').strip.sub(s3_title, '').strip }
    end
  end
  page.search = entries

  text = frag.text
  page.minutes = reading_minutes(text)
  page.ids = frag.css('[id]').map { |e| e['id'] }
  page.lastmod = page.source ? git_date(page.source) : Time.now.iso8601
  page.html = frag.to_html
end

unless broken_links.empty?
  warn "找不到目標的內部連結 #{broken_links.size} 個："
  broken_links.each { |l| warn "  #{l}" }
  abort '內部連結有誤，停止建置' if ENV['STRICT_LINKS']
end

# ---------------------------------------------------------------------------
# 4. 靜態資源
# ---------------------------------------------------------------------------

asset_version = {}
%w[site.css site.js].each do |name|
  src = File.join(WEB, 'assets', name)
  FileUtils.cp(src, File.join(OUT, 'assets', name))
  asset_version[name] = Digest::MD5.file(src).hexdigest[0, 10]
end
Dir.glob(File.join(WEB, 'assets', '*.{png,svg,webp}')).each { |f| FileUtils.cp(f, File.join(OUT, 'assets')) }

ASSET = ->(name) { "/assets/#{name}?v=#{asset_version.fetch(name)}" }

# 程式碼語法高亮配色（亮色與暗色主題）
require 'rouge'
light = Rouge::Themes::Github.mode(:light).render(scope: '.highlight')
dark = Rouge::Themes::Github.mode(:dark).render(scope: ':root[data-theme="dark"] .highlight')
dark_auto = Rouge::Themes::Github.mode(:dark).render(scope: ':root:not([data-theme]) .highlight')
File.write(File.join(OUT, 'assets', 'code.css'),
           "#{light}\n#{dark}\n@media (prefers-color-scheme: dark) {\n#{dark_auto}\n}\n")
asset_version['code.css'] = Digest::MD5.hexdigest(File.read(File.join(OUT, 'assets', 'code.css')))[0, 10]

used_images.each do |src, file|
  dest = File.join(OUT, src)
  FileUtils.cp(file, dest)
  system('cwebp', '-quiet', '-q', '85', '-m', '6', file, '-o', dest.sub(/\.png\z/, '.webp')) if webp
end

Dir.glob(File.join(WEB, 'static', '*'), File::FNM_DOTMATCH).each do |f|
  next if File.directory?(f)

  FileUtils.cp(f, File.join(OUT, File.basename(f)))
  FileUtils.chmod(0o644, File.join(OUT, File.basename(f)))
end

# ---------------------------------------------------------------------------
# 5. 輸出頁面
# ---------------------------------------------------------------------------

def template(name) = ERB.new(File.read(File.join(WEB, 'templates', "#{name}.html.erb")), trim_mode: '-')

LAYOUT = template('layout')
CHAPTER = template('chapter')
HOME = template('home')
NOT_FOUND = template('404')

BOOK_LD = {
  '@type' => 'Book',
  '@id' => "#{SITE_URL}/#book",
  'name' => BOOK_FULL_TITLE,
  'alternateName' => ['Mastering Bitcoin: Programming the Open Blockchain (3rd Edition)', '精通比特幣第三版'],
  'author' => [
    { '@type' => 'Person', 'name' => 'Andreas M. Antonopoulos', 'url' => 'https://aantonop.com' },
    { '@type' => 'Person', 'name' => 'David A. Harding', 'url' => 'https://dtrt.org' }
  ],
  'translator' => { '@type' => 'Person', 'name' => 'Dr. Awesome Doge' },
  'bookEdition' => '第三版',
  'inLanguage' => 'zh-TW',
  'isbn' => '9781098150099',
  'publisher' => { '@type' => 'Organization', 'name' => "O'Reilly Media" },
  'datePublished' => '2023-12',
  'license' => 'https://creativecommons.org/licenses/by-sa/4.0/',
  'isAccessibleForFree' => true,
  'url' => "#{SITE_URL}/",
  'image' => SITE_URL + OG_IMAGE,
  'translationOfWork' => {
    '@type' => 'Book', 'name' => 'Mastering Bitcoin: Programming the Open Blockchain', 'inLanguage' => 'en',
    'url' => ORIGINAL_URL
  }
}.compact

def jsonld(obj) = JSON.generate({ '@context' => 'https://schema.org' }.merge(obj)).gsub('</', '<\/')

def render_page(content:, title:, description:, canonical:, og_type: 'article', jsonld: nil,
                current: nil, pages:, body_class: '', noindex: false, has_math: false, toc: [])
  LAYOUT.result(binding)
end

home_description = '《精通比特幣》（Mastering Bitcoin）第三版繁體中文全文，免費線上閱讀。' \
                   '從金鑰、地址、錢包、交易、腳本到挖礦、共識、Taproot 與閃電網路，完整解說比特幣的技術原理。'

pages.each do |page|
  content = CHAPTER.result(binding)
  ld = {
    '@graph' => [
      {
        '@type' => 'Chapter',
        '@id' => "#{page.url}#chapter",
        'name' => page.full_title,
        'headline' => "#{page.full_title}｜#{BOOK_TITLE}",
        'description' => page.description,
        'url' => page.url,
        'inLanguage' => 'zh-TW',
        'position' => pages.index(page) + 1,
        'dateModified' => page.lastmod,
        'isPartOf' => { '@id' => "#{SITE_URL}/#book" },
        'author' => BOOK_LD['author'],
        'translator' => BOOK_LD['translator'],
        'license' => BOOK_LD['license'],
        'isAccessibleForFree' => true
      },
      BOOK_LD,
      {
        '@type' => 'BreadcrumbList',
        'itemListElement' => [
          { '@type' => 'ListItem', 'position' => 1, 'name' => BOOK_TITLE, 'item' => "#{SITE_URL}/" },
          { '@type' => 'ListItem', 'position' => 2, 'name' => page.full_title, 'item' => page.url }
        ]
      }
    ]
  }
  html = render_page(
    content: content, title: "#{page.full_title}｜#{BOOK_TITLE}繁體中文版", description: page.description,
    canonical: page.url, jsonld: ld, current: page, pages: pages, body_class: 'is-chapter',
    has_math: page.has_math, toc: page.toc
  )
  File.write(File.join(OUT, page.path), html)
end

total_minutes = pages.sum(&:minutes)
home_ld = {
  '@graph' => [
    BOOK_LD.merge('description' => home_description,
                  'hasPart' => pages.map { |p| { '@id' => "#{p.url}#chapter" } }),
    {
      '@type' => 'WebSite', '@id' => "#{SITE_URL}/#website", 'url' => "#{SITE_URL}/", 'name' => SITE_NAME,
      'inLanguage' => 'zh-TW'
    }
  ]
}
File.write(File.join(OUT, 'index.html'), render_page(
  content: HOME.result(binding), title: "#{BOOK_TITLE}繁體中文版｜免費線上閱讀", description: home_description,
  canonical: "#{SITE_URL}/", og_type: 'book', jsonld: home_ld, pages: pages, body_class: 'is-home'
))

File.write(File.join(OUT, '404.html'), render_page(
  content: NOT_FOUND.result(binding), title: "找不到頁面｜#{BOOK_TITLE}", description: home_description,
  canonical: nil, pages: pages, body_class: 'is-404', noindex: true
))

# ---------------------------------------------------------------------------
# 6. sitemap、搜尋索引、舊網址錨點對照、llms-full.txt
# ---------------------------------------------------------------------------

home_lastmod = pages.map(&:lastmod).max
sitemap = +%(<?xml version="1.0" encoding="UTF-8"?>\n)
sitemap << %(<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n)
sitemap << "  <url><loc>#{SITE_URL}/</loc><lastmod>#{home_lastmod}</lastmod></url>\n"
pages.each { |p| sitemap << "  <url><loc>#{p.url}</loc><lastmod>#{p.lastmod}</lastmod></url>\n" }
sitemap << "</urlset>\n"
File.write(File.join(OUT, 'sitemap.xml'), sitemap)

search = pages.flat_map do |p|
  p.search.map { |e| e.merge(c: p.label == p.title ? p.label : "#{p.label}　#{p.title}") }
end
File.write(File.join(OUT, 'search-index.json'), JSON.generate(search))

# 舊版單頁網站的 /#錨點 連結由首頁依此表轉址
ids = {}
pages.each { |p| p.ids.each { |id| ids[id] = p.slug unless id.start_with?('_footnote') } }
pages.each { |p| ids[p.id] = p.slug }
File.write(File.join(OUT, 'ids.json'), JSON.generate(ids))

llms_full = +"# #{BOOK_FULL_TITLE}（繁體中文版）\n\n"
llms_full << "> 原著：Andreas M. Antonopoulos、David A. Harding｜翻譯：Dr. Awesome Doge｜授權：CC BY-SA 4.0\n"
llms_full << "> 線上閱讀：#{SITE_URL}/\n\n"
pages.each do |p|
  llms_full << "\n## #{p.full_title}\n\n來源：#{p.url}\n\n"
  p.search.each_with_index do |e, i|
    llms_full << "### #{e[:t]}\n\n" if i.positive?
    llms_full << "#{e[:x]}\n\n"
  end
end
File.write(File.join(OUT, 'llms-full.txt'), llms_full)


llms = +"# #{BOOK_FULL_TITLE}（繁體中文版）\n\n"
llms << "> 《精通比特幣》（Mastering Bitcoin）第三版的繁體中文全文譯本，由 Andreas M. Antonopoulos 與 David A. Harding 撰寫，" \
        "O'Reilly Media 於 2023 年出版，Dr. Awesome Doge 翻譯，以 CC BY-SA 4.0 授權。\n\n"
llms << "每一章都是獨立頁面；全書純文字版請見 #{SITE_URL}/llms-full.txt 。\n\n## 章節\n\n"
pages.each { |p| llms << "- [#{p.full_title}](#{p.url})：#{p.description}\n" }
llms << "\n## 其他\n\n- [EPUB 電子書下載](#{EPUB_URL})\n- [翻譯專案原始碼](#{REPO_URL})\n- [英文原著](#{ORIGINAL_URL})\n"
File.write(File.join(OUT, 'llms.txt'), llms)

File.write(File.join(OUT, 'CNAME'), "bitcoinbook-3nd-zh.doge.tg\n") if ENV['WRITE_CNAME']

puts "完成：#{pages.size} 個章節頁面、#{used_images.size} 張圖片、#{search.size} 筆搜尋資料 → #{OUT}"
