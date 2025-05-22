# HiPop Technical Architecture Plan

## System Architecture Overview

### Backend Architecture
- **API Framework**: FastAPI (Python) - you're already familiar with this
- **Database**: MongoDB with Beanie ODM - matches your existing expertise
- **Authentication**: Firebase Auth - integrates well with your current stack
- **File Storage**: Firebase Storage for images and documents
- **Hosting**: Render for API hosting - your preferred choice

### Frontend Architecture
- **Mobile App**: Flutter with BLoC pattern - your strongest skillset
- **State Management**: flutter_bloc for predictable state management
- **Navigation**: go_router for declarative routing
- **API Integration**: dio for HTTP requests with interceptors

### Real-time Features
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **Real-time Updates**: WebSocket connections for live event updates
- **Background Sync**: Firebase Cloud Functions for automated tasks

## Database Schema Design

### User Collections
```
users: {
  _id: ObjectId,
  firebase_uid: string,
  user_type: enum['vendor', 'shopper', 'market_organizer'],
  email: string,
  created_at: datetime,
  profile_complete: boolean,
  subscription_tier: enum['free', 'premium']
}

vendor_profiles: {
  _id: ObjectId,
  user_id: ObjectId,
  business_name: string,
  description: string,
  categories: [string],
  images: [string],
  contact_info: object,
  social_links: object,
  analytics_enabled: boolean
}

shopper_profiles: {
  _id: ObjectId,
  user_id: ObjectId,
  display_name: string,
  location: object,
  interests: [string],
  followed_vendors: [ObjectId],
  notification_preferences: object
}

market_organizer_profiles: {
  _id: ObjectId,
  user_id: ObjectId,
  organization_name: string,
  description: string,
  contact_info: object,
  verified: boolean
}
```

### Event & Market Collections
```
markets: {
  _id: ObjectId,
  organizer_id: ObjectId,
  name: string,
  description: string,
  location: {
    address: string,
    coordinates: [lat, lng],
    neighborhood: string
  },
  recurring_schedule: object,
  amenities: [string],
  vendor_spots: number,
  application_deadline: datetime
}

events: {
  _id: ObjectId,
  market_id: ObjectId,
  date: datetime,
  duration: object,
  participating_vendors: [ObjectId],
  status: enum['scheduled', 'active', 'completed', 'cancelled'],
  weather_dependent: boolean,
  special_notes: string
}

vendor_applications: {
  _id: ObjectId,
  vendor_id: ObjectId,
  event_id: ObjectId,
  application_date: datetime,
  status: enum['pending', 'approved', 'rejected'],
  booth_preferences: object,
  products_offered: [string]
}
```

## Flutter App Architecture

### Project Structure
```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── vendor/
│   ├── shopper/
│   ├── market/
│   └── shared/
├── injection_container.dart
└── main.dart
```

### Key BLoC Components
```dart
// Authentication BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Handle login, logout, user type switching
}

// Vendor Dashboard BLoC
class VendorDashboardBloc extends Bloc<VendorEvent, VendorState> {
  // Manage vendor profile, events, applications
}

// Event Discovery BLoC
class EventDiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  // Handle search, filters, recommendations
}

// Notification BLoC
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  // Manage push notifications and real-time updates
}
```

## API Endpoints Structure

### Authentication Endpoints
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `PUT /auth/profile` - Update user profile
- `GET /auth/me` - Get current user

### Vendor Endpoints
- `GET/POST/PUT /vendors/profile` - Vendor profile management
- `GET /vendors/events` - Vendor's upcoming events
- `POST /vendors/applications` - Submit market applications
- `GET /vendors/analytics` - Performance analytics

### Shopper Endpoints
- `GET /events/discover` - Discover events with filters
- `POST /users/follow` - Follow/unfollow vendors
- `GET /users/recommendations` - Personalized recommendations
- `POST /events/save` - Save events to calendar

### Market Organizer Endpoints
- `GET/POST/PUT /markets` - Market management
- `GET /markets/{id}/applications` - View vendor applications
- `PUT /applications/{id}/status` - Approve/reject applications
- `GET /markets/analytics` - Market performance data

## Development Phases

### Phase 1: Core Infrastructure (Weeks 1-4)
1. Set up FastAPI project with basic structure
2. Configure MongoDB with Beanie models
3. Implement Firebase Auth integration
4. Create basic Flutter app with BLoC architecture
5. Set up API communication layer

### Phase 2: Vendor Features (Weeks 5-8)
1. Vendor registration and profile creation
2. Event discovery and application system
3. Basic dashboard with upcoming events
4. Image upload for vendor profiles
5. Push notifications for application updates

### Phase 3: Shopper Experience (Weeks 9-12)
1. Event discovery with map integration
2. Search and filtering capabilities
3. Vendor following and notifications
4. Event calendar and reminders
5. Basic recommendation engine

### Phase 4: Market Organizer Tools (Weeks 13-16)
1. Market creation and management
2. Vendor application review system
3. Event publishing and promotion
4. Basic analytics dashboard
5. Communication tools

## Revenue Implementation

### Subscription Management
- Integrate with RevenueCat or build custom subscription logic
- Implement feature gating based on subscription tiers
- Track usage metrics for freemium conversion

### Payment Processing
- Stripe integration for subscription payments
- Optional: Transaction fees for event bookings
- Market organizer listing fees

## Deployment Strategy

### Backend Deployment (Render)
- Automated deployments from Git
- Environment variable management
- Database connection pooling
- API rate limiting and security

### Mobile App Distribution
- iOS: App Store Connect (you have experience)
- Android: Google Play Store
- Beta testing through Firebase App Distribution

Would you like me to elaborate on any specific aspect of this technical architecture?