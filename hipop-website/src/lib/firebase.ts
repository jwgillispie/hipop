import { initializeApp, getApps } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getAnalytics } from 'firebase/analytics';

// Firebase config for the website project
const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
  measurementId: process.env.NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID
};

// Firebase config for reading from the main app (hipop-markets)
const mainAppConfig = {
  apiKey: process.env.NEXT_PUBLIC_MAIN_APP_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_MAIN_APP_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_MAIN_APP_FIREBASE_PROJECT_ID,
  storageBucket: process.env.NEXT_PUBLIC_MAIN_APP_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.NEXT_PUBLIC_MAIN_APP_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.NEXT_PUBLIC_MAIN_APP_FIREBASE_APP_ID,
};

// Initialize Firebase for website
const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApps()[0];

// Initialize Firebase for main app data (read-only)
const mainApp = getApps().find(app => app.name === 'main-app') || 
  initializeApp(mainAppConfig, 'main-app');

// Get Firestore instances
export const db = getFirestore(app);
export const mainAppDb = getFirestore(mainApp);

// Analytics (only in browser)
export const analytics = typeof window !== 'undefined' ? getAnalytics(app) : null;

export default app;