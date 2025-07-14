import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Privacy Policy - HiPop Markets",
  description: "Privacy Policy for HiPop Markets mobile application and website.",
};

export default function PrivacyPage() {
  return (
    <div className="max-w-4xl mx-auto px-4 py-8 lg:py-16">
      <div className="bg-white rounded-lg shadow-lg p-8 lg:p-12">
        <h1 className="text-4xl font-bold text-gray-900 mb-2">Privacy Policy</h1>
        <p className="text-gray-600 mb-8">
          <strong>Last Updated: January 6, 2025</strong>
        </p>

        <div className="prose prose-lg max-w-none">
          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Introduction</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              At HiPop Markets, we take your privacy seriously. This Privacy Policy explains how we collect, 
              use, disclose, and safeguard your information when you use our mobile application and website 
              (collectively, the "Service"). Please read this Privacy Policy carefully. By using the Service, 
              you consent to the practices described in this Privacy Policy.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Information We Collect</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              We may collect several types of information from and about users of our Service, including:
            </p>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Personal Information</h3>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li><strong>Account Information:</strong> Email address, display name, and authentication information when you register</li>
              <li><strong>Profile Information:</strong> Business name (for vendors), organization name (for market organizers), bio, phone number, website, Instagram handle</li>
              <li><strong>Location Information:</strong> Address information for markets and vendors (when provided)</li>
              <li><strong>Contact Information:</strong> Information you provide when contacting us for support</li>
            </ul>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">User Content</h3>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Vendor profiles and business descriptions</li>
              <li>Market information and schedules</li>
              <li>Product categories and specialties</li>
              <li>Photos and images uploaded to profiles</li>
              <li>Application messages and notes</li>
              <li>Preferences and favorites</li>
            </ul>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Usage Data</h3>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Information about how you use the Service</li>
              <li>Pages visited and features used</li>
              <li>Time spent in the Service</li>
              <li>Search queries and filters applied</li>
              <li>Application and interaction history</li>
            </ul>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Device Information</h3>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Device type, operating system, and version</li>
              <li>Unique device identifiers</li>
              <li>IP address and general location (city/state level)</li>
              <li>Browser type and version (for web users)</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">How We Use Your Information</h2>
            <p className="text-gray-700 leading-relaxed mb-4">We use the information we collect to:</p>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Provide, maintain, and improve the Service</li>
              <li>Connect vendors with market organizers and shoppers</li>
              <li>Process vendor applications and market registrations</li>
              <li>Send you important notifications about your account and applications</li>
              <li>Respond to your comments, questions, and support requests</li>
              <li>Monitor and analyze trends, usage, and activities to improve the Service</li>
              <li>Detect, investigate, and prevent fraudulent or unauthorized activities</li>
              <li>Personalize your experience by showing relevant markets and vendors</li>
              <li>Comply with legal obligations and protect our rights</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">How We Share Your Information</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              We may share information we collect in the following circumstances:
            </p>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Public Information</h3>
            <p className="text-gray-700 leading-relaxed mb-4">
              Information in vendor profiles and market listings is visible to all users of the Service. This includes:
            </p>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Business names and descriptions</li>
              <li>Product categories and specialties</li>
              <li>Market schedules and locations</li>
              <li>Contact information you choose to make public (website, Instagram)</li>
              <li>Photos and images in profiles</li>
            </ul>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Service Providers</h3>
            <p className="text-gray-700 leading-relaxed mb-4">
              We may share information with third-party service providers who perform services on our behalf, including:
            </p>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Cloud hosting and storage providers (Firebase/Google Cloud)</li>
              <li>Authentication services</li>
              <li>Analytics and monitoring services</li>
              <li>Customer support platforms</li>
            </ul>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Legal Requirements</h3>
            <p className="text-gray-700 leading-relaxed mb-4">
              We may disclose your information if required to do so by law or in response to valid requests by public authorities.
            </p>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Business Transfers</h3>
            <p className="text-gray-700 leading-relaxed mb-4">
              If we are involved in a merger, acquisition, or asset sale, your information may be transferred as part of that transaction.
            </p>

            <p className="text-gray-700 leading-relaxed mb-4 font-semibold">
              We do not sell your personal information to third parties.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Data Security</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              We implement appropriate technical and organizational measures to protect the security of your personal 
              information, including:
            </p>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Encryption of data in transit and at rest</li>
              <li>Secure authentication systems</li>
              <li>Regular security monitoring and updates</li>
              <li>Access controls and permission management</li>
              <li>Secure cloud infrastructure (Firebase/Google Cloud)</li>
            </ul>
            <p className="text-gray-700 leading-relaxed mb-4">
              However, please be aware that no method of transmission over the Internet or method of electronic 
              storage is 100% secure.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Data Retention</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              We will retain your personal information only for as long as reasonably necessary to fulfill the 
              purposes for which it was collected, including:
            </p>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Active account information: Retained while your account is active</li>
              <li>Application history: Retained for operational and legal compliance purposes</li>
              <li>Usage data: Aggregated data may be retained indefinitely for analytics</li>
              <li>Legal compliance: Data may be retained longer if required by law</li>
            </ul>
            <p className="text-gray-700 leading-relaxed mb-4">
              When you delete your account, we will delete or anonymize your personal information, though some 
              information may be retained in our backup systems for a limited time.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Children's Privacy</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              The Service is not intended for children under the age of 13, and we do not knowingly collect 
              personal information from children under 13. If we learn we have collected or received personal 
              information from a child under 13, we will delete that information. If you believe we might have 
              any information from or about a child under 13, please contact us.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Your Privacy Rights</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              Depending on your location, you may have certain rights regarding your personal information, including:
            </p>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li><strong>Access:</strong> You can request access to your personal information</li>
              <li><strong>Correction:</strong> You can request that we correct inaccurate or incomplete information</li>
              <li><strong>Deletion:</strong> You can request that we delete your personal information</li>
              <li><strong>Restriction:</strong> You can request that we restrict the processing of your information</li>
              <li><strong>Data Portability:</strong> You can request a copy of your information in a structured format</li>
              <li><strong>Objection:</strong> You can object to our processing of your personal information</li>
            </ul>
            <p className="text-gray-700 leading-relaxed mb-4">
              To exercise these rights, please contact us at support@hipopmarkets.com. We will respond to your 
              request within a reasonable timeframe and in accordance with applicable law.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Location Information</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              The Service may use location information to help you find nearby markets and vendors. Location 
              information is used only to provide location-based features and is not stored or shared unless 
              you explicitly provide address information in your profile.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Third-Party Links</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              The Service may contain links to third-party websites or applications (such as vendor websites or 
              social media profiles). We are not responsible for the privacy practices of these third parties. 
              We encourage you to read the privacy policies of any third-party sites you visit.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">California Privacy Rights</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              If you are a California resident, you have additional rights under the California Consumer Privacy 
              Act (CCPA), including the right to know what personal information we collect, use, and share, and 
              the right to delete your personal information. To exercise these rights, please contact us at 
              support@hipopmarkets.com.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">International Data Transfers</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              Your information may be transferred to and processed in countries other than your own, including 
              the United States. We ensure that any such transfers comply with applicable data protection laws 
              and that appropriate safeguards are in place.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Changes to this Privacy Policy</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              We may update our Privacy Policy from time to time. We will notify you of any changes by posting 
              the new Privacy Policy on this page and updating the "Last Updated" date. For significant changes, 
              we may also send you a notification through the Service or via email. You are advised to review 
              this Privacy Policy periodically for any changes.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Contact Information</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              If you have any questions about this Privacy Policy or our privacy practices, please contact us at:
            </p>
            <div className="bg-gray-50 p-4 rounded-lg">
              <p className="text-gray-700">
                <strong>Email:</strong>{" "}
                <a href="mailto:support@hipopmarkets.com" className="text-blue-600 hover:text-blue-800">
                  support@hipopmarkets.com
                </a>
              </p>
              <p className="text-gray-700 mt-2">
                <strong>Subject Line:</strong> Privacy Policy Inquiry
              </p>
            </div>
          </section>
        </div>

        <div className="mt-12 pt-8 border-t border-gray-200">
          <div className="flex flex-wrap gap-4">
            <a 
              href="/terms" 
              className="text-blue-600 hover:text-blue-800 font-medium"
            >
              Terms of Service
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