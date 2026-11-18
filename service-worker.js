const CACHE_NAME = "smartlib-static-v7";
const CORE_ASSETS = [
  "./",
  "./index.html",
  "./styles.css?v=vertical-layout-1",
  "./app.js",
  "./manifest.json",
  "./assets/smartlib-icon.svg",
  "./js/admin.js",
  "./js/ai.js",
  "./js/auth.js",
  "./js/card-scan.js",
  "./js/catalog-data.js",
  "./js/catalog.js",
  "./js/community.js?v=vertical-layout-1",
  "./js/config.js",
  "./js/loans.js",
  "./js/reading.js",
  "./js/rooms.js",
  "./js/reader.js",
  "./js/shell.js",
  "./js/store.js"
];

self.addEventListener("install", event => {
  event.waitUntil(caches.open(CACHE_NAME).then(cache => cache.addAll(CORE_ASSETS)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", event => {
  event.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(key => key !== CACHE_NAME).map(key => caches.delete(key)))).then(() => self.clients.claim()));
});

self.addEventListener("fetch", event => {
  const request = event.request;
  if (request.method !== "GET" || new URL(request.url).origin !== self.location.origin) return;
  event.respondWith(caches.match(request).then(cached => cached || fetch(request).then(response => {
    if (response.ok && new URL(request.url).pathname.includes("/js/")) {
      const copy = response.clone();
      caches.open(CACHE_NAME).then(cache => cache.put(request, copy));
    }
    return response;
  })));
});
