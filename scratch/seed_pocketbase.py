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

def clear_collection(token, collection_name):
    print(f"Clearing collection: {collection_name}...")
    headers = {"Authorization": token}
    url = f"{BASE_URL}/api/collections/{collection_name}/records?perPage=500"
    res, status = make_request(url, "GET", headers=headers)
    if status == 200 and res and "items" in res:
        for item in res["items"]:
            record_id = item["id"]
            del_url = f"{BASE_URL}/api/collections/{collection_name}/records/{record_id}"
            make_request(del_url, "DELETE", headers=headers)

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
        "fields": [
            {"name": "creole", "type": "text", "required": True},
            {"name": "translation", "type": "text", "required": True},
            {"name": "explanation", "type": "text", "required": False},
            {"name": "audio_url", "type": "url", "required": False}
        ],
        "listRule": "id != ''", "viewRule": "id != ''", "createRule": "", "updateRule": "", "deleteRule": ""
    }
    create_collection(token, proverbs_def)
    
    # 2. Vocabulary Collection
    vocab_def = {
        "name": "vocabulary",
        "type": "base",
        "fields": [
            {"name": "creole", "type": "text", "required": True},
            {"name": "french", "type": "text", "required": True},
            {"name": "category", "type": "text", "required": True},
            {"name": "example_creole", "type": "text", "required": False},
            {"name": "example_french", "type": "text", "required": False},
            {"name": "audio_url", "type": "url", "required": False}
        ],
        "listRule": "id != ''", "viewRule": "id != ''", "createRule": "", "updateRule": "", "deleteRule": ""
    }
    create_collection(token, vocab_def)
    
    # 3. Quizzes Collection
    quizzes_def = {
        "name": "quizzes",
        "type": "base",
        "fields": [
            {"name": "title", "type": "text", "required": True},
            {"name": "description", "type": "text", "required": False},
            {"name": "level", "type": "number", "required": False}
        ],
        "listRule": "id != ''", "viewRule": "id != ''", "createRule": "", "updateRule": "", "deleteRule": ""
    }
    quiz_col_id = create_collection(token, quizzes_def)
    
    # 4. Questions Collection (depends on Quizzes)
    questions_def = {
        "name": "questions",
        "type": "base",
        "fields": [
            {"name": "quiz_id", "type": "relation", "required": True, "collectionId": quiz_col_id, "cascadeDelete": True, "maxSelect": 1},
            {"name": "question_text", "type": "text", "required": True},
            {"name": "options", "type": "json", "required": True},
            {"name": "correct_option_index", "type": "number", "required": False},
            {"name": "explanation", "type": "text", "required": False}
        ],
        "listRule": "id != ''", "viewRule": "id != ''", "createRule": "", "updateRule": "", "deleteRule": ""
    }
    create_collection(token, questions_def)
    
    # 5. Recipes Collection
    recipes_def = {
        "name": "recipes",
        "type": "base",
        "fields": [
            {"name": "title", "type": "text", "required": True},
            {"name": "description", "type": "text", "required": False},
            {"name": "category", "type": "text", "required": True},
            {"name": "image_url", "type": "url", "required": False},
            {"name": "prep_time", "type": "number", "required": False},
            {"name": "difficulty", "type": "text", "required": False},
            {"name": "ingredients", "type": "json", "required": False},
            {"name": "steps", "type": "json", "required": False}
        ],
        "listRule": "id != ''", "viewRule": "id != ''", "createRule": "", "updateRule": "", "deleteRule": ""
    }
    create_collection(token, recipes_def)
    
    # 6. Music Collection
    music_def = {
        "name": "music",
        "type": "base",
        "fields": [
            {"name": "title", "type": "text", "required": True},
            {"name": "rhythm", "type": "text", "required": True},
            {"name": "artist", "type": "text", "required": True},
            {"name": "audio_url", "type": "url", "required": False},
            {"name": "cover_url", "type": "url", "required": False},
            {"name": "history", "type": "text", "required": False}
        ],
        "listRule": "id != ''", "viewRule": "id != ''", "createRule": "", "updateRule": "", "deleteRule": ""
    }
    create_collection(token, music_def)
    
    # 7. Events Collection
    events_def = {
        "name": "events",
        "type": "base",
        "fields": [
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
        "listRule": "id != ''", "viewRule": "id != ''", "createRule": "", "updateRule": "", "deleteRule": ""
    }
    create_collection(token, events_def)
    
    # 8. Map Markers Collection
    markers_def = {
        "name": "map_markers",
        "type": "base",
        "fields": [
            {"name": "name", "type": "text", "required": True},
            {"name": "description", "type": "text", "required": False},
            {"name": "latitude", "type": "number", "required": True},
            {"name": "longitude", "type": "number", "required": True},
            {"name": "category", "type": "text", "required": False},
            {"name": "image_url", "type": "url", "required": False}
        ],
        "listRule": "id != ''", "viewRule": "id != ''", "createRule": "", "updateRule": "", "deleteRule": ""
    }
    create_collection(token, markers_def)
    
    # 9. Traditions Collection
    traditions_def = {
        "name": "traditions",
        "type": "base",
        "fields": [
            {"name": "title", "type": "text", "required": True},
            {"name": "category", "type": "text", "required": True},
            {"name": "description", "type": "text", "required": False},
            {"name": "image_url", "type": "url", "required": False}
        ],
        "listRule": "id != ''", "viewRule": "id != ''", "createRule": "", "updateRule": "", "deleteRule": ""
    }
    create_collection(token, traditions_def)
    
    print("\n--- SCHEMA INITIALIZED SUCCESSFULLY --- \n")
    print("Clearing old records from database...")
    for col_name in ["proverbs", "vocabulary", "questions", "quizzes", "recipes", "music", "events", "map_markers", "traditions"]:
        clear_collection(token, col_name)

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
            "category": "Entrées",
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
            "title": "Féroce d'Avocat",
            "description": "Une entrée traditionnelle martiniquaise mariant la douceur de l'avocat, la texture de la farine de manioc et le piment fort.",
            "category": "Entrées",
            "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuBK0FrgWzRx6198xH7GiQti-An99aMpO6pW-oPyN1puwlw4w3L_5qDUfO7sq2XjM2H0yHSP0fk7XSDVKiW4Y7HVKRxesCVIylt90NN-lrFEahhBiZtOn1i5WLk0hZxHRJW-MeaPl1pqVXY9kllQRhfUOFKxIT4o4ueFkP-NRyMBLxH-69a60WqlUn6wnN6hBffngoeeTI00DuvHWHr-vOLFlc9XMUBNzl_msjy5xQ5lLONieXq4oZ2RxY7D_sDjgD6sb9hkClAOoQ",
            "prep_time": 20,
            "difficulty": "Facile",
            "ingredients": ["2 avocats bien mûrs", "150g de morue dessalée et grillée", "100g de farine de manioc", "1 gousse d'ail hachée", "Piment fort antillais", "Jus de citron vert", "2 cuillères à soupe d'huile de table"],
            "steps": [
                "Émietter très finement la morue grillée.",
                "Récupérer la chair des avocats et l'écraser à la fourchette en purée.",
                "Mélanger la purée d'avocat, la morue émiettée, l'ail haché, le jus de citron vert et le piment finement ciselé.",
                "Ajouter la farine de manioc progressivement tout en mélangeant pour obtenir une pâte homogène.",
                "Incorporer l'huile pour lier le tout, façonner en boulettes ou servir frais tel quel."
            ]
        },
        {
            "title": "Colombo de Poulet",
            "description": "Le plat traditionnel le plus célèbre des Antilles, mijoté avec des épices douces et des légumes locaux.",
            "category": "Plats",
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
        },
        {
            "title": "Colombo de Cabri",
            "description": "L'incontournable plat de fête antillais, mijoté longuement avec des morceaux de cabri (chèvre) et des épices douces.",
            "category": "Plats",
            "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuDcS5KSleAUd1_DvyMTBw5mhwYCxchjyYXqu3_o6gk-2mEFlliP3u1uqg3GQsDQ-HTl2b04iULqekVENCFRePakUMckRXt8ebDCcV0ikl_oFRtBVEAC8lKMF7ptiEHoKikVdgdnMaQiMV8X-r7YMykmlokWM3tYlBJ4qNAwfnl_bVr-kxagPv4YULRTGd6E_oV0cKvVRCR5tiNhsi7_qo7uDBJnvQbCVpoW4Y8ornN3SpY-EAulCJ5MLroBfcrTUCZFipebBT2RVQ",
            "prep_time": 150,
            "difficulty": "Difficile",
            "ingredients": ["1kg de viande de cabri", "3 cuillères à soupe de poudre de colombo", "2 pommes de terre", "1 aubergine", "3 gousses d'ail", "Cives", "Citron vert", "Piment bondamanjak"],
            "steps": [
                "Faire mariner la viande découpée avec le citron vert, l'ail écrasé et une cuillère de colombo pendant une nuit.",
                "Saisir les morceaux de viande dans un filet d'huile chaude.",
                "Ajouter les cives hachées et faire revenir doucement.",
                "Mouiller avec un peu d'eau, rajouter le reste de poudre de colombo, puis les morceaux de pommes de terre et d'aubergine.",
                "Laisser mijoter doucement à couvert pendant 2 heures."
            ]
        },
        {
            "title": "Blanc Manger Coco",
            "description": "Un dessert antillais traditionnel très frais, crémeux et parfumé à la noix de coco, au citron vert et à la cannelle.",
            "category": "Desserts",
            "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuBK0FrgWzRx6198xH7GiQti-An99aMpO6pW-oPyN1puwlw4w3L_5qDUfO7sq2XjM2H0yHSP0fk7XSDVKiW4Y7HVKRxesCVIylt90NN-lrFEahhBiZtOn1i5WLk0hZxHRJW-MeaPl1pqVXY9kllQRhfUOFKxIT4o4ueFkP-NRyMBLxH-69a60WqlUn6wnN6hBffngoeeTI00DuvHWHr-vOLFlc9XMUBNzl_msjy5xQ5lLONieXq4oZ2RxY7D_sDjgD6sb9hkClAOoQ",
            "prep_time": 15,
            "difficulty": "Facile",
            "ingredients": ["400ml de lait de coco", "300g de lait concentré sucré", "4 feuilles de gélatine", "Zeste d'un citron vert", "1 pincée de cannelle", "1 cuillère à café d'extrait de vanille"],
            "steps": [
                "Faire ramollir les feuilles de gélatine dans un bol d'eau froide pendant 5 minutes.",
                "Dans une casserole, faire chauffer le lait de coco avec le zeste de citron vert, la cannelle et la vanille sans faire bouillir.",
                "Hors du feu, ajouter les feuilles de gélatine essorées et mélanger énergiquement pour les dissoudre.",
                "Ajouter le lait concentré sucré et bien remuer.",
                "Verser dans des ramequins ou un grand moule et laisser prendre au réfrigérateur pendant au moins 4 heures avant de servir frais."
            ]
        },
        {
            "title": "Tourment d'Amour",
            "description": "Une petite tartelette originaire des îles des Saintes, composée d'une pâte brisée, d'une confiture de coco et d'une génoise légère.",
            "category": "Desserts",
            "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuDSn9_wYgEGBuWYouZV3pCVK7swux0AnpW4vbIi25gkprKdDrNina-xoTfixoKXo0empN9oMMJthQ2dMTfakdbPo0jxktBdaghnJ8HjPXdnk7GwyU2K_r-tUCNb-j_OJlxwWO4yrxSC4_P-yEKSonMCjtYUTQkpGDY3O3Ys8LvJyfaOtha7WoD0AswUJe8DM4ibhGlbRoGHF_8Q2PNPEhepe-sFVlkldtcduvV7dQkhEyJUIh21nfzHPQrTLDL1QrpyLupMdXn7AA",
            "prep_time": 45,
            "difficulty": "Moyen",
            "ingredients": ["1 rouleau de pâte brisée", "200g de confiture de noix de coco", "3 œufs", "100g de sucre", "100g de farine", "1/2 sachet de levure chimique", "Cannelle et zeste de citron"],
            "steps": [
                "Préchauffer le four à 180°C. Foncer des moules à tartelettes avec la pâte brisée.",
                "Déposer une bonne couche de confiture de noix de coco au fond de chaque tartelette.",
                "Préparer la génoise : battre les œufs et le sucre au batteur électrique jusqu'à ce que le mélange double de volume, puis incorporer délicatement la farine tamisée avec la levure, le zeste de citron et la cannelle.",
                "Verser cette génoise sur la confiture de coco pour recouvrir chaque tartelette.",
                "Enfourner pour environ 20 à 25 minutes jusqu'à ce que la génoise soit bien dorée et gonflée. Laisser refroidir."
            ]
        },
        {
            "title": "Ti' Punch Traditionnel",
            "description": "La boisson emblématique des Antilles françaises. Simple, vigoureuse et parfumée.",
            "category": "Boissons",
            "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuDne7s-KB8vwrk95giZfgIN0YcqNzJbR6ESraBuKM0gt2fpiOevm4pDMmMEDiCfCA9vU39CvRingAnzXpFqIjcs4pSjiUgeasv3XPA7LNkX4jHU0NEeBIgpuhzJ2ub8nR7OPbqhB_Auxz4rltaEMEQYbU6J_2n46AC9Y66-7I8f_-YAJrj2WApqRONg8xxmeOjo1czugwt-Z8nKtbi6X_iOBzRf2gnWWJbn_d52lxtTjwu4g8IemG0coXxfFEMNrtoinCOyHw7TCw",
            "prep_time": 5,
            "difficulty": "Facile",
            "ingredients": ["5cl de rhum blanc agricole martiniquais", "1 quartier de citron vert", "1 cuillère à café de sirop de canne (ou sucre roux)"],
            "steps": [
                "Dans un petit verre, presser le quartier de citron vert et le laisser tomber dedans.",
                "Ajouter la cuillère de sirop de canne (ou de sucre roux).",
                "Verser le rhum blanc agricole et mélanger légèrement à l'aide d'une cuillère.",
                "Déguster à température ambiante, sans glaçons selon la tradition antillaise."
            ]
        },
        {
            "title": "Planteur des Antilles",
            "description": "Un cocktail fruité et convivial très populaire, alliant plusieurs jus de fruits tropicaux et du rhum vieux.",
            "category": "Boissons",
            "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuDne7s-KB8vwrk95giZfgIN0YcqNzJbR6ESraBuKM0gt2fpiOevm4pDMmMEDiCfCA9vU39CvRingAnzXpFqIjcs4pSjiUgeasv3XPA7LNkX4jHU0NEeBIgpuhzJ2ub8nR7OPbqhB_Auxz4rltaEMEQYbU6J_2n46AC9Y66-7I8f_-YAJrj2WApqRONg8xxmeOjo1czugwt-Z8nKtbi6X_iOBzRf2gnWWJbn_d52lxtTjwu4g8IemG0coXxfFEMNrtoinCOyHw7TCw",
            "prep_time": 10,
            "difficulty": "Facile",
            "ingredients": ["10cl de rhum blanc agricole", "5cl de rhum vieux", "20cl de jus d'orange", "20cl de jus d'ananas", "20cl de jus de fruits de la passion", "1 trait de sirop de grenadine", "Cannelle, muscade"],
            "steps": [
                "Dans une grande carafe, verser les rhums blanc et vieux.",
                "Ajouter les jus d'orange, d'ananas et de fruits de la passion.",
                "Ajouter la grenadine et saupoudrer d'une pincée de cannelle et de muscade râpée.",
                "Mélanger bien et laisser reposer au frais pendant au moins 2 heures avant de servir avec des glaçons."
            ]
        },
        {
            "title": "Pâte de Piment Fort",
            "description": "La fameuse purée de piment habanero (bondamanjak) servant à relever tous les plats créoles.",
            "category": "Épices",
            "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuAhlK7znsUTtJetY-JqPP-c7HZ8YGsejUdEbHi3eT1Suxjb7OHdeQFETRcsz1cPk3u5ZLwPIezV8D90wsDZxajiZ7xlJp5_mkY6rye7_wHdID7lHGR4C4Z7Sk4yGbskVGjeeLnMT8Hb59t7B_KInUuf_rFHIebxm_vlIcZHrHP6t91uyQnV9RCEYewEPPV7WZFKTE9QQYuPlfvlUkjZC5GUbUG7uoP3XhLnW0h-UBmB6vD34Afa2Ej6NbHfbexSd6YDmDheJXWijA",
            "prep_time": 15,
            "difficulty": "Facile",
            "ingredients": ["100g de piments bondamanjak (habanero)", "2 gousses d'ail", "Jus de 2 citrons verts", "2 cuillères à soupe d'huile", "1 cuillère à café de sel"],
            "steps": [
                "Mettre des gants de protection indispensables.",
                "Laver les piments, enlever les queues et les couper en morceaux avec leurs graines.",
                "Dans un mixeur, mixer les piments avec les gousses d'ail, le jus de citron vert et le sel jusqu'à obtenir une purée fine.",
                "Ajouter l'huile pour émulsionner et conserver dans un bocal en verre hermétique au réfrigérateur."
            ]
        },
        {
            "title": "Sel Pimenté aux Herbes",
            "description": "Un sel de finition maison aromatisé aux herbes locales séchées et au piment doux pour assaisonner viandes et poissons.",
            "category": "Épices",
            "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuAhlK7znsUTtJetY-JqPP-c7HZ8YGsejUdEbHi3eT1Suxjb7OHdeQFETRcsz1cPk3u5ZLwPIezV8D90wsDZxajiZ7xlJp5_mkY6rye7_wHdID7lHGR4C4Z7Sk4yGbskVGjeeLnMT8Hb59t7B_KInUuf_rFHIebxm_vlIcZHrHP6t91uyQnV9RCEYewEPPV7WZFKTE9QQYuPlfvlUkjZC5GUbUG7uoP3XhLnW0h-UBmB6vD34Afa2Ej6NbHfbexSd6YDmDheJXWijA",
            "prep_time": 10,
            "difficulty": "Facile",
            "ingredients": ["200g de gros sel de mer", "1 cuillère à soupe de thym séché", "1 cuillère à soupe de persil séché", "1 cuillère à café de poudre de piment végétarien (doux)", "Zeste séché de citron vert"],
            "steps": [
                "Dans un mortier ou un petit robot, mélanger le gros sel avec le thym, le persil et le zeste de citron vert.",
                "Broyer grossièrement pour mélanger les saveurs.",
                "Ajouter le piment végétarien en poudre et mélanger.",
                "Conserver dans un pot hermétique à l'abri de l'humidité."
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
            "date": "2026-05-26T20:00:00Z",
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
            "date": "2026-05-28T10:00:00Z",
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
            "date": "2026-05-30T19:00:00Z",
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
            "date": "2026-06-01T20:00:00Z",
            "location_name": "Habitation Clément, Le François",
            "latitude": 14.602,
            "longitude": -60.902,
            "price": 25,
            "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuDvtFzaZv5iOTtpW5PsKCtvBuPMDxdkTd4xgSDv0083j_36WUAWFG5eZZ57HLsLQwoUoZ2z5yk1j8qvwJdyhRRWqSL4PMGQaHdkftIVF006z1asBwXuhZg1Q8JYRKryOp5ymr5-98Pyw2mLHOGMeiSX3ziUprHwFnEC8adg1IvJX7humneU5pzd1ZSvfN4wuf1GBOj5I6KRmOIfZIoJZsiXK2Rn6SuGu9f6dn2lpEtGWSM47I3dQxFSXmZv5eDBGQeg4w1IZppqAQ",
            "category": "Jazz Caribéen"
        },
        {
            "title": "Dimanche Gras - Carnaval",
            "description": "Le début officiel des grands vidés et défilés nocturnes du Carnaval de Martinique.",
            "date": "2026-02-11T09:00:00Z",
            "location_name": "Fort-de-France, Rues de la Ville",
            "latitude": 14.604,
            "longitude": -61.071,
            "price": 0,
            "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuBBMeAJROrPNbZGENYZstga1I9U1PlnrOelWvLGCjkbewZ1jOnJ5IN-w_583kco_7-rY3TQzIs4yg9iWNIZQW2bjiPNFo2p8-FavRx08rcHH55WZbpp0SvxJVY9UWxNkwrjiV5GagWltqfu9c_tRDaXr_llJuzIxTeVZfMdUcvIOjH7LlHp1rRpF6QNG9T8tfbGE0Ca8gzDhO7oEDYihbGG2LWMS-8R5G7VUPHHPsfSqvBQZa9b7gh-EupKNaGTXK2rRuJ7EwtXSA",
            "category": "Carnaval"
        },
        {
            "title": "Vendredi Saint - Chemin de Croix",
            "description": "Le traditionnel pèlerinage et chemin de croix de la Passion au Calvaire de la Martinique.",
            "date": "2026-03-29T08:00:00Z",
            "location_name": "Saint-Pierre, Sentier du Calvaire",
            "latitude": 14.743,
            "longitude": -61.176,
            "price": 0,
            "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuA7FcS-y3GWvTKISp7CVn_tgKuwm0BcxDujPnxxEtY7XjpQSt5vP9sS2NUoz7bLbIAo4GHQBJdiqrA7BWGsY6C-3w2iUzMjzAXMwfS68ZvI6nct6t_j_VnJQRsX_blLaiibPzkb6rz8OBEa8CB61XhIyoBESPx2zTFrYPlgwdxSceRC5Oz87yRq80oN7aie8bdQcgrW_Z0brBSbQQdqSsrQ0FWmUO72gbwh3TDwNM-04XDrcfUwd7sJ4zNgLF944RlwTsqicMWpcA",
            "category": "Tradition"
        },
        {
            "title": "Fête de l'Abolition de l'Esclavage",
            "description": "Commémoration nationale de l'insurrection martiniquaise du 22 mai 1848 et libération des esclaves.",
            "date": "2026-05-22T10:00:00Z",
            "location_name": "Fort-de-France, Place de la Savane",
            "latitude": 14.604,
            "longitude": -61.071,
            "price": 0,
            "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuClj5n6f67Bylk0UGiztgKrExm3C7XoJh-UhHB9UvzBgHkppaEY4b1G5H1C3s1EGm7lw6XXtpaoUV1_T0C9QKKe7DMbJ1wA-MVV2IRmm4DcffDIpAtVKcrXu_j5wR2WPEmymjeAiN5NLFogorIDe0sbH3lztVe1Vh6VhC-SUguelccFfV6HNloFcLZsUIhMiFjP4UohlZyLlgp3NxLHFuZofoXWeBjyVCTS-xTPCvhNA82wtZ1uizyE7u7Vkp0BzUV3eSOGqa1wvw",
            "category": "Cérémonie"
        },
        {
            "title": "Fête des Yoles Rondes",
            "description": "Le plus grand événement nautique de l'île. Régate traditionnelle des yoles au tour de la Martinique.",
            "date": "2026-08-15T09:00:00Z",
            "location_name": "Le François, Baie du François",
            "latitude": 14.615,
            "longitude": -60.903,
            "price": 0,
            "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuA--UpeQVc_L7YQdliO3CG0GLqIM_qloo5_A4YptStMbFyTCO5leiXLnEtLZWj5FoNvSIDlije7KmZn37dAYAYfs80mpWPwHnrePcvDJu_llxvS2cRrj3ou46VZpdAavg55yJhBFPkBLGDyiGuYs8BpDAriZ3ChjJ_Q_SYfhkfmavpsPFrBmQojfBBoW8Zh4uf7hebaxofM09KGeCtQmixV0fLVGK34oa-VYW2Qgj5h3gIScQRxWruWyAbWaY2m3vSkJCMUp8lGQQ",
            "category": "Régate"
        },
        {
            "title": "Éric Dupond-Moretti : J'ai dit oui !",
            "description": "Le célèbre avocat pénaliste et ancien ministre de la justice monte sur scène pour livrer ses vérités et plaider avec force et humour.",
            "date": "2026-05-28T20:00:00Z",
            "location_name": "Fort-de-France, Grand Carbet",
            "latitude": 14.609,
            "longitude": -61.076,
            "price": 35,
            "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuA--UpeQVc_L7YQdliO3CG0GLqIM_qloo5_A4YptStMbFyTCO5leiXLnEtLZWj5FoNvSIDlije7KmZn37dAYAYfs80mpWPwHnrePcvDJu_llxvS2cRrj3ou46VZpdAavg55yJhBFPkBLGDyiGuYs8BpDAriZ3ChjJ_Q_SYfhkfmavpsPFrBmQojfBBoW8Zh4uf7hebaxofM09KGeCtQmixV0fLVGK34oa-VYW2Qgj5h3gIScQRxWruWyAbWaY2m3vSkJCMUp8lGQQ",
            "category": "Théâtre"
        },
        {
            "title": "Le Pita Show",
            "description": "Une pièce drôle et engagée sur la vie quotidienne aux Antilles, mêlant humour créole et satire sociale au Teyat Otonom Mawon.",
            "date": "2026-05-29T19:30:00Z",
            "location_name": "Fort-de-France, Teyat Otonom Mawon",
            "latitude": 14.604,
            "longitude": -61.071,
            "price": 15,
            "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuAJFRaFUbn3vEUMweA5NGpNAh_DpnRzGTwzSaDolfrI9dfryshU0oTo3rQHuukTxnsb0nq14m6WcwM7F2nq_fSLBLXMkEJUkMuqWvf860utlLqEtaGbfJGnMaFK5wrwvq3q6BTJzFv2_LnMWoxjQnBjMJ9cMkjHoFOHDBDqN6mDbMCyacRx3Ke6hK3pJPQKdkyshS-zirgWeiIY9UuU72eC2ObQ77N-KecCzaRxn7pwWOpqy6RdgY5L4lRTzqVTEiE-Iv6icyaX-Q",
            "category": "Théâtre"
        },
        {
            "title": "Jean-Yves Rupert : Ce n'est qu'un Aurevoir",
            "description": "L'humoriste martiniquais emblématique Jean-Yves Rupert revient pour un spectacle hilarant et plein d'émotion au Grand Carbet.",
            "date": "2026-05-30T20:00:00Z",
            "location_name": "Fort-de-France, Grand Carbet",
            "latitude": 14.609,
            "longitude": -61.076,
            "price": 30,
            "image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuDSn9_wYgEGBuWYouZV3pCVK7swux0AnpW4vbIi25gkprKdDrNina-xoTfixoKXo0empN9oMMJthQ2dMTfakdbPo0jxktBdaghnJ8HjPXdnk7GwyU2K_r-tUCNb-j_OJlxwWO4yrxSC4_P-yEKSonMCjtYUTQkpGDY3O3Ys8LvJyfaOtha7WoD0AswUJe8DM4ibhGlbRoGHF_8Q2PNPEhepe-sFVlkldtcduvV7dQkhEyJUIh21nfzHPQrTLDL1QrpyLupMdXn7AA",
            "category": "Théâtre"
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
