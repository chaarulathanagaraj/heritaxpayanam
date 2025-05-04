import os
import re
import logging
from flask import Flask, request, render_template, jsonify
from dotenv import load_dotenv
import google.generativeai as genai
from langchain_google_genai import GoogleGenerativeAIEmbeddings
from langchain_chroma import Chroma
from google.cloud import texttospeech
import io
import base64
from gmap import get_directions
import googlemaps
import json
from datetime import datetime
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={
    r"/chat": {
        "origins": "*",  # Use "*" for testing. For production, restrict this to your frontend's IP/domain.
        "methods": ["POST"],
        "allow_headers": ["Content-Type"]
    }
})

# Initialize Google Maps API Client
gmaps = googlemaps.Client(key='AIzaSyAbmRbJ1gsxTq92FxjlrNMJISVY9_k9H1A')

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# Load environment variables
load_dotenv()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

if not GEMINI_API_KEY:
    raise ValueError("Missing GEMINI_API_KEY in environment variables")

# Configure Gemini
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel("gemini-1.5-flash")

# Initialize Chroma vectorstore
embedding = GoogleGenerativeAIEmbeddings(
    model="models/embedding-001",
    google_api_key=GEMINI_API_KEY
)
vectorstore = Chroma(
    persist_directory="db",
    embedding_function=embedding
)

def is_tamil(text):
    return bool(re.search(r'[\u0B80-\u0BFF]', text))

def translate_text(text, target_language):
    try:
        prompt = f"""
You are a professional translator. Translate the following text to {target_language}. 
Do not explain, do not add extra content. Only return the clean translated sentence.

Text: {text}
Translation:"""
        response = model.generate_content(prompt)
        return response.text.strip()
    except Exception as e:
        logger.error(f"Translation error: {str(e)}")
        return text


@app.route("/generate_voice", methods=["POST"])
def generate_voice(text, language='ta'):
    try:
        client = texttospeech.TextToSpeechClient()

        language_code = 'ta-IN' if language == 'ta' else 'en-US'
        ssml = f"""
<speak>
  <prosody rate="250%" pitch="+4st">
    {text}
  </prosody>
</speak>
"""

        synthesis_input = texttospeech.SynthesisInput(ssml=ssml)

        voice = texttospeech.VoiceSelectionParams(
            language_code=language_code,
            ssml_gender=texttospeech.SsmlVoiceGender.MALE  # FEMALE ignored in ta-IN
        )

        audio_config = texttospeech.AudioConfig(
            audio_encoding=texttospeech.AudioEncoding.MP3
        )

        response = client.synthesize_speech(
            input=synthesis_input,
            voice=voice,
            audio_config=audio_config
        )

        return base64.b64encode(response.audio_content).decode('utf-8')

    except Exception as e:
        logger.error(f"Cloud TTS error: {str(e)}")
        return None


def generate_response(query, context, response_language):
    examples = {
        "english": """
Example:
Question: What is special about Brihadeeswarar Temple?
Context: The Brihadeeswarar Temple is a grand Chola-era temple in Thanjavur built by Raja Raja Chola I.
Answer: Brihadeeswarar Temple is known for its magnificent Chola architecture and was built by Raja Raja Chola I in Thanjavur during the 11th century. It's a UNESCO World Heritage Site famous for its towering vimana (temple tower) and massive Nandi statue.
""",
        "tamil": """
உதாரணம்:
கேள்வி: பிரகதீஸ்வரர் கோயிலின் சிறப்பு என்ன?
Context: பிரகதீஸ்வரர் கோயில் தஞ்சாவூரில் ராஜராஜ சோழனால் கட்டப்பட்டது.
பதில்: பிரகதீஸ்வரர் கோயில் தஞ்சாவூரில் அமைந்துள்ள முக்கியமான சோழர் கோயிலாகும். இது ராஜராஜ சோழனால் 11-ஆம் நூற்றாண்டில் கட்டப்பட்டது. இக்கோயில் யுனெஸ்கோவின் உலகப் பாரம்பரிய தளமாக அறிவிக்கப்பட்டுள்ளது மற்றும் அதன் உயரமான விமானம் மற்றும் பெரிய நந்தி சிலைக்கு பெயர் பெற்றது.
"""
    }

    instruction = f"""
You are a helpful Tamil Nadu tourist and temple assistant. You can answer both temple-related and travel-related questions.

Rules:
Rules:
1. Answer only in {response_language}.
2. If the question is about temples, include historical info, sculptures, architecture, legends, saints, or unique features.
3. Provide detailed and complete responses (2-4 sentences).
4. Use your knowledge when specific context is not provided.
5.Do not include codeblocks or markdown or stars in the response.
6. If the question is about travel, provide directions, distance, travelling options (if train route available include train, bus or car ) include every options for travelling and estimated time
7. Use delimiters like commas,exclamatory marks,or periods only when needed.

{examples[response_language]}

Now answer this question:
Context: {context}
Question: {query}
"""
    try:
        response = model.generate_content(
            instruction,
            generation_config=genai.types.GenerationConfig(
                temperature=0.4,
                max_output_tokens=300
            )
        )
        return response.text.strip()
    except Exception as e:
        logger.error(f"Response generation error: {str(e)}")
        return "Sorry, I couldn't generate an answer."

def detect_intent_and_entities(query):
    prompt = f"""
    Analyze this query and classify its intent:
    - "temple": If about temples, tourist spots, or sightseeing.
    - "travel": Only if asking for directions between two places.

    Return JSON with intent, source (if travel), and destination (if travel).

    Examples:
    - "மகாபலிபுரத்தில் பார்க்க வேண்டிய இடங்கள்?" → {{"intent": "temple"}}
    - "சென்னையில் இருந்து மகாபலிபுரம் போகும் வழி?" → {{"intent": "travel", "source": "Chennai", "destination": "Mahabalipuram"}}

    Query: "{query}"
    """
    try:
        response = model.generate_content(prompt)
        text = response.text.strip()
        if text.startswith(""):
            text = re.sub(r"(?:json)?", "", text).strip("` \n")
        return json.loads(text)
    except Exception as e:
        logger.error(f"Intent detection error: {str(e)}")
        return {"intent": "temple"}  # Default to temple/tourism

def format_travel_directions(source, destination, distance, duration, gmap_url, language, has_toll=True):
    if language == "tamil":
        spoken_text = (
            f"{source} இலிருந்து {destination} வரை பயண தகவல்கள்:\n\n"
            f"தூரம்: {distance}\n"
            f"மதிப்பிடப்பட்ட நேரம்: {duration}\n"
            f"டோல் சாலைகள்: {'உண்டு' if has_toll else 'இல்லை'}\n\n"
            "வழிகாட்டுதலுக்கு கூகுள் மேப்பை பயன்படுத்தவும்"
        )
        display_text = spoken_text + f"\n\nவழிகாட்டும் மேப் இணைப்பு: {gmap_url}"
    else:
        spoken_text = (
            f"Travel details from {source} to {destination}:\n\n"
            f"Distance: {distance}\n"
            f"Estimated Time: {duration}\n"
            f"Toll Roads: {'Yes' if has_toll else 'No'}\n\n"
            "Use Google Maps for navigation"
        )
        display_text = spoken_text + f"\n\nRoute link: {gmap_url}"
    
    return {
        "spoken_text": spoken_text,
        "display_text": display_text,
        "map_url": gmap_url
    }

@app.route("/chat", methods=["POST"])
def chat():
    try:
        data = request.get_json()
        query = data.get("query", "").strip()

        if not query:
            return jsonify({"error": "Please enter a question"}), 400

        is_tamil_query = is_tamil(query)
        working_query = translate_text(query, "english") if is_tamil_query else query
        intent_data = detect_intent_and_entities(working_query)

        if intent_data.get("intent") == "travel":
            source = intent_data.get("source", "").strip()
            destination = intent_data.get("destination", "").strip()

            if not source or not destination:
                return jsonify({"error": "Could not understand the travel locations. Please specify both starting point and destination clearly."}), 400

            directions_data = get_directions(source, destination)
            distance = directions_data.get("distance", "Unknown")
            duration = directions_data.get("duration", "Unknown")
            has_toll = directions_data.get("has_toll", True)

            def generate_gmap_link(source, destination):
                base_url = "https://www.google.com/maps/dir/?api=1"
                source_encoded = source.replace(" ", "+")
                destination_encoded = destination.replace(" ", "+")
                return f"{base_url}&origin={source_encoded}&destination={destination_encoded}&travelmode=driving"

            gmap_url = generate_gmap_link(source, destination)

            formatted_response = format_travel_directions(
                source, destination, distance, duration, gmap_url,
                language="tamil" if is_tamil_query else "english",
                has_toll=has_toll
            )

            if is_tamil_query:
                voice_data = generate_voice(formatted_response["spoken_text"], 'ta')
                return jsonify({
                    "response": formatted_response["display_text"],
                    "voice": voice_data,
                    "language": "tamil",
                    "map_url": gmap_url
                })
            else:
                return jsonify({
                    "response": formatted_response["display_text"],
                    "language": "english",
                    "map_url": gmap_url,
                    "spoken_text": formatted_response["spoken_text"]
                })

        # Temple Q&A fallback
        query_for_context = working_query if is_tamil_query else query
        docs = vectorstore.similarity_search(query_for_context, k=3)

        context = "\n".join([doc.page_content for doc in docs]) if docs else \
            "This is a temple-related question. Use your knowledge to answer fully with historical and architectural detail."

        language = "tamil" if is_tamil_query else "english"
        answer = generate_response(query_for_context, context, language)

        if is_tamil_query:
            voice_data = generate_voice(answer, 'ta')
            return jsonify({
                "response": answer,
                "voice": voice_data,
                "language": "tamil"
            })
        else:
            return jsonify({
                "response": answer,
                "language": "english"
            })

    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return jsonify({"error": str(e)}), 500


@app.route("/", methods=["GET"])
def index():
    return render_template("index.html")

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5001)