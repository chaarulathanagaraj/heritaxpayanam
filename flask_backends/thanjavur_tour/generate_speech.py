from gtts import gTTS
import os

# Tamil text to convert
text = "வணக்கம்! தமிழ் வரலாறு பற்றிய தகவல்கள் இங்கு உள்ளன."

# Generate speech
tts = gTTS(text=text, lang="ta")
tts.save("speech.mp3")

print("Speech generated: speech.mp3")

# Play the audio (optional, works only on some OS)
os.system("start speech.mp3")  # Windows
# os.system("afplay speech.mp3")  # macOS
# os.system("mpg321 speech.mp3")  # Linux