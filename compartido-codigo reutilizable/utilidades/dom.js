/** utils/dom.js — helpers de DOM mínimos, sin dependencias */
export function h(tag, attrs = {}, children = []) {
  const el = document.createElement(tag);
  for (const [k, v] of Object.entries(attrs || {})) {
    if (k === 'class') el.className = v;
    else if (k === 'html') el.innerHTML = v;
    else if (k.startsWith('on') && typeof v === 'function') el.addEventListener(k.slice(2).toLowerCase(), v);
    else if (v !== false && v != null) el.setAttribute(k, v);
  }
  for (const child of [].concat(children)) {
    if (child == null) continue;
    el.appendChild(typeof child === 'string' ? document.createTextNode(child) : child);
  }
  return el;
}
export function qs(sel, ctx = document) { return ctx.querySelector(sel); }
export function qsa(sel, ctx = document) { return [...ctx.querySelectorAll(sel)]; }

export function showToast(message, type = 'info') {
  let region = qs('.toast-region');
  if (!region) {
    region = h('div', { class: 'toast-region', 'aria-live': 'polite' });
    document.body.appendChild(region);
  }
  const toast = h('div', { class: `toast toast--${type}` }, message);
  region.appendChild(toast);
  setTimeout(() => toast.remove(), 4200);
}
