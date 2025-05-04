SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setString('user_id', userId);
await prefs.setString('email', email);
await prefs.setBool('isLoggedIn', true);