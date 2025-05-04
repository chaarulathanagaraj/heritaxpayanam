import googlemaps
from datetime import datetime

# Initialize Google Maps API Client
gmaps = googlemaps.Client(key='AIzaSyAbmRbJ1gsxTq92FxjlrNMJISVY9_k9H1A')

def get_directions(source, destination):
    try:
        # Request directions via Google Maps API
        directions = gmaps.directions(
            source,
            destination,
            mode="driving",  # You can also use 'walking', 'bicycling', 'transit'
            departure_time=datetime.now()
        )

        # Log the raw directions response for debugging purposes
        print("Directions API response:", directions)

        # Extract useful information
        if directions:
            route = directions[0]['legs'][0]
            duration = route['duration']['text']
            distance = route['distance']['text']
            instructions = [step['html_instructions'] for step in route['steps']]

            # Return formatted travel guidance
            travel_guide = {
                "duration": duration,
                "distance": distance,
                "instructions": instructions
            }
            return travel_guide
        else:
            return {"error": "Could not find directions for the provided source and destination."}
    
    except Exception as e:
        print("Error while fetching directions:", str(e))
        return {"error": str(e)}