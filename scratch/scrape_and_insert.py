import urllib.request
import re
import ssl
import os
import json

PAGE_URL = "https://tropiques-atrium.fr/scene-nationale/events/arts-visuels-awa-anhan/"
BASE_URL = "http://127.0.0.1:8090"
ADMIN_EMAIL = "admin@kreyol360.local"
ADMIN_PASS = "AdminKreyol360Password123"

def authenticate():
    url = f"{BASE_URL}/api/collections/_superusers/auth-with-password"
    payload = {"identity": ADMIN_EMAIL, "password": ADMIN_PASS}
    req = urllib.request.Request(url, data=json.dumps(payload).encode("utf-8"), headers={"Content-Type": "application/json"}, method="POST")
    try:
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode("utf-8"))["token"]
    except Exception as e:
        print(f"Auth error: {e}")
        return None

def fetch_image_url_from_page():
    print(f"Fetching page {PAGE_URL}...")
    headers = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    }
    context = ssl._create_unverified_context()
    req = urllib.request.Request(PAGE_URL, headers=headers)
    try:
        with urllib.request.urlopen(req, context=context) as response:
            html = response.read().decode('utf-8', errors='ignore')
            
            # Search for the og:image meta tag
            og_match = re.search(r'<meta[^>]*property=["\']og:image["\'][^>]*content=["\']([^"\']+)["\']', html)
            if og_match:
                return og_match.group(1)
                
            # Fallback search for twitter:image
            tw_match = re.search(r'<meta[^>]*name=["\']twitter:image["\'][^>]*content=["\']([^"\']+)["\']', html)
            if tw_match:
                return tw_match.group(1)
                
            # Fallback search for post thumbnail image inside the html content
            img_matches = re.findall(r'<img[^>]*src=["\']([^"\']+(?:jpg|jpeg|png))["\']', html)
            for img in img_matches:
                if "uploads" in img:
                    return img
                    
    except Exception as e:
        print(f"Error fetching/parsing page: {e}")
    return None

def download_and_save(img_url):
    print(f"Found image URL: {img_url}")
    os.makedirs("pb/pb_public/events", exist_ok=True)
    os.makedirs("pb_public/events", exist_ok=True)
    
    dest1 = "pb/pb_public/events/awa_anhan.jpg"
    dest2 = "pb_public/events/awa_anhan.jpg"
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    }
    context = ssl._create_unverified_context()
    req = urllib.request.Request(img_url, headers=headers)
    try:
        with urllib.request.urlopen(req, context=context) as response:
            data = response.read()
            with open(dest1, 'wb') as f1:
                f1.write(data)
            with open(dest2, 'wb') as f2:
                f2.write(data)
        print("Successfully downloaded and saved image to public folders")
        return True
    except Exception as e:
        print(f"Error downloading image: {e}")
        return False

def insert_event(token):
    headers = {
        "Authorization": token,
        "Content-Type": "application/json"
    }
    
    # Check if event already exists
    check_url = f"{BASE_URL}/api/collections/events/records?filter=(title='Arts Visuels : Awa Anhan')"
    req = urllib.request.Request(check_url, headers=headers)
    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode("utf-8"))
            if data.get("items"):
                print("Event 'Arts Visuels : Awa Anhan' already exists in DB.")
                return
    except Exception as e:
        print(f"Check error: {e}")
        
    # Set event date to today so it displays this week
    from datetime import datetime
    today_iso = datetime.utcnow().strftime('%Y-%m-%dT18:00:00Z')
    
    payload = {
        "title": "Arts Visuels : Awa Anhan",
        "description": "Exposition de Bruno Creuzet à la Galerie André Arsenec. L'artiste crée des espaces mémoriels, des autels chargés de symboles duaux, polysémiques et familiers.",
        "date": today_iso,
        "location_name": "Fort-de-France, Galerie André Arsenec",
        "latitude": 14.608,
        "longitude": -61.073,
        "price": 0,
        "image_url": f"{BASE_URL}/events/awa_anhan.jpg",
        "category": "Théâtre"  # Map to Théâtre so it appears in the active categories list
    }
    
    insert_url = f"{BASE_URL}/api/collections/events/records"
    insert_req = urllib.request.Request(insert_url, data=json.dumps(payload).encode("utf-8"), headers=headers, method="POST")
    try:
        with urllib.request.urlopen(insert_req) as response:
            print("Successfully inserted event into PocketBase!")
    except Exception as e:
        print(f"Insert error: {e}")

def main():
    img_url = fetch_image_url_from_page()
    if img_url:
        if download_and_save(img_url):
            token = authenticate()
            if token:
                insert_event(token)
            else:
                print("Could not authenticate with PocketBase.")
    else:
        print("Could not locate any valid image URL on the page.")

if __name__ == "__main__":
    main()
