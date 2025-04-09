import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' hide context; // Hide Context from path package

class HomePage extends StatefulWidget {
  final String? name;
  final String? email;
  final int? userId;

  const HomePage({
    Key? key, 
    this.name, 
    this.email,
    this.userId,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  
  late DatabaseHelper dbHelper;
  final TextEditingController _searchController = TextEditingController();
  bool isLoggedIn = true;
  String searchQuery = "";
  String get name => widget.name ?? "பயனர்";
  String get email => widget.email ?? "guest@example.com";
  
  List<int> savedPlaceIds = [];
  
  final List<String> sliderImages = [
    'assets/images/nilgiri_mountain_railway.jpg',
    'assets/images/natarajar.jpg',
    'assets/images/dhanushkodi.jpg',
    'assets/images/meenakshi_temple.jpg',
  ];

  final List<Map<String, dynamic>> touristSpots = [
    {
      'name': 'மகாபலிபுரம் கடற்கரைக் கோவில்',
      'englishName': 'Mahabalipuram Shore Temple',
      'image': 'assets/images/mahabalipuram.jpg',
      'description': 'யுனெஸ்கோவின் உலக பாரம்பரிய தளம்',
      'englishDescription': 'UNESCO World Heritage Site',
      'location': 'மகாபலிபுரம்',
      'englishLocation': 'Mahabalipuram',
      'isSaved': false,
      'id': 1,
    },
    {
      'name': 'தஞ்சாவூர் பிரகதீஸ்வரர் கோவில்',
      'englishName': 'Thanjavur Brihadeeswara Temple',
      'image': 'assets/images/periyakovil.jpg',
      'description': 'சோழர்களின் கட்டிடக் கலைத் திறனின் மகுடம்',
      'englishDescription': 'Crown jewel of Chola architecture',
      'location': 'தஞ்சாவூர்',
      'englishLocation': 'Thanjavur',
      'isSaved': false,
      'id': 2,
    },
    {
      'name': 'கங்கைகொண்ட சோழபுரம்',
      'englishName': 'Gangaikonda Cholapuram',
      'image': 'assets/images/gangaikonda_cholapuram.jpg',
      'description': 'சோழர்களின் இரண்டாம் தலைநகரம்',
      'englishDescription': 'Second capital of the Chola dynasty',
      'location': 'கங்கைகொண்ட சோழபுரம்',
      'englishLocation': 'Gangaikonda Cholapuram',
      'isSaved': false,
      'id': 3,
    },
    {
      'name': 'நீலகிரி மலை ரயில்',
      'englishName': 'Nilgiri Mountain Railway',
      'image': 'assets/images/nilgiri_mountain_railway.jpg',
      'description': 'யுனெஸ்கோவின் உலக பாரம்பரிய தொடருந்து',
      'englishDescription': 'UNESCO World Heritage railway',
      'location': 'ஊட்டி',
      'englishLocation': 'Ooty',
      'isSaved': false,
      'id': 4,
    },
    {
      'name': 'ஐராவதேஸ்வரர் கோவில்',
      'englishName': 'Airavatesvara Temple',
      'image': 'assets/images/airavateshwara_temple.jpg',
      'description': 'சோழர் காலத்து கலைக்கோயில்',
      'englishDescription': 'Chola era temple of art',
      'location': 'தாராசுரம்',
      'englishLocation': 'Darasuram',
      'isSaved': false,
      'id': 5,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    dbHelper = DatabaseHelper.instance;
    _loadSavedPlaces();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPlaces() async {
    if (widget.userId != null) {
      final ids = await dbHelper.getSavedPlaceIds(widget.userId!);
      setState(() {
        savedPlaceIds = ids;
      });
    }
  }

  Future<void> _toggleSave(int index) async {
    final placeId = touristSpots[index]['id'];
    
    if (widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save places')),
      );
      return;
    }

    if (savedPlaceIds.contains(placeId)) {
      await dbHelper.removeSavedPlace(widget.userId!, placeId);
    } else {
      await dbHelper.savePlace(widget.userId!, placeId);
    }
    await _loadSavedPlaces();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < sliderImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  List<Map<String, dynamic>> get filteredTouristSpots {
    if (searchQuery.isEmpty) return touristSpots;
    return touristSpots.where((spot) {
      final name = spot['name'].toString().toLowerCase();
      final englishName = spot['englishName'].toString().toLowerCase();
      final location = spot['location'].toString().toLowerCase();
      final englishLocation = spot['englishLocation'].toString().toLowerCase();
      final description = spot['description'].toString().toLowerCase();
      final englishDescription = spot['englishDescription'].toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      return name.contains(query) || 
             englishName.contains(query) || 
             location.contains(query) ||
             englishLocation.contains(query) ||
             description.contains(query) ||
             englishDescription.contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> get savedPlaces {
    return touristSpots.where((spot) => savedPlaceIds.contains(spot['id'])).toList();
  }

  List<String> get placeNameSuggestions {
    return touristSpots.map((spot) => spot['name'] as String).toList();
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => ProfilePage(
          name: name,
          email: email,
          savedPlaces: savedPlaces,
          onRemoveSavedPlace: (placeId) {
            setState(() {
              savedPlaceIds.remove(placeId);
            });
          },
          userId: widget.userId ?? 0,
        ),
      ),
    );
  }

  Widget _buildPlaceCard(int index, [Map<String, dynamic>? spot]) {
    final placeData = spot ?? touristSpots[index];
    final theme = Theme.of(context);
    final isSaved = savedPlaceIds.contains(placeData['id']);
    
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => Dialog(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            placeData['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Container(
                              color: const Color(0xFFF4EFE6),
                              child: Center(
                                child: Icon(Icons.image_not_supported, 
                                          size: 40, 
                                          color: theme.colorScheme.secondary),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              placeData['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Tamil',
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('மூடு', style: TextStyle(fontFamily: 'Tamil')),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: placeData['image'].startsWith('http')
                        ? Image.network(
                            placeData['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Container(
                              color: const Color(0xFFF4EFE6),
                              child: Center(
                                child: Icon(Icons.image_not_supported, 
                                          size: 40, 
                                          color: theme.colorScheme.secondary),
                              ),
                            ),
                          )
                        : Image.asset(
                            placeData['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Container(
                              color: const Color(0xFFF4EFE6),
                              child: Center(
                                child: Icon(Icons.image_not_supported, 
                                          size: 40, 
                                          color: theme.colorScheme.secondary),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _toggleSave(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  placeData['name'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    fontFamily: 'Tamil',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  placeData['englishName'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  placeData['location'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.secondary,
                    fontFamily: 'Tamil',
                  ),
                ),
                Text(
                  placeData['englishLocation'] ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.secondary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.secondary,
        centerTitle: true,
        title: const Text(
          'தமிழ்நாடு சுற்றுலா',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Tamil',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              color: colorScheme.surface,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _navigateToProfile,
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: colorScheme.secondary,
                              child: const Icon(Icons.person, color: Colors.white, size: 28),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'வணக்கம்!!!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                  fontFamily: 'Tamil',
                                ),
                              ),
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (isLoggedIn) {
                            setState(() {
                              isLoggedIn = false;
                            });
                            Navigator.of(context).pushReplacementNamed('/login');
                          } else {
                            setState(() {
                              isLoggedIn = !isLoggedIn;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(
                          isLoggedIn ? 'வெளியேறு' : 'உள்நுழைக',
                          style: const TextStyle(fontFamily: 'Tamil'),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'தேடு... (Search in Tamil or English)',
                        hintStyle: TextStyle(fontFamily: 'Tamil', color: Colors.grey.shade500),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onTap: () {
                        showSearch(
                          context: context,
                          delegate: PlaceSearchDelegate(placeNameSuggestions, touristSpots),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: sliderImages.length,
                    onPageChanged: (int index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return ClipRRect(
                        child: Image.asset(
                          sliderImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: sliderImages.length,
                        effect: const WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor: Color(0xFF019863),
                          dotColor: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'தமிழ்நாட்டிற்கு வரவேற்கிறோம்!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      fontFamily: 'Tamil',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'வண்ணமயமான கலாச்சாரங்கள், அருமையான இடங்கள் மற்றும் நிலைத்த நினைவுகளின் கலவையான மனித நாகரிகத்தின் மையங்களில் ஒன்றான தமிழ்நாட்டிற்கு வருக!',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                      fontFamily: 'Tamil',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'தமிழ்நாடு - கதைகள் ஒருபோதும் முடிவடையாது!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Tamil',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'பிரபலமான சுற்றுலா இடங்கள்:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                          fontFamily: 'Tamil',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  filteredTouristSpots.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'No places found matching your search',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        for (int i = 0; i < filteredTouristSpots.length; i += 3)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                for (int j = i; j < i + 3 && j < filteredTouristSpots.length; j++)
                                  Expanded(
                                    child: _buildPlaceCard(
                                      touristSpots.indexOf(filteredTouristSpots[j]), 
                                      filteredTouristSpots[j]
                                    ),
                                  ),
                                for (int j = filteredTouristSpots.length; j < i + 3 && j < i + 3; j++)
                                  const Expanded(child: SizedBox()),
                              ].expand((widget) => [widget, if (widget != const SizedBox()) const SizedBox(width: 8)]).toList()..removeLast(),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.secondary.withOpacity(0.9),
              child: Column(
                children: [
                  const Text(
                    'Toll Free No: 1800-425-31111 (Within India only)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Department of Tourism, Government of Tamil Nadu, #2, Wallajah Road, Chennai - 600002',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Fax: +044 25333385, 25333567 | Email: tourism@tn.gov.in',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.copyright, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'All rights reserved © Tamil Nadu Tourism 2025.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Copyright | Terms of Use | Cookie Policy | Contact Us',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('AI உதவியாளர்', style: TextStyle(fontFamily: 'Tamil')),
              content: const Text('எப்படி உதவலாம்?', style: TextStyle(fontFamily: 'Tamil')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('மூடு', style: TextStyle(fontFamily: 'Tamil')),
                ),
              ],
            ),
          );
        },
        backgroundColor: theme.colorScheme.secondary,
        child: const Icon(Icons.assistant, color: Colors.white),
      ),
    );
  }
}

class PlaceSearchDelegate extends SearchDelegate<String> {
  final List<String> suggestions;
  final List<Map<String, dynamic>> touristSpots;

  PlaceSearchDelegate(this.suggestions, this.touristSpots);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = touristSpots.where((spot) => 
      spot['name'].toLowerCase().contains(query.toLowerCase()) || 
      spot['englishName'].toLowerCase().contains(query.toLowerCase())
    ).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {
        final spot = results[index];
        return ListTile(
          leading: Image.asset(
            spot['image'],
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.image, color: Colors.grey),
            ),
          ),
          title: Text(
            spot['name'],
            style: const TextStyle(fontFamily: 'Tamil'),
          ),
          subtitle: Text(spot['englishName']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => Scaffold(
                  appBar: AppBar(
                    title: Text(
                      spot['name'],
                      style: const TextStyle(fontFamily: 'Tamil'),
                    ),
                  ),
                  body: Center(
                    child: Image.asset(
                      spot['image'],
                      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => const Icon(Icons.image),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? suggestions
        : suggestions.where((place) => 
            place.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(
            suggestionList[index],
            style: const TextStyle(fontFamily: 'Tamil'),
          ),
          onTap: () {
            query = suggestionList[index];
            showResults(context);
          },
        );
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  final String name;
  final String email;
  final List<Map<String, dynamic>> savedPlaces;
  final Function(int) onRemoveSavedPlace;
  final int userId;

  const ProfilePage({
    Key? key,
    required this.name,
    required this.email,
    required this.savedPlaces,
    required this.onRemoveSavedPlace,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dbHelper = DatabaseHelper.instance;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.secondary,
        title: Text(
          'உங்கள் சுயவிவரம்',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Tamil',
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              color: colorScheme.surface,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: colorScheme.secondary,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "?",
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.bookmark, size: 16, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              '${savedPlaces.length} சேமித்த இடங்கள்',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.primary,
                                fontFamily: 'Tamil',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'சேமித்த இடங்கள்',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onBackground,
                      fontFamily: 'Tamil',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Saved Places',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  savedPlaces.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.bookmark_border,
                              size: 64,
                              color: colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No saved places yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: savedPlaces.length,
                      itemBuilder: (BuildContext context, int index) {
                        final place = savedPlaces[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.asset(
                                place['image'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Container(
                                  width: 60,
                                  height: 60,
                                  color: const Color(0xFFF4EFE6),
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 24,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              place['name'],
                              style: TextStyle(
                                fontFamily: 'Tamil',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              place['englishName'],
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () async {
                                await dbHelper.removeSavedPlace(userId, place['id']);
                                onRemoveSavedPlace(place['id']);
                              },
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => Dialog(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        place['image'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => const Icon(Icons.image),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('மூடு', style: TextStyle(fontFamily: 'Tamil')),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('auth_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE places (
        place_id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        english_name TEXT NOT NULL,
        image TEXT NOT NULL,
        description TEXT NOT NULL,
        english_description TEXT NOT NULL,
        location TEXT NOT NULL,
        english_location TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE saved_places (
        user_id INTEGER,
        place_id INTEGER,
        PRIMARY KEY (user_id, place_id),
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (place_id) REFERENCES places(place_id)
      )
    ''');
  }

  Future<void> savePlace(int userId, int placeId) async {
    final db = await instance.database;
    await db.insert(
      'saved_places',
      {'user_id': userId, 'place_id': placeId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeSavedPlace(int userId, int placeId) async {
    final db = await instance.database;
    await db.delete(
      'saved_places',
      where: 'user_id = ? AND place_id = ?',
      whereArgs: [userId, placeId],
    );
  }

  Future<List<int>> getSavedPlaceIds(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'saved_places',
      columns: ['place_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.map((e) => e['place_id'] as int).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
