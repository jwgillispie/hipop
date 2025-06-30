import Link from 'next/link';
import { HeartIcon, UserGroupIcon, MapPinIcon, SparklesIcon } from '@heroicons/react/24/outline';

export const metadata = {
  title: 'About HiPop Markets - Our Mission & Story',
  description: 'Learn about HiPop Markets mission to connect communities with local farmers and artisans. Discover how we\'re making fresh, local food more accessible.',
  keywords: 'about HiPop Markets, local food mission, farmers market platform, community connection, sustainable agriculture',
};

export default function About() {
  return (
    <div className="bg-white">
      {/* Hero Section */}
      <div className="relative isolate overflow-hidden bg-gradient-to-b from-orange-100/20">
        <div className="mx-auto max-w-7xl px-6 py-24 sm:py-32 lg:px-8">
          <div className="mx-auto max-w-2xl text-center">
            <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-6xl">
              About
              <span className="text-orange-600"> HiPop Markets</span>
            </h1>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              We believe that everyone should have access to fresh, local food and the opportunity 
              to connect with the people who grow it. HiPop Markets bridges the gap between 
              communities and their local food systems.
            </p>
          </div>
        </div>
      </div>

      {/* Mission Section */}
      <div className="py-24 sm:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl lg:text-center">
            <h2 className="text-base font-semibold leading-7 text-orange-600">Our Mission</h2>
            <p className="mt-2 text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Connecting communities with local food
            </p>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              HiPop Markets was born from a simple idea: technology can make it easier for people 
              to discover, connect with, and support their local food community. We're building 
              the bridge between farmers markets and the digital age.
            </p>
          </div>
          <div className="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-4xl">
            <dl className="grid max-w-xl grid-cols-1 gap-x-8 gap-y-10 lg:max-w-none lg:grid-cols-2 lg:gap-y-16">
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <HeartIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Community First
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  Every feature we build is designed to strengthen the connections between shoppers, 
                  vendors, and market organizers in local communities.
                </dd>
              </div>
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <UserGroupIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Supporting Local Business
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  We provide tools that help small farmers and artisans grow their businesses 
                  and connect with customers who value local, sustainable food.
                </dd>
              </div>
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <MapPinIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Accessible to All
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  We make it simple for anyone to find and participate in their local food system, 
                  regardless of their technical expertise or background.
                </dd>
              </div>
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-orange-600">
                    <SparklesIcon className="h-6 w-6 text-white" aria-hidden="true" />
                  </div>
                  Innovation with Purpose
                </dt>
                <dd className="mt-2 text-base leading-7 text-gray-600">
                  We leverage technology to solve real problems in local food systems, 
                  always keeping the human element at the center of what we do.
                </dd>
              </div>
            </dl>
          </div>
        </div>
      </div>

      {/* Story Section */}
      <div className="bg-gray-50 py-24 sm:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl lg:mx-0">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">Our Story</h2>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              HiPop Markets started when our founders realized how difficult it was to find 
              reliable information about local farmers markets. What began as a simple directory 
              has evolved into a comprehensive platform that serves the entire farmers market ecosystem.
            </p>
          </div>
          <div className="mx-auto mt-16 grid max-w-2xl grid-cols-1 gap-8 lg:mx-0 lg:max-w-none lg:grid-cols-2">
            <div className="bg-white rounded-2xl p-8 shadow-lg">
              <h3 className="text-xl font-semibold text-gray-900 mb-4">The Problem We Saw</h3>
              <p className="text-gray-600 leading-7">
                Farmers markets are vital community hubs, but information about them was scattered, 
                outdated, or hard to find. Vendors struggled to reach customers, shoppers couldn't 
                find what they were looking for, and market organizers lacked tools to manage and 
                promote their markets effectively.
              </p>
            </div>
            <div className="bg-white rounded-2xl p-8 shadow-lg">
              <h3 className="text-xl font-semibold text-gray-900 mb-4">Our Solution</h3>
              <p className="text-gray-600 leading-7">
                We built a platform that brings together all the stakeholders in the farmers market 
                ecosystem. Shoppers can easily find markets and vendors, vendors can manage their 
                presence and connect with customers, and organizers can efficiently run their markets 
                with real-time insights.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Values Section */}
      <div className="py-24 sm:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl lg:text-center">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              What We Stand For
            </h2>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              Our values guide every decision we make and every feature we build.
            </p>
          </div>
          <div className="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-4xl">
            <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
              <div className="text-center">
                <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-lg bg-orange-600 text-white mb-6">
                  <svg className="h-8 w-8" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M12 3v2.25m6.364.386l-1.591 1.591M21 12h-2.25m-.386 6.364l-1.591-1.591M12 18.75V21m-4.773-4.227l-1.591 1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75 12a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0z" />
                  </svg>
                </div>
                <h3 className="text-lg font-semibold text-gray-900">Sustainability</h3>
                <p className="mt-2 text-gray-600">
                  We believe in supporting sustainable agriculture and reducing food miles by 
                  connecting people with local producers.
                </p>
              </div>
              <div className="text-center">
                <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-lg bg-orange-600 text-white mb-6">
                  <svg className="h-8 w-8" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M18 18.72a9.094 9.094 0 003.741-.479 3 3 0 00-4.682-2.72m.94 3.198l.001.031c0 .225-.012.447-.037.666A11.944 11.944 0 0112 21c-2.17 0-4.207-.576-5.963-1.584A6.062 6.062 0 016 18.719m12 0a5.971 5.971 0 00-.941-3.197m0 0A5.995 5.995 0 0012 12.75a5.995 5.995 0 00-5.058 2.772m0 0a3 3 0 00-4.681 2.72 8.986 8.986 0 003.74.477m.94-3.197a5.971 5.971 0 00-.94 3.197M15 6.75a3 3 0 11-6 0 3 3 0 016 0zm6 3a2.25 2.25 0 11-4.5 0 2.25 2.25 0 014.5 0zm-13.5 0a2.25 2.25 0 11-4.5 0 2.25 2.25 0 014.5 0z" />
                  </svg>
                </div>
                <h3 className="text-lg font-semibold text-gray-900">Community</h3>
                <p className="mt-2 text-gray-600">
                  Local food systems are about more than transactions - they're about building 
                  relationships and strengthening communities.
                </p>
              </div>
              <div className="text-center">
                <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-lg bg-orange-600 text-white mb-6">
                  <svg className="h-8 w-8" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M3.75 13.5l10.5-11.25L12 10.5h8.25L9.75 21.75 12 13.5H3.75z" />
                  </svg>
                </div>
                <h3 className="text-lg font-semibold text-gray-900">Simplicity</h3>
                <p className="mt-2 text-gray-600">
                  Good technology should be invisible. We focus on creating intuitive, 
                  easy-to-use tools that get out of the way and let people connect.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Impact Section */}
      <div className="bg-gray-50 py-24 sm:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl lg:text-center">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Our Impact
            </h2>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              We measure our success by the strength of the communities we serve.
            </p>
          </div>
          <div className="mx-auto mt-16 grid max-w-2xl grid-cols-1 gap-8 sm:mt-20 lg:mx-0 lg:max-w-none lg:grid-cols-4">
            <div className="text-center">
              <div className="text-3xl font-bold text-orange-600">1000+</div>
              <div className="mt-2 text-sm font-medium text-gray-900">Markets Connected</div>
              <div className="mt-1 text-sm text-gray-600">Farmers markets using our platform</div>
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold text-orange-600">5000+</div>
              <div className="mt-2 text-sm font-medium text-gray-900">Active Vendors</div>
              <div className="mt-1 text-sm text-gray-600">Local businesses growing with us</div>
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold text-orange-600">50,000+</div>
              <div className="mt-2 text-sm font-medium text-gray-900">Community Members</div>
              <div className="mt-1 text-sm text-gray-600">Shoppers discovering local food</div>
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold text-orange-600">200+</div>
              <div className="mt-2 text-sm font-medium text-gray-900">Cities Served</div>
              <div className="mt-1 text-sm text-gray-600">Communities across the country</div>
            </div>
          </div>
        </div>
      </div>

      {/* Team Section */}
      <div className="py-24 sm:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl lg:text-center">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Built by people who care
            </h2>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              Our team combines deep expertise in technology with a genuine passion for 
              local food systems and community building.
            </p>
          </div>
          <div className="mx-auto mt-16 max-w-2xl lg:mx-0 lg:max-w-none">
            <div className="bg-white rounded-2xl p-8 shadow-lg">
              <h3 className="text-xl font-semibold text-gray-900 mb-4">A Diverse Team United by Purpose</h3>
              <p className="text-gray-600 leading-7 mb-4">
                Our team includes software engineers, designers, farmers market organizers, 
                and local food advocates. This diversity of perspectives ensures that we build 
                solutions that truly serve the needs of the entire farmers market ecosystem.
              </p>
              <p className="text-gray-600 leading-7">
                We're distributed across the country, which keeps us connected to local food 
                communities from coast to coast. Many of us are regular farmers market shoppers 
                ourselves, so we understand firsthand the challenges and opportunities we're working to address.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* CTA Section */}
      <div className="bg-orange-600">
        <div className="px-6 py-24 sm:px-6 sm:py-32 lg:px-8">
          <div className="mx-auto max-w-2xl text-center">
            <h2 className="text-3xl font-bold tracking-tight text-white sm:text-4xl">
              Join our mission
            </h2>
            <p className="mx-auto mt-6 max-w-xl text-lg leading-8 text-orange-100">
              Whether you're a shopper looking for fresh local food, a vendor wanting to grow your business, 
              or a market organizer seeking better tools, we'd love to have you as part of our community.
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
                Explore Markets <span aria-hidden="true">→</span>
              </Link>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}