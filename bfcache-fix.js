/**
 * Fix for browser back/forward cache issues
 *
 * IMPORTANT : on ne fait plus de window.location.reload() ici.
 * Un reload complet détruisait l'iframe SoundCloud du lecteur en haut
 * de la page (qui doit pouvoir continuer à jouer / persister via le
 * bfcache), ce qui cassait son interface au retour arrière.
 *
 * La réinitialisation des éléments du DOM (waveform, navbar, animations
 * de scroll, boutons play génériques) est déjà gérée par script.js via
 * son propre écouteur 'pageshow'. Ce fichier ne fait donc plus rien
 * d'intrusif — il est conservé pour compatibilité si jamais on veut
 * réactiver un comportement spécifique au bfcache plus tard.
 */

(function() {
  window.addEventListener('pageshow', (event) => {
    if (event.persisted) {
      // Page restaurée depuis le bfcache : ne RIEN forcer ici.
      // Le lecteur SoundCloud (iframe) doit rester intact et continuer
      // sa lecture telle qu'elle était avant la navigation.
    }
  });
})();
