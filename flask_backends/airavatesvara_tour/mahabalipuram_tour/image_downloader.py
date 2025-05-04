import os
import requests
from urllib.parse import quote

# Base URL from the request header
BASE_URL = "https://www.tamilnadutourism.tn.gov.in/virtualtour-pkg/mammallapuram/"

# List of all image paths from the XML (URL-encoded version)
image_paths = [
    "images/01-11_o_preview_2.jpg", 
    "images/01-11_ovr.jpg",
    "images/01-11_o_preview_5.jpg", 
    "images/01-11_o_4.jpg" ,
    "images/01-11_o_5.jpg",
    "images/01-11_o_preview_0.jpg" ,
    "images/01-11_o_preview_3.jpg",
    "images/01-11_o_2.jpg",
     "images/01-11_o_0.jpg",
     "images/01-11_o_1.jpg", 
     "images/01-11_o_3.jpg",
     "images/01-11_o_preview_1.jpg",
     "images/01-11_o_preview_4.jpg",

    "images/03-03_o_preview_2.jpg",
    "images/03-03_ovr.jpg", 
    "images/03-03_o_preview_5.jpg" ,
    "images/03-03_o_4.jpg", 
    "images/03-03_o_5.jpg",
     "images/03-03_o_preview_0.jpg" ,
     "images/03-03_o_preview_3.jpg",
     "images/03-03_o_2.jpg" ,
     "images/03-03_o_0.jpg",
      "images/03-03_o_1.jpg",
       "images/03-03_o_3.jpg" ,
    "images/03-03_o_preview_1.jpg" ,
    "images/03-03_o_preview_4.jpg" ,
    
    "images/06_o_preview_2.jpg" ,
    "images/06_ovr.jpg",
     "images/06_o_preview_5.jpg",
      "images/06_o_4.jpg",
    "images/06_o_5.jpg",
     "images/06_o_preview_0.jpg",
      "images/06_o_preview_3.jpg" ,
       "images/06_o_2.jpg",
    "images/06_o_0.jpg"
     "images/06_o_1.jpg",
       "images/06_o_3.jpg" ,
       "images/06_o_preview_1.jpg",
        "images/06_o_preview_4.jpg" 
    
]

def download_images():
    # Create images directory if it doesn't exist
    os.makedirs('images', exist_ok=True)
    
    for path in image_paths:
        # URL-encode the path (especially spaces)
        encoded_path = quote(path)
        url = BASE_URL + encoded_path
        local_path = path
        
        # Create subdirectories if needed
        os.makedirs(os.path.dirname(local_path), exist_ok=True)
        
        # Skip if file already exists
        if os.path.exists(local_path):
            print(f"Skipping {local_path} (already exists)")
            continue
            
        try:
            # Set a user-agent header to mimic a browser request
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            }
            
            response = requests.get(url, headers=headers, stream=True)
            response.raise_for_status()
            
            with open(local_path, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
            print(f"Successfully downloaded {local_path}")
        except requests.exceptions.HTTPError as errh:
            print(f"HTTP Error for {url}: {errh}")
        except requests.exceptions.ConnectionError as errc:
            print(f"Error Connecting for {url}: {errc}")
        except requests.exceptions.Timeout as errt:
            print(f"Timeout Error for {url}: {errt}")
        except requests.exceptions.RequestException as err:
            print(f"Something went wrong with {url}: {err}")

if __name__ == "__main__":
    print("Starting image download...")
    download_images()
    print("Download process completed!")