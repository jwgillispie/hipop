import Link from 'next/link';

const navigation = {
  main: [
    { name: 'About', href: '/about' },
    { name: 'Markets', href: '/markets' },
    { name: 'For Vendors', href: '/vendors' },
    { name: 'For Organizers', href: '/organizers' },
    { name: 'For Shoppers', href: '/shoppers' },
    { name: 'Contact', href: 'mailto:hipopmarkets@gmail.com' },
  ],
  legal: [
    { name: 'Privacy Policy', href: '/privacy' },
    { name: 'Terms of Service', href: '/terms' },
  ],
  social: [
    {
      name: 'Instagram',
      href: 'https://instagram.com/hipopmarkets',
      icon: (props: any) => (
        <svg fill="currentColor" viewBox="0 0 24 24" {...props}>
          <path
            fillRule="evenodd"
            d="M12.017 0C5.396 0 .029 5.367.029 11.987c0 6.62 5.367 11.987 11.988 11.987s11.987-5.367 11.987-11.987C24.004 5.367 18.637.001 12.017.001zM8.449 16.988c-1.297 0-2.448-.49-3.337-1.295C3.595 14.24 3.8 12.7 4.3 11.4c.5-1.3 1.4-2.4 2.6-3.1 1.2-.7 2.6-1 4.1-1s2.9.3 4.1 1c1.2.7 2.1 1.8 2.6 3.1.5 1.3.3 2.84-.725 4.293-.889.805-2.04 1.295-3.337 1.295h-4.588z"
            clipRule="evenodd"
          />
        </svg>
      ),
    },
  ],
};

export function Footer() {
  return (
    <footer className="bg-hipop-surface">
      <div className="mx-auto max-w-7xl overflow-hidden px-6 py-20 sm:py-24 lg:px-8">
        <div className="flex justify-center">
          <Link href="/" className="flex items-center">
            <span className="text-3xl font-bold text-hipop-primary">HiPop</span>
            <span className="ml-2 text-2xl text-gray-900">Markets</span>
          </Link>
        </div>
        
        <nav className="-mb-6 columns-2 sm:flex sm:justify-center sm:space-x-12 mt-10" aria-label="Footer">
          {navigation.main.map((item) => (
            <div key={item.name} className="pb-6">
              <Link href={item.href} className="text-sm leading-6 text-gray-600 hover:text-hipop-primary">
                {item.name}
              </Link>
            </div>
          ))}
        </nav>
        
        <div className="mt-10 flex justify-center space-x-10">
          {navigation.social.map((item) => (
            <a 
              key={item.name} 
              href={item.href} 
              target="_blank"
              rel="noopener noreferrer"
              className="text-gray-400 hover:text-hipop-primary"
            >
              <span className="sr-only">{item.name}</span>
              <item.icon className="h-6 w-6" aria-hidden="true" />
            </a>
          ))}
        </div>
        
        <div className="mt-10 flex justify-center space-x-10">
          {navigation.legal.map((item) => (
            <Link key={item.name} href={item.href} className="text-xs leading-5 text-gray-500 hover:text-gray-600">
              {item.name}
            </Link>
          ))}
        </div>
        
        <p className="mt-10 text-center text-xs leading-5 text-gray-500">
          &copy; 2025 HiPop Markets. All rights reserved.
        </p>
      </div>
    </footer>
  );
}