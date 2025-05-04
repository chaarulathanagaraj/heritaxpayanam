from flask import Flask, request, jsonify, url_for, Response, render_template, send_from_directory
from flask_cors import CORS
import google.generativeai as genai
from gtts import gTTS
import os
import time

# Initialize Flask with non-standard static folders
app = Flask(__name__, 
            static_folder='static',
            template_folder='templates')

# CORS settings
CORS(app)


# Gemini API Setup
GEMINI_API_KEY = "AIzaSyDodTt77CU7riogt8mowPtb1y_guGbUqgk"
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel("gemini-1.5-flash")

# Create static audio folder if it doesn't exist
os.makedirs("static/audio", exist_ok=True)

@app.route("/", methods=['GET', 'OPTIONS'])
def home():
    if request.method == 'OPTIONS':
        return '', 200
    return render_template("index.html")

@app.route("/test_voice")
def test_voice():
    try:
        text = "வணக்கம் இது ஒரு சோதனை"
        tts = gTTS(text=text, lang='ta')
        filename = f"speech_test.mp3"
        filepath = os.path.join("static/audio", filename)
        tts.save(filepath)
        
        return Response(
            open(filepath, "rb"),
            mimetype="audio/mpeg",
            headers={"Content-Disposition": "inline"}
        )
    except Exception as e:
        return jsonify({"error": str(e), "message": "Failed to generate voice"}), 500

@app.route("/health", methods=['GET'])
def health_check():
    return jsonify({"status": "healthy"}), 200

@app.route("/chat", methods=["POST"])
def chat():
    try:
        data = request.json
        user_text = data.get("text", "").strip()
        location = data.get("location", "unknown")
        
        if not user_text:
            return jsonify({"error": "No text provided"}), 400
        
        prompt = f"""
        Respond to this in Tamil: "{user_text}"
        User is currently at location: {location}
        If appropriate, include one of these at the end:
        - [ACTION:WAVE] for greetings/farewells
        - [ACTION:NOD] for agreements/confirmations
        Example: "வணக்கம் [ACTION:WAVE]" or "ஆமாம் [ACTION:NOD]"
        """
        response = model.generate_content(prompt)
        reply_text = response.text.strip() if response.text else "மன்னிக்கவும், பதில் இல்லை!"
        
        animations = []
        if "[ACTION:WAVE]" in reply_text:
            animations.append("wave")
            reply_text = reply_text.replace("[ACTION:WAVE]", "")
        if "[ACTION:NOD]" in reply_text:
            animations.append("nod")
            reply_text = reply_text.replace("[ACTION:NOD]", "")
        reply_text = reply_text.strip()
        
        # Generate audio using gTTS
        timestamp = int(time.time())
        filename = f"speech_{timestamp}.mp3"
        filepath = os.path.join("static/audio", filename)
        tts = gTTS(text=reply_text, lang='ta')
        tts.save(filepath)
        
        return jsonify({
            "text": reply_text,
            "audio": url_for('static', filename=f"audio/{filename}", _external=True),
            "animations": animations
        })
    
    except Exception as e:
        print("Error:", str(e))
        return jsonify({
            "text": "மன்னிக்கவும், பிழை ஏற்பட்டுள்ளது",
            "audio": "",
            "animations": []
        }), 500

# Special routes for Pano2VR files located in root directory
@app.route("/pano.xml")
def serve_pano_xml():
    return send_from_directory(".", "pano.xml")

@app.route("/pano2vr_player.js")
def serve_player_js():
    return send_from_directory(".", "pano2vr_player.js")

@app.route("/skin.js")
def serve_skin_js():
    return send_from_directory(".", "skin.js")

# Special route for images folder (if you have panorama images there)
@app.route("/images/<path:filename>")
def serve_images(filename):
    return send_from_directory("images", filename)

# Route for media files
@app.route("/media/<path:filename>")
def serve_media(filename):
    return send_from_directory("media", filename)

if __name__ == "__main__":
    app.run(debug=True, port=5006)





