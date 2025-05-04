import requests

# URLs of the main files (You need to find the exact paths using the Network tab)
files_to_download = [
    "https://www.tamilnadutourism.tn.gov.in/virtualtour-pkg/nilgirimountainailway/index.html",
    "https://www.tamilnadutourism.tn.gov.in/virtualtour-pkg/nilgirimountainailway/pano2vr_player.js",
    "https://www.tamilnadutourism.tn.gov.in/virtualtour-pkg/nilgirimountainailway/skin.js",
    "https://www.tamilnadutourism.tn.gov.in/virtualtour-pkg/nilgirimountainailway/pano.xml"
]

# Save files locally
for url in files_to_download:
    filename = url.split("/")[-1]
    response = requests.get(url)
    if response.status_code == 200:
        with open(filename, "wb") as file:
            file.write(response.content)
        print(f"Downloaded: {filename}")
    else:
        print(f"Failed to download: {filename}")