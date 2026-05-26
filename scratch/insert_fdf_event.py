import urllib.request
import json
import ssl
from datetime import datetime

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

def insert_event(token):
    headers = {
        "Authorization": token,
        "Content-Type": "application/json"
    }
    
    # Check if event already exists
    check_url = f"{BASE_URL}/api/collections/events/records?filter=(title='Mai de Dillon : Village des Associations')"
    req = urllib.request.Request(check_url, headers=headers)
    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode("utf-8"))
            if data.get("items"):
                print("Event 'Mai de Dillon : Village des Associations' already exists in DB.")
                return
    except Exception as e:
        print(f"Check error: {e}")
        
    # Set event date to today (UTC time)
    import datetime as dt
    today_iso = dt.datetime.now(dt.timezone.utc).strftime('%Y-%m-%dT15:00:00Z')
    
    payload = {
        "title": "Mai de Dillon : Village des Associations",
        "description": "Découvrez le village des associations à Dillon dans le cadre des festivités culturelles et citoyennes de Fort-de-France. Rencontres, animations et stands d'information.",
        "date": today_iso,
        "location_name": "Fort-de-France, Dillon",
        "latitude": 14.615,
        "longitude": -61.062,
        "price": 0,
        "image_url": f"{BASE_URL}/events/dillon_village.jpg",
        "category": "Plein air"
    }
    
    insert_url = f"{BASE_URL}/api/collections/events/records"
    insert_req = urllib.request.Request(insert_url, data=json.dumps(payload).encode("utf-8"), headers=headers, method="POST")
    try:
        with urllib.request.urlopen(insert_req) as response:
            print("Successfully inserted FDF event into PocketBase!")
    except Exception as e:
        print(f"Insert error: {e}")

def main():
    token = authenticate()
    if token:
        insert_event(token)
    else:
        print("Could not authenticate with PocketBase.")

if __name__ == "__main__":
    main()
