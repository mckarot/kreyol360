import urllib.request
import json
import sys
import os

BASE_URL = "http://127.0.0.1:8090"
ADMIN_EMAIL = "admin@kreyol360.local"
ADMIN_PASS = "AdminKreyol360Password123"

# Direct stable image URLs found on public media sites for these events
urls = {
    "rupert": "https://www.guadeloupe.franceantilles.fr/images/2023/11/27/1231649_1701103649_rupert1_672x450.jpg",
    "dupond": "https://focusur.fr/wp-content/uploads/2022/09/Eric-Dupond-Moretti.jpg",
    "pita": "https://www.karibinfo.com/wp-content/uploads/2023/10/Pita-show.jpg"
}

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

def download_and_save():
    os.makedirs("pb/pb_public/events", exist_ok=True)
    os.makedirs("pb_public/events", exist_ok=True)
    import ssl
    context = ssl._create_unverified_context()
    
    for key, url in urls.items():
        dest1 = f"pb/pb_public/events/{key}.jpg"
        dest2 = f"pb_public/events/{key}.jpg"
        print(f"Downloading {url}...")
        try:
            headers = {
                'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
                'Accept-Language': 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7'
            }
            req = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(req, context=context) as response:
                data = response.read()
                with open(dest1, 'wb') as f1:
                    f1.write(data)
                with open(dest2, 'wb') as f2:
                    f2.write(data)
            print(f"Successfully downloaded and saved {key}.jpg to both locations")
        except Exception as e:
            print(f"Error downloading {key}: {e}")

def update_db_urls(token):
    headers = {"Authorization": token, "Content-Type": "application/json"}
    
    # 1. Fetch events from PocketBase
    fetch_url = f"{BASE_URL}/api/collections/events/records?perPage=50"
    req = urllib.request.Request(fetch_url, headers=headers)
    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode("utf-8"))
            items = data.get("items", [])
    except Exception as e:
        print(f"Fetch error: {e}")
        return

    for item in items:
        title = item.get("title", "")
        record_id = item.get("id")
        img_url = None
        
        if "Rupert" in title:
            img_url = f"{BASE_URL}/events/rupert.jpg"
        elif "Dupond-Moretti" in title:
            img_url = f"{BASE_URL}/events/dupond.jpg"
        elif "Pita" in title:
            img_url = f"{BASE_URL}/events/pita.jpg"
            
        if img_url:
            update_url = f"{BASE_URL}/api/collections/events/records/{record_id}"
            payload = {"image_url": img_url}
            update_req = urllib.request.Request(update_url, data=json.dumps(payload).encode("utf-8"), headers=headers, method="PATCH")
            try:
                with urllib.request.urlopen(update_req) as resp:
                    print(f"Updated image URL for event '{title}' to {img_url}")
            except Exception as e:
                print(f"Update error for {title}: {e}")

def main():
    download_and_save()
    token = authenticate()
    if token:
        update_db_urls(token)
    else:
        print("Could not authenticate to update database.")

if __name__ == "__main__":
    main()
