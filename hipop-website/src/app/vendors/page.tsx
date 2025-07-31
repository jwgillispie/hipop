import Link from 'next/link';
import { UserGroupIcon, ChartBarIcon, MegaphoneIcon, CurrencyDollarIcon } from '@heroicons/react/24/outline';
import { getPublicVendors } from '@/lib/data';
import PricingSection from '@/components/PricingSection';

export const metadata = {
  title: 'For Vendors - Grow Your Business with HiPop Markets',
  description: 'Join HiPop Markets and connect with more customers at farmers markets. Manage your presence, track analytics, and grow your local food business.',
  keywords: 'farmers market vendors, vendor management, local food business, market analytics, vendor platform',
};

export default async function Vendors() {
  const vendors = await getPublicVendors();

  return (
    <div className="bg-white">
      {/* Hero Section */}
      <div className="relative isolate overflow-hidden bg-gradient-to-b from-orange-100/20">
        <div className="mx-auto max-w-7xl pb-24 pt-10 sm:pb-32 lg:grid lg:grid-cols-2 lg:gap-x-8 lg:px-8 lg:py-40">
          <div className="px-6 lg:px-0 lg:pt-4">
            <div className="mx-auto max-w-2xl">
              <div className="max-w-lg">
                <h1 className="mt-10 text-4xl font-bold tracking-tight text-gray-900 sm:text-6xl">
                  Join Atlanta's
                  <span className="text-orange-600"> Local Market Network</span>
                </h1>
                <p className="mt-6 text-lg leading-8 text-gray-600">
                  Connect with Atlanta-area farmers markets, artisan fairs, vintage markets, and pop-up communities. HiPop's permission system, 
                  pop-up event tools, and unified vendor management help grow your local business.
                </p>
                <div className="mt-10 flex items-center gap-x-6">
                  <Link
                    href="https://hipop-markets.web.app"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="rounded-md bg-orange-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-orange-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-orange-600"
                  >
                    Get Started
                  </Link>
                  <Link href="#features" className="text-sm font-semibold leading-6 text-gray-900">
                    Learn more <span aria-hidden="true">→</span>
                  </Link>
                </div>
              </div>
            </div>
          </div>
          <div className="mt-20 sm:mt-24 md:mx-auto md:max-w-2xl lg:mx-0 lg:mt-0 lg:w-screen">
            <div className="absolute inset-y-0 right-1/2 -z-10 -mr-10 w-[200%] skew-x-[-30deg] bg-white shadow-xl shadow-orange-600/10 ring-1 ring-orange-50 md:-mr-20 lg:-mr-36" />
            <div className="shadow-lg md:rounded-3xl">
              <div className="bg-orange-500 [clip-path:inset(0)] md:[clip-path:inset(0_round_theme(borderRadius.3xl))]">
                <div className="absolute -inset-y-px left-1/2 -z-10 ml-10 w-[200%] skew-x-[-30deg] bg-orange-100 opacity-20 ring-1 ring-inset ring-white md:ml-20 lg:ml-36" />
                <div className="relative px-6 pt-8 sm:pt-16 md:pl-16 md:pr-0">
                  <div className="mx-auto max-w-2xl md:mx-0 md:max-w-none">
                    <div className="w-screen overflow-hidden rounded-tl-xl bg-gray-900">
                      <div className="flex bg-gray-800/40 ring-1 ring-white/5">
                        <div className="-mb-px flex text-sm font-medium leading-6 text-gray-400">
                          <div className="border-b border-r border-b-white/20 border-r-white/10 bg-white/5 px-4 py-2 text-white">
                            Vendor Dashboard
                          </div>
                        </div>
                      </div>
                      <div className="px-6 pb-14 pt-6">
                        {/* Mock vendor dashboard */}
                        <div className="text-white text-sm space-y-4">
                          <div className="flex items-center justify-between">
                            <span>This Week's Sales</span>
                            <span className="text-green-400 font-semibold">↗ +23%</span>
                          </div>
                          <div className="flex items-center justify-between">
                            <span>Customer Favorites</span>
                            <span className="text-orange-400 font-semibold">47</span>
                          </div>
                          <div className="flex items-center justify-between">
                            <span>Next Market</span>
                            <span className="text-blue-400">Saturday 8am</span>
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
      <div id="features" className="py-24 sm:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl lg:text-center">
            <h2 className="text-base font-semibold leading-7 text-orange-600">Everything you need</h2>
            <p className="mt-2 text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Powerful tools for market vendors
            </p>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              From managing your presence to understanding your customers, HiPop Markets gives you the tools to succeed.
            </p>
          </div>
          <div className="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-4xl">
            <dl className="grid max-w-xl grid-cols-1 gap-x-8 gap-y-10 lg:max-w-none lg:grid-cols-2 lg:gap-y-16">
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <UserGroupIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Market Permission System
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Request permission to join markets once, then create unlimited pop-ups for approved markets. No more individual event applications.
                </dd>
              </div>
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <ChartBarIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Central Pop-up Creation
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Create both independent pop-ups and market-associated events from one unified dashboard. Toggle between market types seamlessly.
                </dd>
              </div>
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <MegaphoneIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Vendor-Market Relationships
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Build lasting relationships with market organizers through HiPop's permission-based system. Get recognized as a trusted market vendor.
                </dd>
              </div>
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <CurrencyDollarIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Profile Unification
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  When markets approve your permission request, your profile information automatically populates their vendor directory. No duplicate data entry.
                </dd>
              </div>
            </dl>
          </div>
        </div>
      </div>

      {/* Pricing Section - Commented out until market validation */}
      {/* <PricingSection userType="vendor" /> */}

      {/* Success Stories */}
      <div className="bg-gray-50 py-24 sm:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl lg:mx-0">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">Vendor Success Stories</h2>
            <p className="mt-2 text-lg leading-8 text-gray-600">
              See how HiPop Markets has helped local vendors grow their businesses.
            </p>
          </div>
          <div className="mx-auto mt-16 grid max-w-2xl grid-cols-1 gap-8 sm:mt-20 lg:mx-0 lg:max-w-none lg:grid-cols-3">
            <div className="bg-white rounded-2xl p-8 shadow-lg">
              <div className="flex items-center gap-x-4">
                <div className="h-12 w-12 rounded-full bg-orange-100 flex items-center justify-center">
                  <UserGroupIcon className="h-6 w-6 text-orange-600" />
                </div>
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">Atlanta Artisan Collective</h3>
                  <p className="text-sm text-gray-600">Handcrafted goods & art</p>
                </div>
              </div>
              <blockquote className="mt-6 text-gray-600">
                "HiPop's permission system changed everything. Instead of applying to each event, I requested permission once and now create pop-ups whenever I have new pieces ready."
              </blockquote>
              <div className="mt-4 text-sm text-orange-600 font-medium">
                Streamlined market access
              </div>
            </div>
            
            <div className="bg-white rounded-2xl p-8 shadow-lg">
              <div className="flex items-center gap-x-4">
                <div className="h-12 w-12 rounded-full bg-orange-100 flex items-center justify-center">
                  <ChartBarIcon className="h-6 w-6 text-orange-600" />
                </div>
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">Vintage Peach Boutique</h3>
                  <p className="text-sm text-gray-600">Curated vintage clothing</p>
                </div>
              </div>
              <blockquote className="mt-6 text-gray-600">
                "The unified vendor profile means when markets approve me, my vintage collection automatically appears in their directory. No more filling out forms repeatedly."
              </blockquote>
              <div className="mt-4 text-sm text-orange-600 font-medium">
                Eliminated duplicate data entry
              </div>
            </div>
            
            <div className="bg-white rounded-2xl p-8 shadow-lg">
              <div className="flex items-center gap-x-4">
                <div className="h-12 w-12 rounded-full bg-orange-100 flex items-center justify-center">
                  <MegaphoneIcon className="h-6 w-6 text-orange-600" />
                </div>
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">Southern Craft Studios</h3>
                  <p className="text-sm text-gray-600">Pottery & handmade crafts</p>
                </div>
              </div>
              <blockquote className="mt-6 text-gray-600">
                "I can create independent pop-ups for art shows and also participate in my approved craft markets. HiPop gives me complete flexibility."
              </blockquote>
              <div className="mt-4 text-sm text-orange-600 font-medium">
                Maximum scheduling flexibility
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Featured Vendors */}
      {vendors.length > 0 && (
        <div className="py-24 sm:py-32">
          <div className="mx-auto max-w-7xl px-6 lg:px-8">
            <div className="mx-auto max-w-2xl lg:mx-0">
              <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">Featured Vendors</h2>
              <p className="mt-2 text-lg leading-8 text-gray-600">
                Discover some of the amazing vendors in our network.
              </p>
            </div>
            <div className="mx-auto mt-16 grid max-w-2xl grid-cols-1 gap-8 sm:mt-20 lg:mx-0 lg:max-w-none lg:grid-cols-3">
              {vendors.slice(0, 6).map((vendor) => (
                <div key={vendor.id} className="bg-white rounded-lg border border-gray-200 p-6 hover:shadow-lg transition-shadow">
                  <h3 className="text-lg font-semibold text-gray-900">{vendor.businessName}</h3>
                  <p className="mt-2 text-sm text-gray-600 line-clamp-3">
                    {vendor.description || 'Local vendor offering quality products at farmers markets.'}
                  </p>
                  {vendor.categories.length > 0 && (
                    <div className="mt-4 flex flex-wrap gap-2">
                      {vendor.categories.slice(0, 3).map((category) => (
                        <span
                          key={category}
                          className="inline-flex items-center rounded-md bg-orange-50 px-2 py-1 text-xs font-medium text-orange-700 ring-1 ring-inset ring-orange-700/10"
                        >
                          {category}
                        </span>
                      ))}
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Getting Started */}
      <div className="bg-gray-50 py-24 sm:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl lg:text-center">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Ready to get started?
            </h2>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              Join HiPop today and start connecting with more customers in your local creative community.
            </p>
          </div>
          <div className="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-4xl">
            <dl className="grid max-w-xl grid-cols-1 gap-x-8 gap-y-10 lg:max-w-none lg:grid-cols-3 lg:gap-y-16">
              <div className="text-center">
                <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-lg bg-orange-600 text-white text-2xl font-bold">
                  1
                </div>
                <dt className="mt-4 text-base font-semibold leading-7 text-gray-900">Download the App</dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Get the HiPop Markets app and create your vendor account.
                </dd>
              </div>
              <div className="text-center">
                <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-lg bg-orange-600 text-white text-2xl font-bold">
                  2
                </div>
                <dt className="mt-4 text-base font-semibold leading-7 text-gray-900">Set Up Your Profile</dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Add your business information, products, and market schedule.
                </dd>
              </div>
              <div className="text-center">
                <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-lg bg-orange-600 text-white text-2xl font-bold">
                  3
                </div>
                <dt className="mt-4 text-base font-semibold leading-7 text-gray-900">Start Growing</dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Connect with customers and track your business growth.
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
              Start growing your business today
            </h2>
            <p className="mx-auto mt-6 max-w-xl text-lg leading-8 text-orange-100">
              Join thousands of vendors who are already using HiPop to connect with customers and grow their local creative business.
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
              <Link href="/markets" className="text-sm font-semibold leading-6 text-white">
                Browse Markets <span aria-hidden="true">→</span>
              </Link>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}