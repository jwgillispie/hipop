import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "User Agreement - HiPop Markets",
  description: "User Agreement for HiPop Markets mobile application and website.",
};

export default function UserAgreementPage() {
  return (
    <div className="max-w-4xl mx-auto px-4 py-8 lg:py-16">
      <div className="bg-white rounded-lg shadow-lg p-8 lg:p-12">
        <h1 className="text-4xl font-bold text-gray-900 mb-2">User Agreement</h1>
        <p className="text-gray-600 mb-8">
          <strong>Last Updated: January 6, 2025</strong>
        </p>

        <div className="prose prose-lg max-w-none">
          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Introduction</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              This User Agreement ("Agreement") supplements our Terms of Service and Privacy Policy and establishes 
              specific guidelines for users of the HiPop Markets platform. By using our Service, you agree to comply 
              with this Agreement.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Community Guidelines</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              HiPop Markets is a community platform that connects farmers market participants. To maintain a positive 
              and professional environment for all users, please follow these guidelines:
            </p>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Respectful Communication</h3>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Treat all users with respect and professionalism</li>
              <li>Use appropriate language in all communications</li>
              <li>Respond to messages and applications in a timely manner</li>
              <li>Provide constructive feedback when reviewing applications</li>
            </ul>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Honest and Accurate Information</h3>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Provide truthful and accurate information in your profile</li>
              <li>Update your information when circumstances change</li>
              <li>Do not misrepresent your products, services, or business</li>
              <li>Include accurate market schedules and locations</li>
            </ul>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Professional Conduct</h3>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Honor commitments made through the platform</li>
              <li>Communicate any changes or issues promptly</li>
              <li>Resolve disputes amicably and professionally</li>
              <li>Maintain appropriate business practices</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Vendor Responsibilities</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              As a vendor using HiPop Markets, you agree to:
            </p>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Business Operations</h3>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Maintain all required business licenses and permits</li>
              <li>Comply with local health and safety regulations</li>
              <li>Follow food safety guidelines for food vendors</li>
              <li>Maintain appropriate business insurance</li>
              <li>Pay all applicable taxes and fees</li>
            </ul>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Market Participation</h3>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Attend markets as scheduled and committed</li>
              <li>Notify market organizers of any changes or cancellations</li>
              <li>Follow market rules and guidelines</li>
              <li>Set up and break down according to market schedules</li>
              <li>Pay market fees promptly</li>
            </ul>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Product Standards</h3>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Accurately represent the origin and nature of your products</li>
              <li>Clearly label products with prices and relevant information</li>
              <li>Maintain quality standards for all products offered</li>
              <li>Honor any product guarantees or return policies you establish</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Market Organizer Responsibilities</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              As a market organizer using HiPop Markets, you agree to:
            </p>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Market Management</h3>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Maintain all required permits and insurance for operating a farmers market</li>
              <li>Establish and enforce clear market rules and guidelines</li>
              <li>Provide adequate facilities and infrastructure for vendors</li>
              <li>Ensure compliance with local regulations and zoning requirements</li>
              <li>Maintain a safe and welcoming environment for vendors and customers</li>
            </ul>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Vendor Relations</h3>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Review vendor applications fairly and in a timely manner</li>
              <li>Communicate market rules and expectations clearly</li>
              <li>Provide reasonable notice of any changes to market operations</li>
              <li>Handle vendor concerns and disputes professionally</li>
              <li>Maintain consistent and fair enforcement of market rules</li>
            </ul>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">Information Accuracy</h3>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Keep market schedules and location information current</li>
              <li>Update vendor listings promptly</li>
              <li>Provide accurate information about market amenities and services</li>
              <li>Communicate any temporary changes or closures</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Shopper Guidelines</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              As a shopper using HiPop Markets, you agree to:
            </p>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Respect vendors and their products</li>
              <li>Follow market rules and guidelines</li>
              <li>Be considerate of other shoppers and market participants</li>
              <li>Report any issues or concerns to market organizers</li>
              <li>Support local vendors and the farmers market community</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Application Process</h2>
            
            <h3 className="text-xl font-semibold text-gray-900 mb-3">For Vendors</h3>
            <p className="text-gray-700 leading-relaxed mb-4">
              When applying to markets through HiPop Markets:
            </p>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Complete your vendor profile thoroughly and accurately</li>
              <li>Select appropriate operating days that you can commit to</li>
              <li>Provide any special requirements or requests clearly</li>
              <li>Wait for organizer review before assuming acceptance</li>
              <li>Honor commitments made in your application</li>
            </ul>

            <h3 className="text-xl font-semibold text-gray-900 mb-3">For Market Organizers</h3>
            <p className="text-gray-700 leading-relaxed mb-4">
              When reviewing vendor applications:
            </p>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Review applications promptly and fairly</li>
              <li>Consider market balance and vendor mix</li>
              <li>Provide clear feedback if rejecting an application</li>
              <li>Follow your stated market criteria consistently</li>
              <li>Create vendor profiles for approved applicants</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Prohibited Activities</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              The following activities are strictly prohibited on the HiPop Markets platform:
            </p>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Creating fake or misleading profiles</li>
              <li>Submitting fraudulent applications</li>
              <li>Harassment or discriminatory behavior</li>
              <li>Spam or unsolicited promotional messages</li>
              <li>Attempting to circumvent platform features or security</li>
              <li>Sharing or selling access to your account</li>
              <li>Using the platform for illegal activities</li>
              <li>Infringing on intellectual property rights</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Content Standards</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              All content shared on HiPop Markets must meet these standards:
            </p>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Be accurate and truthful</li>
              <li>Be appropriate for all audiences</li>
              <li>Not contain offensive or discriminatory language</li>
              <li>Not infringe on copyrights or trademarks</li>
              <li>Include only content you have the right to share</li>
              <li>Be relevant to farmers markets and local food</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Dispute Resolution</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              If disputes arise between users:
            </p>
            <ol className="list-decimal list-inside text-gray-700 mb-4 space-y-2">
              <li>Attempt to resolve the issue directly and professionally</li>
              <li>Contact HiPop Markets support if direct resolution is not possible</li>
              <li>Provide all relevant information and documentation</li>
              <li>Cooperate with any investigation or mediation process</li>
              <li>Accept that HiPop Markets has final discretion in dispute resolution</li>
            </ol>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Platform Integrity</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              To maintain the integrity of the HiPop Markets platform:
            </p>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Report suspicious or inappropriate behavior</li>
              <li>Do not attempt to manipulate ratings or reviews</li>
              <li>Use the platform only for its intended purposes</li>
              <li>Respect the privacy and data of other users</li>
              <li>Comply with all applicable laws and regulations</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Enforcement</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              Violations of this User Agreement may result in:
            </p>
            <ul className="list-disc list-inside text-gray-700 mb-4 space-y-2">
              <li>Warning or educational communication</li>
              <li>Temporary restriction of account features</li>
              <li>Suspension of account access</li>
              <li>Permanent termination of account</li>
              <li>Reporting to appropriate authorities if illegal activity is suspected</li>
            </ul>
            <p className="text-gray-700 leading-relaxed mb-4">
              We reserve the right to take appropriate action based on the severity and frequency of violations.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Updates to This Agreement</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              We may update this User Agreement from time to time to reflect changes in our platform, legal 
              requirements, or community needs. We will notify users of significant changes through the platform 
              or via email. Continued use of the Service after changes constitutes acceptance of the updated Agreement.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Contact and Support</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              If you have questions about this User Agreement or need to report a violation, please contact us:
            </p>
            <div className="bg-gray-50 p-4 rounded-lg">
              <p className="text-gray-700">
                <strong>Email:</strong>{" "}
                <a href="mailto:support@hipopmarkets.com" className="text-blue-600 hover:text-blue-800">
                  support@hipopmarkets.com
                </a>
              </p>
              <p className="text-gray-700 mt-2">
                <strong>Subject Line:</strong> User Agreement Inquiry or Violation Report
              </p>
            </div>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Acknowledgment</h2>
            <p className="text-gray-700 leading-relaxed mb-4">
              By using HiPop Markets, you acknowledge that you have read, understood, and agree to be bound by 
              this User Agreement, along with our Terms of Service and Privacy Policy. This Agreement helps 
              ensure that HiPop Markets remains a positive and productive platform for all members of the 
              farmers market community.
            </p>
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
              href="/privacy" 
              className="text-blue-600 hover:text-blue-800 font-medium"
            >
              Privacy Policy
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