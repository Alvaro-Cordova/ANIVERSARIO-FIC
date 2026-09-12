import { h } from '../utilidades/dom.js';
import {
  obtenerConfiguracionVisual,
} from '../configuracion/tema.js';

export function renderPiePagina(root) {
  const settings = obtenerConfiguracionVisual();
  const year = new Date().getFullYear();

  const footer = h(
    'footer',
    { class: 'site-footer' },
    [
      h(
        'div',
        {
          class: 'container footer-grid',
        },
        [
          h(
            'div',
            { class: 'stack' },
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
                    style: 'height:40px',
                    'data-bind-src': 'logoUrl',
                  }),
                ]
              ),

              h('p', {}, settings.tagline),

              h(
                'p',
                {},
                `${settings.faculty} — ${settings.university}`
              ),
            ]
          ),

          h(
            'div',
            { class: 'stack' },
            [
              h('h4', {}, 'Navegación'),
              h(
                'a',
                {
                  href: '../informacion/cronograma.html',
                },
                'El evento'
              ),
              h(
                'a',
                {
                  href: '../informacion/ponentes.html',
                },
                'Ponentes'
              ),
              h(
                'a',
                {
                  href: '../ponencias/index.html',
                },
                'Ponencias'
              ),
              h(
                'a',
                {
                  href: '../concursos/index.html',
                },
                'Concursos'
              ),
            ]
          ),

          h(
            'div',
            { class: 'stack' },
            [
              h('h4', {}, 'Participantes'),
              h(
                'a',
                {
                  href: '../autenticacion/iniciar-sesion.html',
                },
                'Ingresar'
              ),
              h(
                'a',
                {
                  href: '../autenticacion/registro.html',
                },
                'Crear cuenta'
              ),
              h(
                'a',
                {
                  href: '../certificados/verificar.html',
                },
                'Validar certificado'
              ),
            ]
          ),

          h(
            'div',
            { class: 'stack' },
            [
              h('h4', {}, 'Contacto'),
              h(
                'a',
                {
                  href: `mailto:${settings.contactEmail}`,
                },
                settings.contactEmail
              ),
              h('span', {}, settings.eventVenue),
            ]
          ),
        ]
      ),

      h(
        'div',
        {
          class: 'container footer-bottom',
        },
        `© ${year} ${settings.faculty} · ${settings.university}. Precongreso CONEIC Huancayo 2027.`
      ),
    ]
  );

  root.appendChild(footer);

  return footer;
}
