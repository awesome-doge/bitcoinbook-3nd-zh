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
    var scrolled = false;   // 載入時那一次計算不存進度，否則一打開章節就把上次的位置蓋成 0
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
        if (scrolled || total <= 0) saveProgress(ratio);   // 一個畫面就放得下的頁面直接算讀完
      });
    };
    window.addEventListener('scroll', function () { scrolled = true; onScroll(); }, { passive: true });
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
  // mb-progress 以章節路徑為鍵：r 上次位置、m 讀到最遠處（皆為 0–1 的比例）、s 當時所在小節、t 章名、at 時間
  var DONE = 0.97;
  var pathKey = function (p) { return p.replace(/\.html$/, ''); };

  function loadProgress() {
    var p = null;
    try { p = JSON.parse(store.get('mb-progress') || 'null'); } catch (e) { p = null; }
    if (p && typeof p === 'object') return p;
    p = {};
    try {
      var old = JSON.parse(store.get('mb-last') || 'null');   // 舊版只記最後一章
      if (old && old.path) p[pathKey(old.path)] = { r: old.ratio, m: old.ratio, t: old.title, at: old.at || 0 };
    } catch (e) { /* 忽略 */ }
    return p;
  }

  function currentSection() {
    var hs = $$('.prose .sect2 > h2');
    var cur = null;
    for (var i = 0; i < hs.length; i++) {
      if (hs[i].getBoundingClientRect().top < window.innerHeight * 0.3) cur = hs[i];
      else break;
    }
    return cur ? cur.textContent.trim() : '';
  }

  var progress = loadProgress();
  var here = chapter ? progress[pathKey(location.pathname)] : null;   // 打開本頁之前的紀錄
  var holdSave = false;   // 「回到上次位置」提示還在時先不存，免得還沒決定就蓋掉上次的位置
  var saveTimer = null;

  function saveProgress(ratio) {
    if (!chapter || holdSave) return;
    clearTimeout(saveTimer);
    saveTimer = setTimeout(function () {
      var label = $('.chapter-label');
      var key = pathKey(location.pathname);
      progress = loadProgress();   // 其他分頁可能也寫過
      var prev = progress[key] || {};
      progress[key] = {
        r: ratio,
        m: Math.max(prev.m || 0, ratio),
        s: currentSection(),
        t: (label ? label.textContent + '　' : '') + $('.chapter-head h1').textContent.trim(),
        at: Date.now()
      };
      store.set('mb-progress', JSON.stringify(progress));
    }, 400);
  }

  // 等公式排版完（KaTeX 在 load 時渲染，setTimeout 讓它排在所有 load 處理之後）再依比例捲動
  function resumeTo(ratio) {
    var go = function () {
      setTimeout(function () {
        var rect = chapter.getBoundingClientRect();
        window.scrollTo(0, (rect.height - window.innerHeight) * ratio + window.scrollY + rect.top);
      }, 0);
    };
    if (document.readyState === 'complete') go(); else window.addEventListener('load', go);
  }

  // 首頁：「繼續閱讀」指向最近讀的一章；那章已讀完就改指下一章
  var resume = $('[data-resume]');
  var cards = $$('.toc-cards a');
  if (resume) {
    var lastKey = null;
    Object.keys(progress).forEach(function (k) {
      if (progress[k].r > 0.01 && (!lastKey || progress[k].at > progress[lastKey].at)) lastKey = k;
    });
    if (lastKey) {
      var last = progress[lastKey];
      var href = lastKey + '.html';
      var title = last.t;
      var finished = last.r >= DONE;
      if (finished) {
        var idx = cards.map(function (a) { return pathKey(a.getAttribute('href')); }).indexOf(lastKey);
        var next = cards[idx + 1];
        if (idx < 0 || !next) href = null;
        else {
          href = next.getAttribute('href');
          title = $('.card-label', next).textContent + '　' + $('.card-title', next).textContent;
        }
      }
      if (href) {
        resume.hidden = false;
        resume.href = href;
        resume.textContent = '繼續閱讀：' + String(title || '').replace(/\s+/g, ' ');
        if (!finished) {
          resume.addEventListener('click', function () {
            try { sessionStorage.setItem('mb-resume', '1'); } catch (e) { /* 忽略 */ }
          });
        }
      }
    }
  }

  // 首頁目錄卡片：顯示各章讀到哪裡
  cards.forEach(function (a) {
    var p = progress[pathKey(a.getAttribute('href'))];
    if (!p || !(p.m > 0.01)) return;
    var pct = Math.round(p.m * 100);
    var done = p.m >= DONE;
    var el = document.createElement('span');
    el.className = 'card-progress' + (done ? ' is-done' : '');
    el.innerHTML = '<span class="card-bar"><span style="width:' + (done ? 100 : pct) + '%"></span></span>' +
      '<span class="card-pct">' + (done ? '已讀完' : '已讀 ' + pct + '%') + '</span>';
    a.appendChild(el);
  });

  // 章節頁：讀過但沒讀完時，提供「回到上次位置」；首頁按鈕的旗標每次都要用掉，免得留到下一章
  var wantResume = false;
  if (chapter) {
    try { wantResume = sessionStorage.getItem('mb-resume') === '1'; sessionStorage.removeItem('mb-resume'); } catch (e) { /* 忽略 */ }
  }
  if (chapter && !location.hash && here && here.r > 0.03 && here.r < DONE) {
    if (wantResume) {
      resumeTo(here.r);
    } else {
      holdSave = true;
      var toast = document.createElement('div');
      toast.className = 'resume-toast';
      toast.setAttribute('role', 'status');
      toast.innerHTML = '<p class="resume-text"></p>' +
        '<button type="button" class="resume-go">回到上次位置</button>' +
        '<button type="button" class="resume-close" aria-label="從頭閱讀">從頭讀</button>';
      $('.resume-text', toast).textContent = here.s ?
        '上次讀到「' + here.s + '」（約 ' + Math.round(here.r * 100) + '%）' :
        '上次讀到本章約 ' + Math.round(here.r * 100) + '% 處';
      body.appendChild(toast);
      var closeToast = function () {
        holdSave = false;
        window.removeEventListener('scroll', onFarScroll);
        toast.remove();
      };
      // 往下讀超過一個半畫面，就當作選擇從頭讀
      var onFarScroll = function () { if (window.scrollY > window.innerHeight * 1.5) closeToast(); };
      window.addEventListener('scroll', onFarScroll, { passive: true });
      $('.resume-go', toast).addEventListener('click', function () { closeToast(); resumeTo(here.r); });
      $('.resume-close', toast).addEventListener('click', closeToast);
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
    pre.closest('.listingblock').appendChild(btn);
  });

  // ---------- 圖片放大 ----------
  // 點圖片在「符合畫面」與「放大」之間切換（放大後可捲動），點圖片以外或關閉鈕離開
  var lightbox = null;
  function setZoom(big, zoom, e) {
    if (!zoom) {
      lightbox.classList.remove('is-zoomed');
      big.style.width = '';
      return;
    }
    var fit = big.getBoundingClientRect();
    var fx = e ? (e.clientX - fit.left) / fit.width : 0.5;
    var fy = e ? (e.clientY - fit.top) / fit.height : 0.5;
    var w = Math.max(big.naturalWidth, fit.width * 2);
    lightbox.classList.add('is-zoomed');
    big.style.width = w + 'px';
    // 讓點下去的位置維持在畫面中央附近
    lightbox.scrollLeft = w * fx - lightbox.clientWidth / 2;
    lightbox.scrollTop = big.offsetHeight * fy - lightbox.clientHeight / 2;
  }
  document.addEventListener('click', function (e) {
    var img = e.target.closest('.imageblock img');
    if (!img || !window.HTMLDialogElement) return;
    if (!lightbox) {
      lightbox = document.createElement('dialog');
      lightbox.className = 'lightbox';
      lightbox.setAttribute('aria-label', '放大檢視圖片');
      lightbox.innerHTML = '<img alt=""><button type="button" class="lightbox-close" aria-label="關閉">✕</button>';
      lightbox.addEventListener('click', function (ev) {
        var big = $('img', lightbox);
        if (ev.target === big) setZoom(big, !lightbox.classList.contains('is-zoomed'), ev);
        else lightbox.close();
      });
      lightbox.addEventListener('close', function () { setZoom($('img', lightbox), false); });
      body.appendChild(lightbox);
    }
    var big = $('img', lightbox);
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
