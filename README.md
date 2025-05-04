# heritaxpayanam

An AI-powered digital tourism app designed to guide tourists with an interactive and immersive experience. The app provides personalized responses, tourist recommendations, and supports bilingual communication (Tamil and English). It includes both frontend (Flutter) and backend (Python APIs, Flask) components, along with a secure user authentication system.

Features
User registration and login with MySQL database
AI-based avatar to guide users
Voice input and bilingual support (English & Tamil)
Real-time tourist spot recommendations
Modular architecture for easy maintenance

Prerequisites
Make sure the following are installed on your system:

Python 3.7+
MySQL Server
Flutter SDK
Android Studio
xampp
Chrome browser (for running Flutter web app)

How to Run the Project
1. Clone the Repository
git clone https://github.com/chaarulathanagaraj/heritaxpayanam
cd heritaxpayanam

3. Set Up Backend
a. Install Python dependencies

pip install -r requirements.txt
If requirements.txt is missing, install manually:

b. Start the main backend server
python app.py (chatbot)

c. Run all 6 APIs in flask_backends

cd flask_backends/filename (virtual tour) 
python app.py
python app.py
...
Each tool should be started in separate terminal windows or as background processes.

3. Set Up Authentication System
copy auth_api folder to your xampp folder/(htdocs folder)
# Ensure MySQL is running and update DB connection details in the config

4. Run the Flutter App
flutter pub get
flutter run -d chrome
This will launch the app in your default Chrome browser.

Notes
Ensure that all APIs are running before launching the frontend.
If using emulator or physical device, you may need to update localhost to your local IP in the API URLs.

