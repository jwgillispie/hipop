import Link from 'next/link';
import { BuildingStorefrontIcon, UserGroupIcon, ChartBarIcon, CogIcon } from '@heroicons/react/24/outline';
import PricingSection from '@/components/PricingSection';

export const metadata = {
  title: 'For Market Organizers - Manage Your Farmers Market with HiPop',
  description: 'Manage unlimited farmers markets, process vendor applications, and build community with HiPop\'s comprehensive market organizer tools.',
  keywords: 'farmers market management, market organizer tools, vendor applications, market administration',
};

export default function Organizers() {
  return (
    <div className="bg-white">
      {/* Hero Section */}
      <div className="relative isolate overflow-hidden bg-gradient-to-b from-orange-100/20">
        <div className="mx-auto max-w-7xl pb-24 pt-10 sm:pb-32 lg:grid lg:grid-cols-2 lg:gap-x-8 lg:px-8 lg:py-40">
          <div className="px-6 lg:px-0 lg:pt-4">
            <div className="mx-auto max-w-2xl">
              <div className="max-w-lg">
                <h1 className="mt-10 text-4xl font-bold tracking-tight text-gray-900 sm:text-6xl">
                  Manage Your
                  <span className="text-orange-600"> Local Market</span>
                </h1>
                <p className="mt-6 text-lg leading-8 text-gray-600">
                  HiPop provides comprehensive tools for all market organizers: farmers markets, artisan fairs, vintage markets, and pop-up events. 
                  Unlimited market creation, unified vendor management, permission-based applications, and community building.
                </p>
                <div className="mt-10 flex items-center gap-x-6">
                  <Link
                    href="https://hipop-markets.web.app"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="rounded-md bg-orange-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-orange-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-orange-600"
                  >
                    Start Managing
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
                            Market Dashboard
                          </div>
                        </div>
                      </div>
                      <div className="px-6 pb-14 pt-6">
                        <div className="text-white text-sm space-y-4">
                          <div className="flex items-center justify-between">
                            <span>Associated Vendors</span>
                            <span className="text-orange-400 font-semibold">23 (unified)</span>
                          </div>
                          <div className="flex items-center justify-between">
                            <span>Permission Requests</span>
                            <span className="text-green-400 font-semibold">3 pending</span>
                          </div>
                          <div className="flex items-center justify-between">
                            <span>Markets Managed</span>
                            <span className="text-blue-400">Unlimited</span>
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
            <h2 className="text-base font-semibold leading-7 text-orange-600">Complete toolkit</h2>
            <p className="mt-2 text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Everything you need to manage local markets
            </p>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              From unlimited market creation to unified vendor management, HiPop streamlines every aspect of market organization for all types of local markets.
            </p>
          </div>
          <div className="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-4xl">
            <dl className="grid max-w-xl grid-cols-1 gap-x-8 gap-y-10 lg:max-w-none lg:grid-cols-2 lg:gap-y-16">
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <BuildingStorefrontIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Unlimited Market Creation
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Create and manage unlimited local markets with no restrictions. Perfect for farmers markets, artisan fairs, vintage markets, pop-ups, or expanding your market network.
                </dd>
              </div>
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <UserGroupIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Unified Vendor Management
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  See all your vendors in one place with clear source attribution. Whether they came from permissions, applications, or manual additions - no duplicates.
                </dd>
              </div>
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <ChartBarIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Permission-Based Applications
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Review vendor permission requests once, granting ongoing access for pop-up creation. Build lasting relationships with trusted vendors.
                </dd>
              </div>
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <CogIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Comprehensive Market Setup
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Configure market schedules, locations, vendor policies, and community guidelines all from your unified dashboard.
                </dd>
              </div>
            </dl>
          </div>
        </div>
      </div>

      {/* Pricing Section - Commented out until market validation */}
      {/* <PricingSection userType="organizer" /> */}

      {/* Getting Started */}
      <div className="bg-gray-50 py-24 sm:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl lg:text-center">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Ready to organize your market?
            </h2>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              Join Atlanta's diverse market organizer community and start building stronger vendor relationships across all market types with HiPop's comprehensive tools.
            </p>
          </div>
          <div className="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-4xl">
            <dl className="grid max-w-xl grid-cols-1 gap-x-8 gap-y-10 lg:max-w-none lg:grid-cols-3 lg:gap-y-16">
              <div className="text-center">
                <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-lg bg-orange-600 text-white text-2xl font-bold">
                  1
                </div>
                <dt className="mt-4 text-base font-semibold leading-7 text-gray-900">Create Account</dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Sign up for HiPop and select the market organizer profile type.
                </dd>
              </div>
              <div className="text-center">
                <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-lg bg-orange-600 text-white text-2xl font-bold">
                  2
                </div>
                <dt className="mt-4 text-base font-semibold leading-7 text-gray-900">Set Up Your Market</dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Add market details, schedules, and location information.
                </dd>
              </div>
              <div className="text-center">
                <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-lg bg-orange-600 text-white text-2xl font-bold">
                  3
                </div>
                <dt className="mt-4 text-base font-semibold leading-7 text-gray-900">Manage Vendors</dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Review permission requests and build your vendor community.
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
              Start organizing your market today
            </h2>
            <p className="mx-auto mt-6 max-w-xl text-lg leading-8 text-orange-100">
              Join Atlanta's diverse market organizer community and access HiPop's comprehensive market management tools for all market types.
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