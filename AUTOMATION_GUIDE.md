# Guide d'Automatisation de la Récupération des Événements

Ce guide détaille la méthodologie pour rechercher, télécharger des images d'événements et les intégrer automatiquement dans la base de données PocketBase afin qu'ils s'affichent correctement dans l'application.

---

## 1. Méthodologie de Recherche Web (Scraping)

Pour récupérer les événements de manière automatisée, le script CLI doit cibler les sources d'information fiables et publiques :
- **Sites municipaux** (ex: `fortdefrance.fr/agenda/`)
- **Scènes nationales et théâtres** (ex: `tropiques-atrium.fr`)
- **Billetteries locales** (ex: `bizouk.com`, `shotgun.live`)

### Extraction des Informations
Le script charge le code HTML des pages et extrait :
- Le titre de l'événement.
- La description, la date/heure et le lieu précis.
- L'URL de l'image (affiche officielle) via les balises Meta de partage OpenGraph (`<meta property="og:image" content="...">`).

---

## 2. Téléchargement Sécurisé des Images (Contournement des protections anti-robots)

Les sites de billetterie ou médias bloquent souvent les requêtes automatisées simples (Erreurs `403 Forbidden` ou `404 Not Found`).

### Technique de contournement
Pour simuler une navigation humaine, le script doit envoyer des en-têtes HTTP réalistes (User-Agent d'un navigateur moderne) et ignorer la vérification SSL si nécessaire :

```python
import urllib.request
import ssl

context = ssl._create_unverified_context()
headers = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
    'Accept-Language': 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7'
}
req = urllib.request.Request(image_url, headers=headers)
with urllib.request.urlopen(req, context=context) as response:
    image_data = response.read()
```

---

## 3. Stockage et Organisation des Fichiers sur le Serveur

Pour que l'application mobile charge les images sans erreur, elles doivent être stockées dans le répertoire public de PocketBase.

### Emplacement de stockage
Les fichiers téléchargés doivent être écrits dans :
- `pb_public/events/[nom_evenement].jpg`

PocketBase sert automatiquement ces fichiers statiques à l'adresse suivante :
`http://127.0.0.1:8090/events/[nom_evenement].jpg`

---

## 4. Intégration Automatique dans la Base de Données

Une fois l'image stockée, le script doit insérer l'événement dans la collection `events` de PocketBase en utilisant l'API REST.

### Processus d'insertion API
1. **Authentification Super-utilisateur** :
   Requête POST sur `/api/collections/_superusers/auth-with-password` pour obtenir un jeton d'accès (Token).
2. **Vérification des doublons** :
   Rechercher si un événement avec le même titre existe déjà via un filtre GET sur `/api/collections/events/records?filter=(title='...')`.
3. **Création de l'enregistrement** :
   Requête POST sur `/api/collections/events/records` avec les informations de l'événement et l'adresse locale de l'image :
   ```json
   {
     "title": "Arts Visuels : Awa Anhan",
     "description": "Exposition de Bruno Creuzet...",
     "date": "2026-05-26T18:00:00Z",
     "location_name": "Fort-de-France, Galerie André Arsenec",
     "latitude": 14.608,
     "longitude": -61.073,
     "price": 0,
     "image_url": "http://127.0.0.1:8090/events/awa_anhan.jpg",
     "category": "Théâtre"
   }
   ```

---

## 5. Automatisation Périodique (Cron Job)

Pour exécuter cette tâche régulièrement en arrière-plan sans intervention humaine, programmez un Cron Job sur le serveur Linux hébergeant PocketBase :

```bash
# Ouvrir l'éditeur cron
crontab -e

# Exécuter le script de scraping tous les jours à minuit
0 0 * * * /usr/bin/python3 /chemin/vers/votre_script.py >> /chemin/vers/scraping.log 2>&1
```
