'use client';

import { useState, useEffect } from 'react';
import { useSearchParams } from 'next/navigation';
import { collection, addDoc, query, where, getDocs, orderBy } from 'firebase/firestore';
import { mainAppDb } from '@/lib/firebase';

interface VendorApplicationFormProps {
  marketId?: string;
}

interface FormData {
  selectedMarketId: string;
  vendorName: string;
  vendorEmail: string;
  vendorPhone: string;
  businessName: string;
  businessDescription: string;
  websiteUrl: string;
  instagramHandle: string;
  productCategories: string[];
  specialRequests: string;
}

const PRODUCT_CATEGORIES = [
  'Fresh Produce',
  'Organic Vegetables',
  'Fruits & Berries',
  'Herbs & Spices',
  'Baked Goods',
  'Artisan Bread',
  'Pastries & Desserts',
  'Dairy Products',
  'Cheese & Yogurt',
  'Meat & Poultry',
  'Seafood',
  'Prepared Foods',
  'Beverages',
  'Coffee & Tea',
  'Honey & Preserves',
  'Handmade Crafts',
  'Jewelry & Accessories',
  'Artwork',
  'Pottery & Ceramics',
  'Textiles & Clothing',
  'Soaps & Cosmetics',
  'Plants & Flowers',
  'Other'
];

export default function VendorApplicationForm({ marketId }: VendorApplicationFormProps) {
  const searchParams = useSearchParams();
  const preselectedMarketId = marketId || searchParams.get('market') || '';
  
  const [formData, setFormData] = useState<FormData>({
    selectedMarketId: preselectedMarketId,
    vendorName: '',
    vendorEmail: '',
    vendorPhone: '',
    businessName: '',
    businessDescription: '',
    websiteUrl: '',
    instagramHandle: '',
    productCategories: [],
    specialRequests: '',
  });

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitStatus, setSubmitStatus] = useState<'idle' | 'success' | 'error'>('idle');
  const [errorMessage, setErrorMessage] = useState('');
  const [marketInfo, setMarketInfo] = useState<any>(null);
  const [availableMarkets, setAvailableMarkets] = useState<any[]>([]);
  const [isLoadingMarket, setIsLoadingMarket] = useState(true);

  // Load market information and available markets
  useEffect(() => {
    const fetchData = async () => {
      try {
        setIsLoadingMarket(true);
        
        // Fetch all available markets
        const marketsQuery = query(
          collection(mainAppDb, 'markets'),
          where('isActive', '==', true),
          orderBy('name')
        );
        const marketsSnapshot = await getDocs(marketsQuery);
        const markets = marketsSnapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        }));
        setAvailableMarkets(markets);
        
        // If a specific market is preselected, load its info
        if (preselectedMarketId) {
          const selectedMarket = markets.find(m => m.id === preselectedMarketId);
          if (selectedMarket) {
            setMarketInfo(selectedMarket);
          }
        }
      } catch (error) {
        console.error('Error fetching market data:', error);
      } finally {
        setIsLoadingMarket(false);
      }
    };

    fetchData();
  }, [preselectedMarketId]);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value,
    }));
    
    // Update market info when market selection changes
    if (name === 'selectedMarketId') {
      const selectedMarket = availableMarkets.find(m => m.id === value);
      setMarketInfo(selectedMarket || null);
    }
  };

  const handleCategoryToggle = (category: string) => {
    setFormData(prev => ({
      ...prev,
      productCategories: prev.productCategories.includes(category)
        ? prev.productCategories.filter(c => c !== category)
        : [...prev.productCategories, category],
    }));
  };

  const validateForm = (): boolean => {
    if (!formData.selectedMarketId) {
      setErrorMessage('Please select a market to apply to');
      return false;
    }
    if (!formData.vendorName.trim()) {
      setErrorMessage('Vendor name is required');
      return false;
    }
    if (!formData.vendorEmail.trim()) {
      setErrorMessage('Email is required');
      return false;
    }
    if (!formData.businessName.trim()) {
      setErrorMessage('Business name is required');
      return false;
    }
    if (!formData.businessDescription.trim()) {
      setErrorMessage('Business description is required');
      return false;
    }
    if (formData.productCategories.length === 0) {
      setErrorMessage('Please select at least one product category');
      return false;
    }

    // Email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(formData.vendorEmail)) {
      setErrorMessage('Please enter a valid email address');
      return false;
    }

    return true;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!validateForm()) {
      return;
    }

    setIsSubmitting(true);
    setErrorMessage('');

    try {
      // Create vendor application document
      const applicationData = {
        marketId: formData.selectedMarketId,
        vendorId: '', // Will be filled when vendor creates account
        vendorName: formData.vendorName.trim(),
        vendorEmail: formData.vendorEmail.trim().toLowerCase(),
        vendorPhone: formData.vendorPhone.trim() || null,
        businessName: formData.businessName.trim(),
        businessDescription: formData.businessDescription.trim(),
        productCategories: formData.productCategories,
        websiteUrl: formData.websiteUrl.trim() || null,
        instagramHandle: formData.instagramHandle.trim() || null,
        specialRequests: formData.specialRequests.trim() || null,
        status: 'pending',
        reviewNotes: null,
        reviewedBy: null,
        reviewedAt: null,
        createdAt: new Date(),
        updatedAt: new Date(),
        metadata: {
          source: 'website',
          userAgent: navigator.userAgent,
          timestamp: new Date().toISOString(),
        },
      };

      // Submit to Firestore
      await addDoc(collection(mainAppDb, 'vendor_applications'), applicationData);

      setSubmitStatus('success');
      
      // Reset form
      setFormData({
        selectedMarketId: '',
        vendorName: '',
        vendorEmail: '',
        vendorPhone: '',
        businessName: '',
        businessDescription: '',
        websiteUrl: '',
        instagramHandle: '',
        productCategories: [],
        specialRequests: '',
      });

    } catch (error) {
      console.error('Error submitting application:', error);
      setSubmitStatus('error');
      setErrorMessage('There was an error submitting your application. Please try again.');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (isLoadingMarket) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-orange-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading market information...</p>
        </div>
      </div>
    );
  }

  if (submitStatus === 'success') {
    return (
      <div className="min-h-screen flex items-center justify-center px-4">
        <div className="max-w-md w-full bg-white rounded-lg shadow-lg p-8 text-center">
          <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg className="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
            </svg>
          </div>
          <h2 className="text-2xl font-bold text-gray-900 mb-4">Application Submitted!</h2>
          <p className="text-gray-600 mb-6">
            Thank you for your interest in becoming a vendor. Your application has been submitted successfully 
            and the market organizer will review it shortly.
          </p>
          <p className="text-sm text-gray-500 mb-6">
            You'll receive an email confirmation and updates about your application status.
          </p>
          <button
            onClick={() => window.location.href = '/'}
            className="w-full bg-orange-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-orange-700 transition-colors"
          >
            Return to Homepage
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen py-8 px-4">
      <div className="max-w-3xl mx-auto">
        {/* Header */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
          <div className="text-center">
            <h1 className="text-3xl font-bold text-gray-900 mb-2">Apply as a Vendor</h1>
            <p className="text-gray-600">Join our local farmers market community</p>
            <div className="mt-4 text-sm text-gray-500">
              <p>✓ Free to apply • ✓ Quick review process • ✓ No account required</p>
            </div>
          </div>
        </div>

        {/* Application Form */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Market Selection */}
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Select Market</h3>
              <div className="space-y-4">
                <div>
                  <label htmlFor="selectedMarketId" className="block text-sm font-medium text-gray-700 mb-1">
                    Which market would you like to apply to? *
                  </label>
                  <select
                    id="selectedMarketId"
                    name="selectedMarketId"
                    value={formData.selectedMarketId}
                    onChange={handleInputChange}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-500 focus:border-orange-500"
                    required
                  >
                    <option value="">Choose a market...</option>
                    {availableMarkets.map((market) => (
                      <option key={market.id} value={market.id}>
                        {market.name} - {market.city}, {market.state}
                      </option>
                    ))}
                  </select>
                </div>
                
                {/* Selected Market Info */}
                {marketInfo && (
                  <div className="bg-blue-50 border border-blue-200 rounded-md p-4">
                    <h4 className="font-medium text-blue-900 mb-2">{marketInfo.name}</h4>
                    <div className="text-sm text-blue-800 space-y-1">
                      <p><strong>Location:</strong> {marketInfo.address}, {marketInfo.city}, {marketInfo.state}</p>
                      {marketInfo.operatingDays && marketInfo.operatingDays.length > 0 && (
                        <p><strong>Days:</strong> {marketInfo.operatingDays.join(', ')}</p>
                      )}
                      {marketInfo.description && (
                        <p><strong>About:</strong> {marketInfo.description}</p>
                      )}
                    </div>
                  </div>
                )}
              </div>
            </div>

            {/* Personal Information */}
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Personal Information</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label htmlFor="vendorName" className="block text-sm font-medium text-gray-700 mb-1">
                    Your Name *
                  </label>
                  <input
                    type="text"
                    id="vendorName"
                    name="vendorName"
                    value={formData.vendorName}
                    onChange={handleInputChange}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-500 focus:border-orange-500"
                    required
                  />
                </div>
                <div>
                  <label htmlFor="vendorEmail" className="block text-sm font-medium text-gray-700 mb-1">
                    Email Address *
                  </label>
                  <input
                    type="email"
                    id="vendorEmail"
                    name="vendorEmail"
                    value={formData.vendorEmail}
                    onChange={handleInputChange}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-500 focus:border-orange-500"
                    required
                  />
                </div>
                <div className="md:col-span-2">
                  <label htmlFor="vendorPhone" className="block text-sm font-medium text-gray-700 mb-1">
                    Phone Number (Optional)
                  </label>
                  <input
                    type="tel"
                    id="vendorPhone"
                    name="vendorPhone"
                    value={formData.vendorPhone}
                    onChange={handleInputChange}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-500 focus:border-orange-500"
                  />
                </div>
              </div>
            </div>

            {/* Business Information */}
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Business Information</h3>
              <div className="space-y-4">
                <div>
                  <label htmlFor="businessName" className="block text-sm font-medium text-gray-700 mb-1">
                    Business Name *
                  </label>
                  <input
                    type="text"
                    id="businessName"
                    name="businessName"
                    value={formData.businessName}
                    onChange={handleInputChange}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-500 focus:border-orange-500"
                    required
                  />
                </div>
                <div>
                  <label htmlFor="businessDescription" className="block text-sm font-medium text-gray-700 mb-1">
                    Business Description *
                  </label>
                  <textarea
                    id="businessDescription"
                    name="businessDescription"
                    value={formData.businessDescription}
                    onChange={handleInputChange}
                    rows={4}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-500 focus:border-orange-500"
                    placeholder="Tell us about your business, what you sell, and what makes you unique..."
                    required
                  />
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label htmlFor="websiteUrl" className="block text-sm font-medium text-gray-700 mb-1">
                      Website (Optional)
                    </label>
                    <input
                      type="url"
                      id="websiteUrl"
                      name="websiteUrl"
                      value={formData.websiteUrl}
                      onChange={handleInputChange}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-500 focus:border-orange-500"
                      placeholder="https://yourwebsite.com"
                    />
                  </div>
                  <div>
                    <label htmlFor="instagramHandle" className="block text-sm font-medium text-gray-700 mb-1">
                      Instagram Handle (Optional)
                    </label>
                    <input
                      type="text"
                      id="instagramHandle"
                      name="instagramHandle"
                      value={formData.instagramHandle}
                      onChange={handleInputChange}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-500 focus:border-orange-500"
                      placeholder="@yourbusiness"
                    />
                  </div>
                </div>
              </div>
            </div>

            {/* Product Categories */}
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Product Categories *</h3>
              <p className="text-sm text-gray-600 mb-4">Select all categories that apply to your products:</p>
              <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2">
                {PRODUCT_CATEGORIES.map((category) => (
                  <label
                    key={category}
                    className={`
                      flex items-center p-3 rounded-lg border cursor-pointer transition-colors
                      ${formData.productCategories.includes(category)
                        ? 'bg-orange-50 border-orange-300 text-orange-900'
                        : 'bg-white border-gray-200 hover:bg-gray-50'
                      }
                    `}
                  >
                    <input
                      type="checkbox"
                      checked={formData.productCategories.includes(category)}
                      onChange={() => handleCategoryToggle(category)}
                      className="sr-only"
                    />
                    <span className="text-sm font-medium">{category}</span>
                  </label>
                ))}
              </div>
            </div>

            {/* Special Requests */}
            <div>
              <label htmlFor="specialRequests" className="block text-sm font-medium text-gray-700 mb-1">
                Special Requests or Requirements (Optional)
              </label>
              <textarea
                id="specialRequests"
                name="specialRequests"
                value={formData.specialRequests}
                onChange={handleInputChange}
                rows={3}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-500 focus:border-orange-500"
                placeholder="Any special equipment needs, space requirements, or other requests..."
              />
            </div>

            {/* Error Message */}
            {errorMessage && (
              <div className="bg-red-50 border border-red-200 rounded-md p-4">
                <p className="text-red-600 text-sm">{errorMessage}</p>
              </div>
            )}

            {/* Submit Button */}
            <div className="pt-4">
              <button
                type="submit"
                disabled={isSubmitting}
                className={`
                  w-full py-3 px-6 rounded-lg font-semibold text-white transition-colors
                  ${isSubmitting
                    ? 'bg-gray-400 cursor-not-allowed'
                    : 'bg-orange-600 hover:bg-orange-700'
                  }
                `}
              >
                {isSubmitting ? (
                  <div className="flex items-center justify-center">
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                    Submitting Application...
                  </div>
                ) : (
                  'Submit Application'
                )}
              </button>
            </div>

            {/* Footer Note */}
            <div className="bg-blue-50 border border-blue-200 rounded-md p-4">
              <p className="text-blue-800 text-sm">
                <strong>Note:</strong> Your application will be reviewed by the market organizer. 
                You'll receive an email confirmation and updates about your application status.
              </p>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}