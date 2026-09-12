/**
 * configuracion-visual.js
 * ------------------------------------------------------------
 * Configuración visual común para ANIVERSARIO-FIC.
 *
 * Este archivo NO reemplaza servicios/supabase.js.
 * No contiene claves, usuarios ni lógica de negocio.
 * Solo centraliza la identidad visual y los textos comunes.
 */

export const CONFIGURACION_VISUAL = {
  siteName: 'Aniversario FIC · Precongreso CONEIC 2027',
  siteShortName: 'FIC Aniversario',
  tagline: 'Facultad de Ingeniería Civil — UNCP',
  faculty: 'Facultad de Ingeniería Civil',
  university: 'Universidad Nacional del Centro del Perú',
  eventVenue: 'Huancayo, Perú',

  colors: {
    primary: '#6e0f24',
    primaryHover: '#8c1c33',
    secondary: '#c9a227',
    secondaryHover: '#e6c766',
    black: '#0e0e0e',
    bg: '#ffffff',
    bgAlt: '#f7f5f0',
    text: '#0e0e0e',
  },

  logoUrl: '../../recursos/logos/logo-coneic-2027.png',
  heroImageUrl: '../../recursos/imagenes/hero-precongreso.jpg',

  heroEyebrow: 'PRECONGRESO · Rumbo al CONEIC 2027',
  heroTitle: 'Aniversario de la Facultad de Ingeniería Civil',
  heroSubtitle:
    'Una antesala institucional hacia el XXXIV CONEIC Huancayo 2027.',

  contactEmail: 'contacto@ficuncp.edu.pe',

  socials: {
    facebook: '',
    instagram: '',
    tiktok: '',
  },
};
