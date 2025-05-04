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
import 'chatbot.dart'; 
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'dart:ui' as ui;

// Define our professional color scheme
class AppTheme {
  // Core colors from your requested palette
  static const Color gold = Color(0xFFD4AF37);
  static const Color charcoal = Color(0xFF36454F);
  static const Color cream = Color(0xFFF4EFE6);
  static const Color tan = Color(0xFFD2B48C);
  
  // Additional shades
  static const Color lightGold = Color(0xFFE9D8A6);
  static const Color darkGold = Color(0xFFB8860B);
  static const Color lightTan = Color(0xFFE8D5B7);
  static const Color darkCharcoal = Color(0xFF242B30);
  
  // Create the theme
  static ThemeData get theme => ThemeData(
    colorScheme: ColorScheme(
      primary: gold,
      primaryContainer: darkGold,
      secondary: gold,
      secondaryContainer: darkCharcoal,
      surface: cream,
      background: cream,
      error: Colors.red.shade800,
      onPrimary: cream,
      onSecondary: cream,
      onSurface: charcoal,
      onBackground: charcoal,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: cream,
    appBarTheme: AppBarTheme(
      backgroundColor: charcoal,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: cream),
      titleTextStyle: TextStyle(
        fontFamily: 'Tamil', 
        fontWeight: FontWeight.bold,
        color: cream,
        fontSize: 20,
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 3,
      shadowColor: charcoal.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: TextTheme(
     displayLarge: TextStyle(color: Color(0xFF333333)), // Charcoal
  displayMedium: TextStyle(color: Color(0xFF333333)),
  displaySmall: TextStyle(color: Color(0xFF333333)),
  headlineLarge: TextStyle(color: Color(0xFF333333)),
  headlineMedium: TextStyle(color: Color(0xFF333333)),
  headlineSmall: TextStyle(color: Color(0xFF333333)),
  titleLarge: TextStyle(color: Color(0xFF333333)),
  titleMedium: TextStyle(color: Color(0xFF333333)),
  titleSmall: TextStyle(color: Color(0xFF333333)),
  bodyLarge: TextStyle(color: Color(0xFF333333)),
  bodyMedium: TextStyle(color: Color(0xFF333333)),
  bodySmall: TextStyle(color: Color(0xFF333333)),
  labelLarge: TextStyle(color: Color(0xFF333333)),
  labelMedium: TextStyle(color: Color(0xFF333333)),
  labelSmall: TextStyle(color: Color(0xFF333333)),

    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
         backgroundColor: gold,
  foregroundColor: charcoal,
        shadowColor: charcoal.withOpacity(0.3),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: gold, width: 2),
      ),
      hintStyle: TextStyle(color: charcoal.withOpacity(0.5)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: gold,
      foregroundColor: charcoal,
    ),
  );
}


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

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  
  late DatabaseHelper dbHelper;
  bool isLoggedIn = true;
  String get name => widget.name ?? "பயனர்";
  String get email => widget.email ?? "guest@example.com";
  
  final List<String> sliderImages = [
    'assets/images/nilgiri_mountain_railway.jpg',
    'assets/gallery/mahabalipuram/gallery6.jpg',
    'assets/images/natarajar.jpg',
    'assets/gallery/gangaikonda/gallery4.jpg',
    'assets/gallery/nilgiri/gallery2.jpg',
    'assets/images/dhanushkodi.jpg',
    'assets/images/meenakshi_temple.jpg',
  ];

 final List<Map<String, dynamic>> places = [
  {
    'name': 'மகாபலிபுரம் கடற்கரைக் கோவில்',
    'englishName': 'Mahabalipuram Shore Temple',
    'image': 'assets/gallery/mahabalipuram/gallery6.jpg',
    'description': 'யுனெஸ்கோவின் உலக பாரம்பரிய தளம்',
    'englishDescription': 'UNESCO World Heritage Site',
    'location': 'மகாபலிபுரம்',
    'englishLocation': 'Mahabalipuram',
    'id': 1,
    'galleryImages': [
      'assets/gallery/mahabalipuram/gallery1.jpg',
      'assets/gallery/mahabalipuram/gallery2.jpg',
      'assets/gallery/mahabalipuram/gallery4.jpg',
      'assets/gallery/mahabalipuram/gallery5.jpg',
      'assets/gallery/mahabalipuram/gallery6.jpg',
      'assets/gallery/mahabalipuram/gallery7.jpg',
      'assets/gallery/mahabalipuram/gallery8.jpg',
      'assets/gallery/mahabalipuram/gallery9.jpg',
      'assets/gallery/mahabalipuram/gallery10.jpg',
      'assets/gallery/mahabalipuram/gallery11.jpg',
      'assets/gallery/mahabalipuram/gallery12.jpg',
    ],
    'videoUrls': [
      'assets/gallery/mahabalipuram/v1.mp4',
      'assets/gallery/mahabalipuram/v2.mp4',
      'assets/gallery/mahabalipuram/v3.mp4',
      'assets/gallery/mahabalipuram/v4.mp4',
    ],
    'videoPlaceNames': [
      'Krishnas Butter Ball',  
      'Tiger Cave',           
      'View',                 
      'Light House',      
    ],
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
      'assets/gallery/thanjavur/gallery7.jpg',
      'assets/gallery/thanjavur/gallery8.jpg',
      'assets/gallery/thanjavur/gallery9.jpg',
      'assets/gallery/thanjavur/gallery10.jpg',
      'assets/gallery/thanjavur/gallery11.jpg',
      'assets/gallery/thanjavur/gallery12.jpg',
      'assets/gallery/thanjavur/gallery13.jpg',
      'assets/gallery/thanjavur/gallery14.jpg',
      'assets/gallery/thanjavur/gallery15.jpg',
      'assets/gallery/thanjavur/gallery16.jpg',
    ],
    'videoUrls': [
      'assets/gallery/thanjavur/v1.mp4',
      'assets/gallery/thanjavur/v2.mp4',
      'assets/gallery/thanjavur/v3.mp4',
      'assets/gallery/thanjavur/v4.mp4',
      'assets/gallery/thanjavur/v5.mp4',
    ],
    'videoPlaceNames': [
      'Bharatanatiyam',
      'Birth Temple',
      'Kalvettu',
      'Vimana',
      'Kalai Vizha',
    ],
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
      'assets/gallery/gangaikonda/gallery7.jpg',
      'assets/gallery/gangaikonda/gallery8.jpg',
      'assets/gallery/gangaikonda/gallery9.jpg',
      'assets/gallery/gangaikonda/gallery10.jpg',
      'assets/gallery/gangaikonda/gallery15.jpg',
      'assets/gallery/gangaikonda/gallery12.jpg',
      'assets/gallery/gangaikonda/gallery13.jpg',
      'assets/gallery/gangaikonda/gallery14.jpg',
    ],
    'videoUrls': [
      'assets/gallery/gangaikonda/v1.mp4',
      'assets/gallery/gangaikonda/v2.mp4',
      'assets/gallery/gangaikonda/v3.mp4',
      'assets/gallery/gangaikonda/v4.mp4',
    ],
    'videoPlaceNames': [
      'Kalvettu',
      'Statues',
      'View',
      'Steps',
    ],
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
      'assets/gallery/nilgiri/gallery7.jpg',
      'assets/gallery/nilgiri/gallery8.jpg',
      'assets/gallery/nilgiri/gallery9.jpg',
    ],
    'videoUrls': [
      'assets/gallery/nilgiri/v1.mp4',
      'assets/gallery/nilgiri/v2.mp4',
      'assets/gallery/nilgiri/v3.mp4',
      'assets/gallery/nilgiri/v4.mp4',
    ],
    'videoPlaceNames': [
      'Ooty Train',
      'Coonoor Station',
      'Train Travel',
      'Drone View',
    ],
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
      'assets/gallery/airavatesvara/gallery7.jpg',
      'assets/gallery/airavatesvara/gallery8.jpg',
      'assets/gallery/airavatesvara/gallery9.jpg',
      'assets/gallery/airavatesvara/gallery10.jpg',
      'assets/gallery/airavatesvara/gallery11.jpg',
    ],
    'videoUrls': [
      'assets/gallery/airavatesvara/v1.mp4',
      'assets/gallery/airavatesvara/v2.mp4',
      'assets/gallery/airavatesvara/v3.mp4',
      'assets/gallery/airavatesvara/v4.mp4',
    ],
    'videoPlaceNames': [
      'Elephant Dance',
      'Musical steps',
      'Temple Courtyard',
      'Sculptures',
    ],
  },
];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    dbHelper = DatabaseHelper.instance;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
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

 Widget _buildPlaceCard(int index) {
  final placeData = places[index];
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    child: EnhancedPlaceCard(
      placeData: placeData,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailPage(placeData: placeData),
          ),
        );
      },
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image slider
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: sliderImages.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Image.asset(
                  sliderImages[index],
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          
          // Color overlay with reduced opacity
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          
          // Content
          SingleChildScrollView(
            child: Column(
              children: [
                // Header with user info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white.withOpacity(0.7),
                            child: Icon(Icons.person, color: AppTheme.charcoal, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'வணக்கம்!!!',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppTheme.charcoal,
                                  fontFamily: 'Tamil',
                                ),
                              ),
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.charcoal,
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
                          backgroundColor: Colors.white.withOpacity(0.7),
                          foregroundColor: AppTheme.charcoal,
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
                ),

                // Welcome section
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gold.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
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
                          color: AppTheme.charcoal,
                          fontFamily: 'Tamil',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'வண்ணமயமான கலாச்சாரங்கள், அருமையான இடங்கள் மற்றும் நிலைத்த நினைவுகளின் கலவையான மனித நாகரிகத்தின் மையங்களில் ஒன்றான தமிழ்நாட்டிற்கு வருக!',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.charcoal,
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
                          color: AppTheme.gold,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Tamil',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

 // Tourist spots section
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 8),
  child: Column(
    children: [
      Text(
        'பிரபலமான சுற்றுலா இடங்கள்:',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.charcoal,
          fontFamily: 'Tamil',
        ),
      ),
      const SizedBox(height: 12),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 6),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.99, // Better aspect ratio for cards
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: places.length,
        itemBuilder: (context, index) => _buildPlaceCard(index),
      ),
    ],
  ),
),
                // Footer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Toll Free No: 1800-425-31111 (Within India only)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Department of Tourism, Government of Tamil Nadu, #2, Wallajah Road, Chennai - 600002',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
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
                        children: [
                          Icon(Icons.copyright, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
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
                      Text(
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.gold.withOpacity(0.5),
        child: const Icon(Icons.assistant, color: Colors.white),
      ),
    );
  }
}
// Enhanced Place Card with animations and transitions
class EnhancedPlaceCard extends StatefulWidget {
  final Map<String, dynamic> placeData;
  final VoidCallback? onTap; // Make onTap optional

  const EnhancedPlaceCard({
    Key? key, 
    required this.placeData,
    this.onTap, // Optional parameter
  }) : super(key: key);

  @override
  _EnhancedPlaceCardState createState() => _EnhancedPlaceCardState();
}

class _EnhancedPlaceCardState extends State<EnhancedPlaceCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isHovering = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleHover(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
      if (isHovering) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: widget.onTap, // Will be null if not provided
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.charcoal.withOpacity(_isHovering ? 0.3 : 0.1),
                      blurRadius: _isHovering ? 8 : 4,
                      offset: Offset(0, _isHovering ? 4 : 2),
                      spreadRadius: _isHovering ? 2 : 0,
                    ),
                  ],
                ),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: _isHovering 
                      ? BorderSide(color: AppTheme.gold, width: 2) 
                      : BorderSide.none,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: AspectRatio(
                              aspectRatio: 16/9,
                              child: widget.placeData['image'].startsWith('http')
                                ? Image.network(
                                    widget.placeData['image'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: AppTheme.cream,
                                      child: const Center(child: Icon(Icons.image_not_supported, color: AppTheme.charcoal)),
                                    ),
                                  )
                                : Image.asset(
                                    widget.placeData['image'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: AppTheme.cream,
                                      child: const Center(child: Icon(Icons.image_not_supported, color: AppTheme.charcoal)),
                                    ),
                                  ),
                            ),
                          ),
                          
                          // Gold overlay that appears on hover
                          if (_isHovering)
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppTheme.gold.withOpacity(0.1),
                                        AppTheme.gold.withOpacity(0.4),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                          // "View details" button that appears on hover
                          if (_isHovering)
                            Positioned.fill(
                              child: Center(
                                child: FadeTransition(
                                  opacity: _opacityAnimation,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.charcoal.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: AppTheme.gold, width: 1),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.visibility,
                                          color: AppTheme.gold,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'விவரங்களைப் பார்க்க',
                                          style: const TextStyle(
                                            color: AppTheme.cream,
                                            fontFamily: 'Tamil',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.place,
                                  size: 16,
                                  color: AppTheme.gold,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.placeData['name'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.charcoal,
                                      fontFamily: 'Tamil',
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.placeData['englishName'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: AppTheme.charcoal.withOpacity(0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            
                            // Location row
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_city,
                                  color: AppTheme.tan,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.placeData['location'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.charcoal.withOpacity(0.8),
                                    fontFamily: 'Tamil',
                                  ),
                                ),
                              ],
                            ),
                            
                            // Divider
                            if (_isHovering)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Divider(
                                  color: AppTheme.gold.withOpacity(0.5),
                                  thickness: 1,
                                ),
                              ),
                              
                            // Description preview that appears on hover
                            if (_isHovering)
                              FadeTransition(
                                opacity: _opacityAnimation,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    widget.placeData['description'] ?? '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.charcoal.withOpacity(0.8),
                                      fontFamily: 'Tamil',
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Enhanced Search Bar with animation
class AnimatedSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onSubmitted;
  final VoidCallback onTap;

  const AnimatedSearchBar({
    Key? key,
    required this.controller,
    this.onSubmitted,
    required this.onTap,
  }) : super(key: key);

  @override
  _AnimatedSearchBarState createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  late Animation<double> _opacityAnimation;
  bool _isFocused = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _widthAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            _isFocused = true;
            _animationController.forward();
          });
        },
        onExit: (_) {
          setState(() {
            _isFocused = true;
            _animationController.forward();
          });
        },
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _widthAnimation.value,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: _isFocused ? AppTheme.gold : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.charcoal.withOpacity(_isFocused ? 0.2 : 0.1),
                      blurRadius: _isFocused ? 8 : 4,
                      offset: Offset(0, _isFocused ? 3 : 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Icon(
                        Icons.search,
                        color: _isFocused ? AppTheme.gold : AppTheme.charcoal.withOpacity(0.5),
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        decoration: InputDecoration(
                          hintText: 'தேடு... (Search in Tamil or English)',
                          hintStyle: TextStyle(
                            fontFamily: 'Tamil',
                            color: Colors.grey.shade500,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: widget.onSubmitted,
                        readOnly: true,
                      ),
                    ),
                    if (_isFocused)
                      FadeTransition(
                        opacity: _opacityAnimation,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Icon(
                            Icons.touch_app,
                            color: AppTheme.gold,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Enhanced Color Scheme with Professional Palette
class AppColors {
  static const Color gold = Color(0xFFD4AF37);       // Rich gold
  static const Color darkGold = Color(0xFFB8860B);   // Darker gold
  static const Color tan = Color(0xFFD2B48C);        // Warm tan
  static const Color lightTan = Color(0xFFE8D5B7);   // Light tan
  static const Color charcoal = Color(0xFF36454F);   // Dark charcoal
  static const Color darkCharcoal = Color(0xFF242B30); // Deeper charcoal
  static const Color cream = Color(0xFFF4EFE6);      // Soft cream
  static const Color lightCream = Color(0xFFFDF9F2); // Lighter cream
}

// Enhanced Theme Data
final appTheme = ThemeData(
  colorScheme: ColorScheme.light(
    primary: AppColors.gold,
    primaryContainer: AppColors.darkGold,
    secondary: AppColors.gold,
    secondaryContainer: AppColors.darkCharcoal,
    surface: AppColors.cream,
    background: AppColors.lightCream,
    onPrimary: AppColors.charcoal,
    onSecondary: Colors.white,
    onSurface: AppColors.charcoal,
    onBackground: AppColors.charcoal,
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: EdgeInsets.all(8),
  ),
);

// Enhanced PlaceDetailPage with Premium Styling





class PlaceDetailPage extends StatelessWidget {
  final Map<String, dynamic> placeData;

  const PlaceDetailPage({Key? key, required this.placeData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image
          Image.network(
            placeData['image'],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Overlay with opacity
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          // Single Content Container
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7), // Reduced opacity
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.gold, // Using gold color from theme
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          placeData['name'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.gold, // Using gold color
                            fontFamily: 'Tamil',
                          ),
                        ),
                        Text(
                          placeData['englishName'],
                          style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Location Section
                    Row(
                      children: [
                        Icon(Icons.location_on, 
                            color: AppTheme.gold, size: 20), // Gold color
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${placeData['location']} (${placeData['englishLocation']})',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                              fontFamily: 'Tamil',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: AppTheme.gold, height: 30), // Gold divider
                    
                    // Description Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          placeData['description'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            fontFamily: 'Tamil',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          placeData['englishDescription'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: AppTheme.gold, height: 30), // Gold divider
                    
                    // Explore Section
                    Column(
                      children: [
                        Text(
                          'எங்களுடன் சுற்றுலா செல்லுங்கள்',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.gold, // Gold color
                            fontFamily: 'Tamil',
                          ),
                        ),
                        Text(
                          'Explore With Us',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 20),
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
                            ),
                            _buildExploreOption(
                              context,
                              Icons.videocam,
                              'காணொளி',
                              'Video',
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerPage(
                                    videoUrls: placeData['videoUrls'],
      placeNames: placeData['videoPlaceNames'],
                                  ),
                                ),
                              ),
                            ),
                            _buildExploreOption(
                              context,
                              Icons.visibility,
                              'மெய்நிகர் சுற்றுலா',
                              'Virtual Tour',
                              () => Navigator.push(
                                context,
                                 MaterialPageRoute(
      builder: (context) => const VirtualTourSelectionPage(),
    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

 Widget _buildExploreOption(
  BuildContext context,
  IconData icon,
  String titleTamil,
  String titleEnglish,
  VoidCallback onTap,
) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: 100,
       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
       color: Colors.white.withOpacity(0.7), 
        borderRadius: BorderRadius.circular(12),
         border: Border.all(color: AppTheme.gold),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,  color: AppTheme.gold, size: 32,),
          const SizedBox(height: 8),
          Text(
            titleTamil,
            style: const TextStyle(
              fontSize: 12,
               fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontFamily: 'Tamil',
            ),
          ),
          Text(
            titleEnglish,
            style: const TextStyle(
             fontSize: 11,
                color: Colors.grey,
            ),
          ),
        ],
      ),
    ),
  );
}



class VirtualTourPage extends StatefulWidget {
  final int port;
  final String placeName;
  final bool isProduction;

  const VirtualTourPage({
    super.key,
    required this.port,
    required this.placeName,
    this.isProduction = false,
  });

  @override
  State<VirtualTourPage> createState() => _VirtualTourPageState();
}

class _VirtualTourPageState extends State<VirtualTourPage> {
  late final String viewTypeId;
  bool _isLoading = true;
  bool _errorOccurred = false;
  late String _tourUrl;

  @override
  void initState() {
    super.initState();
    viewTypeId = 'tour-iframe-${UniqueKey()}';
    _tourUrl = VirtualTourManager.getTourUrl(widget.port, isProduction: widget.isProduction);

    if (kIsWeb) {
      try {
        // Register the view type for embedding an iframe in web
        // ignore: undefined_prefixed_name
        ui.platformViewRegistry.registerViewFactory(
          viewTypeId,
          (int viewId) {
            final iframe = html.IFrameElement()
              ..src = _tourUrl
              ..style.border = 'none'
              ..style.width = '100%'
              ..style.height = '100%'
          ..allow = 'microphone'
          
              ..onLoad.listen((event) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              })
              ..onError.listen((event) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _errorOccurred = true;
                  });
                }
              });

            return iframe;
          },
        );
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorOccurred = true;
          });
        }
      }
    } else {
      // Not a web platform
      _isLoading = false;
      _errorOccurred = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.placeName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          if (kIsWeb && !_errorOccurred)
            HtmlElementView(viewType: viewTypeId),

          if (_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.gold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'மெய்நிகர் சுற்றுலா ஏற்றப்படுகிறது...',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.charcoal,
                      fontFamily: 'Tamil',
                    ),
                  ),
                  Text(
                    'Loading virtual tour...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.charcoal.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

          if (_errorOccurred)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    kIsWeb
                        ? 'மெய்நிகர் சுற்றுலாவை ஏற்ற முடியவில்லை'
                        : 'மெய்நிகர் சுற்றுலா வலைத்தளத்தில் மட்டுமே கிடைக்கும்',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.charcoal,
                      fontFamily: 'Tamil',
                    ),
                  ),
                  Text(
                    kIsWeb
                        ? 'Failed to load virtual tour'
                        : 'Virtual tour is only available on web',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.charcoal.withOpacity(0.7),
                    ),
                  ),
                  if (kIsWeb) const SizedBox(height: 24),
                  if (kIsWeb)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorOccurred = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.gold,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('மீண்டும் முயற்சிக்கவும்'),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
// Custom Animations and Effects
class ShimmerText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const ShimmerText({required this.text, required this.style});

  @override
  _ShimmerTextState createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                AppColors.gold.withOpacity(0.7),
                AppColors.gold,
                AppColors.gold.withOpacity(0.7),
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.style,
          ),
        );
      },
    );
  }
}

class AnimatedPinIcon extends StatefulWidget {
  @override
  _AnimatedPinIconState createState() => _AnimatedPinIconState();
}

class _AnimatedPinIconState extends State<AnimatedPinIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Icon(
            Icons.location_on,
            color: AppColors.gold,
            size: 24,
          ),
        );
      },
    );
  }
}

class FadeInText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const FadeInText({required this.text, required this.style});

  @override
  _FadeInTextState createState() => _FadeInTextState();
}

class _FadeInTextState extends State<FadeInText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Text(
        widget.text,
        style: widget.style,
      ),
    );
  }
}

class HoverCard extends StatefulWidget {
  final Widget child;
  final Color color;

  const HoverCard({required this.child, required this.color});

  @override
  _HoverCardState createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 + (_controller.value * 0.05),
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(_controller.value * 0.3),
                    blurRadius: 8 * _controller.value,
                    spreadRadius: 2 * _controller.value,
                    offset: Offset(0, 4 * _controller.value),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
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

  // Professional color scheme
  static const Color kGold = Color(0xFFD4AF37);
  static const Color kTan = Color(0xFFD2B48C);
  static const Color kCharcoal = Color(0xFF36454F);
  static const Color kCream = Color(0xFFFFFDD0);

  @override
  Widget build(BuildContext context) {
    // Track current page index
    final pageNotifier = ValueNotifier<int>(0);
    
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
              color: kCream,
            ),
          ),
          backgroundColor: kCharcoal,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [kCharcoal, kCharcoal.withOpacity(0.8)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined, size: 100, color: kTan),
                const SizedBox(height: 16),
                Text(
                  'No images available',
                  style: TextStyle(
                    fontSize: 20,
                    color: kCream,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGold,
                    foregroundColor: kCharcoal,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '$placeName - Gallery',
          style: const TextStyle(
            fontFamily: 'Tamil',
            fontWeight: FontWeight.bold,
            color: kCream,
            shadows: [
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 3.0,
                color: Color.fromARGB(150, 0, 0, 0),
              ),
            ],
          ),
        ),
        backgroundColor: kCharcoal.withOpacity(0.5),
        elevation: 0,
        iconTheme: const IconThemeData(color: kGold),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view_rounded),
            onPressed: () {
              // Show grid view dialog of images
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  backgroundColor: kCharcoal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Gallery Overview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kGold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Flexible(
                          child: GridView.builder(
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  pageNotifier.value = index;
                                },
                                child: Hero(
                                  tag: 'gallery_${images[index]}',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: kGold.withOpacity(0.5)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: kGold.withOpacity(0.3),
                                          blurRadius: 5,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        images[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              final imagePath = images[index];
              debugPrint('Loading image at index $index: $imagePath');
              
              return PhotoViewGalleryPageOptions(
                imageProvider: AssetImage(imagePath),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2.5,
                heroAttributes: PhotoViewHeroAttributes(tag: 'gallery_${images[index]}'),
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading image $imagePath: $error');
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: kCharcoal.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image, size: 60, color: kTan),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: kCream, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image $index',
                            style: TextStyle(color: kTan),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            itemCount: images.length,
            loadingBuilder: (context, event) => Center(
              child: Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kCharcoal.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CircularProgressIndicator(
                  value: event == null
                      ? 0
                      : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
                  color: kGold,
                  strokeWidth: 3,
                ),
              ),
            ),
            backgroundDecoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, kCharcoal.withOpacity(0.9)],
              )
            ),
            pageController: PageController(),
            onPageChanged: (index) {
              pageNotifier.value = index;
            },
          ),
          
          // Image counter indicator
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: kCharcoal.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: kGold.withOpacity(0.5)),
                ),
                child: ValueListenableBuilder<int>(
                  valueListenable: pageNotifier,
                  builder: (context, currentIndex, _) {
                    return Text(
                      'Image ${currentIndex + 1} / ${images.length}',
                      style: TextStyle(
                        color: kCream,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class VideoPlayerPage extends StatefulWidget {
  final List<String> videoUrls;
  final List<String> placeNames;
  
  const VideoPlayerPage({
    Key? key, 
    required this.videoUrls, 
    required this.placeNames,
  }) : super(key: key);

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoPlayerController; // Make nullable
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentVideoIndex = 0;
  
  // Professional color scheme
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _charcoal = Color(0xFF36454F);
  static const Color _cream = Color(0xFFFFFDD0);
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
    
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    _initializePlayer();
  }
  
  Future<void> _initializePlayer() async {
    try {
      if (widget.videoUrls.isEmpty) {
        setState(() {
          _errorMessage = 'No videos are available';
          _isLoading = false;
        });
        return;
      }
      
      await _loadVideo(_currentVideoIndex);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading video: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadVideo(int index) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Dispose previous controllers safely
      _chewieController?.dispose();
      await _videoPlayerController?.dispose();
      
      final String videoUrl = widget.videoUrls[index];
      
      if (videoUrl.isEmpty) {
        setState(() {
          _errorMessage = 'Video URL is not available';
          _isLoading = false;
        });
        return;
      }
      
      // Initialize new controller
      _videoPlayerController = videoUrl.startsWith('http')
          ? VideoPlayerController.network(videoUrl)
          : VideoPlayerController.asset(videoUrl);
      
      await _videoPlayerController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        fullScreenByDefault: true,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        showControls: true,
        showControlsOnInitialize: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: _gold,
          handleColor: _gold,
          backgroundColor: _charcoal.withOpacity(0.5),
          bufferedColor: _gold.withOpacity(0.3),
        ),
        errorBuilder: (context, errorMessage) {
          return _buildErrorWidget(errorMessage);
        },
      );
      
      setState(() {
        _currentVideoIndex = index;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading video: $e';
        _isLoading = false;
      });
    }
  }
  
  void _navigateToNextVideo() {
    if (_currentVideoIndex < widget.videoUrls.length - 1) {
      _loadVideo(_currentVideoIndex + 1);
    }
  }
  
  void _navigateToPreviousVideo() {
    if (_currentVideoIndex > 0) {
      _loadVideo(_currentVideoIndex - 1);
    }
  }
  
  Widget _buildErrorWidget(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _charcoal.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _gold.withOpacity(0.5), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: _gold),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: _cream,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: _charcoal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: const Text(
                'Go Back',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _charcoal.withOpacity(0.6),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _gold.withOpacity(0.5)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: _gold),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            widget.placeNames[_currentVideoIndex],
            style: const TextStyle(
              fontFamily: 'Tamil',
              fontWeight: FontWeight.bold,
              color: _cream,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 3,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.black, _charcoal],
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: _isLoading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              color: _gold,
                              strokeWidth: 3,
                              backgroundColor: _charcoal,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Loading video...',
                            style: TextStyle(
                              color: _cream,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : _errorMessage != null
                        ? _buildErrorWidget(_errorMessage!)
                        : SizedBox.expand(
                            child: _chewieController != null 
                                ? Chewie(controller: _chewieController!)
                                : const SizedBox(),
                          ),
              ),
              
              if (!_isLoading && _errorMessage == null)
                Positioned.fill(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _currentVideoIndex > 0
                          ? GestureDetector(
                              onTap: _navigateToPreviousVideo,
                              child: Container(
                                width: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      _charcoal.withOpacity(0.6),
                                      _charcoal.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.navigate_before,
                                    size: 40,
                                    color: _gold.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(width: 60),
                          
                      _currentVideoIndex < widget.videoUrls.length - 1
                          ? GestureDetector(
                              onTap: _navigateToNextVideo,
                              child: Container(
                                width: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerRight,
                                    end: Alignment.centerLeft,
                                    colors: [
                                      _charcoal.withOpacity(0.6),
                                      _charcoal.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.navigate_next,
                                    size: 40,
                                    color: _gold.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(width: 60),
                    ],
                  ),
                ),
                
              if (!_isLoading && _errorMessage == null)
                Positioned(
                  bottom: 5,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.videoUrls.length,
                      (index) => Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentVideoIndex
                              ? _gold
                              : _gold.withOpacity(0.3),
                          border: Border.all(
                            color: _cream.withOpacity(0.5),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 2,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class VirtualTourSelectionPage extends StatelessWidget {
  const VirtualTourSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text(
          'மெய்நிகர் சுற்றுலா விருப்பங்கள்',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Tamil',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.gold,
        elevation: 0,
        iconTheme: const IconThemeData(color:Colors.white),
      ),
      body: Container(
       
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/tourismbg.jpg'), // Your tourism background
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.99, 
          mainAxisSpacing: 8,
          crossAxisSpacing: 8, // More compact cards
            ),
            itemCount: VirtualTourManager.virtualTours.length,
            itemBuilder: (context, index) {
              final tour = VirtualTourManager.virtualTours[index];
              return _buildTourCard(context, tour);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTourCard(BuildContext context, Map<String, dynamic> tour) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VirtualTourPage(
                port: tour['port'],
                placeName: tour['nameEnglish'],
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(tour['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour['nameTamil'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tamil',
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    tour['nameEnglish'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.place, size: 14, color: AppTheme.gold),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          tour['location'],
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'Tamil',
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}


class VirtualTourManager {
  static final List<Map<String, dynamic>> virtualTours = [
    {
      'id': 1,
      'nameTamil': 'ஐராவதேஸ்வரர் கோவில்',
      'nameEnglish': 'Airavatesvara Temple',
      'description': 'சோழர் காலத்து கலைக்கோயில்',
      'englishDescription': 'Chola era temple of art',
      'location': 'தாராசுரம்',
      'englishLocation': 'Darasuram',
      'port': 5006,
      'folder': 'airavatesvara_tour',
      'image': 'assets/gallery/airavatesvara/gallery1.jpg',
    },
    {
      'id': 2,
      'nameTamil': 'மகாபலிபுரம் கடற்கரைக் கோவில்',
      'nameEnglish': 'Mahabalipuram Shore Temple',
      'description': 'யுனெஸ்கோவின் உலக பாரம்பரிய தளம்',
      'englishDescription': 'UNESCO World Heritage Site',
      'location': 'மகாபலிபுரம்',
      'englishLocation': 'Mahabalipuram',
      'port': 5002,
      'folder': 'mahabalipuram_tour',
      'image': 'assets/gallery/mahabalipuram/gallery6.jpg',
    },
    {
      'id': 3,
      'nameTamil': 'தஞ்சாவூர் பிரகதீஸ்வரர் கோவில்',
      'nameEnglish': 'Thanjavur Brihadeeswara Temple',
      'description': 'சோழர்களின் கட்டிடக் கலைத் திறனின் மகுடம்',
      'englishDescription': 'Crown jewel of Chola architecture',
      'location': 'தஞ்சாவூர்',
      'englishLocation': 'Thanjavur',
      'port': 5003,
      'folder': 'thanjavur_tour',
      'image': 'assets/images/periyakovil.jpg',
    },
    {
      'id': 4,
      'nameTamil': 'கங்கைகொண்ட சோழபுரம்',
      'nameEnglish': 'Gangaikonda Cholapuram',
      'description': 'சோழர்களின் இரண்டாம் தலைநகரம்',
      'englishDescription': 'Second capital of the Chola dynasty',
      'location': 'கங்கைகொண்ட சோழபுரம்',
      'englishLocation': 'Gangaikonda Cholapuram',
      'port': 5004,
      'folder': 'gangaikonda_tour',
      'image': 'assets/images/gangaikonda_cholapuram.jpg',
    },
    {
      'id': 5,
      'nameTamil': 'நீலகிரி மலை ரயில்',
      'nameEnglish': 'Nilgiri Mountain Railway',
      'description': 'யுனெஸ்கோவின் உலக பாரம்பரிய தொடருந்து',
      'englishDescription': 'UNESCO World Heritage railway',
      'location': 'ஊட்டி',
      'englishLocation': 'Ooty',
      'port': 5005,
      'folder': 'nilgiri_tour',
      'image': 'assets/images/nilgiri_mountain_railway.jpg',
    },
  ];

  static String getTourUrl(int port, {bool isProduction = false}) {
    return isProduction
        ? 'https://yourdomain.com/${virtualTours.firstWhere((t) => t['port'] == port)['folder']}'
        : 'http://localhost:$port';
  }
}
