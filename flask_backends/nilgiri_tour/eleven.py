import requests

ELEVENLABS_API_KEY ="sk_ef733a2579851b5ee50b25601f21d2e15aaea3938efa3fbd"
elevenlabs_url = "https://api.elevenlabs.io/v1/text-to-speech/Z0ocGS7BSRxFSMhV00nB"  # Ensure correct voice ID

headers = {
    "xi-api-key": ELEVENLABS_API_KEY,
    "Content-Type": "application/json"
}

payload = {
    "text": "Testing ElevenLabs API",
    "model_id": "eleven_multilingual_v2",
    "voice_settings": {"stability": 0.5, "similarity_boost": 0.5}
}

response = requests.post(elevenlabs_url, json=payload, headers=headers)

print(response.status_code, response.text)