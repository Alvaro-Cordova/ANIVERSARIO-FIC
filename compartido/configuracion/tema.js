/**
 * tema.js
 * ------------------------------------------------------------
 * Aplica la configuración visual como variables CSS.
 *
 * Se mantiene separado de Supabase para no interferir con
 * la base V3.2.1 del proyecto actual.
 *
 * Más adelante el panel admin puede guardar estos mismos valores
 * en Supabase sin cambiar los módulos visuales.
 */

import { CONFIGURACION_VISUAL } from './configuracion-visual.js';

const CLAVE_LOCAL = 'aniversario_fic_tema_v1';

export function obtenerConfiguracionVisual() {
  try {
    const guardado = JSON.parse(localStorage.getItem(CLAVE_LOCAL) || 'null');

    if (!guardado) {
      return structuredClone(CONFIGURACION_VISUAL);
    }

    return {
      ...structuredClone(CONFIGURACION_VISUAL),
      ...guardado,
      colors: {
        ...CONFIGURACION_VISUAL.colors,
        ...(guardado.colors || {}),
      },
      socials: {
        ...CONFIGURACION_VISUAL.socials,
        ...(guardado.socials || {}),
      },
    };
  } catch {
    return structuredClone(CONFIGURACION_VISUAL);
  }
}

export function guardarConfiguracionVisual(parcial = {}) {
  const actual = obtenerConfiguracionVisual();

  const nueva = {
    ...actual,
    ...parcial,
    colors: {
      ...actual.colors,
      ...(parcial.colors || {}),
    },
    socials: {
      ...actual.socials,
      ...(parcial.socials || {}),
    },
  };

  localStorage.setItem(
    CLAVE_LOCAL,
    JSON.stringify(nueva)
  );

  aplicarTema(nueva);

  return nueva;
}

export function restablecerConfiguracionVisual() {
  localStorage.removeItem(CLAVE_LOCAL);
  const original = structuredClone(CONFIGURACION_VISUAL);
  aplicarTema(original);
  return original;
}

export function aplicarTema(config = obtenerConfiguracionVisual()) {
  const root = document.documentElement;
  const c = config.colors || {};

  const mapa = {
    '--color-primary': c.primary,
    '--color-primary-hover': c.primaryHover,
    '--color-secondary': c.secondary,
    '--color-secondary-hover': c.secondaryHover,
    '--color-black': c.black,
    '--color-bg': c.bg,
    '--color-bg-alt': c.bgAlt,
    '--color-text': c.text,
  };

  for (const [propiedad, valor] of Object.entries(mapa)) {
    if (valor) {
      root.style.setProperty(propiedad, valor);
    }
  }

  if (config.logoUrl) {
    root.style.setProperty(
      '--img-logo',
      `url('${config.logoUrl}')`
    );
  }

  if (config.heroImageUrl) {
    root.style.setProperty(
      '--img-hero',
      `url('${config.heroImageUrl}')`
    );
  }

  document.title =
    config.siteName || CONFIGURACION_VISUAL.siteName;

  let themeColor =
    document.querySelector('meta[name="theme-color"]');

  if (!themeColor) {
    themeColor = document.createElement('meta');
    themeColor.name = 'theme-color';
    document.head.appendChild(themeColor);
  }

  themeColor.content =
    c.primary || CONFIGURACION_VISUAL.colors.primary;

  document
    .querySelectorAll('[data-bind="siteName"]')
    .forEach(el => {
      el.textContent = config.siteName;
    });

  document
    .querySelectorAll('[data-bind="siteShortName"]')
    .forEach(el => {
      el.textContent = config.siteShortName;
    });

  document
    .querySelectorAll('[data-bind-src="logoUrl"]')
    .forEach(el => {
      el.src = config.logoUrl;
    });

  return config;
}

export function activarTemaOscuro(activo = true) {
  document.documentElement.toggleAttribute(
    'data-theme',
    activo
  );

  if (activo) {
    document.documentElement.setAttribute(
      'data-theme',
      'dark'
    );
  } else {
    document.documentElement.removeAttribute(
      'data-theme'
    );
  }
}
