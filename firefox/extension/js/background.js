// Sonder Startpage — Background Script
// Seamlessly redirects about:privatebrowsing to Sonder startpage in private windows

(() => {
  'use strict';

  function redirectToSonder(tabId) {
    const targetUrl = browser.runtime.getURL('newtab.html');
    browser.tabs.update(tabId, { url: targetUrl }).catch(() => {
      // Tab was closed or already redirected
    });
  }

  // Intercept new tab creation in private windows
  browser.tabs.onCreated.addListener((tab) => {
    if (tab.incognito && tab.url === 'about:privatebrowsing') {
      redirectToSonder(tab.id);
    }
  });

  // Intercept tab navigation to about:privatebrowsing
  browser.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
    if (tab.incognito && (changeInfo.url === 'about:privatebrowsing' || tab.url === 'about:privatebrowsing')) {
      redirectToSonder(tabId);
    }
  });
})();
