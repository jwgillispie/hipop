import Link from 'next/link';
import { CheckIcon } from '@heroicons/react/24/outline';

interface PricingTier {
  name: string;
  price: string;
  description: string;
  features: string[];
  ctaText: string;
  ctaLink: string;
  highlighted?: boolean;
  badge?: string;
}

interface PricingSectionProps {
  userType: 'organizer' | 'vendor' | 'shopper';
  title?: string;
  description?: string;
}

export default function PricingSection({ userType, title, description }: PricingSectionProps) {
  const getOrganizerTiers = (): PricingTier[] => [
    {
      name: 'Free',
      price: 'Free Forever',
      description: 'Perfect for getting started',
      badge: 'Always Free',
      features: [
        'Manage up to 2 markets',
        'Vendor communications',
        '1 vendor post per month',
        'Basic vendor management',
        'Application review tools',
        'Community access'
      ],
      ctaText: 'Start Free',
      ctaLink: 'https://hipop-markets.web.app',
      highlighted: true
    },
    {
      name: 'Market Organizer Pro',
      price: '$69/month',
      description: 'For serious market organizers',
      badge: 'Most Popular',
      features: [
        'Unlimited markets',
        'Unlimited events',
        'Vendor discovery tools',
        'Multi-market management',
        'Vendor analytics dashboard',
        'Bulk messaging & templates',
        'Financial reporting',
        'Unlimited vendor posts',
        'Priority vendor matching',
        'Advanced communication suite'
      ],
      ctaText: 'Upgrade Now',
      ctaLink: 'https://hipop-markets.web.app'
    },
    {
      name: 'Enterprise',
      price: '$199/month',
      description: 'For large market networks & organizations',
      badge: 'Full Suite',
      features: [
        'All Market Organizer Pro features',
        'White-label analytics',
        'API access',
        'Custom reporting',
        'Custom branding',
        'Dedicated account manager',
        'Advanced data export',
        'Third-party integrations',
        'Enterprise SLA',
        'Custom training & onboarding'
      ],
      ctaText: 'Contact Sales',
      ctaLink: 'mailto:hipopmarkets@gmail.com'
    }
  ];

  const getVendorTiers = (): PricingTier[] => [
    {
      name: 'Free',
      price: 'Free Forever',
      description: 'Perfect for getting started',
      badge: 'Always Free',
      features: [
        'Basic vendor profile',
        'Up to 5 market applications per month',
        'Up to 3 photos per post',
        'Up to 3 global products',
        '1 product list',
        '3 popup posts per month',
        'Application status tracking',
        'Community access'
      ],
      ctaText: 'Start Free',
      ctaLink: 'https://hipop-markets.web.app',
      highlighted: true
    },
    {
      name: 'Vendor Premium',
      price: '$29/month',
      description: 'Full access to all vendor tools',
      badge: 'Best Value',
      features: [
        'All Free features',
        'Market discovery tools',
        'Full vendor analytics',
        'Product performance analytics',
        'Revenue & sales tracking',
        'Unlimited markets',
        'Customer acquisition analysis',
        'Profit optimization tools',
        'Market expansion recommendations',
        'Seasonal business planning',
        'Weather correlation data',
        'Priority support'
      ],
      ctaText: 'Upgrade Now',
      ctaLink: 'https://hipop-markets.web.app'
    }
  ];

  const getShopperTiers = (): PricingTier[] => [
    {
      name: 'Free Forever',
      price: 'Free',
      description: 'Complete market discovery experience for everyone',
      badge: 'Everything Included',
      features: [
        'Search cities and markets',
        'Find vendors and products',
        'Advanced search & filtering',
        'Unlimited favorites',
        'Personal calendar',
        'Market schedules & events',
        'Vendor following',
        'Market alerts & notifications',
        'Community access',
        'Mobile app access'
      ],
      ctaText: 'Start Shopping',
      ctaLink: 'https://hipop-markets.web.app',
      highlighted: true
    }
  ];

  const getTiers = () => {
    switch (userType) {
      case 'organizer':
        return getOrganizerTiers();
      case 'vendor':
        return getVendorTiers();
      case 'shopper':
        return getShopperTiers();
      default:
        return [];
    }
  };

  const getDefaultTitle = () => {
    switch (userType) {
      case 'organizer':
        return 'Simple, transparent pricing for market organizers';
      case 'vendor':
        return 'Affordable pricing that grows with your business';
      case 'shopper':
        return 'Everything free forever for shoppers';
      default:
        return 'Choose your plan';
    }
  };

  const getDefaultDescription = () => {
    switch (userType) {
      case 'organizer':
        return 'Start free with basic market management, upgrade to Pro for $69/month for advanced features, or choose Enterprise for $199/month for large organizations.';
      case 'vendor':
        return 'Start completely free with essential vendor tools, or upgrade to Premium for $29/month to unlock advanced analytics and unlimited market access.';
      case 'shopper':
        return 'Search cities, find vendors and products, save unlimited favorites, and access your personal calendar - all completely free forever.';
      default:
        return '';
    }
  };

  const tiers = getTiers();

  return (
    <div className="bg-white py-24 sm:py-32">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="mx-auto max-w-4xl text-center">
          <h2 className="text-base font-semibold leading-7 text-hipop-primary">Pricing</h2>
          <p className="mt-2 text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl">
            {title || getDefaultTitle()}
          </p>
        </div>
        <p className="mx-auto mt-6 max-w-2xl text-center text-lg leading-8 text-gray-600">
          {description || getDefaultDescription()}
        </p>
        <div className={`isolate mx-auto mt-16 grid max-w-md grid-cols-1 gap-y-8 sm:mt-20 lg:mx-0 lg:max-w-none ${
          tiers.length === 2 ? 'lg:grid-cols-2' : 'lg:grid-cols-3'
        }`}>
          {tiers.map((tier, tierIdx) => (
            <div
              key={tier.name}
              className={`flex flex-col justify-between rounded-3xl bg-white p-8 ring-1 xl:p-10 ${
                tier.highlighted
                  ? 'ring-2 ring-hipop-primary lg:z-10 lg:rounded-b-none'
                  : 'ring-[#E8D4E0] lg:mt-8'
              } ${tierIdx === 0 ? 'lg:rounded-r-none' : ''} ${
                tierIdx === tiers.length - 1 ? 'lg:rounded-l-none' : ''
              }`}
            >
              <div>
                <div className="flex items-center justify-between gap-x-4">
                  <h3 className="text-lg font-semibold leading-8 text-gray-900">
                    {tier.name}
                  </h3>
                  {tier.badge && (
                    <p className="rounded-full bg-hipop-primary/10 px-2.5 py-1 text-xs font-semibold leading-5 text-hipop-primary">
                      {tier.badge}
                    </p>
                  )}
                </div>
                <p className="mt-4 text-sm leading-6 text-gray-600">{tier.description}</p>
                <p className="mt-6 flex items-baseline gap-x-1">
                  <span className="text-4xl font-bold tracking-tight text-gray-900">
                    {tier.price.includes('$') ? tier.price.split('/')[0] : tier.price}
                  </span>
                  {tier.price.includes('/') && (
                    <span className="text-sm font-semibold leading-6 text-gray-600">
                      /{tier.price.split('/')[1]}
                    </span>
                  )}
                </p>
                <ul role="list" className="mt-8 space-y-3 text-sm leading-6 text-gray-600">
                  {tier.features.map((feature) => (
                    <li key={feature} className="flex gap-x-3">
                      <CheckIcon
                        className="h-6 w-5 flex-none text-hipop-primary"
                        aria-hidden="true"
                      />
                      {feature}
                    </li>
                  ))}
                </ul>
              </div>
              <Link
                href={tier.ctaLink}
                target="_blank"
                rel="noopener noreferrer"
                className={`mt-8 block rounded-md px-3 py-2 text-center text-sm font-semibold leading-6 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 ${
                  tier.highlighted
                    ? 'bg-hipop-primary text-white shadow-sm hover:bg-[#3D6450] focus-visible:outline-[#558B6E]'
                    : 'text-hipop-primary ring-1 ring-inset ring-[#E8D4E0] hover:ring-[#F1C8DB] focus-visible:outline-[#558B6E]'
                }`}
              >
                {tier.ctaText}
              </Link>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}