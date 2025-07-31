import Link from 'next/link';
import { ArrowRightIcon, MapPinIcon, ShoppingBagIcon, HeartIcon } from '@heroicons/react/24/outline';
import { getFeaturedMarkets } from '@/lib/data';

export default async function Home() {
  const featuredMarkets = await getFeaturedMarkets(6);

  return (
    <div>
      {/* Hero Section */}
      <div className="relative isolate overflow-hidden bg-gradient-to-b from-orange-100/20">
        <div className="mx-auto max-w-7xl pb-24 pt-10 sm:pb-32 lg:grid lg:grid-cols-2 lg:gap-x-8 lg:px-8 lg:py-40">
          <div className="px-6 lg:px-0 lg:pt-4">
            <div className="mx-auto max-w-2xl">
              <div className="max-w-lg">
                <h1 className="mt-10 text-4xl font-bold tracking-tight text-gray-900 sm:text-6xl">
                  Atlanta's Premier
                  <span className="text-orange-600"> Local Market Network</span>
                </h1>
                <p className="mt-6 text-lg leading-8 text-gray-600">
                  Connect Atlanta's creative community through farmers markets, artisan fairs, vintage markets, and pop-up events. 
                  HiPop brings together market organizers, vendors, and shoppers in one seamless platform.
                </p>
                <div className="mt-10 flex items-center gap-x-6">
                  <Link
                    href="https://hipop-markets.web.app"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="rounded-md bg-orange-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-orange-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-orange-600"
                  >
                    Go to the App
                  </Link>
                  <Link href="/markets" className="text-sm font-semibold leading-6 text-gray-900">
                    Browse Markets <span aria-hidden="true">→</span>
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
                            HiPop Markets
                          </div>
                        </div>
                      </div>
                      <div className="px-6 pb-14 pt-6">
                        {/* Mock app interface */}
                        <div className="text-white text-sm space-y-4">
                          <div className="flex items-center space-x-2">
                            <MapPinIcon className="h-5 w-5 text-orange-400" />
                            <span>Find markets near you</span>
                          </div>
                          <div className="flex items-center space-x-2">
                            <ShoppingBagIcon className="h-5 w-5 text-green-400" />
                            <span>Discover fresh local produce</span>
                          </div>
                          <div className="flex items-center space-x-2">
                            <HeartIcon className="h-5 w-5 text-red-400" />
                            <span>Save your favorite vendors</span>
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
            <h2 className="text-base font-semibold leading-7 text-orange-600">Everything you need</h2>
            <p className="mt-2 text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Connect with your local creative community
            </p>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              HiPop brings together shoppers, vendors, and market organizers in one seamless platform.
            </p>
          </div>
          <div className="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-4xl">
            <dl className="grid max-w-xl grid-cols-1 gap-x-8 gap-y-10 lg:max-w-none lg:grid-cols-2 lg:gap-y-16">
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <MapPinIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Smart Market Discovery
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Find Atlanta-area farmers markets, artisan fairs, vintage markets, and pop-up events with detailed vendor info, schedules, and real-time updates.
                </dd>
              </div>
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <ShoppingBagIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Vendor-Market Connections
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  HiPop's permission system lets vendors request access to markets, while organizers can manage their vendor community seamlessly.
                </dd>
              </div>
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <HeartIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Pop-up Event System
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Vendors can create independent pop-ups or associate with approved markets. Shoppers discover both regular market days and special events.
                </dd>
              </div>
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <ArrowRightIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Unified Management
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Market organizers get unlimited market creation, unified vendor lists, and comprehensive application management tools.
                </dd>
              </div>
            </dl>
          </div>
        </div>
      </div>

      {/* Featured Markets */}
      {featuredMarkets.length > 0 && (
        <div className="bg-gray-50 py-24 sm:py-32">
          <div className="mx-auto max-w-7xl px-6 lg:px-8">
            <div className="mx-auto max-w-2xl lg:mx-0">
              <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">Featured Markets</h2>
              <p className="mt-2 text-lg leading-8 text-gray-600">
                Discover some of the amazing farmers markets in our network.
              </p>
            </div>
            <div className="mx-auto mt-10 grid max-w-2xl grid-cols-1 gap-x-8 gap-y-16 border-t border-gray-200 pt-10 sm:mt-16 sm:pt-16 lg:mx-0 lg:max-w-none lg:grid-cols-3">
              {featuredMarkets.map((market) => (
                <article key={market.id} className="flex max-w-xl flex-col items-start justify-between">
                  <div className="group relative">
                    <h3 className="mt-3 text-lg font-semibold leading-6 text-gray-900 group-hover:text-gray-600">
                      <Link href={`/markets/${market.id}`}>
                        <span className="absolute inset-0" />
                        {market.name}
                      </Link>
                    </h3>
                    <p className="mt-5 line-clamp-3 text-sm leading-6 text-gray-600">
                      {market.description || `Located in ${market.city}, ${market.state}`}
                    </p>
                  </div>
                  <div className="relative mt-8 flex items-center gap-x-4">
                    <div className="text-sm leading-6">
                      <p className="font-semibold text-gray-900">
                        <span className="absolute inset-0" />
                        {market.city}, {market.state}
                      </p>
                      <p className="text-gray-600">{Array.isArray(market.operatingDays) ? market.operatingDays.join(', ') : 'Check app for days'}</p>
                    </div>
                  </div>
                </article>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* CTA Section */}
      <div className="bg-orange-600">
        <div className="px-6 py-24 sm:px-6 sm:py-32 lg:px-8">
          <div className="mx-auto max-w-2xl text-center">
            <h2 className="text-3xl font-bold tracking-tight text-white sm:text-4xl">
              Ready to discover local markets?
            </h2>
            <p className="mx-auto mt-6 max-w-xl text-lg leading-8 text-orange-100">
              Go to the HiPop Markets app and start exploring fresh, local food in your community today.
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