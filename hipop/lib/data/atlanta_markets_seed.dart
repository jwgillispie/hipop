import '../models/market.dart';

class AtlantaMarketsSeed {
  static List<Market> getAtlantaMarkets() {
    final now = DateTime.now();
    
    return [
      Market(
        id: '', // Will be set by Firestore
        name: 'Ponce City Market',
        address: '675 Ponce de Leon Ave NE',
        city: 'Atlanta',
        state: 'GA',
        latitude: 33.7701,
        longitude: -84.3657,
        placeId: 'ChIJ8S0EmX4X9YgR-jYUE4nRCVM',
        operatingDays: {
          'monday': '11AM-9PM',
          'tuesday': '11AM-9PM',
          'wednesday': '11AM-9PM',
          'thursday': '11AM-9PM',
          'friday': '11AM-10PM',
          'saturday': '10AM-10PM',
          'sunday': '12PM-8PM',
        },
        description: 'A mixed-use development with shops, restaurants, and food vendors in a historic Sears building.',
        imageUrl: 'https://example.com/ponce-city-market.jpg',
        isActive: true,
        createdAt: now,
      ),
      
      Market(
        id: '',
        name: 'West End Farmers Market',
        address: '45 Ralph David Abernathy Blvd SW',
        city: 'Atlanta',
        state: 'GA',
        latitude: 33.7356,
        longitude: -84.4123,
        operatingDays: {
          'saturday': '9AM-1PM',
        },
        description: 'Community farmers market featuring local vendors, fresh produce, and artisanal goods.',
        isActive: true,
        createdAt: now,
      ),
      
      Market(
        id: '',
        name: 'Grant Park Farmers Market',
        address: '840 Cherokee Ave SE',
        city: 'Atlanta',
        state: 'GA',
        latitude: 33.7421,
        longitude: -84.3706,
        operatingDays: {
          'sunday': '9AM-1PM',
        },
        description: 'Neighborhood farmers market in historic Grant Park with local vendors and live music.',
        isActive: true,
        createdAt: now,
      ),
      
      Market(
        id: '',
        name: 'Peachtree Road Farmers Market',
        address: '3393 Peachtree Rd NE',
        city: 'Atlanta',
        state: 'GA',
        latitude: 33.8418,
        longitude: -84.3733,
        operatingDays: {
          'saturday': '8AM-12PM',
        },
        description: 'Upscale farmers market in Buckhead featuring premium vendors and gourmet food options.',
        isActive: true,
        createdAt: now,
      ),
      
      Market(
        id: '',
        name: 'Tucker Farmers Market',
        address: '4799 LaVista Rd',
        city: 'Tucker',
        state: 'GA',
        latitude: 33.8546,
        longitude: -84.2174,
        operatingDays: {
          'saturday': '8AM-12PM',
        },
        description: 'Family-friendly farmers market serving the Tucker community with local vendors.',
        isActive: true,
        createdAt: now,
      ),
      
      Market(
        id: '',
        name: 'Morningside Farmers Market',
        address: '1393 N Highland Ave NE',
        city: 'Atlanta',
        state: 'GA',
        latitude: 33.7872,
        longitude: -84.3533,
        operatingDays: {
          'saturday': '8AM-11:30AM',
        },
        description: 'Intimate neighborhood market in Virginia-Highland with carefully curated vendors.',
        isActive: true,
        createdAt: now,
      ),
      
      Market(
        id: '',
        name: 'Dunwoody Farmers Market',
        address: '5339 Chamblee Dunwoody Rd',
        city: 'Dunwoody',
        state: 'GA',
        latitude: 33.9284,
        longitude: -84.3455,
        operatingDays: {
          'saturday': '8AM-12PM',
        },
        description: 'Suburban farmers market with diverse vendors and family activities.',
        isActive: true,
        createdAt: now,
      ),
    ];
  }
}