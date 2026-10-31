// 精通比特幣繁體中文版：線上閱讀互動功能
(function () {
  'use strict';

  var root = document.documentElement;
  var body = document.body;
  var $ = function (sel, el) { return (el || document).querySelector(sel); };
  var $$ = function (sel, el) { return Array.prototype.slice.call((el || document).querySelectorAll(sel)); };

  var store = {
    get: function (k) { try { return localStorage.getItem(k); } catch (e) { return null; } },
    set: function (k, v) { try { localStorage.setItem(k, v); } catch (e) { /* 無痕模式等情況 */ } }
  };

  // ---------- 舊版單頁網址：/#錨點 → 對應的章節頁 ----------
  if (body.classList.contains('is-home') && location.hash.length > 1) {
    var target = decodeURIComponent(location.hash.slice(1));
    fetch('/ids.json').then(function (r) { return r.json(); }).then(function (ids) {
      var slug = ids[target];
      if (slug) location.replace('/chapters/' + slug + '.html#' + encodeURIComponent(target));
    }).catch(function () {});
  }

  // ---------- 閱讀設定 ----------
  var SIZES = [15, 16, 17, 18, 19, 20, 22, 24];
  var settings = $('#settings');
  var settingsBtn = $('[data-action="settings"]');

  function currentSize() {
    return parseInt(store.get('mb-size'), 10) || 18;
  }

  function syncSettings() {
    var theme = store.get('mb-theme') || 'auto';
    var font = store.get('mb-font') || 'sans';
    $$('[data-theme-set]').forEach(function (b) { b.setAttribute('aria-pressed', String(b.dataset.themeSet === theme)); });
    $$('[data-font-set]').forEach(function (b) { b.setAttribute('aria-pressed', String(b.dataset.fontSet === font)); });
    $('.size-value').textContent = currentSize();
  }

  function toggleSettings(open) {
    if (open === undefined) open = settings.hidden;
    settings.hidden = !open;
    settingsBtn.setAttribute('aria-expanded', String(open));
    if (open) syncSettings();
  }

  settingsBtn.addEventListener('click', function (e) { e.stopPropagation(); toggleSettings(); });
  settings.addEventListener('click', function (e) {
    var b = e.target.closest('button');
    if (!b) return;
    if (b.dataset.themeSet) {
      var t = b.dataset.themeSet;
      store.set('mb-theme', t);
      if (t === 'auto') root.removeAttribute('data-theme'); else root.setAttribute('data-theme', t);
    } else if (b.dataset.fontSet) {
      store.set('mb-font', b.dataset.fontSet);
      root.setAttribute('data-font', b.dataset.fontSet);
    } else if (b.dataset.size) {
      var i = SIZES.indexOf(currentSize());
      if (i < 0) i = 3;
      var size = SIZES[Math.min(SIZES.length - 1, Math.max(0, i + parseInt(b.dataset.size, 10)))];
      store.set('mb-size', String(size));
      root.style.setProperty('--fs', size + 'px');
    }
    syncSettings();
  });
  document.addEventListener('click', function (e) {
    if (!settings.hidden && !settings.contains(e.target)) toggleSettings(false);
  });

  // ---------- 目錄側欄 ----------
  var navBtn = $('[data-action="toggle-nav"]');
  var sidebar = $('#sidebar');
  var mobileNav = window.matchMedia('(max-width: 1023px)');

  function setNav(open) {
    body.classList.toggle('nav-open', open);
    navBtn.setAttribute('aria-expanded', String(open));
    navBtn.setAttribute('aria-label', open ? '關閉目錄' : '開啟目錄');
    if (open) {
      var cur = $('.is-current', sidebar);
      if (cur) cur.scrollIntoView({ block: 'center' });
    }
  }
  navBtn.addEventListener('click', function () { setNav(!body.classList.contains('nav-open')); });
  $('[data-action="close-nav"]').addEventListener('click', function () { setNav(false); });
  sidebar.addEventListener('click', function (e) {
    if (mobileNav.matches && e.target.closest('a')) setNav(false);
  });
  if (!mobileNav.matches) {
    var cur = $('.is-current', sidebar);
    if (cur && cur.offsetTop > sidebar.clientHeight * 0.6) sidebar.scrollTop = cur.offsetTop - sidebar.clientHeight / 3;
  }

  // ---------- 章節頁：進度條、標題、目前小節 ----------
  var chapter = $('.chapter');
  var bar = $('.progress span');
  var topTitle = $('.topbar-title');
  var head = $('.chapter-head');

  if (chapter) {
    var ticking = false;
    var onScroll = function () {
      if (ticking) return;
      ticking = true;
      requestAnimationFrame(function () {
        ticking = false;
        var rect = chapter.getBoundingClientRect();
        var total = rect.height - window.innerHeight;
        var ratio = total > 0 ? Math.min(1, Math.max(0, -rect.top / total)) : 1;
        bar.style.transform = 'scaleX(' + ratio + ')';
        if (topTitle) topTitle.classList.toggle('is-visible', head.getBoundingClientRect().bottom < 0);
        saveProgress(ratio);
      });
    };
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();

    // 目前閱讀的小節（右側欄與側欄同步高亮）
    var tocLinks = $$('.rail a, .section-toc a');
    var headings = $$('.prose .sect2 > h2');
    if (headings.length && 'IntersectionObserver' in window) {
      var active = null;
      var setActive = function (id) {
        if (id === active) return;
        active = id;
        tocLinks.forEach(function (a) { a.classList.toggle('is-active', a.getAttribute('href') === '#' + id); });
        var railLink = $('.rail a.is-active');
        if (railLink) {
          var rail = $('.rail');
          var top = railLink.offsetTop;
          if (top < rail.scrollTop || top > rail.scrollTop + rail.clientHeight - 40) rail.scrollTop = top - rail.clientHeight / 3;
        }
      };
      var observer = new IntersectionObserver(function () {
        var current = headings[0];
        for (var i = 0; i < headings.length; i++) {
          if (headings[i].getBoundingClientRect().top < window.innerHeight * 0.3) current = headings[i];
          else break;
        }
        setActive(current.id);
      }, { rootMargin: '0px 0px -70% 0px', threshold: [0, 1] });
      headings.forEach(function (hd) { observer.observe(hd); });
    }
  }

  // ---------- 閱讀進度記憶 ----------
  var saveTimer = null;
  function saveProgress(ratio) {
    if (!chapter) return;
    clearTimeout(saveTimer);
    saveTimer = setTimeout(function () {
      var label = $('.chapter-label');
      store.set('mb-last', JSON.stringify({
        path: location.pathname,
        title: (label ? label.textContent + '　' : '') + $('.chapter-head h1').textContent.trim(),
        ratio: ratio,
        at: Date.now()
      }));
    }, 400);
  }

  var last = null;
  try { last = JSON.parse(store.get('mb-last') || 'null'); } catch (e) { last = null; }

  var resume = $('[data-resume]');
  if (resume && last && last.path && last.ratio > 0.01) {
    resume.hidden = false;
    resume.href = last.path;
    resume.textContent = '繼續閱讀：' + last.title.replace(/\s+/g, ' ');
    resume.addEventListener('click', function () {
      try { sessionStorage.setItem('mb-resume', '1'); } catch (e) { /* 忽略 */ }
    });
  }
  if (chapter && !location.hash && last && last.path === location.pathname) {
    var wantResume = false;
    try { wantResume = sessionStorage.getItem('mb-resume') === '1'; sessionStorage.removeItem('mb-resume'); } catch (e) { /* 忽略 */ }
    if (wantResume) {
      window.addEventListener('load', function () {
        var rect = chapter.getBoundingClientRect();
        window.scrollTo(0, (rect.height - window.innerHeight) * last.ratio + window.scrollY + rect.top);
      });
    }
  }

  // ---------- 程式碼複製 ----------
  $$('.listingblock pre').forEach(function (pre) {
    var btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'copy-btn';
    btn.textContent = '複製';
    btn.setAttribute('aria-label', '複製程式碼');
    btn.addEventListener('click', function () {
      var text = pre.innerText.replace(/\n$/, '');
      var done = function () {
        btn.textContent = '已複製';
        setTimeout(function () { btn.textContent = '複製'; }, 1500);
      };
      if (navigator.clipboard) navigator.clipboard.writeText(text).then(done, function () {});
    });
    pre.parentNode.appendChild(btn);
  });

  // ---------- 圖片放大 ----------
  var lightbox = null;
  document.addEventListener('click', function (e) {
    var img = e.target.closest('.imageblock img');
    if (!img || !window.HTMLDialogElement) return;
    if (!lightbox) {
      lightbox = document.createElement('dialog');
      lightbox.className = 'lightbox';
      lightbox.setAttribute('aria-label', '放大檢視圖片');
      lightbox.appendChild(document.createElement('img'));
      lightbox.addEventListener('click', function () { lightbox.close(); });
      body.appendChild(lightbox);
    }
    var big = lightbox.querySelector('img');
    big.src = img.currentSrc || img.src;
    big.alt = img.alt;
    lightbox.showModal();
  });

  // ---------- 全書搜尋 ----------
  var dialog = $('#search');
  var input = $('#search-input');
  var results = $('.search-results');
  var status = $('.search-status');
  var index = null;
  var loading = null;
  var selected = -1;
  var t2s = {};
  var synonyms = [];

  // 逐字轉小寫並轉成簡體，長度不變：繁簡兩種查詢都能比對，比對到的位置也能直接用在原文上
  function norm(s) {
    var out = '';
    for (var i = 0; i < s.length; i++) {
      var c = s[i];
      var lc = c.toLowerCase();
      if (lc.length === 1) c = lc;
      out += t2s[c] || c;
    }
    return out;
  }

  // 查詢詞本身，加上把其中的同義詞換成同組其他詞的變化（例如「助記詞」也找「恢復碼」）
  function expand(term) {
    var alts = [term];
    synonyms.forEach(function (group) {
      group.forEach(function (w) {
        if (term.indexOf(w) < 0) return;
        group.forEach(function (other) {
          var alt = term.split(w).join(other);
          if (alts.indexOf(alt) < 0) alts.push(alt);
        });
      });
    });
    return alts;
  }

  function loadIndex() {
    if (!loading) {
      status.textContent = '正在載入搜尋資料…';
      loading = fetch('/search-index.json').then(function (r) { return r.json(); }).then(function (data) {
        for (var i = 0; i + 1 < data.t2s.length; i += 2) t2s[data.t2s[i]] = data.t2s[i + 1];
        synonyms = data.synonyms.map(function (g) { return g.map(norm); });
        index = data.entries.map(function (e) { return { e: e, t: norm(e.t), x: norm(e.x) }; });
        status.textContent = '';
        runSearch();
      }).catch(function () {
        loading = null;
        status.textContent = '搜尋資料載入失敗，請稍後再試。';
      });
    }
    return loading;
  }

  function openSearch() {
    if (!dialog.showModal) return;
    toggleSettings(false);
    dialog.showModal();
    input.select();
    loadIndex();
  }

  function escapeHtml(s) {
    return s.replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; });
  }

  // text 是原文，normed 是它轉換後的版本（長度相同），在 normed 找到的位置直接標示在原文上
  function highlight(text, normed, words) {
    var marks = [];
    words.forEach(function (w) {
      for (var p = normed.indexOf(w); p >= 0; p = normed.indexOf(w, p + w.length)) marks.push([p, p + w.length]);
    });
    marks.sort(function (a, b) { return a[0] - b[0]; });
    var html = '';
    var at = 0;
    marks.forEach(function (m) {
      if (m[0] < at) return;
      html += escapeHtml(text.slice(at, m[0])) + '<mark>' + escapeHtml(text.slice(m[0], m[1])) + '</mark>';
      at = m[1];
    });
    return html + escapeHtml(text.slice(at));
  }

  function snippet(item, words) {
    var i = -1;
    var len = 0;
    words.forEach(function (w) {
      var p = item.x.indexOf(w);
      if (p >= 0 && (i < 0 || p < i)) { i = p; len = w.length; }
    });
    var start = i < 0 ? 0 : Math.max(0, i - 36);
    var end = i < 0 ? 90 : i + len + 60;
    return {
      pre: start > 0 ? '…' : '',
      text: item.e.x.slice(start, end),
      normed: item.x.slice(start, end),
      post: end < item.x.length ? '…' : ''
    };
  }

  function count(hay, w) {
    var n = 0;
    for (var p = hay.indexOf(w); p >= 0 && n < 20; p = hay.indexOf(w, p + w.length)) n++;
    return n;
  }

  function runSearch() {
    if (!index) return;
    var q = norm(input.value.trim());
    selected = -1;
    if (!q) {
      results.innerHTML = '';
      status.textContent = '';
      return;
    }
    var terms = q.split(/\s+/).filter(Boolean).map(expand);
    var words = [].concat.apply([], terms);
    var hits = [];
    index.forEach(function (item) {
      var score = 0;
      for (var i = 0; i < terms.length; i++) {
        var best = 0;
        terms[i].forEach(function (w) {
          var s = (item.t.indexOf(w) >= 0 ? 20 : 0) + count(item.x, w);
          if (s > best) best = s;
        });
        if (!best) return;
        score += best;
      }
      hits.push({ item: item, score: score });
    });
    hits.sort(function (a, b) { return b.score - a.score; });
    status.textContent = hits.length ? '找到 ' + hits.length + ' 個相關小節' : '沒有找到「' + input.value.trim() + '」，試試其他關鍵字。';
    results.innerHTML = hits.slice(0, 40).map(function (h) {
      var e = h.item.e;
      var s = snippet(h.item, words);
      return '<li><a href="' + e.u + '"><span class="sr-chapter">' + escapeHtml(e.c) + '</span>' +
        '<span class="sr-title">' + highlight(e.t, h.item.t, words) + '</span>' +
        '<span class="sr-snippet">' + s.pre + highlight(s.text, s.normed, words) + s.post + '</span></a></li>';
    }).join('');
  }

  function moveSelection(step) {
    var links = $$('a', results);
    if (!links.length) return;
    selected = (selected + step + links.length) % links.length;
    links.forEach(function (a, i) { a.classList.toggle('is-selected', i === selected); });
    links[selected].scrollIntoView({ block: 'nearest' });
  }

  var searchTimer = null;
  input.addEventListener('input', function () {
    clearTimeout(searchTimer);
    searchTimer = setTimeout(runSearch, 120);
  });
  input.addEventListener('keydown', function (e) {
    if (e.key === 'ArrowDown') { e.preventDefault(); moveSelection(1); }
    else if (e.key === 'ArrowUp') { e.preventDefault(); moveSelection(-1); }
    else if (e.key === 'Enter') {
      e.preventDefault();
      var links = $$('a', results);
      var link = links[selected >= 0 ? selected : 0];
      if (link) location.href = link.href;
    }
  });
  results.addEventListener('click', function (e) {
    if (e.target.closest('a')) dialog.close();
  });
  dialog.addEventListener('click', function (e) {
    if (e.target === dialog) dialog.close();
  });
  $('[data-action="search"]').addEventListener('click', openSearch);

  // ---------- 鍵盤快捷鍵 ----------
  document.addEventListener('keydown', function (e) {
    var el = document.activeElement;
    var typing = el && (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA' || el.isContentEditable);
    if ((e.key === 'k' || e.key === 'K') && (e.metaKey || e.ctrlKey)) {
      e.preventDefault();
      openSearch();
      return;
    }
    if (typing || e.metaKey || e.ctrlKey || e.altKey) return;
    if (e.key === '/') {
      e.preventDefault();
      openSearch();
    } else if (e.key === 'Escape') {
      toggleSettings(false);
      setNav(false);
    } else if (chapter && (e.key === 'ArrowLeft' || e.key === 'ArrowRight') && !e.shiftKey) {
      if (el && el.closest && el.closest('pre, .table-wrap, .stemblock')) return;
      var link = $(e.key === 'ArrowLeft' ? 'link[rel="prev"]' : 'link[rel="next"]');
      if (link) location.href = link.href;
    }
  });

  // ---------- 數學公式（僅含公式的章節會載入 KaTeX） ----------
  if (window.addEventListener && $('.stemblock, .prose')) {
    window.addEventListener('load', function () {
      if (window.renderMathInElement) {
        window.renderMathInElement($('.prose'), {
          delimiters: [{ left: '\\[', right: '\\]', display: true }, { left: '\\(', right: '\\)', display: false }],
          throwOnError: false
        });
      }
    });
  }
})();
