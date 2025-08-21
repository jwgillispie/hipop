import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Terms of Service - HiPop Markets",
  description: "Terms of Service for HiPop Markets mobile application and website.",
};

export default function TermsPage() {
  return (
    <div className="max-w-4xl mx-auto px-4 py-8 lg:py-16">
      <div className="bg-white rounded-lg shadow-lg p-8 lg:p-12">
        <h1 className="text-4xl font-bold text-gray-900 mb-2">Terms of Service</h1>
        <p className="text-gray-600 mb-8">
          <strong>Last Updated: August 12, 2025</strong>
        </p>

        <div className="prose prose-lg max-w-none">
          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Introduction</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              Welcome to HiPop Markets ("we," "our," or "us"). By downloading, accessing, or using our mobile 
              application and website (collectively, the "Service"), you agree to be bound by these Terms of 
              Service ("Terms").
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Acceptance of Terms</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              By registering for and/or using the Service in any manner, you agree to these Terms and all other 
              operating rules, policies, and procedures that may be published by us. If you do not agree to these 
              Terms, you may not access or use the Service.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Description of Service</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              HiPop Markets is a platform that connects farmers market shoppers with local vendors and markets. 
              Our Service allows users to:
            </p>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Discover local farmers markets and vendors</li>
              <li>Browse vendor profiles and product offerings</li>
              <li>View market schedules and locations</li>
              <li>Apply to participate in markets (for vendors)</li>
              <li>Manage market operations (for market organizers)</li>
              <li>Favorite vendors and markets</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">User Types and Responsibilities</h2>
            
            <h3 className="text-xl font-semibold text-gray-900 mb-3">Shoppers</h3>
            <p className="text-gray-700 leading-relaxed mb-4">
              Shoppers can browse markets, discover vendors, and use the Service to find local food and artisan products. 
              Shoppers agree to use accurate location information when required.
            </p>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Vendors</h3>
            <p className="text-gray-700 leading-relaxed mb-4">
              Vendors can create profiles, apply to markets, and showcase their products. Vendors agree to:
            </p>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Provide accurate information about their business and products</li>
              <li>Comply with all applicable health, safety, and business regulations</li>
              <li>Honor any commitments made through the Service</li>
              <li>Maintain current and accurate profile information</li>
            </ul>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Market Organizers</h3>
            <p className="text-gray-700 leading-relaxed mb-4">
              Market organizers can manage market information, review vendor applications, and organize their markets. 
              Organizers agree to:
            </p>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Provide accurate market information and schedules</li>
              <li>Review vendor applications fairly and in a timely manner</li>
              <li>Comply with all applicable local regulations for operating farmers markets</li>
              <li>Maintain current and accurate market information</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Account Registration</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              To use certain features of the Service, you must register for an account. You agree to:
            </p>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Provide accurate, current, and complete information during registration</li>
              <li>Update such information to keep it accurate, current, and complete</li>
              <li>Safeguard your password and account credentials</li>
              <li>Notify us immediately of any unauthorized use of your account</li>
              <li>Take responsibility for all activities under your account</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">User Content</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              The Service allows you to create and store content, including but not limited to vendor profiles, 
              market information, product descriptions, and images ("User Content"). You retain all rights in 
              your User Content. By providing User Content to the Service, you grant us a worldwide, non-exclusive, 
              royalty-free license to use, copy, modify, and display your User Content in connection with the 
              operation of the Service.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Acceptable Use</h2>
            <p className="text-gray-700 leading-relaxed mb-4">You agree not to use the Service to:</p>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Violate any applicable law or regulation</li>
              <li>Infringe the rights of any third party</li>
              <li>Transmit any material that is harmful, threatening, abusive, harassing, defamatory, vulgar, obscene, or invasive of another's privacy</li>
              <li>Transmit any viruses, malware, or other harmful code</li>
              <li>Interfere with or disrupt the Service or servers or networks connected to the Service</li>
              <li>Attempt to gain unauthorized access to any part of the Service</li>
              <li>Use the Service for any commercial purpose not explicitly permitted</li>
              <li>Create false or misleading vendor profiles or market information</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Transactions and Payments</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              HiPop Markets facilitates connections between vendors and customers but does not process payments 
              or handle transactions directly. All transactions occur directly between vendors and customers. 
              We are not responsible for the quality, safety, legality, or availability of products or services 
              offered by vendors.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Termination</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              We may terminate or suspend your access to the Service immediately, without prior notice or liability, 
              for any reason whatsoever, including without limitation if you breach these Terms. Upon termination, 
              your right to use the Service will immediately cease. If you wish to terminate your account, you may 
              simply discontinue using the Service.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Disclaimer of Warranties</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              THE SERVICE IS PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS, WITHOUT WARRANTIES OF ANY KIND, 
              EITHER EXPRESS OR IMPLIED. TO THE FULLEST EXTENT PERMISSIBLE UNDER APPLICABLE LAW, WE DISCLAIM ALL 
              WARRANTIES, EXPRESS OR IMPLIED, INCLUDING IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
              PARTICULAR PURPOSE, AND NON-INFRINGEMENT.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Limitation of Liability</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              TO THE MAXIMUM EXTENT PERMITTED BY LAW, IN NO EVENT SHALL WE BE LIABLE FOR ANY INDIRECT, INCIDENTAL, 
              SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, INCLUDING WITHOUT LIMITATION, LOSS OF PROFITS, DATA, USE, 
              GOODWILL, OR OTHER INTANGIBLE LOSSES, RESULTING FROM YOUR ACCESS TO OR USE OF OR INABILITY TO ACCESS 
              OR USE THE SERVICE.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Changes to Terms</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              We reserve the right to modify these Terms at any time. We will notify you of any changes by posting 
              the new Terms on the Service with a new effective date. Your continued use of the Service after any 
              such changes constitutes your acceptance of the new Terms.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Governing Law</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              These Terms shall be governed by and construed in accordance with the laws of the United States and 
              the State of Georgia, without regard to its conflict of law provisions.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Contact Information</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              If you have any questions about these Terms, please contact us at:{" "}
              <a href="mailto:support@hipopmarkets.com" className="text-blue-600 hover:text-blue-800">
                support@hipopmarkets.com
              </a>
            </p>
          </section>
        </div>

        <div className="mt-12 pt-8 border-t border-gray-200">
          <div className="flex flex-wrap gap-4">
            <a 
              href="/privacy" 
              className="text-blue-600 hover:text-blue-800 font-medium"
            >
              Privacy Policy
            </a>
            <a 
              href="/user-agreement" 
              className="text-blue-600 hover:text-blue-800 font-medium"
            >
              User Agreement
            </a>
            <a 
              href="/" 
              className="text-blue-600 hover:text-blue-800 font-medium"
            >
              Back to Home
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}