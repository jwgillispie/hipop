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
      <div className="relative isolate overflow-hidden bg-hipop-surface-gradient">
        <div className="mx-auto max-w-7xl px-6 py-24 sm:py-32 lg:px-8">
          <div className="mx-auto max-w-2xl text-center">
            <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-6xl">
              About
              <span className="text-hipop-primary"> HiPop</span>
            </h1>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              HiPop connects Atlanta's local creative community through innovative market and vendor management technology. 
              Our platform streamlines the relationship between market organizers, vendors, and shoppers across all types of local markets.
            </p>
          </div>
        </div>
      </div>

      {/* Mission Section */}
      <div className="py-24 sm:py-32">
        <div className="mx-auto max-w-7xl px-6 lg:px-8">
          <div className="mx-auto max-w-2xl lg:text-center">
            <h2 className="text-base font-semibold leading-7 text-hipop-primary">Our Mission</h2>
            <p className="mt-2 text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Atlanta's premier local market network
            </p>
            <p className="mt-6 text-lg leading-8 text-gray-600">
              HiPop was born from Atlanta's vibrant creative community. We've built sophisticated 
              permission-based systems, unified vendor management, and pop-up event tools that 
              revolutionize how all types of markets and vendors work together.
            </p>
          </div>
          <div className="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-4xl">
            <dl className="grid max-w-xl grid-cols-1 gap-x-8 gap-y-10 lg:max-w-none lg:grid-cols-2 lg:gap-y-16">
              <div className="relative pl-16">
                <dt className="text-base font-semibold leading-7 text-gray-900">
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-hipop-primary">
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
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-hipop-primary">
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
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-hipop-primary">
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
                  <div className="absolute left-0 top-0 flex h-10 w-10 items-center justify-center rounded-lg bg-hipop-primary">
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
      <div className="bg-hipop-surface py-24 sm:py-32">
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
              <h3 className="text-xl font-semibold text-gray-900 mb-4">The Atlanta Innovation</h3>
              <p className="text-gray-600 leading-7">
                Traditional market systems required vendors to apply for each event individually. 
                Market organizers struggled with duplicate vendor data and complex application processes. 
                Atlanta's growing creative market scene needed something better.
              </p>
            </div>
            <div className="bg-white rounded-2xl p-8 shadow-lg">
              <h3 className="text-xl font-semibold text-gray-900 mb-4">HiPop's Breakthrough</h3>
              <p className="text-gray-600 leading-7">
                We pioneered a permission-based system where vendors request market access once, 
                then create unlimited pop-ups. Unified vendor management eliminates duplicates. 
                Market organizers can create unlimited markets with comprehensive tools. 
                Atlanta's creative community now has the sophisticated platform it deserves.
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
                <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-lg bg-hipop-primary text-white mb-6">
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
                <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-lg bg-hipop-primary text-white mb-6">
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
                <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-lg bg-hipop-primary text-white mb-6">
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
      <div className="bg-hipop-surface py-24 sm:py-32">
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
              <div className="text-3xl font-bold text-hipop-primary">Unlimited</div>
              <div className="mt-2 text-sm font-medium text-gray-900">Market Creation</div>
              <div className="mt-1 text-sm text-gray-600">No restrictions for organizers</div>
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold text-hipop-primary">Unified</div>
              <div className="mt-2 text-sm font-medium text-gray-900">Vendor Management</div>
              <div className="mt-1 text-sm text-gray-600">No duplicate data entry</div>
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold text-hipop-primary">Permission</div>
              <div className="mt-2 text-sm font-medium text-gray-900">Based System</div>
              <div className="mt-1 text-sm text-gray-600">Apply once, create unlimited pop-ups</div>
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold text-hipop-primary">Atlanta</div>
              <div className="mt-2 text-sm font-medium text-gray-900">Focused Network</div>
              <div className="mt-1 text-sm text-gray-600">Built for our creative community</div>
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
              <h3 className="text-xl font-semibold text-gray-900 mb-4">Built by Atlanta's Creative Community</h3>
              <p className="text-gray-600 leading-7 mb-4">
                HiPop was created by people deeply embedded in Atlanta's diverse market scene. 
                Our team includes regular market shoppers, vendor advocates, and organizers who 
                understand the unique dynamics of Atlanta's farmers markets, artisan fairs, vintage markets, and pop-up community.
              </p>
              <p className="text-gray-600 leading-7">
                We've witnessed firsthand the challenges of traditional market management systems. 
                That's why we built sophisticated solutions like permission-based vendor relationships, 
                unified management tools, and flexible pop-up systems that reflect how Atlanta's 
                diverse creative community actually works.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* CTA Section */}
      <div className="bg-hipop-gradient">
        <div className="px-6 py-24 sm:px-6 sm:py-32 lg:px-8">
          <div className="mx-auto max-w-2xl text-center">
            <h2 className="text-3xl font-bold tracking-tight text-white sm:text-4xl">
              Join our mission
            </h2>
            <p className="mx-auto mt-6 max-w-xl text-lg leading-8 text-white/90">
              Whether you're a shopper looking for fresh local food, a vendor wanting to grow your business, 
              or a market organizer seeking better tools, we'd love to have you as part of our community.
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