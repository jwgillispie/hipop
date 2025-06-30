import { Metadata } from 'next';
import { Suspense } from 'react';
import VendorApplicationForm from '@/components/VendorApplicationForm';

export const metadata: Metadata = {
  title: 'Apply as Vendor - HiPop Markets',
  description: 'Apply to become a vendor at local farmers markets. Join our community of local producers and artisans.',
  keywords: 'vendor application, farmers market vendor, local producer, artisan vendor, market application',
  openGraph: {
    title: 'Apply as Vendor - HiPop Markets',
    description: 'Apply to become a vendor at local farmers markets',
    type: 'website',
  },
};

export default function VendorApplicationPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      <Suspense fallback={
        <div className="min-h-screen flex items-center justify-center">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-orange-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">Loading application form...</p>
          </div>
        </div>
      }>
        <VendorApplicationForm />
      </Suspense>
    </div>
  );
}