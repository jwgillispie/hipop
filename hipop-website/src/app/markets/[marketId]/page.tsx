import { Metadata } from 'next';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import { MapPinIcon, ClockIcon, CalendarIcon, UserGroupIcon, CheckIcon } from '@heroicons/react/24/outline';
import { collection, doc, getDoc, query, where, getDocs } from 'firebase/firestore';
import { mainAppDb } from '@/lib/firebase';
import { Market } from '@/lib/data';

interface Props {
  params: Promise<{
    marketId: string;
  }>;
}

async function getMarketById(marketId: string): Promise<Market | null> {
  try {
    const docRef = doc(mainAppDb, 'markets', marketId);
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists() && docSnap.data().isActive) {
      return {
        id: docSnap.id,
        ...docSnap.data()
      } as Market;
    }
    return null;
  } catch (error) {
    console.error('Error fetching market:', error);
    return null;
  }
}

async function getMarketVendors(marketId: string) {
  try {
    const q = query(
      collection(mainAppDb, 'managed_vendors'),
      where('marketId', '==', marketId),
      where('isActive', '==', true)
    );
    
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  } catch (error) {
    console.error('Error fetching market vendors:', error);
    return [];
  }
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { marketId } = await params;
  const market = await getMarketById(marketId);
  
  if (!market) {
    return {
      title: 'Market Not Found - HiPop Markets',
    };
  }
  
  return {
    title: `${market.name} - Farmers Market | HiPop Markets`,
    description: market.description || `Visit ${market.name} farmers market in ${market.city}, ${market.state}. Fresh local produce, artisanal foods, and community vendors.`,
    keywords: `${market.name}, farmers market, ${market.city}, ${market.state}, local produce, vendors, apply vendor`,
    openGraph: {
      title: `${market.name} - Farmers Market`,
      description: market.description || `Visit ${market.name} farmers market in ${market.city}, ${market.state}`,
      type: 'website',
    },
  };
}

export default async function MarketDetailPage({ params }: Props) {
  const { marketId } = await params;
  const [market, vendors] = await Promise.all([
    getMarketById(marketId),
    getMarketVendors(marketId)
  ]);

  if (!market) {
    notFound();
  }

  const formatOperatingHours = (hours: { [key: string]: string }) => {
    if (!hours || Object.keys(hours).length === 0) return 'Check app for hours';
    
    const entries = Object.entries(hours);
    if (entries.length === 1) {
      return entries[0][1];
    }
    
    return entries.map(([day, time]) => `${day}: ${time}`).join(', ');
  };

  return (
    <div className="bg-white">
      {/* Hero Section */}
      <div className="bg-gray-50 py-16 sm:py-24">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl lg:mx-0">
            <nav className="flex mb-8" aria-label="Breadcrumb">
              <ol className="flex items-center space-x-4">
                <li>
                  <Link href="/markets" className="text-gray-400 hover:text-gray-500">
                    Markets
                  </Link>
                </li>
                <li>
                  <div className="flex items-center">
                    <svg className="h-5 w-5 flex-shrink-0 text-gray-300" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clipRule="evenodd" />
                    </svg>
                    <span className="ml-4 text-gray-700 font-medium">{market.name}</span>
                  </div>
                </li>
              </ol>
            </nav>
            
            <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-6xl">
              {market.name}
            </h1>
            <div className="mt-6 flex items-center text-lg text-gray-600">
              <MapPinIcon className="h-6 w-6 mr-2 text-orange-500" />
              <span>{market.address}, {market.city}, {market.state}</span>
            </div>
            {market.description && (
              <p className="mt-6 text-lg leading-8 text-gray-600">
                {market.description}
              </p>
            )}
          </div>
        </div>
      </div>

      {/* Market Details */}
      <div className="py-16 sm:py-24">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto grid max-w-2xl grid-cols-1 gap-8 lg:mx-0 lg:max-w-none lg:grid-cols-3">
            
            {/* Market Information */}
            <div className="lg:col-span-2">
              <div className="bg-white rounded-2xl shadow-sm border border-gray-200 p-8">
                <h2 className="text-2xl font-bold text-gray-900 mb-6">Market Information</h2>
                
                <div className="space-y-6">
                  {Array.isArray(market.operatingDays) && market.operatingDays.length > 0 && (
                    <div className="flex items-start">
                      <CalendarIcon className="h-6 w-6 text-orange-500 mt-1 mr-3" />
                      <div>
                        <h3 className="font-semibold text-gray-900">Operating Days</h3>
                        <p className="text-gray-600">{market.operatingDays.join(', ')}</p>
                      </div>
                    </div>
                  )}
                  
                  {market.operatingHours && Object.keys(market.operatingHours).length > 0 && (
                    <div className="flex items-start">
                      <ClockIcon className="h-6 w-6 text-orange-500 mt-1 mr-3" />
                      <div>
                        <h3 className="font-semibold text-gray-900">Hours</h3>
                        <p className="text-gray-600">{formatOperatingHours(market.operatingHours)}</p>
                      </div>
                    </div>
                  )}
                  
                  <div className="flex items-start">
                    <MapPinIcon className="h-6 w-6 text-orange-500 mt-1 mr-3" />
                    <div>
                      <h3 className="font-semibold text-gray-900">Location</h3>
                      <p className="text-gray-600">{market.address}</p>
                      <p className="text-gray-600">{market.city}, {market.state}</p>
                    </div>
                  </div>
                  
                  {vendors.length > 0 && (
                    <div className="flex items-start">
                      <UserGroupIcon className="h-6 w-6 text-orange-500 mt-1 mr-3" />
                      <div>
                        <h3 className="font-semibold text-gray-900">Current Vendors</h3>
                        <p className="text-gray-600">{vendors.length} active vendors</p>
                      </div>
                    </div>
                  )}
                </div>
              </div>
              
              {/* Current Vendors */}
              {vendors.length > 0 && (
                <div className="mt-8 bg-white rounded-2xl shadow-sm border border-gray-200 p-8">
                  <h2 className="text-2xl font-bold text-gray-900 mb-6">Current Vendors</h2>
                  <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                    {vendors.slice(0, 6).map((vendor: any) => (
                      <div key={vendor.id} className="border border-gray-200 rounded-lg p-4">
                        <h3 className="font-semibold text-gray-900">{vendor.businessName}</h3>
                        {vendor.description && (
                          <p className="text-sm text-gray-600 mt-1 line-clamp-2">{vendor.description}</p>
                        )}
                        {vendor.categories && vendor.categories.length > 0 && (
                          <div className="mt-2 flex flex-wrap gap-1">
                            {vendor.categories.slice(0, 3).map((category: string) => (
                              <span key={category} className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-orange-100 text-orange-800">
                                {category}
                              </span>
                            ))}
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                  {vendors.length > 6 && (
                    <p className="mt-4 text-sm text-gray-500 text-center">
                      And {vendors.length - 6} more vendors...
                    </p>
                  )}
                </div>
              )}
            </div>

            {/* Sidebar - Apply as Vendor */}
            <div className="lg:col-span-1">
              <div className="sticky top-8">
                <div className="bg-orange-50 rounded-2xl border border-orange-200 p-8">
                  <div className="text-center">
                    <div className="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-orange-100 mb-4">
                      <CheckIcon className="h-6 w-6 text-orange-600" />
                    </div>
                    <h3 className="text-lg font-semibold text-gray-900 mb-2">
                      Join This Market
                    </h3>
                    <p className="text-sm text-gray-600 mb-6">
                      Apply to become a vendor at {market.name}. Share your products with the local community.
                    </p>
                    
                    <Link
                      href={`/apply?market=${market.id}`}
                      className="w-full inline-flex justify-center items-center rounded-md bg-orange-600 px-6 py-3 text-base font-semibold text-white shadow-sm hover:bg-orange-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-orange-600 mb-4"
                    >
                      Apply as Vendor
                    </Link>
                    
                    <div className="text-xs text-gray-500 space-y-1">
                      <div className="flex items-center justify-start">
                        <CheckIcon className="h-3 w-3 text-green-500 mr-1" />
                        <span>Free to apply</span>
                      </div>
                      <div className="flex items-center justify-start">
                        <CheckIcon className="h-3 w-3 text-green-500 mr-1" />
                        <span>Quick review process</span>
                      </div>
                      <div className="flex items-center justify-start">
                        <CheckIcon className="h-3 w-3 text-green-500 mr-1" />
                        <span>No account required</span>
                      </div>
                    </div>
                  </div>
                </div>
                
                {/* Market Stats */}
                <div className="mt-6 bg-white rounded-2xl shadow-sm border border-gray-200 p-6">
                  <h4 className="font-semibold text-gray-900 mb-4">Market Stats</h4>
                  <div className="space-y-3">
                    <div className="flex justify-between">
                      <span className="text-sm text-gray-600">Active Vendors</span>
                      <span className="text-sm font-medium text-gray-900">{vendors.length}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-sm text-gray-600">Location</span>
                      <span className="text-sm font-medium text-gray-900">{market.city}</span>
                    </div>
                    {market.operatingDays?.length > 0 && (
                      <div className="flex justify-between">
                        <span className="text-sm text-gray-600">Market Days</span>
                        <span className="text-sm font-medium text-gray-900">{market.operatingDays.length}</span>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* CTA Section */}
      <div className="bg-gray-50 py-16 sm:py-24">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl text-center">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Ready to join {market.name}?
            </h2>
            <p className="mx-auto mt-6 max-w-xl text-lg leading-8 text-gray-600">
              Apply now to become a vendor and start connecting with customers in your local community.
            </p>
            <div className="mt-10 flex items-center justify-center gap-x-6">
              <Link
                href={`/apply?market=${market.id}`}
                className="rounded-md bg-orange-600 px-6 py-3 text-base font-semibold text-white shadow-sm hover:bg-orange-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-orange-600"
              >
                Apply as Vendor
              </Link>
              <Link 
                href="/markets" 
                className="text-base font-semibold leading-6 text-gray-900"
              >
                Browse Other Markets <span aria-hidden="true">→</span>
              </Link>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}