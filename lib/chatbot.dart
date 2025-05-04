import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isLoading = false;
  bool _isTamil = true;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _lastError = '';
  Timer? _responseTimer;

  static const String _baseUrl = 'http://127.0.0.1:5001';
  static const Duration _responseTimeout = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    _initTTS();
    _initSpeech();
    
    _messages.add(ChatMessage(
      text: 'எப்படி உதவலாம்?', 
      isMe: false, 
      isTamil: true,
    ));
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    _responseTimer?.cancel();
    super.dispose();
  }

  Future<void> _initTTS() async {
    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setLanguage(_isTamil ? 'ta-IN' : 'en-US');
      await _tts.setSpeechRate(0.9);
      
      _tts.setErrorHandler((msg) {
        if (!msg.contains('interrupt')) {
          setState(() => _lastError = 'TTS Error: $msg');
        }
        _isSpeaking = false;
      });
      
      _tts.setStartHandler(() => setState(() => _isSpeaking = true));
      _tts.setCompletionHandler(() => setState(() => _isSpeaking = false));
    } catch (e) {
      setState(() => _lastError = 'TTS Init Error: $e');
    }
  }

  Future<void> _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Speech status: $status'),
        onError: (error) => setState(() => _lastError = error.errorMsg),
      );
      if (!available) {
        setState(() => _lastError = 'Speech recognition not available');
      }
    } catch (e) {
      setState(() => _lastError = 'Speech init error: $e');
    }
  }
  
  Future<void> _stopSpeaking() async {
    try {
      if (_isSpeaking) {
        await _tts.stop();
        setState(() => _isSpeaking = false);
      }
    } catch (e) {
      if (!e.toString().contains('interrupt')) {
        setState(() => _lastError = 'Stop error: $e');
      }
    }
  }

  Future<void> _speakResponse(String text) async {
    if (_isSpeaking) await _stopSpeaking();
    
    final urlPattern = RegExp(
      r'https?:\/\/[^\s]+|www\.[^\s]+|\.com|\.in|map|location|route|http',
      caseSensitive: false,
    );
    
    if (urlPattern.hasMatch(text) || text.trim().isEmpty) return;

    try {
      await _tts.setLanguage(_isTamil ? 'ta-IN' : 'en-US');
      await _tts.setSpeechRate(_isTamil ? 0.8 : 0.9); // Slower for Tamil
      await _tts.speak(text);
    } catch (e) {
      if (!e.toString().contains('interrupt')) {
        setState(() => _lastError = 'Speech error: $e');
      }
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    try {
      setState(() {
        _isListening = true;
        _lastError = '';
      });
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
            if (result.finalResult) {
              _sendMessage();
            }
          });
        },
        localeId: _isTamil ? 'ta_IN' : 'en_US',
        listenMode: stt.ListenMode.confirmation,
      );
    } catch (e) {
      setState(() {
        _isListening = false;
        _lastError = 'Listen error: $e';
      });
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
      setState(() => _isListening = false);
    } catch (e) {
      setState(() => _lastError = 'Stop listen error: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isMe: true, isTamil: _isTamil));
      _controller.clear();
      _isLoading = true;
      _isListening = false;
    });

    // Start timeout timer
    _responseTimer = Timer(_responseTimeout, () {
      if (_isLoading) {
        setState(() {
          _isLoading = false;
          _messages.add(ChatMessage(
            text: 'Response is taking longer than usual. Please wait...',
            isMe: false,
            isTamil: _isTamil,
          ));
        });
      }
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': text,
          'language': _isTamil ? 'tamil' : 'english',
          'disable_url_voice': true
        }),
      ).timeout(_responseTimeout);

      _responseTimer?.cancel(); // Cancel timer if response received

      final data = jsonDecode(response.body);
      final responseText = data['response'] ?? 'No response from server';
      
      setState(() {
        _messages.add(ChatMessage(
          text: responseText,
          isMe: false,
          isTamil: _isTamil,
        ));
      });

      // Handle map URL if present
      if (data['map_url'] != null) {
        setState(() {
          _messages.add(ChatMessage(
            text: _isTamil 
              ? 'வழிகாட்டுதலுக்கு கூகுள் மேப்பைப் பயன்படுத்தவும்' 
              : 'Use Google Maps for navigation',
            isMe: false,
            isTamil: _isTamil,
            isMapLink: true,
            mapUrl: data['map_url'],
          ));
        });
      }

      await _speakResponse(responseText);
    } catch (e) {
      _responseTimer?.cancel();
      setState(() {
        _messages.add(ChatMessage(
          text: 'Error: ${e.toString().replaceAll('Exception: ', '')}',
          isMe: false,
          isError: true,
        ));
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI உதவியாளர்', style: TextStyle(fontFamily: 'Tamil')),
        backgroundColor: AppTheme.gold,
        actions: [
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: _isSpeaking ? _stopSpeaking : null,
            color: _isSpeaking ? Colors.red : AppTheme.charcoal.withOpacity(0.5),
          ),
          Switch(
            value: _isTamil,
            activeColor: AppTheme.gold,
            activeTrackColor: _isTamil ? Colors.white.withOpacity(0.3) : AppTheme.gold.withOpacity(0.3),
            inactiveThumbColor: AppTheme.charcoal,
            inactiveTrackColor: AppTheme.charcoal.withOpacity(0.3),
            onChanged: (value) => setState(() => _isTamil = value),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              _isTamil ? 'தமிழ்' : 'English', 
              style: TextStyle(
                fontFamily: _isTamil ? 'Tamil' : null,
                color: AppTheme.charcoal,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/tourismbg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.white.withOpacity(0.5),
          child: Column(
            children: [
              if (_lastError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _lastError,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) => _messages.reversed.toList()[index],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.1),
                  border: Border(
                    top: BorderSide(color: AppTheme.gold.withOpacity(0.3), width: 1.0),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                      color: _isListening ? Colors.red : AppTheme.gold,
                      onPressed: _toggleListening,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: _isTamil ? 'செய்தியை உள்ளிடுக...' : 'Type or speak...',
                          hintStyle: TextStyle(color: AppTheme.charcoal.withOpacity(0.6)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.gold),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.gold, width: 2.0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.gold.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        style: TextStyle(color: AppTheme.charcoal),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: _isLoading
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.gold),
                            )
                          : Icon(Icons.send, color: AppTheme.gold),
                      onPressed: _isLoading ? null : _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isMe;
  final bool isError;
  final bool isTamil;
  final bool isMapLink;
  final String? mapUrl;

  const ChatMessage({
    super.key,
    required this.text,
    this.isMe = false,
    this.isError = false,
    this.isTamil = false,
    this.isMapLink = false,
    this.mapUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isError
              ? Colors.red[100]
              : isMe
                  ? AppTheme.gold.withOpacity(0.9)
                  : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isError
                ? Colors.red.withOpacity(0.5)
                : isMe
                    ? AppTheme.gold.withOpacity(0.3)
                    : AppTheme.charcoal.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: isMapLink && mapUrl != null
            ? InkWell(
                onTap: () => _launchUrl(mapUrl!),
                child: Text(
                  text,
                  style: TextStyle(
                    fontFamily: isTamil ? 'Tamil' : null,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontFamily: isTamil ? 'Tamil' : null,
                  color: isMe ? AppTheme.charcoal : AppTheme.charcoal,
                ),
              ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    // Implement URL launching functionality
    // You might want to use url_launcher package
    print('Launching URL: $url');
  }
}

class AppTheme {
  static const Color charcoal = Color(0xFF333333);
  static const Color gold = Color(0xFFD4AF37);
  static const Color tan = Color(0xFFD2B48C);
}