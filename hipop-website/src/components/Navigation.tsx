'use client';

import { useState } from 'react';
import Link from 'next/link';
import { Bars3Icon, XMarkIcon } from '@heroicons/react/24/outline';

const navigation = [
  { name: 'Home', href: '/' },
  { name: 'For Vendors', href: '/vendors' },
  { name: 'For Organizers', href: '/organizers' },
  { name: 'For Shoppers', href: '/shoppers' },
  { name: 'About', href: '/about' },
];

export function Navigation() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <header className="bg-white shadow-sm">
      <nav className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8" aria-label="Top">
        <div className="flex w-full items-center justify-between border-b border-hipop-primary py-6 lg:border-none">
          <div className="flex items-center">
            <Link href="/" className="flex items-center">
              <span className="text-2xl font-bold text-hipop-primary">HiPop</span>
              <span className="ml-2 text-xl text-gray-900">Markets</span>
            </Link>
          </div>
          
          {/* Desktop navigation */}
          <div className="ml-10 hidden space-x-8 lg:block">
            {navigation.map((link) => (
              <Link
                key={link.name}
                href={link.href}
                className="text-base font-medium text-gray-500 hover:text-hipop-primary transition-colors"
              >
                {link.name}
              </Link>
            ))}
          </div>

          {/* Download button */}
          <div className="ml-10 hidden lg:block">
            <Link
              href="https://hipop-markets.web.app"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center rounded-md border border-transparent bg-hipop-primary px-4 py-2 text-base font-medium text-white shadow-sm hover:bg-[#3D6450] transition-colors"
            >
              Go to the App
            </Link>
          </div>

          {/* Mobile menu button */}
          <div className="lg:hidden">
            <button
              type="button"
              className="-m-2.5 inline-flex items-center justify-center rounded-md p-2.5 text-gray-700"
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            >
              <span className="sr-only">Open main menu</span>
              {mobileMenuOpen ? (
                <XMarkIcon className="h-6 w-6" aria-hidden="true" />
              ) : (
                <Bars3Icon className="h-6 w-6" aria-hidden="true" />
              )}
            </button>
          </div>
        </div>

        {/* Mobile menu */}
        {mobileMenuOpen && (
          <div className="lg:hidden">
            <div className="space-y-1 pb-3 pt-2">
              {navigation.map((link) => (
                <Link
                  key={link.name}
                  href={link.href}
                  className="block border-l-4 border-transparent py-2 pl-3 pr-4 text-base font-medium text-gray-600 hover:border-hipop-primary hover:bg-hipop-surface-variant hover:text-hipop-primary"
                  onClick={() => setMobileMenuOpen(false)}
                >
                  {link.name}
                </Link>
              ))}
              <Link
                href="https://hipop-markets.web.app"
                target="_blank"
                rel="noopener noreferrer"
                className="block border-l-4 border-hipop-primary bg-hipop-surface-variant py-2 pl-3 pr-4 text-base font-medium text-hipop-primary"
                onClick={() => setMobileMenuOpen(false)}
              >
                Go to the App
              </Link>
            </div>
          </div>
        )}
      </nav>
    </header>
  );
}