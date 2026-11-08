#!/usr/bin/env ruby
# frozen_string_literal: true

# 檢查建置好的網站：
#   - 每個站內連結都指向存在的檔案，#錨點 都能在目標頁找到對應的 id
#   - 每個圖片、樣式、腳本都存在
#   - sitemap 列出的網址與實際頁面一致
#   - 每頁的 title、description、canonical 不重複，且每頁只有一個 h1
#
# 用法：ruby scripts/check-site.rb [網站目錄，預設 public]

Encoding.default_external = Encoding::UTF_8

require 'nokogiri'
require 'cgi'
require 'set'

DIR = File.expand_path(ARGV[0] || 'public')
SITE_URL = 'https://bitcoinbook-3nd-zh.doge.tg'

errors = []
docs = {}
Dir.glob(File.join(DIR, '**/*.html')).sort.each do |file|
  docs['/' + file.delete_prefix("#{DIR}/")] = Nokogiri::HTML5(File.read(file))
end
ids = docs.transform_values { |doc| doc.css('[id]').map { |e| e['id'] }.to_set }

resolve = lambda do |from, href|
  path, frag = href.split('#', 2)
  path = from if path.nil? || path.empty?
  path = File.expand_path(path, File.dirname(from)) unless path.start_with?('/')
  path += 'index.html' if path.end_with?('/')
  [path, frag && CGI.unescape(frag)]
end

docs.each do |page, doc|
  doc.css('a[href], link[href], img[src], source[srcset], script[src]').each do |el|
    ref = el['href'] || el['src'] || el['srcset']
    next if ref.nil? || ref.empty? || ref.match?(%r{\A(https?:|mailto:|data:|//)})
    next if el.name == 'link' && %w[canonical alternate].include?(el['rel'])

    path, frag = resolve.call(page, ref.sub(/\?.*?(?=#|\z)/, ''))
    if docs.key?(path)
      errors << "#{page}: 找不到錨點 #{ref}" if frag && !frag.empty? && !ids[path].include?(frag)
    elsif !File.exist?(File.join(DIR, path))
      errors << "#{page}: 檔案不存在 #{ref}"
    end
  end
end

indexable = docs.reject { |_, doc| doc.at_css('meta[name="robots"][content*="noindex"]') }
%w[title description canonical].each do |field|
  values = indexable.map do |page, doc|
    v = case field
        when 'title' then doc.at_css('title')&.text
        when 'description' then doc.at_css('meta[name="description"]')&.[]('content')
        else doc.at_css('link[rel="canonical"]')&.[]('href')
        end
    errors << "#{page}: 缺少 #{field}" if v.nil? || v.strip.empty?
    v
  end
  values.compact.tally.each { |v, n| errors << "重複的 #{field}（#{n} 頁）：#{v}" if n > 1 }
end

indexable.each do |page, doc|
  n = doc.css('h1').size
  errors << "#{page}: 有 #{n} 個 h1" unless n == 1
  canonical = doc.at_css('link[rel="canonical"]')&.[]('href')
  expected = SITE_URL + (page == '/index.html' ? '/' : page)
  errors << "#{page}: canonical 應為 #{expected}，實際為 #{canonical}" if canonical && canonical != expected
  # 正文不用破折號（見 translation/style-guide.md）；程式碼與腳本不算
  body = doc.at_css('main')&.dup
  next unless body
  body.css('pre, code, script, style').remove
  body.text.scan(/.{0,15}[—–].{0,15}/).each { |m| errors << "#{page}: 正文有破折號：#{m.strip}" }
end

sitemap = Nokogiri::XML(File.read(File.join(DIR, 'sitemap.xml'))).remove_namespaces!
listed = sitemap.css('loc').map(&:text).to_set
expected = indexable.keys.map { |p| SITE_URL + (p == '/index.html' ? '/' : p) }.to_set
(listed - expected).each { |u| errors << "sitemap 多列了 #{u}" }
(expected - listed).each { |u| errors << "sitemap 漏列了 #{u}" }

if errors.empty?
  puts "網站檢查通過：#{docs.size} 個頁面、#{ids.values.sum(&:size)} 個錨點、sitemap #{listed.size} 個網址"
else
  warn errors.uniq.first(200)
  abort "網站檢查失敗：#{errors.uniq.size} 個問題"
end
