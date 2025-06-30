import Link from 'next/link';
import { MapPinIcon, ClockIcon, CalendarIcon } from '@heroicons/react/24/outline';
import { getPublicMarkets, getCitiesWithMarkets } from '@/lib/data';

export const metadata = {
  title: 'Farmers Markets Directory - Find Markets Near You | HiPop Markets',
  description: 'Browse our comprehensive directory of farmers markets. Find fresh local produce, artisanal foods, and connect with vendors in your community.',
  keywords: 'farmers markets directory, local markets, fresh produce, farmers market locations, organic food markets',
};

export default async function Markets() {
  const [markets, cities] = await Promise.all([
    getPublicMarkets(),
    getCitiesWithMarkets()
  ]);

  return (
    <div className="bg-white">
      {/* Hero Section */}
      <div className="bg-gray-50 py-24 sm:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl text-center">
            <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-6xl">
              Farmers Markets
              <span className="text-orange-600"> Directory</span>
            </h1>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              Discover fresh, local produce and artisanal foods at farmers markets in your area. 
              Connect with local vendors and support your community.
            </p>
            <div className="mt-10">
              <Link
                href="https://hipop-markets.web.app"
                target="_blank"
                rel="noopener noreferrer"
                className="rounded-md bg-orange-600 px-6 py-3 text-base font-semibold text-white shadow-sm hover:bg-orange-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-orange-600"
              >
                Go to the App
              </Link>
            </div>
          </div>
        </div>
      </div>

      {/* Cities Section */}
      {cities.length > 0 && (
        <div className="py-16 sm:py-24">
          <div className="mx-auto max-w-7xl px-6 lg:px-8">
            <div className="mx-auto max-w-2xl lg:mx-0">
              <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">Browse by City</h2>
              <p className="mt-2 text-lg leading-8 text-gray-600">
                Find farmers markets in cities across our network.
              </p>
            </div>
            <div className="mx-auto mt-10 grid max-w-2xl grid-cols-2 gap-4 sm:grid-cols-3 lg:mx-0 lg:max-w-none lg:grid-cols-5">
              {cities.slice(0, 10).map((city) => (
                <Link
                  key={city}
                  href={`/markets/${city.toLowerCase().replace(/\s+/g, '-')}`}
                  className="group relative flex items-center space-x-3 rounded-lg border border-gray-300 bg-white px-6 py-5 shadow-sm hover:border-gray-400 focus-within:ring-2 focus-within:ring-indigo-500 focus-within:ring-offset-2 hover:shadow-md transition-all"
                >
                  <div className="flex-shrink-0">
                    <MapPinIcon className="h-6 w-6 text-orange-600" />
                  </div>
                  <div className="min-w-0 flex-1">
                    <span className="absolute inset-0" aria-hidden="true" />
                    <p className="text-sm font-medium text-gray-900 group-hover:text-orange-600 transition-colors">
                      {city}
                    </p>
                  </div>
                </Link>
              ))}
            </div>
            {cities.length > 10 && (
              <div className="mt-8 text-center">
                <Link
                  href="/markets/cities"
                  className="text-sm font-semibold leading-6 text-orange-600 hover:text-orange-500"
                >
                  View all cities <span aria-hidden="true">→</span>
                </Link>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Markets Grid */}
      <div className="bg-gray-50 py-16 sm:py-24">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl lg:mx-0">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">Featured Markets</h2>
            <p className="mt-2 text-lg leading-8 text-gray-600">
              Explore some of the amazing farmers markets in our network.
            </p>
          </div>
          
          {markets.length > 0 ? (
            <div className="mx-auto mt-16 grid max-w-2xl grid-cols-1 gap-8 sm:mt-20 lg:mx-0 lg:max-w-none lg:grid-cols-3">
              {markets.map((market) => (
                <article
                  key={market.id}
                  className="bg-white rounded-2xl shadow-lg overflow-hidden hover:shadow-xl transition-shadow"
                >
                  <div className="p-8">
                    <div className="flex items-center gap-x-4 text-xs">
                      <div className="flex items-center text-gray-500">
                        <MapPinIcon className="h-4 w-4 mr-1" />
                        {market.city}, {market.state}
                      </div>
                    </div>
                    <div className="group relative">
                      <h3 className="mt-3 text-lg font-semibold leading-6 text-gray-900 group-hover:text-gray-600">
                        <Link href={`/markets/${market.id}`}>
                          <span className="absolute inset-0" />
                          {market.name}
                        </Link>
                      </h3>
                      <p className="mt-5 line-clamp-3 text-sm leading-6 text-gray-600">
                        {market.description || `Fresh local produce and artisanal foods in ${market.city}, ${market.state}`}
                      </p>
                    </div>
                    
                    <div className="mt-6 space-y-3">
                      {Array.isArray(market.operatingDays) && market.operatingDays.length > 0 && (
                        <div className="flex items-center text-sm text-gray-600">
                          <CalendarIcon className="h-4 w-4 mr-2 text-orange-500" />
                          <span>{market.operatingDays.join(', ')}</span>
                        </div>
                      )}
                      
                      {market.operatingHours && Object.keys(market.operatingHours).length > 0 && (
                        <div className="flex items-center text-sm text-gray-600">
                          <ClockIcon className="h-4 w-4 mr-2 text-orange-500" />
                          <span>
                            {Object.entries(market.operatingHours)[0]?.[1] || 'Check app for hours'}
                          </span>
                        </div>
                      )}
                    </div>
                    
                    <div className="mt-6">
                      <Link
                        href={`/markets/${market.id}`}
                        className="text-sm font-semibold leading-6 text-orange-600 hover:text-orange-500"
                      >
                        View Details <span aria-hidden="true">→</span>
                      </Link>
                    </div>
                  </div>
                </article>
              ))}
            </div>
          ) : (
            <div className="mt-16 text-center">
              <MapPinIcon className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-semibold text-gray-900">No markets found</h3>
              <p className="mt-1 text-sm text-gray-500">
                We're working on adding more markets to our directory.
              </p>
              <div className="mt-6">
                <Link
                  href="https://hipop-markets.web.app"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center rounded-md bg-orange-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-orange-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-orange-600"
                >
                  Go to the App to Find Markets
                </Link>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Info Section */}
      <div className="py-16 sm:py-24">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl lg:text-center">
            <h2 className="text-base font-semibold leading-7 text-orange-600">Why Choose Farmers Markets?</h2>
            <p className="mt-2 text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Fresh, Local, Community-Driven
            </p>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              Farmers markets offer more than just fresh produce - they're community hubs that connect you directly with local growers and artisans.
            </p>
          </div>
          <div className="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-4xl">
            <dl className="grid max-w-xl grid-cols-1 gap-x-8 gap-y-10 lg:max-w-none lg:grid-cols-2 lg:gap-y-16">
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <svg className="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M12 3v2.25m6.364.386l-1.591 1.591M21 12h-2.25m-.386 6.364l-1.591-1.591M12 18.75V21m-4.773-4.227l-1.591 1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75 12a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0z" />
                    </svg>
                  </div>
                  Fresh & Seasonal
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Produce is picked at peak ripeness and sold within days, ensuring maximum flavor and nutrition.
                </dd>
              </div>
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <svg className="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M15 19.128a9.38 9.38 0 002.625.372 9.337 9.337 0 004.121-.952 4.125 4.125 0 00-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 018.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0111.964-3.07M12 6.375a3.375 3.375 0 11-6.75 0 3.375 3.375 0 016.75 0zm8.25 2.25a2.625 2.625 0 11-5.25 0 2.625 2.625 0 015.25 0z" />
                    </svg>
                  </div>
                  Support Local Economy
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Your purchases directly support local farmers, artisans, and small businesses in your community.
                </dd>
              </div>
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <svg className="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M9.75 3.104v5.714a2.25 2.25 0 01-.659 1.591L5 14.5M9.75 3.104c-.251.023-.501.05-.75.082m.75-.082a24.301 24.301 0 014.5 0m0 0v5.714c0 .597.237 1.17.659 1.591L19.8 15.3M14.25 3.104c.251.023.501.05.75.082M19.8 15.3l-1.57.393A9.065 9.065 0 0112 15a9.065 9.065 0 00-6.23-.693L5 14.5m14.8.8l1.402 1.402c1.232 1.232.65 3.318-1.067 3.611A48.309 48.309 0 0112 21c-2.773 0-5.491-.235-8.135-.687-1.718-.293-2.3-2.379-1.067-3.611L5 14.5" />
                    </svg>
                  </div>
                  Environmental Benefits
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Reduced transportation miles and packaging waste make farmers markets an eco-friendly choice.
                </dd>
              </div>
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <svg className="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M8.625 12a.375.375 0 11-.75 0 .375.375 0 01.75 0zm0 0H8.25m4.125 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zm0 0H12m4.125 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zm0 0h-.375M21 12c0 4.556-4.03 8.25-9 8.25a9.764 9.764 0 01-2.555-.337A5.972 5.972 0 015.41 20.97a5.969 5.969 0 01-.474-.065 4.48 4.48 0 00.978-2.025c.09-.457-.133-.901-.467-1.226C3.93 16.178 3 14.189 3 12c0-4.556 4.03-8.25 9-8.25s9 3.694 9 8.25z" />
                    </svg>
                  </div>
                  Learn & Connect
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Talk directly with growers to learn about their products, get cooking tips, and discover new foods.
                </dd>
              </div>
            </dl>
          </div>
        </div>
      </div>

      {/* CTA Section */}
      <div className="bg-orange-600">
        <div className="px-6 py-24 sm:px-6 sm:py-32 lg:px-8">
          <div className="mx-auto max-w-2xl text-center">
            <h2 className="text-3xl font-bold tracking-tight text-white sm:text-4xl">
              Find your next favorite market
            </h2>
            <p className="mx-auto mt-6 max-w-xl text-lg leading-8 text-orange-100">
              Download the HiPop Markets app to discover real-time information about vendors, hours, and special events.
            </p>
            <div className="mt-10 flex items-center justify-center gap-x-6">
              <Link
                href="https://hipop-markets.web.app"
                target="_blank"
                rel="noopener noreferrer"
                className="rounded-md bg-white px-3.5 py-2.5 text-sm font-semibold text-orange-600 shadow-sm hover:bg-gray-100 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white"
              >
                Go to the App
              </Link>
              <Link href="#" className="text-sm font-semibold leading-6 text-white">
                View Market Map <span aria-hidden="true">→</span>
              </Link>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}