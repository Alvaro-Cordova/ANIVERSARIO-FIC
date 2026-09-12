import { h } from '../utilidades/dom.js';
import {
  obtenerConfiguracionVisual,
} from '../configuracion/tema.js';

/**
 * Cabecera reutilizable.
 *
 * No consulta Supabase ni decide permisos.
 * El módulo que la use puede indicar si hay sesión.
 */
export function renderCabecera(
  root,
  {
    sesionActiva = false,
    rutaCuenta = '../autenticacion/perfil.html',
    rutaLogin = '../autenticacion/iniciar-sesion.html',
    links = [
      { href: '../../index.html', label: 'Inicio' },
      { href: '../informacion/cronograma.html', label: 'Evento' },
      { href: '../informacion/ponentes.html', label: 'Ponentes' },
      { href: '../ponencias/index.html', label: 'Ponencias' },
      { href: '../concursos/index.html', label: 'Concursos' },
    ],
  } = {}
) {
  const settings = obtenerConfiguracionVisual();

  const navLinks = links.map(link =>
    h(
      'a',
      { href: link.href },
      link.label
    )
  );

  const enlaceCuenta = sesionActiva
    ? h(
        'a',
        { href: rutaCuenta },
        'Mi cuenta'
      )
    : h(
        'a',
        {
          href: rutaLogin,
          class: 'btn btn--primary btn--sm',
        },
        'Ingresar'
      );

  const nav = h(
    'nav',
    {
      class: 'nav-links',
      id: 'primaryNav',
      'aria-label': 'Navegación principal',
    },
    [...navLinks, enlaceCuenta]
  );

  const header = h(
    'header',
    { class: 'site-header' },
    [
      h(
        'div',
        {
          class: 'container site-header__bar',
        },
        [
          h(
            'a',
            {
              href: '../../index.html',
              class: 'brand',
            },
            [
              h('img', {
                src: settings.logoUrl,
                alt: settings.siteShortName,
                'data-bind-src': 'logoUrl',
              }),
              h(
                'span',
                {
                  class: 'brand__name',
                  'data-bind': 'siteShortName',
                },
                settings.siteShortName
              ),
            ]
          ),

          nav,

          h(
            'button',
            {
              class: 'btn btn--ghost btn--sm nav-toggle',
              'aria-label': 'Abrir menú',
              'aria-expanded': 'false',

              onClick: event => {
                const abierto =
                  nav.classList.toggle('is-open');

                event.currentTarget.setAttribute(
                  'aria-expanded',
                  String(abierto)
                );
              },
            },
            '☰'
          ),
        ]
      ),
    ]
  );

  root.prepend(header);

  return header;
}
