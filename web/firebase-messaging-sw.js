importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

// Initialize Firebase in the service worker with the Web project credentials
firebase.initializeApp({
  apiKey: "AIzaSyApoglQ5upsRszr5bp7Gug4ZwGAjW-emMU",
  authDomain: "code-store001.firebaseapp.com",
  projectId: "code-store001",
  storageBucket: "code-store001.firebasestorage.app",
  messagingSenderId: "377191190351",
  appId: "1:377191190351:web:171f7d5c4bed7c74a1bf3a",
  measurementId: "G-2JSQPZHLMR"
});

const messaging = firebase.messaging();

// Handle background push notifications when app tab is closed or in background
messaging.onBackgroundMessage((payload) => {
  console.log("[firebase-messaging-sw.js] Received background message ", payload);
  const notificationTitle =
    (payload.notification && payload.notification.title) ||
    (payload.data && payload.data.title) ||
    "CodeStore Notification";

  const notificationOptions = {
    body:
      (payload.notification && payload.notification.body) ||
      (payload.data && payload.data.body) ||
      "",
    icon: "/icons/Icon-192.png",
    data: payload.data,
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
