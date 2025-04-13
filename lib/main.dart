import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basic Auth App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF019863),
        hintColor: Color(0xFFA18249),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF019863),
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF019863)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFA18249)),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final response = await http.post(
          Uri.parse('http://192.168.1.4/auth_api/login.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': _emailController.text,
            'password': _passwordController.text,
          }),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
           final name = responseData['user']['name'];
          final email = _emailController.text;
          final userId = int.parse(responseData['user']['id'].toString());

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomePage(
                name: name,
                email: email,
                userId: userId, 
              ),
            ),
          );
        } else {
          setState(() {
            _errorMessage = responseData['error'] ?? 'Login failed. Please try again.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Connection error. Please check your internet.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF019863).withOpacity(0.8),
              Color(0xFFA18249).withOpacity(0.6),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 80,
                          color: Color(0xFF019863),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF019863),
                          ),
                        ),
                        SizedBox(height: 24),
                        if (_errorMessage.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              _errorMessage,
                              style: TextStyle(color: Colors.red.shade800),
                            ),
                          ),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email, color: Color(0xFFA18249)),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock, color: Color(0xFFA18249)),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text('LOGIN', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account?"),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  color: Color(0xFF019863),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
        _successMessage = '';
      });

      try {
        final response = await http.post(
          Uri.parse('http://192.168.1.4/auth_api/register.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': _nameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
          }),
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 201 || response.statusCode == 200) {
          setState(() {
            _successMessage = 'Registration successful! You can now login.';
            _nameController.clear();
            _emailController.clear();
            _passwordController.clear();
            _confirmPasswordController.clear();
          });

          Future.delayed(Duration(seconds: 2), () {
            Navigator.pop(context);
          });
        } else {
          setState(() {
            _errorMessage = data['error'] ?? 'Registration failed. Please try again.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Connection error. Please check your internet.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF019863).withOpacity(0.8),
              Color(0xFFA18249).withOpacity(0.6),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_add_outlined,
                          size: 80,
                          color: Color(0xFF019863),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF019863),
                          ),
                        ),
                        SizedBox(height: 24),
                        if (_errorMessage.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              _errorMessage,
                              style: TextStyle(color: Colors.red.shade800),
                            ),
                          ),
                        if (_successMessage.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Text(
                              _successMessage,
                              style: TextStyle(color: Colors.green.shade800),
                            ),
                          ),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person, color: Color(0xFFA18249)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email, color: Color(0xFFA18249)),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock, color: Color(0xFFA18249)),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: Icon(Icons.lock_outlined, color: Color(0xFFA18249)),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text('REGISTER', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account?"),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: Color(0xFF019863),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
