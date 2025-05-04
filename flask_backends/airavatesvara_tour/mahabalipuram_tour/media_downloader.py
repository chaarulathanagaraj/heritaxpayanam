import os
import requests
from urllib.parse import quote

# Base URL from the request header
BASE_URL = "https://www.tamilnadutourism.tn.gov.in/virtualtour-pkg/mamallapuram/"

media_urls = ["hotspot.png"]

def download_files(url_list, target_folder):
    os.makedirs(target_folder, exist_ok=True)
    
    for path in url_list:
        encoded_path = quote(path)
        url = BASE_URL + encoded_path
        local_path = os.path.join(target_folder, os.path.basename(path))
        
        if os.path.exists(local_path):
            print(f"Skipping {local_path} (already exists)")
            continue
            
        try:
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
    print("Starting downloads...")
    
    print("\nDownloading media files...")
    download_files(media_urls, 'media')
    
    print("\nDownload process completed!")