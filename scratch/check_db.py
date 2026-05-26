import urllib.request
import urllib.parse
import json
import sys

BASE_URL = "http://127.0.0.1:8090"
ADMIN_EMAIL = "admin@kreyol360.local"
ADMIN_PASS = "AdminKreyol360Password123"

def make_request(url, method="GET", data=None, headers=None):
    if headers is None:
        headers = {}
    
    req_data = None
    if data is not None:
        req_data = json.dumps(data).encode("utf-8")
        headers["Content-Type"] = "application/json"
    
    req = urllib.request.Request(url, data=req_data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode("utf-8")), response.status
    except Exception as e:
        print(f"Error: {e}")
        return None, 500

# Authenticate
url = f"{BASE_URL}/api/collections/_superusers/auth-with-password"
payload = {"identity": ADMIN_EMAIL, "password": ADMIN_PASS}
res, status = make_request(url, "POST", payload)
if status == 200 and res:
    token = res["token"]
    headers = {"Authorization": token}
    
    # Get events collection details
    col_url = f"{BASE_URL}/api/collections/events"
    col, status = make_request(col_url, "GET", headers=headers)
    print(json.dumps(col, indent=2))
else:
    print("Auth failed")
