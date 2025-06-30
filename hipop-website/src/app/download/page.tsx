import Link from 'next/link';
import { ArrowDownTrayIcon, DevicePhoneMobileIcon, GlobeAltIcon } from '@heroicons/react/24/outline';

export const metadata = {
  title: 'Download HiPop Markets App - iOS & Android',
  description: 'Download the HiPop Markets app for iOS and Android. Find farmers markets, discover fresh local produce, and connect with vendors in your community.',
  keywords: 'download HiPop Markets app, farmers market app iOS, farmers market app Android, local food app',
};

export default function Download() {
  return (
    <div className="bg-white">
      {/* Hero Section */}
      <div className="relative isolate overflow-hidden bg-gradient-to-b from-orange-100/20">
        <div className="mx-auto max-w-7xl pb-24 pt-10 sm:pb-32 lg:grid lg:grid-cols-2 lg:gap-x-8 lg:px-8 lg:py-40">
          <div className="px-6 lg:px-0 lg:pt-4">
            <div className="mx-auto max-w-2xl">
              <div className="max-w-lg">
                <h1 className="mt-10 text-4xl font-bold tracking-tight text-gray-900 sm:text-6xl">
                  Download
                  <span className="text-orange-600"> HiPop Markets</span>
                </h1>
                <p className="mt-6 text-lg leading-8 text-gray-600">
                  Get the app and start discovering the best farmers markets in your area. 
                  Available for iOS and Android devices.
                </p>
                <div className="mt-10 flex flex-col gap-y-4 sm:flex-row sm:gap-x-6">
                  {/* App Store Button */}
                  <a
                    href="https://apps.apple.com/app/hipop-markets/idXXXXXX"
                    className="flex items-center justify-center rounded-lg bg-black px-6 py-3 text-white hover:bg-gray-800 transition-colors"
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    <svg className="w-7 h-7 mr-3" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
                    </svg>
                    <div className="text-left">
                      <div className="text-xs">Download on the</div>
                      <div className="text-sm font-semibold">App Store</div>
                    </div>
                  </a>

                  {/* Google Play Button */}
                  <a
                    href="https://play.google.com/store/apps/details?id=com.hipop.markets"
                    className="flex items-center justify-center rounded-lg bg-black px-6 py-3 text-white hover:bg-gray-800 transition-colors"
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    <svg className="w-7 h-7 mr-3" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M3,20.5V3.5C3,2.91 3.34,2.39 3.84,2.15L13.69,12L3.84,21.85C3.34,21.6 3,21.09 3,20.5M16.81,15.12L6.05,21.34L14.54,12.85L16.81,15.12M20.16,10.81C20.5,11.08 20.75,11.5 20.75,12C20.75,12.5 20.53,12.9 20.18,13.18L17.89,14.5L15.39,12L17.89,9.5L20.16,10.81M6.05,2.66L16.81,8.88L14.54,11.15L6.05,2.66Z"/>
                    </svg>
                    <div className="text-left">
                      <div className="text-xs">Get it on</div>
                      <div className="text-sm font-semibold">Google Play</div>
                    </div>
                  </a>
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
                            HiPop Markets App
                          </div>
                        </div>
                      </div>
                      <div className="px-6 pb-14 pt-6">
                        {/* Phone mockup */}
                        <div className="bg-white rounded-3xl p-6 shadow-2xl max-w-sm mx-auto">
                          <div className="text-center space-y-4">
                            <div className="w-16 h-16 bg-orange-600 rounded-2xl mx-auto flex items-center justify-center">
                              <DevicePhoneMobileIcon className="h-10 w-10 text-white" />
                            </div>
                            <h3 className="text-lg font-bold text-gray-900">HiPop Markets</h3>
                            <p className="text-sm text-gray-600">Find fresh, local produce and connect with vendors in your community.</p>
                            <div className="flex space-x-2 justify-center">
                              <div className="w-2 h-2 bg-orange-600 rounded-full"></div>
                              <div className="w-2 h-2 bg-gray-300 rounded-full"></div>
                              <div className="w-2 h-2 bg-gray-300 rounded-full"></div>
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
      </div>

      {/* Features Section */}
      <div className="py-24 sm:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl lg:text-center">
            <h2 className="text-base font-semibold leading-7 text-orange-600">Why Download HiPop?</h2>
            <p className="mt-2 text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Everything you need to explore local markets
            </p>
          </div>
          <div className="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-4xl">
            <dl className="grid max-w-xl grid-cols-1 gap-x-8 gap-y-10 lg:max-w-none lg:grid-cols-2 lg:gap-y-16">
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <GlobeAltIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Real-time Market Info
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Get up-to-date information about market hours, vendor availability, and special events.
                </dd>
              </div>
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <ArrowDownTrayIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Offline Access
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Save market information for offline viewing when you're on the go.
                </dd>
              </div>
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <DevicePhoneMobileIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Location-based Search
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Find markets near your current location or search by city and neighborhood.
                </dd>
              </div>
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <svg className="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M21 8.25c0-2.485-2.099-4.5-4.688-4.5-1.935 0-3.597 1.126-4.312 2.733-.715-1.607-2.377-2.733-4.313-2.733C5.1 3.75 3 5.765 3 8.25c0 7.22 9 12 9 12s9-4.78 9-12z" />
                    </svg>
                  </div>
                  Save Favorites
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Keep track of your favorite markets and vendors for easy access.
                </dd>
              </div>
            </dl>
          </div>
        </div>
      </div>

      {/* QR Code Section */}
      <div className="bg-gray-50 py-24 sm:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl text-center">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Scan to Download
            </h2>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              Use your phone's camera to scan the QR code and download the app instantly.
            </p>
            <div className="mt-10 flex justify-center">
              <div className="bg-white p-8 rounded-2xl shadow-lg">
                {/* QR Code placeholder - replace with actual QR code */}
                <div className="w-48 h-48 bg-gray-200 rounded-lg flex items-center justify-center">
                  <div className="text-center">
                    <DevicePhoneMobileIcon className="h-12 w-12 text-gray-400 mx-auto mb-2" />
                    <p className="text-sm text-gray-500">QR Code</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* System Requirements */}
      <div className="py-24 sm:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl lg:text-center">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              System Requirements
            </h2>
          </div>
          <div className="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-4xl">
            <div className="grid grid-cols-1 gap-8 lg:grid-cols-2">
              <div className="bg-white rounded-lg border border-gray-200 p-8">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">iOS</h3>
                <ul className="space-y-2 text-gray-600">
                  <li>• iOS 14.0 or later</li>
                  <li>• iPhone, iPad, and iPod touch</li>
                  <li>• 50 MB storage space</li>
                  <li>• Internet connection required</li>
                </ul>
              </div>
              <div className="bg-white rounded-lg border border-gray-200 p-8">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">Android</h3>
                <ul className="space-y-2 text-gray-600">
                  <li>• Android 7.0 (API level 24) or later</li>
                  <li>• 50 MB storage space</li>
                  <li>• Internet connection required</li>
                  <li>• Location services recommended</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* CTA Section */}
      <div className="bg-orange-600">
        <div className="px-6 py-24 sm:px-6 sm:py-32 lg:px-8">
          <div className="mx-auto max-w-2xl text-center">
            <h2 className="text-3xl font-bold tracking-tight text-white sm:text-4xl">
              Start exploring today
            </h2>
            <p className="mx-auto mt-6 max-w-xl text-lg leading-8 text-orange-100">
              Join thousands of users who have already discovered their local food community with HiPop Markets.
            </p>
            <div className="mt-10 flex flex-col gap-y-4 sm:flex-row sm:gap-x-6 sm:justify-center">
              <a
                href="https://apps.apple.com/app/hipop-markets/idXXXXXX"
                className="flex items-center justify-center rounded-lg bg-white px-6 py-3 text-orange-600 hover:bg-gray-100 transition-colors"
                target="_blank"
                rel="noopener noreferrer"
              >
                Download for iOS
              </a>
              <a
                href="https://play.google.com/store/apps/details?id=com.hipop.markets"
                className="flex items-center justify-center rounded-lg bg-white px-6 py-3 text-orange-600 hover:bg-gray-100 transition-colors"
                target="_blank"
                rel="noopener noreferrer"
              >
                Download for Android
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}