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
      name: 'Pioneer Organizer',
      price: 'Free Forever',
      description: 'For the first 3 market organizers to join',
      badge: 'Limited Spots',
      features: [
        'Completely free forever',
        'Unlimited markets',
        'Unlimited vendor management',
        'Permission-based applications',
        'Real-time analytics',
        'Custom branding',
        'Revenue reporting',
        'Community building tools'
      ],
      ctaText: 'Claim Your Spot',
      ctaLink: 'https://hipop-markets.web.app',
      highlighted: true
    },
    {
      name: 'Standard Organizer',
      price: '$29/month',
      description: 'For markets 4-23 per organizer',
      badge: 'Markets 4-23',
      features: [
        'All organizer features',
        '$29/month per market (4-23)',
        'Advanced vendor insights',
        'Multi-market dashboard',
        'Priority support',
        'Custom integrations',
        'Advanced reporting'
      ],
      ctaText: 'Get Started',
      ctaLink: 'https://hipop-markets.web.app'
    },
    {
      name: 'Enterprise Organizer',
      price: '$49/month',
      description: 'For large market networks (24+ markets)',
      badge: 'Markets 24+',
      features: [
        'All Standard features',
        '$49/month per market (24+)',
        'White-label options',
        'API access',
        'Dedicated account manager',
        'Custom training',
        'Enterprise support'
      ],
      ctaText: 'Contact Sales',
      ctaLink: 'https://hipop-markets.web.app'
    }
  ];

  const getVendorTiers = (): PricingTier[] => [
    {
      name: 'Free Vendor',
      price: 'Free Forever',
      description: 'Perfect for getting started',
      badge: 'Always Free',
      features: [
        'Create and manage pop-up events',
        'Attach to approved markets',
        'Basic vendor profile',
        'Contact information display',
        'Community access',
        'Basic support'
      ],
      ctaText: 'Start Free',
      ctaLink: 'https://hipop-markets.web.app',
      highlighted: true
    },
    {
      name: 'Pioneer Vendor',
      price: 'Free for 1 Year',
      description: 'For vendors who join the first 3 markets',
      badge: 'Limited Spots',
      features: [
        'All Free Vendor features',
        'Digital catalog with item lists',
        'Pre-order functionality',
        'Customer insights & analytics',
        'Performance metrics',
        'Social media integration',
        'Priority support during free period'
      ],
      ctaText: 'Claim Your Spot',
      ctaLink: 'https://hipop-markets.web.app'
    },
    {
      name: 'Premium Vendor',
      price: '$29/month',
      description: 'Full access to all vendor tools',
      features: [
        'All Pioneer features',
        'Advanced analytics & reporting',
        'Priority market placement',
        'Custom branding options',
        'Email marketing tools',
        'Revenue optimization',
        'Priority support'
      ],
      ctaText: 'Upgrade',
      ctaLink: 'https://hipop-markets.web.app'
    }
  ];

  const getShopperTiers = (): PricingTier[] => [
    {
      name: 'Early Shopper',
      price: 'Free Forever',
      description: 'Essential market discovery for everyone',
      badge: 'Always Free',
      features: [
        'Find local markets',
        'Browse vendor profiles',
        'Basic search functionality',
        'Market schedules',
        'Location-based discovery',
        'Community access'
      ],
      ctaText: 'Start Shopping',
      ctaLink: 'https://hipop-markets.web.app',
      highlighted: true
    },
    {
      name: 'Premium Shopper',
      price: '$3.99/month',
      description: 'Enhanced shopping experience',
      badge: 'Best Value',
      features: [
        'All Early Shopper features',
        'Advanced search filters',
        'Pre-order capability',
        'Exclusive deals & discounts',
        'Unlimited favorites',
        'Push notifications',
        'Early access to new markets',
        'Premium customer support'
      ],
      ctaText: 'Upgrade Now',
      ctaLink: 'https://hipop-markets.web.app'
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
        return 'Free to start, premium features available';
      default:
        return 'Choose your plan';
    }
  };

  const getDefaultDescription = () => {
    switch (userType) {
      case 'organizer':
        return 'The first 3 market organizers to join get unlimited markets completely free forever. After that, pay only as you grow your market network.';
      case 'vendor':
        return 'Start completely free with basic features, get premium free for a year in our first 3 markets, or upgrade to premium anytime for $29/month.';
      case 'shopper':
        return 'Start shopping local markets for free forever, or upgrade to premium for enhanced features and exclusive early access.';
      default:
        return '';
    }
  };

  const tiers = getTiers();

  return (
    <div className="bg-white py-24 sm:py-32">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="mx-auto max-w-4xl text-center">
          <h2 className="text-base font-semibold leading-7 text-orange-600">Pricing</h2>
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
                  ? 'ring-2 ring-orange-600 lg:z-10 lg:rounded-b-none'
                  : 'ring-gray-200 lg:mt-8'
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
                    <p className="rounded-full bg-orange-600/10 px-2.5 py-1 text-xs font-semibold leading-5 text-orange-600">
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
                        className="h-6 w-5 flex-none text-orange-600"
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
                    ? 'bg-orange-600 text-white shadow-sm hover:bg-orange-500 focus-visible:outline-orange-600'
                    : 'text-orange-600 ring-1 ring-inset ring-orange-200 hover:ring-orange-300 focus-visible:outline-orange-600'
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