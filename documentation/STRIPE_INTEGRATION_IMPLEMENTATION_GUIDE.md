# HiPOP Stripe Integration Implementation Guide

## Executive Summary

This document provides specific implementation steps for integrating Stripe payment processing into the HiPOP platform to support our tiered subscription model for markets, vendors, and shoppers. The implementation will handle our unique pricing structure including lifetime free tiers, monthly subscriptions, and free trial periods.

## HiPOP Pricing Strategy Overview

### Markets
- **First 3 Markets**: FREE for life (premium features)
- **Markets 4-23**: $29/month
- **Markets 24+**: $49/month

### Vendors
- **Free Vendors**: FREE forever (basic features)
- **First 3 Markets' Vendors**: FREE for first year (premium features)
- **All Other Vendors**: $29/month (premium features)

### Shoppers
- **Basic Features**: FREE
- **Premium Features**: $3.99/month

## Feature Breakdown by Tier

### Vendor Tiers
#### Free Vendors (Always Free)
- Create and manage pop-up events
- Attach to approved markets
- Basic vendor profile
- Contact information display
- **Limitations**: No item lists, no pre-order functionality, no advanced analytics

#### Pioneer Vendors (Free for 1 Year - First 3 Markets Only)
- All Free Vendor features
- Digital catalog with item lists
- Pre-order functionality
- Customer insights and basic analytics
- Performance metrics
- Social media integration

#### Premium Vendors ($29/month)
- All Pioneer Vendor features
- Advanced analytics and reporting
- Priority market placement
- Custom branding options
- Email marketing tools
- Revenue optimization tools
- Priority customer support

## Implementation Architecture

### 1. Stripe Products & Pricing Setup

First, create Stripe products and prices for each subscription tier:

```bash
# Market Products
stripe products create --name "HiPOP Market Premium (Tier 1)" --description "Premium features for markets 4-23"
stripe prices create --product prod_xxx --currency usd --recurring interval=month --unit-amount 2900

stripe products create --name "HiPOP Market Premium (Tier 2)" --description "Premium features for markets 24+"
stripe prices create --product prod_xxx --currency usd --recurring interval=month --unit-amount 4900

# Vendor Product
stripe products create --name "HiPOP Vendor Premium" --description "Premium features for vendors"
stripe prices create --product prod_xxx --currency usd --recurring interval=month --unit-amount 2900

# Shopper Product
stripe products create --name "HiPOP Shopper Premium" --description "Premium features for shoppers"
stripe prices create --product prod_xxx --currency usd --recurring interval=month --unit-amount 399
```

### 2. Flutter Dependencies

Add Stripe Flutter SDK to `pubspec.yaml`:

```yaml
dependencies:
  # Add to existing dependencies
  stripe_flutter: ^10.1.1
  stripe_checkout: ^2.0.0
  http: ^1.2.2 # Already present
  
  # Server communication
  cloud_functions: ^5.1.3
```

### 3. Model Updates

Update the existing `UserSubscription` model to include Stripe-specific fields:

**File: `lib/models/user_subscription.dart`**

Add these fields to the existing model:
```dart
// Add these fields to the existing UserSubscription class
final String? stripeProductId;
final String? stripePriceId;
final String? stripeInvoiceId;
final DateTime? trialEndDate;
final bool isLifetimeFree;
final int marketCount; // For determining market pricing tier
```

### 4. Payment Service Implementation

Create a comprehensive payment service:

**File: `lib/services/payment_service.dart`**

```dart
import 'package:stripe_flutter/stripe_flutter.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_subscription.dart';

class PaymentService {
  static const String publishableKey = 'pk_test_...'; // Replace with your key
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize Stripe
  Future<void> initialize() async {
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  // Create customer and setup subscription
  Future<UserSubscription?> createSubscription({
    required String userId,
    required String userType,
    required String priceId,
    String? paymentMethodId,
    bool hasFreeTrial = false,
  }) async {
    try {
      // Call Cloud Function to create subscription
      final result = await _functions.httpsCallable('createSubscription').call({
        'userId': userId,
        'userType': userType,
        'priceId': priceId,
        'paymentMethodId': paymentMethodId,
        'hasFreeTrial': hasFreeTrial,
      });

      if (result.data['success']) {
        return await _getSubscriptionFromFirestore(userId);
      }
      throw Exception(result.data['error']);
    } catch (e) {
      throw Exception('Failed to create subscription: $e');
    }
  }

  // Handle payment method setup
  Future<PaymentMethod> attachPaymentMethod(String paymentMethodId, String customerId) async {
    final result = await _functions.httpsCallable('attachPaymentMethod').call({
      'paymentMethodId': paymentMethodId,
      'customerId': customerId,
    });

    if (!result.data['success']) {
      throw Exception(result.data['error']);
    }

    return PaymentMethod.fromJson(result.data['paymentMethod']);
  }

  // Determine pricing based on user type and count
  String getPriceId(String userType, {int marketCount = 0, bool isLifetimeFree = false}) {
    if (isLifetimeFree) return ''; // No price needed for lifetime free

    switch (userType) {
      case 'market_organizer':
        if (marketCount <= 3) return ''; // First 3 are free for life
        if (marketCount <= 23) return 'price_market_tier1'; // $29
        return 'price_market_tier2'; // $49
      case 'vendor':
        return 'price_vendor_premium'; // $29
      case 'shopper':
        return 'price_shopper_premium'; // $3.99
      default:
        throw Exception('Invalid user type');
    }
  }

  // Check if user qualifies for lifetime free
  Future<bool> qualifiesForLifetimeFree(String userId, String userType) async {
    if (userType == 'market_organizer') {
      // Check if this is one of the first 3 markets
      final marketCount = await _getMarketCount();
      return marketCount < 3;
    } else if (userType == 'vendor') {
      // Check if vendor belongs to one of the first 3 markets
      return await _isVendorInPioneerMarket(userId);
    }
    return false;
  }

  // Cancel subscription
  Future<bool> cancelSubscription(String subscriptionId) async {
    try {
      final result = await _functions.httpsCallable('cancelSubscription').call({
        'subscriptionId': subscriptionId,
      });
      return result.data['success'];
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  // Update payment method
  Future<bool> updatePaymentMethod(String subscriptionId, String paymentMethodId) async {
    try {
      final result = await _functions.httpsCallable('updatePaymentMethod').call({
        'subscriptionId': subscriptionId,
        'paymentMethodId': paymentMethodId,
      });
      return result.data['success'];
    } catch (e) {
      throw Exception('Failed to update payment method: $e');
    }
  }

  // Helper methods
  Future<UserSubscription?> _getSubscriptionFromFirestore(String userId) async {
    final doc = await _firestore.collection('user_subscriptions').doc(userId).get();
    return doc.exists ? UserSubscription.fromFirestore(doc) : null;
  }

  Future<int> _getMarketCount() async {
    final snapshot = await _firestore.collection('markets').get();
    return snapshot.docs.length;
  }

  Future<bool> _isVendorInPioneerMarket(String vendorId) async {
    // Logic to check if vendor is in one of the first 3 markets
    // This would involve querying the vendor's market associations
    final vendorDoc = await _firestore.collection('vendors').doc(vendorId).get();
    if (!vendorDoc.exists) return false;
    
    final marketIds = List<String>.from(vendorDoc.data()?['marketIds'] ?? []);
    
    // Get the first 3 markets created
    final pioneerMarkets = await _firestore
        .collection('markets')
        .orderBy('createdAt')
        .limit(3)
        .get();
    
    final pioneerMarketIds = pioneerMarkets.docs.map((doc) => doc.id).toList();
    
    return marketIds.any((id) => pioneerMarketIds.contains(id));
  }
}
```

### 5. Firebase Cloud Functions

Create server-side functions to handle Stripe operations securely:

**File: `server/stripe-functions.js`**

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const stripe = require('stripe')(functions.config().stripe.secret_key);

admin.initializeApp();
const db = admin.firestore();

// Create subscription
exports.createSubscription = functions.https.onCall(async (data, context) => {
  try {
    const { userId, userType, priceId, paymentMethodId, hasFreeTrial } = data;
    
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    // Create or get Stripe customer
    let customer;
    const userDoc = await db.collection('users').doc(userId).get();
    const userData = userDoc.data();
    
    if (userData.stripeCustomerId) {
      customer = await stripe.customers.retrieve(userData.stripeCustomerId);
    } else {
      customer = await stripe.customers.create({
        email: userData.email,
        metadata: { userId, userType }
      });
      
      // Update user with Stripe customer ID
      await db.collection('users').doc(userId).update({
        stripeCustomerId: customer.id
      });
    }

    // Attach payment method if provided
    if (paymentMethodId) {
      await stripe.paymentMethods.attach(paymentMethodId, {
        customer: customer.id,
      });
      
      // Set as default payment method
      await stripe.customers.update(customer.id, {
        invoice_settings: {
          default_payment_method: paymentMethodId,
        },
      });
    }

    // Create subscription
    const subscriptionData = {
      customer: customer.id,
      items: [{ price: priceId }],
      metadata: { userId, userType },
    };

    // Add trial period if applicable
    if (hasFreeTrial) {
      if (userType === 'vendor') {
        // 1 year free trial for vendors in first 3 markets
        subscriptionData.trial_period_days = 365;
      } else if (userType === 'shopper') {
        // 30-day free trial for shoppers
        subscriptionData.trial_period_days = 30;
      }
    }

    const subscription = await stripe.subscriptions.create(subscriptionData);

    // Save subscription to Firestore
    await db.collection('user_subscriptions').doc(userId).set({
      userId,
      userType,
      tier: 'premium',
      status: subscription.status,
      stripeCustomerId: customer.id,
      stripeSubscriptionId: subscription.id,
      stripePriceId: priceId,
      subscriptionStartDate: admin.firestore.Timestamp.fromDate(new Date(subscription.start_date * 1000)),
      nextPaymentDate: subscription.current_period_end ? 
        admin.firestore.Timestamp.fromDate(new Date(subscription.current_period_end * 1000)) : null,
      trialEndDate: subscription.trial_end ? 
        admin.firestore.Timestamp.fromDate(new Date(subscription.trial_end * 1000)) : null,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
    });

    return { success: true, subscriptionId: subscription.id };
  } catch (error) {
    console.error('Error creating subscription:', error);
    return { success: false, error: error.message };
  }
});

// Cancel subscription
exports.cancelSubscription = functions.https.onCall(async (data, context) => {
  try {
    const { subscriptionId } = data;
    
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    await stripe.subscriptions.update(subscriptionId, {
      cancel_at_period_end: true,
    });

    // Update Firestore
    const subscriptionDoc = await db.collection('user_subscriptions')
      .where('stripeSubscriptionId', '==', subscriptionId)
      .get();
    
    if (!subscriptionDoc.empty) {
      await subscriptionDoc.docs[0].ref.update({
        status: 'cancelled',
        updatedAt: admin.firestore.Timestamp.now(),
      });
    }

    return { success: true };
  } catch (error) {
    console.error('Error canceling subscription:', error);
    return { success: false, error: error.message };
  }
});

// Handle webhooks
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, functions.config().stripe.webhook_secret);
  } catch (err) {
    console.error('Webhook signature verification failed.', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  try {
    switch (event.type) {
      case 'customer.subscription.updated':
      case 'customer.subscription.deleted':
        await handleSubscriptionChange(event.data.object);
        break;
      case 'invoice.payment_succeeded':
        await handlePaymentSucceeded(event.data.object);
        break;
      case 'invoice.payment_failed':
        await handlePaymentFailed(event.data.object);
        break;
    }
  } catch (error) {
    console.error('Error handling webhook:', error);
    return res.status(400).send(`Webhook Error: ${error.message}`);
  }

  res.json({ received: true });
});

async function handleSubscriptionChange(subscription) {
  const subscriptionDoc = await db.collection('user_subscriptions')
    .where('stripeSubscriptionId', '==', subscription.id)
    .get();
  
  if (!subscriptionDoc.empty) {
    await subscriptionDoc.docs[0].ref.update({
      status: subscription.status,
      updatedAt: admin.firestore.Timestamp.now(),
    });
  }
}

async function handlePaymentSucceeded(invoice) {
  const subscription = await stripe.subscriptions.retrieve(invoice.subscription);
  const subscriptionDoc = await db.collection('user_subscriptions')
    .where('stripeSubscriptionId', '==', subscription.id)
    .get();
  
  if (!subscriptionDoc.empty) {
    await subscriptionDoc.docs[0].ref.update({
      status: 'active',
      lastPaymentDate: admin.firestore.Timestamp.fromDate(new Date(invoice.status_transitions.paid_at * 1000)),
      nextPaymentDate: admin.firestore.Timestamp.fromDate(new Date(subscription.current_period_end * 1000)),
      updatedAt: admin.firestore.Timestamp.now(),
    });
  }
}

async function handlePaymentFailed(invoice) {
  const subscription = await stripe.subscriptions.retrieve(invoice.subscription);
  const subscriptionDoc = await db.collection('user_subscriptions')
    .where('stripeSubscriptionId', '==', subscription.id)
    .get();
  
  if (!subscriptionDoc.empty) {
    await subscriptionDoc.docs[0].ref.update({
      status: 'past_due',
      updatedAt: admin.firestore.Timestamp.now(),
    });
  }
}
```

### 6. Payment UI Components

Create reusable payment components:

**File: `lib/widgets/subscription_upgrade_widget.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stripe_flutter/stripe_flutter.dart';
import '../services/payment_service.dart';
import '../models/user_subscription.dart';

class SubscriptionUpgradeWidget extends StatefulWidget {
  final String userId;
  final String userType;
  final Function(UserSubscription) onSubscriptionCreated;

  const SubscriptionUpgradeWidget({
    Key? key,
    required this.userId,
    required this.userType,
    required this.onSubscriptionCreated,
  }) : super(key: key);

  @override
  State<SubscriptionUpgradeWidget> createState() => _SubscriptionUpgradeWidgetState();
}

class _SubscriptionUpgradeWidgetState extends State<SubscriptionUpgradeWidget> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = false;
  CardFormEditController controller = CardFormEditController();

  @override
  void initState() {
    super.initState();
    _paymentService.initialize();
  }

  Future<void> _handlePayment() async {
    setState(() => _isLoading = true);

    try {
      // Check if user qualifies for lifetime free
      final isLifetimeFree = await _paymentService.qualifiesForLifetimeFree(
        widget.userId, 
        widget.userType
      );

      if (isLifetimeFree) {
        // Create free subscription
        final subscription = UserSubscription.createFree(widget.userId, widget.userType)
            .copyWith(isLifetimeFree: true);
        widget.onSubscriptionCreated(subscription);
        return;
      }

      // Create payment method
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      // Get price ID based on user type
      final priceId = _paymentService.getPriceId(widget.userType);
      
      // Create subscription
      final subscription = await _paymentService.createSubscription(
        userId: widget.userId,
        userType: widget.userType,
        priceId: priceId,
        paymentMethodId: paymentMethod.id,
        hasFreeTrial: widget.userType == 'shopper' || 
                     (widget.userType == 'vendor' && await _paymentService.qualifiesForLifetimeFree(widget.userId, 'vendor')),
      );

      if (subscription != null) {
        widget.onSubscriptionCreated(subscription);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Upgrade to Premium',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildPricingInfo(),
            const SizedBox(height: 16),
            CardFormField(
              controller: controller,
              style: CardFormStyle(
                backgroundColor: Colors.white,
                textColor: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _handlePayment,
              child: _isLoading 
                ? const CircularProgressIndicator()
                : const Text('Subscribe'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingInfo() {
    String price = '';
    String features = '';

    switch (widget.userType) {
      case 'market_organizer':
        price = 'Starting at \$29/month';
        features = '• Real-time analytics\n• Vendor management\n• Custom branding\n• Revenue reporting';
        break;
      case 'vendor':
        price = '\$29/month';
        features = '• Digital catalog\n• Customer insights\n• Pre-order functionality\n• Performance metrics';
        break;
      case 'shopper':
        price = '\$3.99/month';
        features = '• Advanced search\n• Pre-order capability\n• Exclusive deals\n• Unlimited favorites';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          price,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(features),
      ],
    );
  }
}
```

### 7. Subscription Management Screen

**File: `lib/screens/subscription_management_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/user_subscription.dart';
import '../services/payment_service.dart';
import '../widgets/subscription_upgrade_widget.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  final String userId;
  final String userType;

  const SubscriptionManagementScreen({
    Key? key,
    required this.userId,
    required this.userType,
  }) : super(key: key);

  @override
  State<SubscriptionManagementScreen> createState() => _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState extends State<SubscriptionManagementScreen> {
  final PaymentService _paymentService = PaymentService();
  UserSubscription? _subscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    // Load subscription from Firestore
    // Implementation depends on your data layer
    setState(() => _isLoading = false);
  }

  Future<void> _cancelSubscription() async {
    if (_subscription?.stripeSubscriptionId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text('Are you sure you want to cancel your subscription? You will lose access to premium features at the end of your billing period.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Subscription'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _paymentService.cancelSubscription(_subscription!.stripeSubscriptionId!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription cancelled successfully')),
        );
        _loadSubscription(); // Refresh
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel subscription: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_subscription?.isPremium == true) ...[
              _buildCurrentSubscriptionCard(),
              const SizedBox(height: 16),
              if (!_subscription!.isLifetimeFree) _buildManageSubscriptionCard(),
            ] else ...[
              SubscriptionUpgradeWidget(
                userId: widget.userId,
                userType: widget.userType,
                onSubscriptionCreated: (subscription) {
                  setState(() => _subscription = subscription);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSubscriptionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Premium Active',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_subscription!.isLifetimeFree) ...[
              const Text('Lifetime Free Account'),
              const Text('You have permanent access to all premium features!'),
            ] else ...[
              Text('Next billing: ${_subscription!.nextPaymentDate?.toString().split(' ')[0] ?? 'N/A'}'),
              Text('Status: ${_subscription!.status.name}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildManageSubscriptionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Manage Subscription',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _cancelSubscription,
              child: const Text('Cancel Subscription'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 8. Implementation Checklist

#### Phase 1: Setup (Week 1)
- [ ] Create Stripe account and get API keys
- [ ] Set up Stripe products and pricing in dashboard
- [ ] Add Stripe dependencies to Flutter project
- [ ] Set up Firebase Cloud Functions for Stripe operations
- [ ] Configure webhook endpoints

#### Phase 2: Core Integration (Week 2-3)
- [ ] Implement PaymentService class
- [ ] Update UserSubscription model with Stripe fields
- [ ] Create subscription upgrade UI components
- [ ] Implement payment method handling
- [ ] Add error handling and validation

#### Phase 3: Business Logic (Week 4)
- [ ] Implement lifetime free tier logic
- [ ] Add market count-based pricing for organizers
- [ ] Implement vendor free year trial for pioneer markets
- [ ] Add subscription status checks throughout app
- [ ] Create subscription management screen

#### Phase 4: Testing & Security (Week 5)
- [ ] Test all payment flows with test cards
- [ ] Implement proper error handling
- [ ] Add logging and analytics
- [ ] Security audit of payment flows
- [ ] Test webhook handling

#### Phase 5: Production Deployment (Week 6)
- [ ] Switch to production Stripe keys
- [ ] Deploy Cloud Functions
- [ ] Configure production webhooks
- [ ] Monitor payment flows
- [ ] Set up customer support for payment issues

### 9. Security Considerations

1. **Never store card details** - Use Stripe's secure token system
2. **Validate webhooks** - Always verify webhook signatures
3. **Server-side validation** - All payment operations happen server-side
4. **PCI compliance** - Let Stripe handle card data
5. **Error handling** - Don't expose sensitive error details to users

### 10. Testing Strategy

#### Test Cards for Development
```
# Successful payments
4242424242424242 (Visa)
4000056655665556 (Visa Debit)

# Failed payments
4000000000000002 (Card declined)
4000000000009995 (Insufficient funds)

# 3D Secure
4000002500003155 (Requires authentication)
```

#### Test Scenarios
- [ ] Successful subscription creation
- [ ] Failed payment handling
- [ ] Subscription cancellation
- [ ] Payment method updates
- [ ] Webhook processing
- [ ] Free tier assignments
- [ ] Trial period handling

### 11. Monitoring & Analytics

Track these key metrics:
- Subscription conversion rates
- Payment failure rates
- Churn rates by user type
- Revenue by subscription tier
- Free-to-paid conversion rates

### 12. Next Steps

1. **Set up Stripe account** and get API keys
2. **Create test products** in Stripe dashboard
3. **Implement PaymentService** with basic functionality
4. **Build subscription UI** components
5. **Test end-to-end** payment flow
6. **Deploy to staging** environment
7. **Launch with limited beta** users
8. **Monitor and iterate** based on feedback

---

*This implementation guide provides the foundation for HiPOP's subscription-based revenue model. Regular updates and testing will ensure a robust payment system that supports our aggressive growth strategy.*

*Last updated: January 2025*