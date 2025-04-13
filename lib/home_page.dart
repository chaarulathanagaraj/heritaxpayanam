import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' hide context;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'package:flutter/services.dart'; 

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
      'id': 1,
      'galleryImages': [
        'assets/gallery/mahabalipuram/gallery1.jpg',
        'assets/gallery/mahabalipuram/gallery2.jpg',
        'assets/gallery/mahabalipuram/gallery3.jpg',
        'assets/gallery/mahabalipuram/gallery4.jpg',
        'assets/gallery/mahabalipuram/gallery5.jpg',
        'assets/gallery/mahabalipuram/gallery6.jpg',
      ],
      'videoUrl': 'assets/images/mahabalipuram.mp4',
    },
    {
      'name': 'தஞ்சாவூர் பிரகதீஸ்வரர் கோவில்',
      'englishName': 'Thanjavur Brihadeeswara Temple',
      'image': 'assets/images/periyakovil.jpg',
      'description': 'சோழர்களின் கட்டிடக் கலைத் திறனின் மகுடம்',
      'englishDescription': 'Crown jewel of Chola architecture',
      'location': 'தஞ்சாவூர்',
      'englishLocation': 'Thanjavur',
      'id': 2,
       'galleryImages': [
        'assets/gallery/thanjavur/gallery1.jpg',
        'assets/gallery/thanjavur/gallery2.jpg',
        'assets/gallery/thanjavur/gallery3.jpg',
        'assets/gallery/thanjavur/gallery4.jpg',
        'assets/gallery/thanjavur/gallery5.jpg',
        'assets/gallery/thanjavur/gallery6.jpg',
      ],
      'videoUrl': 'assets/images/thanjavur.mp4',
    },
    {
      'name': 'கங்கைகொண்ட சோழபுரம்',
      'englishName': 'Gangaikonda Cholapuram',
      'image': 'assets/images/gangaikonda_cholapuram.jpg',
      'description': 'சோழர்களின் இரண்டாம் தலைநகரம்',
      'englishDescription': 'Second capital of the Chola dynasty',
      'location': 'கங்கைகொண்ட சோழபுரம்',
      'englishLocation': 'Gangaikonda Cholapuram',
      'id': 3,
       'galleryImages': [
        'assets/gallery/gangaikonda/gallery1.jpg',
        'assets/gallery/gangaikonda/gallery2.jpg',
        'assets/gallery/gangaikonda/gallery3.jpg',
        'assets/gallery/gangaikonda/gallery4.jpg',
        'assets/gallery/gangaikonda/gallery5.jpg',
        'assets/gallery/gangaikonda/gallery6.jpg',
      ],
      'videoUrl': 'assets/images/gangaikonda.mp4',
    },
    {
      'name': 'நீலகிரி மலை ரயில்',
      'englishName': 'Nilgiri Mountain Railway',
      'image': 'assets/images/nilgiri_mountain_railway.jpg',
      'description': 'யுனெஸ்கோவின் உலக பாரம்பரிய தொடருந்து',
      'englishDescription': 'UNESCO World Heritage railway',
      'location': 'ஊட்டி',
      'englishLocation': 'Ooty',
      'id': 4,
      'galleryImages': [
        'assets/gallery/nilgiri/gallery1.jpg',
        'assets/gallery/nilgiri/gallery2.jpg',
        'assets/gallery/nilgiri/gallery3.jpg',
        'assets/gallery/nilgiri/gallery4.jpg',
        'assets/gallery/nilgiri/gallery5.jpg',
        'assets/gallery/nilgiri/gallery6.jpg',
      ],
      'videoUrl': 'assets/images/nilgiri.mp4',
    },
    {
      'name': 'ஐராவதேஸ்வரர் கோவில்',
      'englishName': 'Airavatesvara Temple',
      'image': 'assets/images/airavateshwara_temple.jpg',
      'description': 'சோழர் காலத்து கலைக்கோயில்',
      'englishDescription': 'Chola era temple of art',
      'location': 'தாராசுரம்',
      'englishLocation': 'Darasuram',
      'id': 5,
      'galleryImages': [
        'assets/gallery/airavatesvara/gallery1.jpg',
        'assets/gallery/airavatesvara/gallery2.jpg',
        'assets/gallery/airavatesvara/gallery3.jpg',
        'assets/gallery/airavatesvara/gallery4.jpg',
        'assets/gallery/airavatesvara/gallery5.jpg',
        'assets/gallery/airavatesvara/gallery6.jpg',
      ],
      'videoUrl': 'assets/images/aira.mp4',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    dbHelper = DatabaseHelper.instance;
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

  List<String> get placeNameSuggestions {
    return touristSpots.map((spot) => spot['name'] as String).toList();
  }

 Widget _buildPlaceCard(int index, [Map<String, dynamic>? spot]) {
  final placeData = spot ?? touristSpots[index];
  final theme = Theme.of(context);
  
  return Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceDetailPage(placeData: placeData),
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
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: theme.colorScheme.secondary
                        ),
                      ),
                    ),
                  )
                : Image.asset(
                    placeData['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Container(
                      color: const Color(0xFFF4EFE6),
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: theme.colorScheme.secondary
                        ),
                      ),
                    ),
                  ),
            ),
          ),
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
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: colorScheme.secondary,
                            child: const Icon(Icons.person, color: Colors.white, size: 28),
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
    if (query.isEmpty) {
      return const Center(
        child: Text('Please enter a search term'),
      );
    }
    
    final results = touristSpots.where((spot) =>
      spot['name'].toLowerCase().contains(query.toLowerCase()) ||
      spot['englishName'].toLowerCase().contains(query.toLowerCase())
    ).toList();
    
    if (results.isEmpty) {
      return Center(
        child: Text('No results found for "$query"'),
      );
    }
    
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
            close(context, spot['name']); // Close the search interface
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceDetailPage(placeData: spot),
              ),
            );
          },
        );
      },
    );
  }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Start typing to search in Tamil or English'),
      );
    }
    
    final suggestionList = suggestions.where((place) =>
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
     class PlaceDetailPage extends StatelessWidget {
  final Map<String, dynamic> placeData;

  const PlaceDetailPage({Key? key, required this.placeData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          placeData['name'],
          style: const TextStyle(
            fontFamily: 'Tamil',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.colorScheme.secondary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image section removed as requested
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    placeData['name'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      fontFamily: 'Tamil',
                    ),
                  ),
                  Text(
                    placeData['englishName'],
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: colorScheme.secondary, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${placeData['location']} (${placeData['englishLocation']})',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.secondary,
                          fontFamily: 'Tamil',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    placeData['description'],
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface,
                      fontFamily: 'Tamil',
                    ),
                  ),
                  Text(
                    placeData['englishDescription'],
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'எங்களுடன் சுற்றுலா செல்லுங்கள்',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      fontFamily: 'Tamil',
                    ),
                  ),
                  Text(
                    'Explore With Us',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      _buildExploreOption(
                        context, 
                        Icons.photo_library, 
                        'படத்தொகுப்பு', 
                        'Gallery',
                        () => Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => GalleryPage(
  images: placeData['galleryImages'] ?? [],
  placeName: placeData['name'],
),
                          ),
                        ),
                        colorScheme,
                      ),
                      _buildExploreOption(
                        context, 
                        Icons.play_circle_fill, 
                        'காணொளி', 
                        'Video',
                        () => Navigator.push(
                          context, 
                          MaterialPageRoute(
                           builder: (context) => VideoPlayerPage(
  videoUrl: placeData['videoUrl'] ?? '',
  placeName: placeData['name'],
),
                          ),
                        ),
                        colorScheme,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExploreOption(
    BuildContext context, 
    IconData icon, 
    String tamilText, 
    String englishText, 
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              tamilText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                fontFamily: 'Tamil',
              ),
            ),
            Text(
              englishText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withOpacity(0.7),
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
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
class GalleryPage extends StatelessWidget {
  final List<String> images;
  final String placeName;
  
  const GalleryPage({
    Key? key, 
    required this.images, 
    required this.placeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Debug print to check the images list
    debugPrint('Gallery images: $images');
    
    if (images.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '$placeName - Gallery',
            style: const TextStyle(
              fontFamily: 'Tamil',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: colorScheme.secondary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.photo_library_outlined, size: 72, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No images available',
                style: TextStyle(
                  fontSize: 18,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '$placeName - Gallery',
          style: const TextStyle(
            fontFamily: 'Tamil',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black.withOpacity(0.7),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          final imagePath = images[index];
          debugPrint('Loading image at index $index: $imagePath');
          
          return PhotoViewGalleryPageOptions(
            imageProvider: AssetImage(imagePath),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading image $imagePath: $error');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    const SizedBox(height: 10),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Index: $index',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              );
            },
          );
        },
        itemCount: images.length,
        loadingBuilder: (context, event) => Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
              color: colorScheme.primary,
            ),
          ),
        ),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }
}
class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String placeName;
  
  const VideoPlayerPage({
    Key? key, 
    required this.videoUrl, 
    required this.placeName,
  }) : super(key: key);

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;
  bool isLoading = true;
  String? errorMessage;
  
  @override
  void initState() {
    super.initState();
    // Force landscape orientation for fullscreen video
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initializePlayer();
  }
  
  Future<void> _initializePlayer() async {
    try {
      if (widget.videoUrl.isEmpty) {
        setState(() {
          errorMessage = 'Video URL is not available';
          isLoading = false;
        });
        return;
      }
      
      // Check if the URL is a network URL or an asset
      if (widget.videoUrl.startsWith('http')) {
        videoPlayerController = VideoPlayerController.network(widget.videoUrl);
      } else {
        videoPlayerController = VideoPlayerController.asset(widget.videoUrl);
      }
      
      await videoPlayerController.initialize();
      
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        // Always use full screen mode
        fullScreenByDefault: true,
        // Use the video's actual aspect ratio instead of constraining it
        aspectRatio: videoPlayerController.value.aspectRatio,
        // Add controls overlay
        showControls: true,
        // Make controls always visible briefly when video starts
        showControlsOnInitialize: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      );
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading video: $e';
        isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    // Reset orientation when leaving the page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    videoPlayerController.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Make app full immersive for video playback
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
    
    return Scaffold(
      // Hide app bar for full screen video experience
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: isLoading
            ? CircularProgressIndicator(color: colorScheme.primary)
            : errorMessage != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 72, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Go Back'),
                      ),
                    ],
                  )
                : SizedBox.expand(
                    child: Chewie(
                      controller: chewieController!,
                    ),
                  ),
      ),
    );
  }
}
