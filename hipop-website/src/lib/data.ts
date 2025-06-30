import { collection, getDocs, query, where, orderBy, limit } from 'firebase/firestore';
import { mainAppDb } from './firebase';

export interface Market {
  id: string;
  name: string;
  address: string;
  city: string;
  state: string;
  description?: string;
  operatingDays: string[];
  operatingHours: { [key: string]: string };
  isActive: boolean;
  isPublic?: boolean;
}

export interface Vendor {
  id: string;
  businessName: string;
  description?: string;
  categories: string[];
  isActive: boolean;
  isFeatured?: boolean;
  marketId?: string;
}

// Fetch public markets for website display
export async function getPublicMarkets(): Promise<Market[]> {
  try {
    const q = query(
      collection(mainAppDb, 'markets'),
      where('isActive', '==', true),
      // Only get markets that are marked as public or don't have isPublic field (default public)
      orderBy('name')
    );
    
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Market));
  } catch (error) {
    console.error('Error fetching public markets:', error);
    return [];
  }
}

// Fetch markets by city for SEO pages
export async function getMarketsByCity(city: string): Promise<Market[]> {
  try {
    const q = query(
      collection(mainAppDb, 'markets'),
      where('isActive', '==', true),
      where('city', '==', city),
      orderBy('name')
    );
    
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Market));
  } catch (error) {
    console.error('Error fetching markets by city:', error);
    return [];
  }
}

// Get featured markets for homepage
export async function getFeaturedMarkets(limitCount: number = 6): Promise<Market[]> {
  try {
    const q = query(
      collection(mainAppDb, 'markets'),
      where('isActive', '==', true),
      orderBy('name'),
      limit(limitCount)
    );
    
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Market));
  } catch (error) {
    console.error('Error fetching featured markets:', error);
    return [];
  }
}

// Get all cities with markets (for sitemap and city pages)
export async function getCitiesWithMarkets(): Promise<string[]> {
  try {
    const q = query(
      collection(mainAppDb, 'markets'),
      where('isActive', '==', true)
    );
    
    const snapshot = await getDocs(q);
    const cities = new Set<string>();
    
    snapshot.docs.forEach(doc => {
      const data = doc.data();
      if (data.city) {
        cities.add(data.city);
      }
    });
    
    return Array.from(cities).sort();
  } catch (error) {
    console.error('Error fetching cities:', error);
    return [];
  }
}

// Get public vendors (for vendor directory)
export async function getPublicVendors(): Promise<Vendor[]> {
  try {
    const q = query(
      collection(mainAppDb, 'managed_vendors'),
      where('isActive', '==', true),
      orderBy('businessName')
    );
    
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Vendor));
  } catch (error) {
    console.error('Error fetching public vendors:', error);
    return [];
  }
}