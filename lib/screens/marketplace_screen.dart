import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/marketplace_listing.dart';
import '../models/user.dart' as app_user;
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/marketplace_card.dart';
import 'add_listing_screen.dart';

/// Marketplace screen for AgriAI app
/// Allows farmers to list crops and buyers to browse listings
class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> with TickerProviderStateMixin {
  
  late TabController _tabController;
  List<MarketplaceListing> _allListings = [];
  List<MarketplaceListing> _filteredListings = [];
  List<MarketplaceListing> _myListings = [];
  app_user.User? _currentUser;
  bool _isLoading = true;
  String _selectedCrop = '';
  String _selectedState = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      _currentUser = authService.currentUser;
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load marketplace data from Firebase/API
  Future<void> _loadData() async {
    try {
      // Load marketplace listings from Firebase/API instead of dummy data
      final apiService = ApiService();
      _allListings = await apiService.fetchMarketplaceListings();
      
      _filteredListings = List.from(_allListings);
      
      // Load user's own listings if logged in
      if (_currentUser != null) {
        _myListings = await apiService.fetchMarketplaceListingsByFarmer(_currentUser!.id);
        
        // Also add user's listings to all listings if not already present
        for (var myListing in _myListings) {
          if (!_allListings.any((listing) => listing.id == myListing.id)) {
            _allListings.add(myListing);
          }
        }
        _filteredListings = List.from(_allListings);
      } else {
        _myListings = [];
      }
    } catch (e) {
      print('Error loading marketplace data: $e');
      // Fallback: Load demo marketplace listings
      _allListings = _getDemoMarketplaceListings();
      _filteredListings = List.from(_allListings);
      
      // Filter demo listings by current user if available
      if (_currentUser != null) {
        _myListings = _allListings
            .where((listing) => listing.farmerId == _currentUser!.id)
            .toList();
      } else {
        _myListings = [];
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Filter listings using API search
  Future<void> _filterListings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      
      // Use API search for better performance with large datasets
      _filteredListings = await apiService.searchMarketplaceListings(
        cropName: _selectedCrop.isEmpty ? null : _selectedCrop,
        state: _selectedState.isEmpty ? null : _selectedState,
      );
    } catch (e) {
      print('Error filtering listings: $e');
      // Fallback to local filtering
      _filteredListings = _allListings.where((listing) {
        bool matchesCrop = _selectedCrop.isEmpty || 
            listing.cropName.toLowerCase().contains(_selectedCrop.toLowerCase());
        bool matchesState = _selectedState.isEmpty || 
            listing.state.toLowerCase().contains(_selectedState.toLowerCase());
        return matchesCrop && matchesState && listing.isAvailable;
      }).toList();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Get unique crop names
  List<String> get _uniqueCrops {
    return _allListings.map((listing) => listing.cropName).toSet().toList()..sort();
  }

  /// Get unique states
  List<String> get _uniqueStates {
    return _allListings.map((listing) => listing.state).toSet().toList()..sort();
  }

  /// Get demo marketplace listings for fallback
  List<MarketplaceListing> _getDemoMarketplaceListings() {
    return [
      // Cereal Crops
      MarketplaceListing(
        id: 'mp_rice_001',
        farmerId: 'farmer1',
        farmerName: 'Ramesh Patil',
        contactPhone: '+91 9876543210',
        cropName: 'Rice',
        quantity: 5.0,
        unit: 'quintal',
        pricePerQuintal: 3500.0,
        description: 'Fresh organic rice, recently harvested. No chemicals used.',
        imageUrls: [],
        state: 'Maharashtra',
        location: 'Pune, Maharashtra',
        cropVariety: 'Basmati',
        qualityGrade: 'A',
        isOrganic: true,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 2)),
      ),
      MarketplaceListing(
        id: 'mp_rice_002',
        farmerId: 'farmer5',
        farmerName: 'Harpal Singh',
        contactPhone: '+91 9876543220',
        cropName: 'Rice',
        quantity: 8.0,
        unit: 'quintal',
        pricePerQuintal: 3400.0,
        description: 'Premium quality Pusa Basmati rice, aged for better aroma.',
        imageUrls: [],
        state: 'Haryana',
        location: 'Karnal, Haryana',
        cropVariety: 'Pusa Basmati',
        qualityGrade: 'A+',
        isOrganic: false,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 1)),
      ),
      MarketplaceListing(
        id: 'mp_wheat_001',
        farmerId: 'farmer2',
        farmerName: 'Suresh Kumar',
        contactPhone: '+91 9876543211',
        cropName: 'Wheat',
        quantity: 3.0,
        unit: 'quintal',
        pricePerQuintal: 4200.0,
        description: 'High quality wheat grains, perfect for flour making.',
        imageUrls: [],
        state: 'Uttar Pradesh',
        location: 'Agra, Uttar Pradesh',
        cropVariety: 'Lokvan',
        qualityGrade: 'A',
        isOrganic: false,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 3)),
      ),
      MarketplaceListing(
        id: 'mp_wheat_002',
        farmerId: 'farmer6',
        farmerName: 'Mohan Lal',
        contactPhone: '+91 9876543221',
        cropName: 'Wheat',
        quantity: 6.5,
        unit: 'quintal',
        pricePerQuintal: 4100.0,
        description: 'Durum wheat variety, excellent for pasta and bread making.',
        imageUrls: [],
        state: 'Madhya Pradesh',
        location: 'Bhopal, Madhya Pradesh',
        cropVariety: 'Durum',
        qualityGrade: 'A',
        isOrganic: true,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 2)),
      ),
      MarketplaceListing(
        id: 'mp_maize_001',
        farmerId: 'farmer7',
        farmerName: 'Venkatesh Reddy',
        contactPhone: '+91 9876543222',
        cropName: 'Maize',
        quantity: 4.0,
        unit: 'quintal',
        pricePerQuintal: 2800.0,
        description: 'Yellow maize, suitable for animal feed and food processing.',
        imageUrls: [],
        state: 'Karnataka',
        location: 'Davangere, Karnataka',
        cropVariety: 'Yellow Dent',
        qualityGrade: 'B+',
        isOrganic: false,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 4)),
      ),
      
      // Vegetables
      MarketplaceListing(
        id: 'mp_tomato_001',
        farmerId: 'farmer3',
        farmerName: 'Lakshmi Devi',
        contactPhone: '+91 9876543212',
        cropName: 'Tomato',
        quantity: 2.0,
        unit: 'quintal',
        pricePerQuintal: 2500.0,
        description: 'Fresh red tomatoes, pesticide free, perfect for cooking.',
        imageUrls: [],
        state: 'Karnataka',
        location: 'Bangalore, Karnataka',
        cropVariety: 'Hybrid',
        qualityGrade: 'A',
        isOrganic: true,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 1)),
      ),
      MarketplaceListing(
        id: 'mp_tomato_002',
        farmerId: 'farmer8',
        farmerName: 'Rajesh Sharma',
        contactPhone: '+91 9876543223',
        cropName: 'Tomato',
        quantity: 3.5,
        unit: 'quintal',
        pricePerQuintal: 2800.0,
        description: 'Premium cherry tomatoes, ideal for salads and restaurants.',
        imageUrls: [],
        state: 'Delhi',
        location: 'Ghaziabad, Delhi NCR',
        cropVariety: 'Cherry Tomato',
        qualityGrade: 'A+',
        isOrganic: true,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      MarketplaceListing(
        id: 'mp_onion_001',
        farmerId: 'farmer4',
        farmerName: 'Prakash Singh',
        contactPhone: '+91 9876543213',
        cropName: 'Onion',
        quantity: 4.0,
        unit: 'quintal',
        pricePerQuintal: 3000.0,
        description: 'Quality red onions, good for long storage, low moisture.',
        imageUrls: [],
        state: 'Rajasthan',
        location: 'Jodhpur, Rajasthan',
        cropVariety: 'Red Onion',
        qualityGrade: 'B',
        isOrganic: false,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 4)),
      ),
      MarketplaceListing(
        id: 'mp_onion_002',
        farmerId: 'farmer9',
        farmerName: 'Kiran Patil',
        contactPhone: '+91 9876543224',
        cropName: 'Onion',
        quantity: 6.0,
        unit: 'quintal',
        pricePerQuintal: 3200.0,
        description: 'White onions, premium quality from Nashik region.',
        imageUrls: [],
        state: 'Maharashtra',
        location: 'Nashik, Maharashtra',
        cropVariety: 'White Onion',
        qualityGrade: 'A',
        isOrganic: false,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 3)),
      ),
      MarketplaceListing(
        id: 'mp_potato_001',
        farmerId: 'farmer10',
        farmerName: 'Bharat Kumar',
        contactPhone: '+91 9876543225',
        cropName: 'Potato',
        quantity: 5.0,
        unit: 'quintal',
        pricePerQuintal: 1800.0,
        description: 'Fresh potatoes, good for chips and cooking, no sprouting.',
        imageUrls: [],
        state: 'Uttar Pradesh',
        location: 'Agra, Uttar Pradesh',
        cropVariety: 'Kufri Jyoti',
        qualityGrade: 'A',
        isOrganic: false,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 2)),
      ),
      MarketplaceListing(
        id: 'mp_cabbage_001',
        farmerId: 'farmer11',
        farmerName: 'Sunita Devi',
        contactPhone: '+91 9876543226',
        cropName: 'Cabbage',
        quantity: 2.5,
        unit: 'quintal',
        pricePerQuintal: 1200.0,
        description: 'Fresh green cabbage, organically grown in hill station.',
        imageUrls: [],
        state: 'Tamil Nadu',
        location: 'Ooty, Tamil Nadu',
        cropVariety: 'Green Cabbage',
        qualityGrade: 'A+',
        isOrganic: true,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 1)),
      ),
      
      // Cash Crops
      MarketplaceListing(
        id: 'mp_cotton_001',
        farmerId: 'farmer12',
        farmerName: 'Gita Sharma',
        contactPhone: '+91 9876543214',
        cropName: 'Cotton',
        quantity: 1.5,
        unit: 'quintal',
        pricePerQuintal: 5500.0,
        description: 'Premium BT cotton, grade A quality, pest resistant.',
        imageUrls: [],
        state: 'Gujarat',
        location: 'Surat, Gujarat',
        cropVariety: 'BT Cotton',
        qualityGrade: 'A',
        isOrganic: false,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 5)),
      ),
      MarketplaceListing(
        id: 'mp_cotton_002',
        farmerId: 'farmer13',
        farmerName: 'Ravi Patel',
        contactPhone: '+91 9876543227',
        cropName: 'Cotton',
        quantity: 2.0,
        unit: 'quintal',
        pricePerQuintal: 5400.0,
        description: 'Organic cotton, naturally grown without chemicals.',
        imageUrls: [],
        state: 'Telangana',
        location: 'Adilabad, Telangana',
        cropVariety: 'Organic Cotton',
        qualityGrade: 'A',
        isOrganic: true,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 6)),
      ),
      MarketplaceListing(
        id: 'mp_sugarcane_001',
        farmerId: 'farmer14',
        farmerName: 'Mahesh Yadav',
        contactPhone: '+91 9876543228',
        cropName: 'Sugarcane',
        quantity: 10.0,
        unit: 'quintal',
        pricePerQuintal: 3200.0,
        description: 'High sucrose content sugarcane, suitable for sugar mills.',
        imageUrls: [],
        state: 'Uttar Pradesh',
        location: 'Lucknow, Uttar Pradesh',
        cropVariety: 'Co-0238',
        qualityGrade: 'A',
        isOrganic: false,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 7)),
      ),
      
      // Oilseeds
      MarketplaceListing(
        id: 'mp_soybean_001',
        farmerId: 'farmer15',
        farmerName: 'Deepak Jain',
        contactPhone: '+91 9876543229',
        cropName: 'Soybean',
        quantity: 3.0,
        unit: 'quintal',
        pricePerQuintal: 4800.0,
        description: 'Yellow soybean, high protein content, perfect for oil extraction.',
        imageUrls: [],
        state: 'Madhya Pradesh',
        location: 'Indore, Madhya Pradesh',
        cropVariety: 'JS-335',
        qualityGrade: 'A',
        isOrganic: false,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 3)),
      ),
      MarketplaceListing(
        id: 'mp_groundnut_001',
        farmerId: 'farmer16',
        farmerName: 'Jayesh Bhai',
        contactPhone: '+91 9876543230',
        cropName: 'Groundnut',
        quantity: 2.5,
        unit: 'quintal',
        pricePerQuintal: 5200.0,
        description: 'Bold groundnuts, high oil content, drought resistant variety.',
        imageUrls: [],
        state: 'Gujarat',
        location: 'Rajkot, Gujarat',
        cropVariety: 'GG-20',
        qualityGrade: 'A+',
        isOrganic: false,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 4)),
      ),
      MarketplaceListing(
        id: 'mp_mustard_001',
        farmerId: 'farmer17',
        farmerName: 'Hemant Singh',
        contactPhone: '+91 9876543231',
        cropName: 'Mustard',
        quantity: 1.8,
        unit: 'quintal',
        pricePerQuintal: 6200.0,
        description: 'Black mustard seeds, high oil content, aromatic variety.',
        imageUrls: [],
        state: 'Rajasthan',
        location: 'Jaipur, Rajasthan',
        cropVariety: 'Pusa Bold',
        qualityGrade: 'A',
        isOrganic: true,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 5)),
      ),
      
      // Pulses
      MarketplaceListing(
        id: 'mp_tur_001',
        farmerId: 'farmer18',
        farmerName: 'Ashok Patil',
        contactPhone: '+91 9876543232',
        cropName: 'Tur Dal',
        quantity: 2.0,
        unit: 'quintal',
        pricePerQuintal: 8500.0,
        description: 'Premium quality tur dal, uniform size, high protein.',
        imageUrls: [],
        state: 'Maharashtra',
        location: 'Latur, Maharashtra',
        cropVariety: 'Asha (ICPL-87)',
        qualityGrade: 'A+',
        isOrganic: false,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 2)),
      ),
      MarketplaceListing(
        id: 'mp_chana_001',
        farmerId: 'farmer19',
        farmerName: 'Dinesh Kumar',
        contactPhone: '+91 9876543233',
        cropName: 'Chana',
        quantity: 1.5,
        unit: 'quintal',
        pricePerQuintal: 7200.0,
        description: 'Desi chana, small size, high protein, good for dal making.',
        imageUrls: [],
        state: 'Rajasthan',
        location: 'Kota, Rajasthan',
        cropVariety: 'Desi Chana',
        qualityGrade: 'A',
        isOrganic: true,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 3)),
      ),
      MarketplaceListing(
        id: 'mp_moong_001',
        farmerId: 'farmer20',
        farmerName: 'Kavita Sharma',
        contactPhone: '+91 9876543234',
        cropName: 'Moong',
        quantity: 1.0,
        unit: 'quintal',
        pricePerQuintal: 9500.0,
        description: 'Green moong dal, fresh harvest, perfect for sprouts.',
        imageUrls: [],
        state: 'Rajasthan',
        location: 'Jaipur, Rajasthan',
        cropVariety: 'Pusa Vishal',
        qualityGrade: 'A+',
        isOrganic: false,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 1)),
      ),
      
      // Fruits
      MarketplaceListing(
        id: 'mp_apple_001',
        farmerId: 'farmer21',
        farmerName: 'Rajinder Singh',
        contactPhone: '+91 9876543235',
        cropName: 'Apple',
        quantity: 0.5,
        unit: 'quintal',
        pricePerQuintal: 8000.0,
        description: 'Red delicious apples from Shimla, crisp and sweet.',
        imageUrls: [],
        state: 'Himachal Pradesh',
        location: 'Shimla, Himachal Pradesh',
        cropVariety: 'Red Delicious',
        qualityGrade: 'A+',
        isOrganic: false,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      MarketplaceListing(
        id: 'mp_banana_001',
        farmerId: 'farmer22',
        farmerName: 'Sunil Patil',
        contactPhone: '+91 9876543236',
        cropName: 'Banana',
        quantity: 1.0,
        unit: 'quintal',
        pricePerQuintal: 1800.0,
        description: 'Robusta bananas, naturally ripened, perfect sweetness.',
        imageUrls: [],
        state: 'Maharashtra',
        location: 'Jalgaon, Maharashtra',
        cropVariety: 'Robusta',
        qualityGrade: 'A',
        isOrganic: true,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 2)),
      ),
      MarketplaceListing(
        id: 'mp_orange_001',
        farmerId: 'farmer23',
        farmerName: 'Pradeep Kumar',
        contactPhone: '+91 9876543237',
        cropName: 'Orange',
        quantity: 2.0,
        unit: 'quintal',
        pricePerQuintal: 3200.0,
        description: 'Nagpur oranges, juicy and sweet, high vitamin C content.',
        imageUrls: [],
        state: 'Maharashtra',
        location: 'Nagpur, Maharashtra',
        cropVariety: 'Nagpur Orange',
        qualityGrade: 'A+',
        isOrganic: false,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 1)),
      ),
      
      // Spices
      MarketplaceListing(
        id: 'mp_turmeric_001',
        farmerId: 'farmer24',
        farmerName: 'Murugan Raju',
        contactPhone: '+91 9876543238',
        cropName: 'Turmeric',
        quantity: 0.8,
        unit: 'quintal',
        pricePerQuintal: 12500.0,
        description: 'Salem turmeric, high curcumin content, bright yellow color.',
        imageUrls: [],
        state: 'Tamil Nadu',
        location: 'Erode, Tamil Nadu',
        cropVariety: 'Salem Turmeric',
        qualityGrade: 'A+',
        isOrganic: true,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 3)),
      ),
      MarketplaceListing(
        id: 'mp_coriander_001',
        farmerId: 'farmer25',
        farmerName: 'Gopal Joshi',
        contactPhone: '+91 9876543239',
        cropName: 'Coriander',
        quantity: 0.3,
        unit: 'quintal',
        pricePerQuintal: 18000.0,
        description: 'Rajasthan coriander seeds, aromatic variety, good oil content.',
        imageUrls: [],
        state: 'Rajasthan',
        location: 'Ramganj Mandi, Rajasthan',
        cropVariety: 'Pant Haritima',
        qualityGrade: 'A',
        isOrganic: false,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 4)),
      ),
      MarketplaceListing(
        id: 'mp_chilli_001',
        farmerId: 'farmer26',
        farmerName: 'Venkat Rao',
        contactPhone: '+91 9876543240',
        cropName: 'Red Chilli',
        quantity: 0.5,
        unit: 'quintal',
        pricePerQuintal: 15000.0,
        description: 'Guntur red chillies, high pungency, deep red color.',
        imageUrls: [],
        state: 'Andhra Pradesh',
        location: 'Guntur, Andhra Pradesh',
        cropVariety: 'Teja',
        qualityGrade: 'A+',
        isOrganic: false,
        isAvailable: true,
        status: 'active',
        dateListed: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Browse', icon: Icon(Icons.shopping_cart)),
            Tab(text: 'My Listings', icon: Icon(Icons.inventory)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBrowseTab(),
                _buildMyListingsTab(),
              ],
            ),
      floatingActionButton: Consumer<AuthService>(
        builder: (context, authService, child) {
          final user = authService.currentUser;
          if (user == null || user.userType != 'farmer') return Container();
          
          return FloatingActionButton.extended(
            onPressed: _showAddListingDialog,
            backgroundColor: Colors.purple[600],
            icon: const Icon(Icons.add),
            label: const Text('Add Listing'),
          );
        },
      ),
    );
  }

  /// Build browse tab
  Widget _buildBrowseTab() {
    return Column(
      children: [
        // Filters
        _buildFiltersSection(),
        
        // Listings
        Expanded(
          child: _buildListingsList(_filteredListings),
        ),
      ],
    );
  }

  /// Build my listings tab
  Widget _buildMyListingsTab() {
    return _buildListingsList(_myListings, isMyListings: true);
  }

  /// Build filters section
  Widget _buildFiltersSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Listings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCrop.isEmpty ? null : _selectedCrop,
                  decoration: InputDecoration(
                    labelText: 'Crop',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('All Crops'),
                    ),
                    ..._uniqueCrops.map((crop) {
                      return DropdownMenuItem(
                        value: crop,
                        child: Text(crop),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCrop = value ?? '';
                      _filterListings();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedState.isEmpty ? null : _selectedState,
                  decoration: InputDecoration(
                    labelText: 'State',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('All States'),
                    ),
                    ..._uniqueStates.map((state) {
                      return DropdownMenuItem(
                        value: state,
                        child: Text(state),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedState = value ?? '';
                      _filterListings();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build listings list
  Widget _buildListingsList(List<MarketplaceListing> listings, {bool isMyListings = false}) {
    if (listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isMyListings ? Icons.inventory : Icons.shopping_cart,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isMyListings ? 'No listings yet' : 'No listings found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isMyListings 
                  ? 'Add your first listing to start selling'
                  : 'Try adjusting your filters',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        return MarketplaceCard(
          listing: listing,
          isOwner: isMyListings,
          onTap: () => _showListingDetails(listing),
          onContact: () => _contactFarmer(listing),
          onEdit: isMyListings ? () => _editListing(listing) : null,
          onDelete: isMyListings ? () => _deleteListing(listing) : null,
        );
      },
    );
  }

  /// Show listing details
  void _showListingDetails(MarketplaceListing listing) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(listing.cropName),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Farmer: ${listing.farmerName}'),
                Text('Location: ${listing.location}, ${listing.state}'),
                Text('Quantity: ${listing.quantity} ${listing.unit}'),
                Text('Price: ${listing.formattedPrice}'),
                Text('Quality Grade: ${listing.qualityGrade}'),
                Text('Organic: ${listing.organicBadge}'),
                if (listing.cropVariety.isNotEmpty)
                  Text('Variety: ${listing.cropVariety}'),
                const SizedBox(height: 16),
                if (listing.description.isNotEmpty) ...[
                  const Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(listing.description),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            if (listing.isAvailable)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _contactFarmer(listing);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Contact Farmer'),
              ),
          ],
        );
      },
    );
  }

  /// Contact farmer
  void _contactFarmer(MarketplaceListing listing) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Contact Farmer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Contact ${listing.farmerName} for ${listing.cropName}'),
              const SizedBox(height: 16),
              Text('Phone: ${listing.contactPhone}'),
              const SizedBox(height: 16),
              const Text(
                'You can call the farmer directly or the app will notify them of your interest.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Farmer has been notified of your interest!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Express Interest'),
            ),
          ],
        );
      },
    );
  }

  /// Show add listing screen
  void _showAddListingDialog() async {
    // Get current user from auth service
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add listings'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddListingScreen(currentUser: authService.currentUser!),
      ),
    );
    
    // If a listing was added successfully, refresh the data
    if (result == true) {
      setState(() => _isLoading = true);
      _currentUser = authService.currentUser; // Update current user
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  /// Edit listing
  void _editListing(MarketplaceListing listing) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit listing feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Delete listing
  void _deleteListing(MarketplaceListing listing) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Listing'),
          content: Text('Are you sure you want to delete the listing for ${listing.cropName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  // Remove from demo data
                  setState(() {
                    _myListings.removeWhere((l) => l.id == listing.id);
                    _allListings.removeWhere((l) => l.id == listing.id);
                    _filterListings();
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Listing deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting listing: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}