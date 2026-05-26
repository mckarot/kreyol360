import urllib.request
import ssl
import os

IMG_URL = "https://www.fortdefrance.fr/wp-content/uploads/2026/05/686948021_1371607595001933_5506863502066142218_n.jpg"

def download_and_save():
    os.makedirs("pb/pb_public/events", exist_ok=True)
    os.makedirs("pb_public/events", exist_ok=True)
    
    dest1 = "pb/pb_public/events/dillon_village.jpg"
    dest2 = "pb_public/events/dillon_village.jpg"
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
        'Accept-Language': 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7'
    }
    context = ssl._create_unverified_context()
    req = urllib.request.Request(IMG_URL, headers=headers)
    try:
        print(f"Downloading {IMG_URL}...")
        with urllib.request.urlopen(req, context=context) as response:
            data = response.read()
            with open(dest1, 'wb') as f1:
                f1.write(data)
            with open(dest2, 'wb') as f2:
                f2.write(data)
        print("Successfully downloaded and saved Fort-de-France event poster!")
        return True
    except Exception as e:
        print(f"Error downloading image: {e}")
        return False

if __name__ == "__main__":
    download_and_save()
