/* X46 LIMS — shared table column settings.
   Detects the page's main list grid (header row + data rows sharing one
   grid-template-columns), and exposes a Settings drawer that hides/reorders
   its columns for real. Preferences persist per page in localStorage. */
(function () {
  if (window.__x46TableSettings) return;
  window.__x46TableSettings = true;

  var KEY = 'x46-table-settings:' + location.pathname.split('/').pop();
  var state = load();
  var table = null;      // { tracks:[], rows:[], labels:[] }
  var prefs = null;      // { order:[i], hidden:{i:true} }
  var drawer, list, btn, applying = false;

  function load() { try { return JSON.parse(localStorage.getItem(KEY)) || {}; } catch (e) { return {}; } }
  function save() { try { localStorage.setItem(KEY, JSON.stringify(state)); } catch (e) {} }

  function splitTracks(v) {
    var out = [], depth = 0, cur = '';
    for (var i = 0; i < v.length; i++) {
      var c = v[i];
      if (c === '(') depth++;
      if (c === ')') depth--;
      if (/\s/.test(c) && depth === 0) { if (cur) { out.push(cur); cur = ''; } }
      else cur += c;
    }
    if (cur) out.push(cur);
    return out;
  }

  function cells(el) {
    return Array.prototype.filter.call(el.children, function (c) { return c.nodeType === 1; });
  }

  function detect() {
    var groups = {};
    var all = document.querySelectorAll('[style*="grid-template-columns"]');
    Array.prototype.forEach.call(all, function (el) {
      var tpl = el.style.gridTemplateColumns;
      if (!tpl) return;
      var tracks = splitTracks(tpl);
      if (tracks.length < 4) return;
      if (cells(el).length < tracks.length - 2) return;
      (groups[tpl] = groups[tpl] || []).push(el);
    });
    var best = null;
    Object.keys(groups).forEach(function (tpl) {
      var g = groups[tpl];
      if (g.length < 2) return;
      var sticky = /sticky/.test(g[0].getAttribute('style') || '');
      var score = g.length + (sticky ? 100 : 0);
      if (!best || score > best.score) best = { score: score, tpl: tpl, els: g };
    });
    var tbl = detectNativeTable();
    if (!best && !tbl) return null;
    if (tbl && (!best || best.score < tbl.score)) return tbl;
    var nTracks = splitTracks(best.tpl).length;
    var head = best.els.filter(function (e) { return /sticky/.test(e.getAttribute('style') || ''); })[0]
      || best.els.filter(function (e) { return cells(e).length === nTracks; })[0]
      || best.els[0];
    var labels = cells(head).map(function (c, i) {
      var t = (c.textContent || '').trim().replace(/\s+/g, ' ');
      return t ? t.slice(0, 28) : 'Column ' + (i + 1);
    });
    while (labels.length < nTracks) labels.push('Column ' + (labels.length + 1));
    return { kind: 'grid', tpl: best.tpl, tracks: splitTracks(best.tpl), els: best.els, labels: labels };
  }

  function detectNativeTable() {
    var best = null;
    var tables = document.querySelectorAll('table');
    Array.prototype.forEach.call(tables, function (t, i) {
      var ths = t.querySelectorAll('thead tr:last-child > th, thead tr:last-child > td');
      var bodyRows = t.querySelectorAll('tbody tr');
      if (ths.length < 3 || bodyRows.length < 1) return;
      var score = bodyRows.length + 1;
      if (!best || score > best.score) best = { index: i, score: score, ths: ths, count: ths.length };
    });
    if (!best) return null;
    var labels = Array.prototype.map.call(best.ths, function (c, i) {
      var t = (c.textContent || '').trim().replace(/\s+/g, ' ');
      return t ? t.slice(0, 28) : 'Column ' + (i + 1);
    });
    return { kind: 'table', tableIndex: best.index, tracks: new Array(best.count).fill(''), labels: labels };
  }

  function applyNativeTable() {
    var t = document.querySelectorAll('table')[table.tableIndex];
    if (!t) return;
    var anyHidden = Object.keys(prefs.hidden).length > 0;
    if (t.style.minWidth || t.__x46minw != null) {
      if (t.__x46minw == null) t.__x46minw = t.style.minWidth;
      t.style.minWidth = anyHidden ? 'auto' : t.__x46minw;
    }
    var rows = t.querySelectorAll('tr');
    Array.prototype.forEach.call(rows, function (r) {
      var cs = cells(r);
      if (cs.length !== table.tracks.length) return;
      cs.forEach(function (c, i) { c.style.display = prefs.hidden[i] ? 'none' : ''; });
    });
  }

  function defaults(n) {
    var o = []; for (var i = 0; i < n; i++) o.push(i);
    return { order: o, hidden: {} };
  }

  function apply() {
    if (!table) return;
    applying = true;
    if (table.kind === 'table') {
      applyNativeTable();
      requestAnimationFrame(function () { applying = false; });
      return;
    }
    var visible = prefs.order.filter(function (i) { return !prefs.hidden[i]; });
    var vt = visible.map(function (i) { return table.tracks[i]; });
    if (vt.length && !vt.some(function (t) { return /fr\b|fr\)/.test(t); })) {
      var last = vt[vt.length - 1];
      vt[vt.length - 1] = /^\d/.test(last) ? 'minmax(' + last + ', 1fr)' : last;
    }
    var tpl = vt.join(' ');
    document.querySelectorAll('[style*="grid-template-columns"]').forEach(function (el) {
      if (el.__x46tpl !== table.tpl && el.style.gridTemplateColumns !== table.tpl && el.__x46tpl == null) return;
      var cs = cells(el);
      if (cs.length !== table.tracks.length) return;
      el.__x46tpl = table.tpl;
      el.style.gridTemplateColumns = tpl;
      var wrap = el.parentElement;
      if (wrap && wrap.style.minWidth) {
        if (wrap.__x46minw == null) wrap.__x46minw = wrap.style.minWidth;
        wrap.style.minWidth = visible.length < table.tracks.length ? 'auto' : wrap.__x46minw;
      } else if (wrap && wrap.__x46minw != null && visible.length === table.tracks.length) {
        wrap.style.minWidth = wrap.__x46minw;
      }
      prefs.order.forEach(function (idx, pos) {
        var c = cs[idx];
        if (!c) return;
        c.style.order = String(pos);
        c.style.display = prefs.hidden[idx] ? 'none' : '';
      });
    });
    requestAnimationFrame(function () { applying = false; });
  }

  function css() {
    var s = document.createElement('style');
    s.textContent = [
      '.x46ts-btn{display:inline-flex;align-items:center;gap:6px;padding:5px 10px;background:#fff;color:var(--color-text-secondary,#5a6675);',
      'border:1px solid var(--color-border-base,#dfe3e9);border-radius:4px;font:600 11.5px/1 inherit;cursor:pointer;margin-left:auto;flex-shrink:0;align-self:center;}',
      '.x46ts-btn.x46ts-float{position:fixed;right:18px;bottom:18px;z-index:9998;padding:9px 14px;border-radius:999px;font-size:12px;box-shadow:0 3px 12px rgba(16,24,40,.14);margin:0;}',
      '.x46ts-btn:hover{border-color:var(--color-primary-bright,#0099FF);color:var(--color-primary-deep,#0052A3);}',
      '.x46ts-mask{position:fixed;inset:0;background:rgba(16,24,40,.28);z-index:9998;opacity:0;pointer-events:none;transition:opacity .18s;}',
      '.x46ts-mask.open{opacity:1;pointer-events:auto;}',
      '.x46ts-panel{position:fixed;top:0;right:0;bottom:0;width:328px;max-width:88vw;background:#fff;z-index:9999;',
      'display:flex;flex-direction:column;box-shadow:-8px 0 28px rgba(16,24,40,.18);transform:translateX(102%);transition:transform .2s ease;}',
      '.x46ts-panel.open{transform:none;}',
      '.x46ts-hd{padding:14px 16px;border-bottom:1px solid var(--color-border-light,#eaedf1);display:flex;align-items:flex-start;justify-content:space-between;gap:12px;}',
      '.x46ts-hd h3{margin:0;font-size:13.5px;font-weight:700;color:var(--color-text-primary,#1b2430);}',
      '.x46ts-hd p{margin:3px 0 0;font-size:11.5px;color:var(--color-text-secondary,#5a6675);}',
      '.x46ts-x{background:none;border:none;font-size:17px;line-height:1;color:var(--color-text-tertiary,#8b95a3);cursor:pointer;padding:0 2px;}',
      '.x46ts-sec{padding:11px 16px 6px;font-size:10px;font-weight:700;letter-spacing:.06em;text-transform:uppercase;color:var(--color-text-tertiary,#8b95a3);}',
      '.x46ts-list{flex:1;overflow-y:auto;}',
      '.x46ts-row{display:flex;align-items:center;gap:10px;padding:9px 16px;border-bottom:1px solid var(--color-border-light,#eaedf1);font-size:12.5px;}',
      '.x46ts-row input{width:14px;height:14px;accent-color:var(--color-primary-deep,#0052A3);cursor:pointer;}',
      '.x46ts-row span{flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:var(--color-text-primary,#1b2430);}',
      '.x46ts-mv{width:24px;height:24px;border:1px solid var(--color-border-base,#dfe3e9);background:#fff;border-radius:4px;',
      'color:var(--color-text-secondary,#5a6675);font-size:10px;cursor:pointer;line-height:1;}',
      '.x46ts-mv:hover:not(:disabled){border-color:var(--color-primary-bright,#0099FF);color:var(--color-primary-deep,#0052A3);}',
      '.x46ts-mv:disabled{opacity:.35;cursor:default;}',
      '.x46ts-ft{padding:12px 16px;border-top:1px solid var(--color-border-light,#eaedf1);display:flex;gap:8px;justify-content:space-between;}',
      '.x46ts-ft button{padding:7px 13px;border-radius:4px;font:600 12px/1 inherit;cursor:pointer;}',
      '.x46ts-reset{background:#fff;border:1px solid var(--color-border-base,#dfe3e9);color:var(--color-text-secondary,#5a6675);}',
      '.x46ts-done{background:var(--color-primary-deep,#0052A3);border:none;color:#fff;}'
    ].join('');
    document.head.appendChild(s);
  }

  function render() {
    var sub = drawer.querySelector('.x46ts-hd p');
    if (sub) sub.textContent = table.kind === 'table'
      ? 'Choose which columns appear on this list.'
      : 'Choose which columns appear on this list and in what order.';
    list.innerHTML = '';
    var shown = prefs.order.filter(function (i) { return !prefs.hidden[i]; }).length;
    prefs.order.forEach(function (idx, pos) {
      var row = document.createElement('div');
      row.className = 'x46ts-row';
      var cb = document.createElement('input');
      cb.type = 'checkbox';
      cb.checked = !prefs.hidden[idx];
      if (cb.checked) cb.setAttribute('checked', '');
      cb.disabled = !prefs.hidden[idx] && shown <= 1;
      cb.onchange = function () {
        if (cb.checked) delete prefs.hidden[idx]; else prefs.hidden[idx] = true;
        commit();
      };
      var label = document.createElement('span');
      label.textContent = table.labels[idx];
      var up = document.createElement('button');
      up.className = 'x46ts-mv'; up.textContent = '▲'; up.title = 'Move up';
      up.disabled = pos === 0 || table.kind === 'table';
      up.onclick = function () { move(pos, -1); };
      var down = document.createElement('button');
      down.className = 'x46ts-mv'; down.textContent = '▼'; down.title = 'Move down';
      down.disabled = pos === prefs.order.length - 1 || table.kind === 'table';
      down.onclick = function () { move(pos, 1); };
      row.appendChild(cb); row.appendChild(label); row.appendChild(up); row.appendChild(down);
      list.appendChild(row);
    });
  }

  function move(pos, dir) {
    var to = pos + dir;
    if (to < 0 || to >= prefs.order.length) return;
    var o = prefs.order.slice();
    var t = o[pos]; o[pos] = o[to]; o[to] = t;
    prefs.order = o;
    commit();
  }

  function commit() { state.prefs = prefs; save(); apply(); render(); }

  function anchorEl() {
    var el = table.kind === 'table' ? document.querySelectorAll('table')[table.tableIndex] : table.els[0];
    if (!el) return null;
    var scroller = el;
    for (var i = 0; i < 5 && scroller.parentElement; i++) {
      var st = scroller.getAttribute('style') || '';
      if (/overflow/.test(st)) break;
      scroller = scroller.parentElement;
    }
    var prev = scroller.previousElementSibling;
    while (prev) {
      if (prev.offsetHeight > 0 && prev.offsetHeight < 70 && prev.childElementCount <= 6 && !prev.querySelector('table') && !/grid-template-columns/.test(prev.getAttribute('style') || '')) return prev;
      prev = prev.previousElementSibling;
    }
    return null;
  }

  function mount() {
    var a = anchorEl();
    if (a && btn.parentElement === a) return;
    if (a) {
      btn.classList.remove('x46ts-float');
      var cs2 = getComputedStyle(a);
      var isFlex = cs2.display.indexOf('flex') >= 0;
      btn.style.cssFloat = isFlex ? '' : 'right';
      btn.style.marginLeft = isFlex && cs2.justifyContent === 'space-between' ? '0' : '';
      btn.style.marginTop = isFlex ? '' : '-4px';
      if (btn.parentElement !== a) a.appendChild(btn);
    } else {
      btn.classList.add('x46ts-float');
      if (btn.parentElement !== document.body) document.body.appendChild(btn);
    }
  }

  function build() {
    css();
    btn = document.createElement('button');
    btn.className = 'x46ts-btn';
    btn.innerHTML = '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.6 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.6a1.65 1.65 0 0 0 1-1.51V3a2 2 0 1 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9c.14.63.68 1.09 1.32 1.1H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg><span>Settings</span>';
    btn.onclick = open;
    mount();

    var mask = document.createElement('div');
    mask.className = 'x46ts-mask';
    mask.onclick = close;
    document.body.appendChild(mask);

    drawer = document.createElement('aside');
    drawer.className = 'x46ts-panel';
    drawer.innerHTML =
      '<div class="x46ts-hd"><div><h3>Table Settings</h3><p>Choose which columns appear on this list and in what order.</p></div>' +
      '<button class="x46ts-x" title="Close">✕</button></div>' +
      '<div class="x46ts-sec">Columns</div><div class="x46ts-list"></div>' +
      '<div class="x46ts-ft"><button class="x46ts-reset">Reset</button><button class="x46ts-done">Done</button></div>';
    document.body.appendChild(drawer);
    list = drawer.querySelector('.x46ts-list');
    drawer.querySelector('.x46ts-x').onclick = close;
    drawer.querySelector('.x46ts-done').onclick = close;
    drawer.querySelector('.x46ts-reset').onclick = function () {
      prefs = defaults(table.tracks.length); commit();
    };
    drawer.__mask = mask;

    function open() { render(); mask.classList.add('open'); drawer.classList.add('open'); }
    function close() { mask.classList.remove('open'); drawer.classList.remove('open'); }
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape') close(); });
  }

  function hasNativeColumnControl() {
    var els = document.querySelectorAll('button, [role="button"], summary, a');
    for (var i = 0; i < els.length; i++) {
      var t = (els[i].textContent || '').trim();
      if (/^columns\b/i.test(t) && t.length < 24) return true;
    }
    return false;
  }

  function start() {
    if (hasNativeColumnControl()) return true;
    var found = detect();
    if (!found) return false;
    table = found;
    var saved = state.prefs;
    if (saved && Array.isArray(saved.order) && saved.order.length === table.tracks.length) prefs = saved;
    else prefs = defaults(table.tracks.length);
    if (!btn) build(); else mount();
    apply();
    return true;
  }

  function watch() {
    var pending = false;
    new MutationObserver(function () {
      if (applying || pending) return;
      pending = true;
      requestAnimationFrame(function () {
        pending = false;
        if (table) { if (btn) mount(); apply(); }
        else start();
      });
    }).observe(document.body, { childList: true, subtree: true, attributes: true, attributeFilter: ['style'] });
  }

  function boot() {
    var tries = 0;
    (function attempt() {
      if (!start() && tries++ < 40) return setTimeout(attempt, 150);
      watch();
    })();
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', boot);
  else boot();
})();
