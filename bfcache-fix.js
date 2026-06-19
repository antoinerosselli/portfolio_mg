/**
 * Fix for browser back/forward cache issues
 * Force reload when returning to the page
 */

(function() {
  // Listen for page visibility changes
  window.addEventListener('pageshow', (event) => {
    // If the page was restored from bfcache (browser back)
    if (event.persisted) {
      // Force reload to re-execute all scripts
      window.location.reload();
    }
  });

  // Alternative: Disable bfcache by unloading
  window.addEventListener('pagehide', () => {
    // This helps ensure a fresh reload
  });
})();
