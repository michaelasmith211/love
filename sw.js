const CACHE_NAME = 'lovecalc-v3.0';
const ASSETS_TO_CACHE = [
  './',
  './index.html',
  './name-compatibility.html',
  './zodiac-compatibility.html',
  './birthday-compatibility.html',
  './flames-game.html',
  './love-percentage-chart.html',
  './science-of-love.html',
  './methodology.html',
  './faq.html',
  './widget.html',
  './about.html',
  './contact.html',
  './editorial-policy.html',
  './disclaimer.html',
  './sitemap.html',
  './privacy-policy.html',
  './terms.html',
  './404.html',
  './css/style.css',
  './js/calculator.js',
  './js/particles.js',
  './js/audio.js',
  './js/share-card.js',
  './assets/favicon.svg',
  './manifest.json'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(ASSETS_TO_CACHE);
    })
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))
      );
    })
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  // Stale-while-revalidate strategy for maximum speed and offline support
  event.respondWith(
    caches.match(event.request).then((cachedResponse) => {
      const fetchPromise = fetch(event.request).then((networkResponse) => {
        if (networkResponse && networkResponse.status === 200 && networkResponse.type === 'basic') {
          const responseToCache = networkResponse.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseToCache);
          });
        }
        return networkResponse;
      }).catch(() => cachedResponse);

      return cachedResponse || fetchPromise;
    })
  );
});
