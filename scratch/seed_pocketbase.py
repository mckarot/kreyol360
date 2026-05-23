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
    except urllib.error.HTTPError as e:
        err_msg = e.read().decode("utf-8")
        print(f"HTTP Error {e.code}: {err_msg}", file=sys.stderr)
        return None, e.code
    except Exception as e:
        print(f"Error making request: {str(e)}", file=sys.stderr)
        return None, 500

def authenticate():
    print("Authenticating as admin...")
    url = f"{BASE_URL}/api/collections/_superusers/auth-with-password"
    payload = {"identity": ADMIN_EMAIL, "password": ADMIN_PASS}
    res, status = make_request(url, "POST", payload)
    if status == 200 and res:
        print("Authenticated successfully!")
        return res["token"]
    else:
        print("Authentication failed!", file=sys.stderr)
        sys.exit(1)

def create_collection(token, schema_def):
    name = schema_def["name"]
    print(f"Creating/updating collection: {name}...")
    headers = {"Authorization": token}
    
    # Check if already exists
    check_url = f"{BASE_URL}/api/collections?filter=(name='{name}')"
    res, _ = make_request(check_url, "GET", headers=headers)
    
    if res and res.get("items"):
        existing_col = res["items"][0]
        col_id = existing_col["id"]
        print(f"Collection '{name}' already exists with ID: {col_id}. Merging/updating...")
        # Update existing
        update_url = f"{BASE_URL}/api/collections/{col_id}"
        schema_def["id"] = col_id
        res_update, status = make_request(update_url, "PATCH", schema_def, headers)
        if status == 200:
            return col_id
    else:
        # Create new
        url = f"{BASE_URL}/api/collections"
        res_create, status = make_request(url, "POST", schema_def, headers)
        if status == 200 and res_create:
            return res_create["id"]
    return None

def insert_record(token, collection_name, data):
    headers = {"Authorization": token}
    url = f"{BASE_URL}/api/collections/{collection_name}/records"
    res, status = make_request(url, "POST", data, headers)
    return res if status == 200 else None

def main():
    token = authenticate()
    
    # 1. Proverbs Collection
    proverbs_def = {
        "name": "proverbs",
        "type": "base",
        "schema": [
            {"name": "creole", "type": "text", "required": True},
            {"name": "translation", "type": "text", "required": True},
            {"name": "explanation", "type": "text", "required": False},
            {"name": "audio_url", "type": "url", "required": False}
        ],
        "listRule": "", "viewRule": "", "createRule": "", "updateRule": "", "deleteRule": ""
    }
    create_collection(token, proverbs_def)
    
    # 2. Vocabulary Collection
    vocab_def = {
        "name": "vocabulary",
        "type": "base",
        "schema": [
            {"name": "creole", "type": "text", "required": True},
            {"name": "french", "type": "text", "required": True},
            {"name": "category", "type": "text", "required": True},
            {"name": "example_creole", "type": "text", "required": False},
            {"name": "example_french", "type": "text", "required": False},
            {"name": "audio_url", "type": "url", "required": False}
        ],
        "listRule": "", "viewRule": "", "createRule": "", "updateRule": "", "deleteRule": ""
    }
    create_collection(token, vocab_def)
    
    # 3. Quizzes Collection
    quizzes_def = {
        "name": "quizzes",
        "type": "base",
        "schema": [
            {"name": "title", "type": "text", "required": True},
            {"name": "description", "type": "text", "required": False},
            {"name": "level", "type": "number", "required": False}
        ],
        "listRule": "", "viewRule": "", "createRule": "", "updateRule": "", "deleteRule": ""
    }
    quiz_col_id = create_collection(token, quizzes_def)
    
    # 4. Questions Collection (depends on Quizzes)
    questions_def = {
        "name": "questions",
        "type": "base",
        "schema": [
            {"name": "quiz_id", "type": "relation", "required": True, "options": {"maxSelect": 1, "collectionId": quiz_col_id, "cascadeDelete": True}},
            {"name": "question_text", "type": "text", "required": True},
            {"name": "options", "type": "json", "required": True},
            {"name": "correct_option_index", "type": "number", "required": True},
            {"name": "explanation", "type": "text", "required": False}
        ],
        "listRule": "", "viewRule": "", "createRule": "", "updateRule": "", "deleteRule": ""
    }
    create_collection(token, questions_def)
    
    # 5. Recipes Collection
    recipes_def = {
        "name": "recipes",
        "type": "base",
        "schema": [
            {"name": "title", "type": "text", "required": True},
            {"name": "description", "type": "text", "required": False},
            {"name": "image_url", "type": "url", "required": False},
            {"name": "prep_time", "type": "number", "required": False},
            {"name": "difficulty", "type": "text", "required": False},
            {"name": "ingredients", "type": "json", "required": False},
            {"name": "steps", "type": "json", "required": False}
        ],
        "listRule": "", "viewRule": "", "createRule": "", "updateRule": "", "deleteRule": ""
    }
    create_collection(token, recipes_def)
    
    # 6. Music Collection
    music_def = {
        "name": "music",
        "type": "base",
        "schema": [
            {"name": "title", "type": "text", "required": True},
            {"name": "rhythm", "type": "text", "required": True},
            {"name": "artist", "type": "text", "required": True},
            {"name": "audio_url", "type": "url", "required": False},
            {"name": "cover_url", "type": "url", "required": False},
            {"name": "history", "type": "text", "required": False}
        ],
        "listRule": "", "viewRule": "", "createRule": "", "updateRule": "", "deleteRule": ""
    }
    create_collection(token, music_def)
    
    # 7. Events Collection
    events_def = {
        "name": "events",
        "type": "base",
        "schema": [
            {"name": "title", "type": "text", "required": True},
            {"name": "description", "type": "text", "required": False},
            {"name": "date", "type": "text", "required": False},
            {"name": "location_name", "type": "text", "required": False},
            {"name": "latitude", "type": "number", "required": False},
            {"name": "longitude", "type": "number", "required": False},
            {"name": "price", "type": "number", "required": False},
            {"name": "image_url", "type": "url", "required": False},
            {"name": "category", "type": "text", "required": False}
        ],
        "listRule": "", "viewRule": "", "createRule": "", "updateRule": "", "deleteRule": ""
    }
    create_collection(token, events_def)
    
    # 8. Map Markers Collection
    markers_def = {
        "name": "map_markers",
        "type": "base",
        "schema": [
            {"name": "name", "type": "text", "required": True},
            {"name": "description", "type": "text", "required": False},
            {"name": "latitude", "type": "number", "required": True},
            {"name": "longitude", "type": "number", "required": True},
            {"name": "category", "type": "text", "required": False},
            {"name": "image_url", "type": "url", "required": False}
        ],
        "listRule": "", "viewRule": "", "createRule": "", "updateRule": "", "deleteRule": ""
    }
    create_collection(token, markers_def)
    
    # 9. Traditions Collection
    traditions_def = {
        "name": "traditions",
        "type": "base",
        "schema": [
            {"name": "title", "type": "text", "required": True},
            {"name": "category", "type": "text", "required": True},
            {"name": "description", "type": "text", "required": False},
            {"name": "image_url", "type": "url", "required": False}
        ],
        "listRule": "", "viewRule": "", "createRule": "", "updateRule": "", "deleteRule": ""
    }
    create_collection(token, traditions_def)
    
    print("\n--- SCHEMA INITIALIZED SUCCESSFULLY --- \n")
    print("Inserting mock data...")
    
    # Seeding proverbs
    proverbs_data = [
        {
            "creole": "Pati pou chaché, pa di ou trouvé",
            "translation": "Partir pour chercher ne veut pas dire qu'on a trouvé.",
            "explanation": "Ce proverbe enseigne la modestie et rappelle que l'effort de recherche n'est que la première étape avant d'atteindre le succès.",
            "audio_url": "https://example.com/audio/proverb1.mp3"
        },
        {
            "creole": "Sa ki fèt an nwit ka kléré la jounen",
            "translation": "Ce qui se fait la nuit éclaire le jour.",
            "explanation": "Les secrets finissent toujours par être découverts.",
            "audio_url": "https://example.com/audio/proverb2.mp3"
        }
    ]
    for p in proverbs_data:
        insert_record(token, "proverbs", p)
        
    # Seeding vocabulary
    vocab_data = [
        {"creole": "Bonjou", "french": "Bonjour", "category": "Salutations", "example_creole": "Bonjou Mathieu, kouman ou yé?", "example_french": "Bonjour Mathieu, comment vas-tu?", "audio_url": "https://example.com/audio/bonjou.mp3"},
        {"creole": "Bel ti manmay", "french": "Bel enfant", "category": "Expressions", "example_creole": "I sé an bel ti manmay.", "example_french": "C'est un bel enfant.", "audio_url": "https://example.com/audio/manmay.mp3"},
        {"creole": "Sa ka maché", "french": "Ça va", "category": "Salutations", "example_creole": "Oui, sa ka maché ba mwen.", "example_french": "Oui, ça va bien pour moi.", "audio_url": "https://example.com/audio/sakamache.mp3"},
        {"creole": "Dousin", "french": "Douceur / Câlin", "category": "Sentiments", "example_creole": "Ba mwen an ti dousin.", "example_french": "Donne-moi un petit câlin.", "audio_url": "https://example.com/audio/dousin.mp3"}
    ]
    for v in vocab_data:
        insert_record(token, "vocabulary", v)
        
    # Seeding quizzes and questions
    quiz_res = insert_record(token, "quizzes", {"title": "Kréyol Débutant", "description": "Évaluez vos bases en langue créole martiniquaise.", "level": 1})
    if quiz_res:
        quiz_id = quiz_res["id"]
        q1 = {
            "quiz_id": quiz_id,
            "question_text": "Que signifie 'Kouman ou yé' ?",
            "options": ["Comment vas-tu ?", "Où vas-tu ?", "Qui es-tu ?", "Quel âge as-tu ?"],
            "correct_option_index": 0,
            "explanation": "'Kouman ou yé' est la formule standard pour demander des nouvelles de quelqu'un."
        }
        q2 = {
            "quiz_id": quiz_id,
            "question_text": "Que signifie le mot 'Manjé' ?",
            "options": ["Dormir", "Manger", "Courir", "Chanter"],
            "correct_option_index": 1,
            "explanation": "'Manjé' désigne à la fois le verbe manger et la nourriture en général."
        }
        insert_record(token, "questions", q1)
        insert_record(token, "questions", q2)
        
    # Seeding recipes
    recipes_data = [
        {
            "title": "Accras de Morue",
            "description": "Les fameux beignets croustillants à la morue et aux piments doux, incontournables des apéritifs martiniquais.",
            "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuAhlK7znsUTtJetY-JqPP-c7HZ8YGsejUdEbHi3eT1Suxjb7OHdeQFETRcsz1cPk3u5ZLwPIezV8D90wsDZxajiZ7xlJp5_mkY6rye7_wHdID7lHGR4C4Z7Sk4yGbskVGjeeLnMT8Hb59t7B_KInUuf_rFHIebxm_vlIcZHrHP6t91uyQnV9RCEYewEPPV7WZFKTE9QQYuPlfvlUkjZC5GUbUG7uoP3XhLnW0h-UBmB6vD34Afa2Ej6NbHfbexSd6YDmDheJXWijA",
            "prep_time": 30,
            "difficulty": "Facile",
            "ingredients": ["250g de morue dessalée", "200g de farine", "150ml d'eau ou de lait", "1 oignon pays (cive)", "2 gousses d'ail", "Piment végétarien", "Persil", "1/2 sachet de levure chimique"],
            "steps": [
                "Émietter finement la morue dessalée.",
                "Hacher l'ail, le persil, l'oignon pays et le piment.",
                "Dans un saladier, mélanger la farine, la levure, puis ajouter l'eau progressivement pour former une pâte épaisse.",
                "Incorporer la morue et les aromates hachés. Laisser reposer 15 minutes.",
                "Faire frire des petites cuillerées de pâte dans de l'huile bien chaude jusqu'à ce qu'elles soient bien dorées."
            ]
        },
        {
            "title": "Colombo de Poulet",
            "description": "Le plat traditionnel le plus célèbre des Antilles, mijoté avec des épices douces et des légumes locaux.",
            "image_url": "https://images.unsplash.com/photo-1546069901-ba9599a7e63c",
            "prep_time": 60,
            "difficulty": "Moyen",
            "ingredients": ["1 poulet découpé", "3 cuillères à soupe de poudre de colombo", "2 pommes de terre", "1 aubergine", "2 gousses d'ail", "Citron vert", "Oignon", "Cives", "Piment végétarien"],
            "steps": [
                "Faire mariner le poulet avec l'ail, le citron vert, le sel et une cuillère de colombo.",
                "Faire dorer les morceaux de poulet dans une cocotte.",
                "Ajouter les oignons, les cives et faire revenir.",
                "Incorporer le reste de poudre de colombo délayé dans de l'eau, puis ajouter les pommes de terre et l'aubergine coupées en morceaux.",
                "Laisser mijoter à feu doux pendant 40 minutes jusqu'à ce que la sauce soit bien onctueuse."
            ]
        }
    ]
    for r in recipes_data:
        insert_record(token, "recipes", r)
        
    # Seeding music
    music_data = [
        {
            "title": "Rhythm of Bèlè",
            "rhythm": "Bèlè",
            "artist": "Ti Raoul",
            "audio_url": "https://example.com/audio/bele_track.mp3",
            "cover_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuDne7s-KB8vwrk95giZfgIN0YcqNzJbR6ESraBuKM0gt2fpiOevm4pDMmMEDiCfCA9vU39CvRingAnzXpFqIjcs4pSjiUgeasv3XPA7LNkX4jHU0NEeBIgpuhzJ2ub8nR7OPbqhB_Auxz4rltaEMEQYbU6J_2n46AC9Y66-7I8f_-YAJrj2WApqRONg8xxmeOjo1czugwt-Z8nKtbi6X_iOBzRf2gnWWJbn_d52lxtTjwu4g8IemG0coXxfFEMNrtoinCOyHw7TCw",
            "history": "Le Bèlè est une danse et un rythme traditionnel de la Martinique, né de l'adaptation des rythmes africains. Il mêle le tambour bèlè, le tibwa (deux baguettes en bois frappées sur le flanc du tambour) et un dialogue chanté entre un soliste et le chœur (répondè)."
        },
        {
            "title": "Léwoz Classique",
            "rhythm": "Gwo Ka",
            "artist": "Gérard Pomer",
            "audio_url": "https://example.com/audio/gwoka_track.mp3",
            "cover_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuBzsbJtgKdRsKAcc9Udhj3bib5WfWhqeXeCCIYm-F850KSmnxG3SkbfFhmBk5OeKWBfWKA3nvLaZw-GZDdKgQbsGYz6pRiVmW1dHlYUqYvsNlPiBnGlelpshWJVkv5OQvwAdWqQhs37bRhwO6U9BPI-SrIQGIxZtkn5MrANvP9JCB-eD7ZPClMglnRFY3l4YS17rdvU0UoZtqUzvEum1R0ztkja8emFsU_ip9voOysj69_9ohZ_zpNmopZX-MRxzZkJ1oHfpF6mQA",
            "history": "Le Gwo Ka rassemble sept rythmes de base symbolisant différents aspects de la vie quotidienne et des émotions du peuple guadeloupéen et antillais."
        }
    ]
    for m in music_data:
        insert_record(token, "music", m)
        
    # Seeding events
    events_data = [
        {
            "title": "Grand Concert Bèlè au Clair de Lune",
            "description": "Une immersion authentique dans les rythmes du Nord de la Martinique avec les plus grands maîtres du tambour.",
            "date": "2026-06-12T20:00:00Z",
            "location_name": "Sainte-Marie, Maison du Bèlè",
            "latitude": 14.782,
            "longitude": -60.993,
            "price": 15,
            "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuDSn9_wYgEGBuWYouZV3pCVK7swux0AnpW4vbIi25gkprKdDrNina-xoTfixoKXo0empN9oMMJthQ2dMTfakdbPo0jxktBdaghnJ8HjPXdnk7GwyU2K_r-tUCNb-j_OJlxwWO4yrxSC4_P-yEKSonMCjtYUTQkpGDY3O3Ys8LvJyfaOtha7WoD0AswUJe8DM4ibhGlbRoGHF_8Q2PNPEhepe-sFVlkldtcduvV7dQkhEyJUIh21nfzHPQrTLDL1QrpyLupMdXn7AA",
            "category": "Concert"
        },
        {
            "title": "Atelier de Cuisine : Initiation aux Accras",
            "description": "Apprenez les secrets d'un accra croustillant et léger avec la cheffe Marie-Louise.",
            "date": "2026-06-14T10:00:00Z",
            "location_name": "Fort-de-France, Marché Couvert",
            "latitude": 14.604,
            "longitude": -61.071,
            "price": 25,
            "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuAJFRaFUbn3vEUMweA5NGpNAh_DpnRzGTwzSaDolfrI9dfryshU0oTo3rQHuukTxnsb0nq14m6WcwM7F2nq_fSLBLXMkEJUkMuqWvf860utlLqEtaGbfJGnMaFK5wrwvq3q6BTJzFv2_LnMWoxjQnBjMJ9cMkjHoFOHDBDqN6mDbMCyacRx3Ke6hK3pJPQKdkyshS-zirgWeiIY9UuU72eC2ObQ77N-KecCzaRxn7pwWOpqy6RdgY5L4lRTzqVTEiE-Iv6icyaX-Q",
            "category": "Atelier"
        },
        {
            "title": "Soirée Bèlè Lakour",
            "description": "\"L'authenticité des tambours sous les étoiles.\"",
            "date": "19h00 - 23h30",
            "location_name": "Place de la Mairie, Case-Pilote",
            "latitude": 14.636,
            "longitude": -61.138,
            "price": 0,
            "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuAJFRaFUbn3vEUMweA5NGpNAh_DpnRzGTwzSaDolfrI9dfryshU0oTo3rQHuukTxnsb0nq14m6WcwM7F2nq_fSLBLXMkEJUkMuqWvf860utlLqEtaGbfJGnMaFK5wrwvq3q6BTJzFv2_LnMWoxjQnBjMJ9cMkjHoFOHDBDqN6mDbMCyacRx3Ke6hK3pJPQKdkyshS-zirgWeiIY9UuU72eC2ObQ77N-KecCzaRxn7pwWOpqy6RdgY5L4lRTzqVTEiE-Iv6icyaX-Q",
            "category": "Tradition"
        },
        {
            "title": "Jazz sous les Filaos",
            "description": "\"Une fusion parfaite entre notes cuivrées et brise tropicale.\"",
            "date": "20h00 - 01h00",
            "location_name": "Habitation Clément, Le François",
            "latitude": 14.602,
            "longitude": -60.902,
            "price": 25,
            "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuDvtFzaZv5iOTtpW5PsKCtvBuPMDxdkTd4xgSDv0083j_36WUAWFG5eZZ57HLsLQwoUoZ2z5yk1j8qvwJdyhRRWqSL4PMGQaHdkftIVF006z1asBwXuhZg1Q8JYRKryOp5ymr5-98Pyw2mLHOGMeiSX3ziUprHwFnEC8adg1IvJX7humneU5pzd1ZSvfN4wuf1GBOj5I6KRmOIfZIoJZsiXK2Rn6SuGu9f6dn2lpEtGWSM47I3dQxFSXmZv5eDBGQeg4w1IZppqAQ",
            "category": "Jazz Caribéen"
        }
    ]
    for e in events_data:
        insert_record(token, "events", e)
        
    # Seeding map markers
    markers_data = [
        {"name": "Maison du Bèlè", "description": "Centre de transmission culturel dédié au tambour bèlè, à la danse et au chant traditionnel.", "latitude": 14.782, "longitude": -60.993, "category": "Patrimoine", "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuBcmh7lwA4VnIHrtENHLcrls6vaWxhkPC2C6NviADDubaYsNKv5KtjIZzrWbm-8ZYVdlsG_jiscK3RoDTBAJVll-ebDoHrNd4c-2aQi4bnpd5cgq7yIQ5P2GfvwfvtoxVoglVJ-9Kp0SB8SvTSB_fhHXhjQ1wCJBbsEl3q0rM4IxAgaw3peSuEO8p9PAxQF2y-dBPBxHFC6etpBnubEcJivqm9jS2jaF2Phyc6DHMzDEeVYkWTjtO_O_EiOjO9nezHKIcfzn0-_qg"},
        {"name": "Habitation Clément", "description": "Superbe domaine historique regroupant une ancienne distillerie de rhum agricole, une maison créole et des galeries d'art contemporain.", "latitude": 14.602, "longitude": -60.902, "category": "Rhumerie", "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuCugaGloe5_ni3bmwpEFx7zDTHV36nXnv1g_JQNSvQ289KZaWddMSdcvV2a83STeWD0rYZAEgHijuG3VquZBq84xYdZ1V3D1hSASbtYddxBRbnM7hI-PJnAuKDFhIMLMasN5ceVCHUhQnM0ba9jk4JfmclRTbZlgVDOEXynI3wlrcy5AmYYH34VQimUuh0S03sLOHjnnneL1sCLzE2BPgbM5SODx7ArFeBix27U4dnhc4OTGAye5zLapefdV0judfuHkrXFrYl6ww"},
        {"name": "La Savane des Esclaves", "description": "Reconstitution historique d'un village d'esclaves marrons, retraçant l'histoire de la Martinique rurale.", "latitude": 14.536, "longitude": -61.026, "category": "Patrimoine", "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuA--UpeQVc_L7YQdliO3CG0GLqIM_qloo5_A4YptStMbFyTCO5leiXLnEtLZWj5FoNvSIDlije7KmZn37dAYAYfs80mpWPwHnrePcvDJu_llxvS2cRrj3ou46VZpdAavg55yJhBFPkBLGDyiGuYs8BpDAriZ3ChjJ_Q_SYfhkfmavpsPFrBmQojfBBoW8Zh4uf7hebaxofM09KGeCtQmixV0fLVGK34oa-VYW2Qgj5h3gIScQRxWruWyAbWaY2m3vSkJCMUp8lGQQ"}
    ]
    for m in markers_data:
        insert_record(token, "map_markers", m)
        
    # Seeding traditions
    traditions_data = [
        {"title": "Le Carnaval Martiniquais", "category": "Carnaval", "description": "Une célébration unique caractérisée par ses jours en couleur (les diables rouges du Mardi Gras, les veuves noires de Vaval le Mercredi des Cendres).", "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuBBMeAJROrPNbZGENYZstga1I9U1PlnrOelWvLGCjkbewZ1jOnJ5IN-w_583kco_7-rY3TQzIs4yg9iWNIZQW2bjiPNFo2p8-FavRx08rcHH55WZbpp0SvxJVY9UWxNkwrjiV5GagWltqfu9c_tRDaXr_llJuzIxTeVZfMdUcvIOjH7LlHp1rRpF6QNG9T8tfbGE0Ca8gzDhO7oEDYihbGG2LWMS-8R5G7VUPHHPsfSqvBQZa9b7gh-EupKNaGTXK2rRuJ7EwtXSA"},
        {"title": "Chanté Nwèl", "category": "Noël", "description": "Les rassemblements festifs de décembre où l'on chante des cantiques rythmés accompagnés de ti bwa, de tambours, tout en partageant le ragoût de porc et le jambon de Noël.", "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuBK0FrgWzRx6198xH7GiQti-An99aMpO6pW-oPyN1puwlw4w3L_5qDUfO7sq2XjM2H0yHSP0fk7XSDVKiW4Y7HVKRxesCVIylt90NN-lrFEahhBiZtOn1i5WLk0hZxHRJW-MeaPl1pqVXY9kllQRhfUOFKxIT4o4ueFkP-NRyMBLxH-69a60WqlUn6wnN6hBffngoeeTI00DuvHWHr-vOLFlc9XMUBNzl_msjy5xQ5lLONieXq4oZ2RxY7D_sDjgD6sb9hkClAOoQ"},
        {"title": "Bèlè Lakour", "category": "Bèlè", "description": "Cercles de tambours et danses ancestrales.", "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuDVjFXiM2QR9ihJlIEibEmwBvpS7fPDcUShvKSE7tD8vuYdQh23ZrAJQl3tJTAIpVBKALw_Pel-VlTXe7I_-ESzUUo-LCBGLsf2hxvC_rkJT2kLDUVldwermcz7Q5aSaaG2ipkIb2n1y9AMb3zitKCYeNX_45v0UQP2ckT9IetVjx_ob1dGQET2bOMpgN8kNmGBR9-mjPtTktqxNbrDaJCLsHVjkyZa0X2eAEqnRBX_r_Yq2pngPptNcD9jWyvPHq4WRPY_Bj63mQ"},
        {"title": "Fêtes Patronales", "category": "Fêtes", "description": "Festivals communaux et foires culinaires.", "image_url": ""},
        {"title": "Fêtes Maritimes", "category": "Sport", "description": "Courses de yoles et patrimoine de la pêche.", "image_url": ""}
    ]
    for t in traditions_data:
        insert_record(token, "traditions", t)
        
    print("\n--- POCKETBASE MOCK DATA SEEDED SUCCESSFULLY --- \n")

if __name__ == "__main__":
    main()
