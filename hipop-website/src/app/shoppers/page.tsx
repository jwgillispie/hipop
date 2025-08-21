import Link from 'next/link';
import { MapPinIcon, MagnifyingGlassIcon, HeartIcon, BellIcon, ClockIcon, CurrencyDollarIcon, CalendarIcon } from '@heroicons/react/24/outline';
import PricingSection from '@/components/PricingSection';
import { getPublicMarkets, getCitiesWithMarkets } from '@/lib/data';

export const metadata = {
  title: 'For Shoppers - Discover Local Markets & Artisan Goods | HiPop Markets',
  description: 'Find farmers markets, artisan markets, vintage clothing markets, and local vendors near you. Discover fresh produce, handmade jewelry, vintage clothing, crafts, and unique local products using HiPop Markets.',
  keywords: 'local markets finder, farmers markets, artisan markets, vintage clothing markets, handmade goods, vintage clothing, local jewelry, crafts, local vendors, local shopping app',
};

export default async function Shoppers() {
  const [markets, cities] = await Promise.all([
    getPublicMarkets(),
    getCitiesWithMarkets()
  ]);
  return (
    <div className="bg-white">
      {/* Hero Section */}
      <div className="relative isolate overflow-hidden bg-hipop-surface-gradient">
        <div className="mx-auto max-w-7xl pb-24 pt-10 sm:pb-32 lg:grid lg:grid-cols-2 lg:gap-x-8 lg:px-8 lg:py-40">
          <div className="px-6 lg:px-0 lg:pt-4">
            <div className="mx-auto max-w-2xl">
              <div className="max-w-lg">
                <h1 className="mt-10 text-4xl font-bold tracking-tight text-gray-900 sm:text-6xl">
                  Discover
                  <span className="text-hipop-primary"> Local Markets</span>
                </h1>
                <p className="mt-6 text-lg leading-8 text-gray-600">
                  Find farmers markets, artisan markets, vintage clothing markets, and local vendors in your area. Discover fresh produce, 
                  handmade jewelry, unique vintage clothing, crafts, and authentic local products from the people who make them.
                </p>
                <div className="mt-10 flex items-center gap-x-6">
                  <Link
                    href="https://hipop-markets.web.app"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="rounded-md bg-hipop-primary px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-[#3D6450] focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#558B6E]"
                  >
                    Get Started
                  </Link>
                  <Link href="#markets" className="text-sm font-semibold leading-6 text-gray-900">
                    View Markets Below <span aria-hidden="true">↓</span>
                  </Link>
                </div>
              </div>
            </div>
          </div>
          <div className="mt-20 sm:mt-24 md:mx-auto md:max-w-2xl lg:mx-0 lg:mt-0 lg:w-screen">
            <div className="absolute inset-y-0 right-1/2 -z-10 -mr-10 w-[200%] skew-x-[-30deg] bg-white shadow-xl shadow-[#558B6E]/10 ring-1 ring-[#F1C8DB] md:-mr-20 lg:-mr-36" />
            <div className="shadow-lg md:rounded-3xl">
              <div className="bg-hipop-gradient [clip-path:inset(0)] md:[clip-path:inset(0_round_theme(borderRadius.3xl))]">
                <div className="absolute -inset-y-px left-1/2 -z-10 ml-10 w-[200%] skew-x-[-30deg] bg-[#F1C8DB] opacity-20 ring-1 ring-inset ring-white md:ml-20 lg:ml-36" />
                <div className="relative px-6 pt-8 sm:pt-16 md:pl-16 md:pr-0">
                  <div className="mx-auto max-w-2xl md:mx-0 md:max-w-none">
                    <div className="w-screen overflow-hidden rounded-tl-xl bg-gray-900">
                      <div className="flex bg-gray-800/40 ring-1 ring-white/5">
                        <div className="-mb-px flex text-sm font-medium leading-6 text-gray-400">
                          <div className="border-b border-r border-b-white/20 border-r-white/10 bg-white/5 px-4 py-2 text-white">
                            Find Markets
                          </div>
                        </div>
                      </div>
                      <div className="px-6 pb-14 pt-6">
                        {/* Mock app interface for shoppers */}
                        <div className="text-white text-sm space-y-4">
                          <div className="flex items-center space-x-2">
                            <MapPinIcon className="h-5 w-5 text-hipop-primary" />
                            <span>3 markets within 5 miles</span>
                          </div>
                          <div className="flex items-center space-x-2">
                            <ClockIcon className="h-5 w-5 text-hipop-secondary" />
                            <span>Open today: 8am - 2pm</span>
                          </div>
                          <div className="flex items-center space-x-2">
                            <HeartIcon className="h-5 w-5 text-hipop-accent" />
                            <span>5 favorite vendors available</span>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Features Section */}
      <div className="py-24 sm:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl lg:text-center">
            <h2 className="text-base font-semibold leading-7 text-hipop-primary">Everything you need</h2>
            <p className="mt-2 text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Your guide to local markets
            </p>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              HiPop Markets puts the power of local market discovery in your pocket with tools designed for shoppers who value authentic, locally-made products.
            </p>
          </div>
          <div className="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-4xl">
            <dl className="grid max-w-xl grid-cols-1 gap-x-8 gap-y-10 lg:max-w-none lg:grid-cols-2 lg:gap-y-16">
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-hipop-primary">
                    <MapPinIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Smart Market Discovery
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Find farmers markets, artisan markets, vintage clothing markets, and craft fairs near you with intelligent search that understands your location, preferences, and schedule.
                </dd>
              </div>
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-hipop-primary">
                    <MagnifyingGlassIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Vendor & Product Search
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Search for specific vendors, products, or crafts to find exactly what you're looking for - from fresh produce to handmade jewelry, vintage clothing, and unique artisan goods.
                </dd>
              </div>
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-hipop-primary">
                    <HeartIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Save Your Favorites
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Keep track of your favorite markets, vendors, and products - whether it's a weekly produce vendor or that jewelry maker with the perfect pieces.
                </dd>
              </div>
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-hipop-primary">
                    <BellIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Smart Notifications
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Get notified when your favorite vendors have new collections, special items, market schedule changes, or when new artisan markets open nearby.
                </dd>
              </div>
            </dl>
          </div>
        </div>
      </div>

      {/* Pricing Section */}
      <PricingSection userType="shopper" />

      {/* Benefits Section */}
      <div className="bg-hipop-surface py-24 sm:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl lg:mx-0">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">Why shop at local markets?</h2>
            <p className="mt-2 text-lg leading-8 text-gray-600">
              Discover the benefits of choosing local products - from fresh food to handmade crafts - for you, your community, and local artisans.
            </p>
          </div>
          <div className="mx-auto mt-16 grid max-w-2xl grid-cols-1 gap-8 sm:mt-20 lg:mx-0 lg:max-w-none lg:grid-cols-3">
            <div className="bg-white rounded-2xl p-8 shadow-lg">
              <div className="flex items-center gap-x-4 mb-6">
                <div className="h-12 w-12 rounded-full bg-hipop-surface-variant flex items-center justify-center">
                  <svg className="h-6 w-6 text-hipop-primary" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M12 3v2.25m6.364.386l-1.591 1.591M21 12h-2.25m-.386 6.364l-1.591-1.591M12 18.75V21m-4.773-4.227l-1.591 1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75 12a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0z" />
                  </svg>
                </div>
                <h3 className="text-lg font-semibold text-gray-900">Authentic & Unique</h3>
              </div>
              <p className="text-gray-600">
                From farm-fresh produce to one-of-a-kind handmade jewelry and crafts, local markets offer 
                authentic products you won't find in big box stores, each with its own story.
              </p>
            </div>
            
            <div className="bg-white rounded-2xl p-8 shadow-lg">
              <div className="flex items-center gap-x-4 mb-6">
                <div className="h-12 w-12 rounded-full bg-hipop-surface-variant flex items-center justify-center">
                  <CurrencyDollarIcon className="h-6 w-6 text-hipop-primary" />
                </div>
                <h3 className="text-lg font-semibold text-gray-900">Support Local Economy</h3>
              </div>
              <p className="text-gray-600">
                Every dollar spent at local markets stays in your community, supporting small farmers, 
                artisans, jewelry makers, and crafters while creating local jobs and economic growth.
              </p>
            </div>
            
            <div className="bg-white rounded-2xl p-8 shadow-lg">
              <div className="flex items-center gap-x-4 mb-6">
                <div className="h-12 w-12 rounded-full bg-hipop-surface-variant flex items-center justify-center">
                  <svg className="h-6 w-6 text-hipop-primary" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M9.75 3.104v5.714a2.25 2.25 0 01-.659 1.591L5 14.5M9.75 3.104c-.251.023-.501.05-.75.082m.75-.082a24.301 24.301 0 014.5 0m0 0v5.714c0 .597.237 1.17.659 1.591L19.8 15.3M14.25 3.104c.251.023.501.05.75.082M19.8 15.3l-1.57.393A9.065 9.065 0 0112 15a9.065 9.065 0 00-6.23-.693L5 14.5m14.8.8l1.402 1.402c1.232 1.232.65 3.318-1.067 3.611A48.309 48.309 0 0112 21c-2.773 0-5.491-.235-8.135-.687-1.718-.293-2.3-2.379-1.067-3.611L5 14.5" />
                  </svg>
                </div>
                <h3 className="text-lg font-semibold text-gray-900">Environmental Impact</h3>
              </div>
              <p className="text-gray-600">
                Reduce your environmental impact with locally made products that require minimal transportation. 
                Support sustainable practices from organic farming to eco-friendly crafting methods.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* How It Works */}
      <div className="py-24 sm:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl lg:text-center">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              How it works
            </h2>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              Getting started with local food shopping is easier than you think.
            </p>
          </div>
          <div className="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-4xl">
            <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
              <div className="text-center">
                <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-lg bg-hipop-primary text-white text-2xl font-bold mb-6">
                  1
                </div>
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Find Markets Near You</h3>
                <p className="text-gray-600">
                  Use our smart search to discover farmers markets, artisan markets, and craft fairs in your area. 
                  Filter by distance, days open, or specific types of vendors you're looking for.
                </p>
              </div>
              <div className="text-center">
                <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-lg bg-hipop-primary text-white text-2xl font-bold mb-6">
                  2
                </div>
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Explore Vendors & Products</h3>
                <p className="text-gray-600">
                  Browse vendor profiles to see what's available - from seasonal produce to handmade jewelry collections. 
                  Read about the artisans and farmers behind your favorite products.
                </p>
              </div>
              <div className="text-center">
                <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-lg bg-hipop-primary text-white text-2xl font-bold mb-6">
                  3
                </div>
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Save & Get Notified</h3>
                <p className="text-gray-600">
                  Save your favorites and get personalized notifications about new collections, special products, 
                  market updates, and new artisan vendors in your area.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Testimonials */}
      <div className="bg-hipop-surface py-24 sm:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl lg:mx-0">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">What shoppers are saying</h2>
            <p className="mt-2 text-lg leading-8 text-gray-600">
              See how HiPop Markets has transformed the way people discover and enjoy local food.
            </p>
          </div>
          <div className="mx-auto mt-16 grid max-w-2xl grid-cols-1 gap-8 sm:mt-20 lg:mx-0 lg:max-w-none lg:grid-cols-3">
            <div className="bg-white rounded-2xl p-8 shadow-lg">
              <div className="flex items-center gap-x-4 mb-6">
                <div className="h-12 w-12 rounded-full bg-hipop-surface-variant flex items-center justify-center">
                  <span className="text-hipop-primary font-semibold">S</span>
                </div>
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">Sarah M.</h3>
                  <p className="text-sm text-gray-600">Busy mom from Atlanta</p>
                </div>
              </div>
              <blockquote className="text-gray-600">
"HiPop Markets helped me discover three local markets within walking distance - one with amazing fresh produce, 
                another with beautiful handmade jewelry, and a craft market perfect for unique gifts!"
              </blockquote>
            </div>
            
            <div className="bg-white rounded-2xl p-8 shadow-lg">
              <div className="flex items-center gap-x-4 mb-6">
                <div className="h-12 w-12 rounded-full bg-hipop-surface-variant flex items-center justify-center">
                  <span className="text-hipop-primary font-semibold">D</span>
                </div>
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">David L.</h3>
                  <p className="text-sm text-gray-600">Small business owner from Portland</p>
                </div>
              </div>
              <blockquote className="text-gray-600">
"As a boutique owner, I love sourcing unique local products. The vendor search helps me find 
                everything from artisan soaps to handcrafted jewelry for my store."
              </blockquote>
            </div>
            
            <div className="bg-white rounded-2xl p-8 shadow-lg">
              <div className="flex items-center gap-x-4 mb-6">
                <div className="h-12 w-12 rounded-full bg-hipop-surface-variant flex items-center justify-center">
                  <span className="text-hipop-primary font-semibold">M</span>
                </div>
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">Maria R.</h3>
                  <p className="text-sm text-gray-600">Art lover from Denver</p>
                </div>
              </div>
              <blockquote className="text-gray-600">
"The notifications feature is perfect! I get alerts when my favorite jewelry maker has new pieces 
                or when the pottery vendor I love is at weekend markets. Never miss out again!"
              </blockquote>
            </div>
          </div>
        </div>
      </div>

      {/* Markets Section */}
      <div id="markets" className="py-24 sm:py-32 bg-gray-50">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl lg:mx-0">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">Browse Local Markets</h2>
            <p className="mt-2 text-lg leading-8 text-gray-600">
              Explore amazing markets in our network and find fresh produce, handmade goods, and unique artisan products.
            </p>
          </div>
          
          {/* Cities Section */}
          {cities.length > 0 && (
            <div className="mt-16">
              <h3 className="text-lg font-semibold text-gray-900 mb-6">Markets by City</h3>
              <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-5">
                {cities.slice(0, 10).map((city) => (
                  <div
                    key={city}
                    className="group relative flex items-center space-x-3 rounded-lg border border-gray-300 bg-white px-6 py-5 shadow-sm hover:border-gray-400 hover:shadow-md transition-all"
                  >
                    <div className="flex-shrink-0">
                      <MapPinIcon className="h-5 w-5 text-hipop-primary" />
                    </div>
                    <div className="min-w-0 flex-1">
                      <p className="text-sm font-medium text-gray-900 group-hover:text-hipop-primary transition-colors">
                        {city}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
          
          {/* Markets Grid */}
          {markets.length > 0 ? (
            <div className="mx-auto mt-16 grid max-w-2xl grid-cols-1 gap-8 lg:mx-0 lg:max-w-none lg:grid-cols-3">
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
                        {market.name}
                      </h3>
                      <p className="mt-5 line-clamp-3 text-sm leading-6 text-gray-600">
                        {market.description || `Fresh local produce and artisanal foods in ${market.city}, ${market.state}`}
                      </p>
                    </div>
                    
                    <div className="mt-6 space-y-3">
                      {Array.isArray(market.operatingDays) && market.operatingDays.length > 0 && (
                        <div className="flex items-center text-sm text-gray-600">
                          <CalendarIcon className="h-4 w-4 mr-2 text-hipop-primary" />
                          <span>{market.operatingDays.join(', ')}</span>
                        </div>
                      )}
                      
                      {market.operatingHours && Object.keys(market.operatingHours).length > 0 && (
                        <div className="flex items-center text-sm text-gray-600">
                          <ClockIcon className="h-4 w-4 mr-2 text-hipop-primary" />
                          <span>
                            {Object.entries(market.operatingHours)[0]?.[1] || 'Check app for hours'}
                          </span>
                        </div>
                      )}
                    </div>
                    
                    <div className="mt-6">
                      <Link
                        href="/apply"
                        className="inline-flex items-center rounded-md bg-hipop-primary px-3 py-1.5 text-xs font-semibold text-white shadow-sm hover:bg-[#3D6450] focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-hipop-primary"
                      >
                        Apply as Vendor
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
                  className="inline-flex items-center rounded-md bg-hipop-primary px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-[#3D6450] focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-hipop-primary"
                >
                  Go to the App to Find Markets
                </Link>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* CTA Section */}
      <div className="bg-hipop-gradient">
        <div className="px-6 py-24 sm:px-6 sm:py-32 lg:px-8">
          <div className="mx-auto max-w-2xl text-center">
            <h2 className="text-3xl font-bold tracking-tight text-white sm:text-4xl">
              Start your local market journey today
            </h2>
            <p className="mx-auto mt-6 max-w-xl text-lg leading-8 text-white/90">
              Join thousands of shoppers who have discovered the joy of local markets - from fresh food to unique handmade treasures. 
              Go to HiPop Markets and find your next favorite local market.
            </p>
            <div className="mt-10 flex items-center justify-center gap-x-6">
              <Link
                href="https://hipop-markets.web.app"
                target="_blank"
                rel="noopener noreferrer"
                className="rounded-md bg-white px-3.5 py-2.5 text-sm font-semibold text-hipop-primary shadow-sm hover:bg-gray-100 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white"
              >
                Go to the App
              </Link>
              <Link href="#markets" className="text-sm font-semibold leading-6 text-white">
                View Markets Above <span aria-hidden="true">↑</span>
              </Link>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}