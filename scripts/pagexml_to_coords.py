# ============================================================
# Script de conversion PAGE XML → JSON overlays
# Utilisé pour générer les boîtes de texte interactives
# affichées au-dessus des images de manuscrits sur le site.
#
# Entrée : fichiers PAGE XML (OCR / transcription ligne par ligne)
# Sortie : fichiers JSON contenant les coordonnées + le texte.
# ============================================================

# lxml.etree = bibliothèque XML plus puissante que xml.etree standard
# utilisée ici pour parser facilement les fichiers PAGE XML
from lxml import etree

# bibliothèques standard
import json, os, re

# typing = uniquement pour aider l'éditeur / la lisibilité
from typing import List, Tuple, Optional


# ============================================================
# Namespace XML utilisé par les fichiers PAGE XML
#
# Les fichiers PAGE utilisent un namespace XML obligatoire.
# Sans ce dictionnaire, les recherches XPath ne fonctionneraient pas.
#
# "pc" est un alias que l'on utilise ensuite dans les requêtes
# XPath comme : .//pc:TextLine
# ============================================================

NS = {"pc": "http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15"}


# ============================================================
# Convertit une liste de points polygonaux en bounding box
#
# PAGE XML stocke les lignes de texte comme des polygones :
#   points="x1,y1 x2,y2 x3,y3 ..."
#
# Pour l'overlay JS du site, on veut un rectangle simple :
#   x, y, width, height
#
# Cette fonction calcule donc la bounding box minimale
# qui contient tous les points du polygone.
# ============================================================

def points_to_bbox(points_str: str):

    # liste des points convertis
    pts = []

    # "x1,y1 x2,y2 ..." → ["x1,y1", "x2,y2", ...]
    for pair in points_str.strip().split():

        # sépare x et y
        x, y = pair.split(",")

        # conversion en entiers
        pts.append((int(float(x)), int(float(y))))

    # extraction des coordonnées
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]

    # retourne :
    #   x min
    #   y min
    #   largeur
    #   hauteur
    return min(xs), min(ys), max(xs) - min(xs), max(ys) - min(ys)


# ============================================================
# Convertit UN fichier PAGE XML → JSON overlay
#
# Exemple :
#   pagexml/lanepage01.xml
#   → assets/overlays/lane_01.json
# ============================================================

def convert_one(pagexml_path: str, out_json_path: str):

    # charge le fichier XML
    tree = etree.parse(pagexml_path)

    # récupère l'élément <Page>
    page = tree.find(".//pc:Page", NS)

    # sécurité si le XML est invalide
    if page is None:
        raise ValueError(f"Page element not found in {pagexml_path}")

    # structure JSON finale
    data = {

        # nom de l'image associée
        "image": page.get("imageFilename"),

        # dimensions natives de l'image
        "nativeW": int(float(page.get("imageWidth"))),
        "nativeH": int(float(page.get("imageHeight"))),

        # liste des boîtes de texte
        "boxes": []
    }

    # ========================================================
    # Parcours de toutes les lignes de texte du document
    # ========================================================

    for tl in tree.findall(".//pc:TextLine", NS):

        # coordonnées polygonales
        coords = tl.find("./pc:Coords", NS)

        # texte reconnu
        uni = tl.find("./pc:TextEquiv/pc:Unicode", NS)

        # ignore les lignes mal formées
        if coords is None or uni is None:
            continue

        # récupère le texte
        text = (uni.text or "").strip()

        # ignore les lignes vides
        if not text:
            continue

        # conversion du polygone → bounding box
        x, y, w, h = points_to_bbox(coords.get("points"))

        # ajout dans la liste JSON
        data["boxes"].append({
            "x": x,
            "y": y,
            "w": w,
            "h": h,
            "t": text
        })

    # ========================================================
    # Écriture du fichier JSON
    # ========================================================

    # crée le dossier si nécessaire
    os.makedirs(os.path.dirname(out_json_path), exist_ok=True)

    # écrit le JSON
    with open(out_json_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    # log terminal
    print(f"✔ {out_json_path} ({len(data['boxes'])} boxes)")


# ============================================================
# Analyse le numéro de page extrait du nom de fichier
#
# Exemples acceptés :
#   1
#   01
#   2a
#   02b
#   11c
#
# Retourne :
#   (numéro, suffixe)
#
# Exemple :
#   "02a" → (2, "a")
# ============================================================

def parse_page_token(token: str) -> Optional[Tuple[int, str]]:

    """
    token examples:
      "1", "01", "2a", "02b", "10", "11c"
    returns (num, suffix) where suffix is "" or "a"/"b"/...
    """

    token = token.strip().lower()

    # regex :
    # (\d+) = un ou plusieurs chiffres
    # ([a-z]?) = lettre optionnelle
    m = re.fullmatch(r"(\d+)([a-z]?)", token)

    if not m:
        return None

    # numéro de page
    num = int(m.group(1))

    # suffixe éventuel (a/b/c...)
    suf = m.group(2) or ""

    return num, suf


# ============================================================
# Reformate le token de page pour la sortie JSON
#
# Exemple :
#   (2,"a") → "02a"
#   (2,"")  → "02"
# ============================================================

def format_page_token(num: int, suf: str) -> str:

    """
    (2,"a") -> "02a"
    (2,"")  -> "02"
    """

    # :02d = padding à deux chiffres
    return f"{num:02d}{suf}"


# ============================================================
# Convertit toute une série de pages
#
# Exemple :
#   prefix = "lane"
#
# Recherche :
#   lanepage01.xml
#   lanepage02a.xml
#
# Produit :
#   lane_01.json
#   lane_02a.json
# ============================================================

def export_series(in_dir: str, prefix: str, out_dir: str):

    """
    in_dir: dossier pagexml
    prefix: lane / nelson / stannard
    out_dir: assets/overlays
    """

    # regex pour trouver les bons fichiers
    rx = re.compile(
        rf"^{re.escape(prefix)}page(\d+[a-z]?)\.xml$",
        re.IGNORECASE
    )

    # liste des fichiers trouvés
    files: List[Tuple[Tuple[int, str], str]] = []

    # parcours du dossier
    for fn in os.listdir(in_dir):

        m = rx.match(fn)

        if not m:
            continue

        token = m.group(1)

        # parse le numéro
        parsed = parse_page_token(token)

        if not parsed:
            continue

        num, suf = parsed

        # Tri futur : (2,"") avant (2,"a") avant (2,"b")
        files.append(((num, suf), fn))

    # tri des fichiers
    files.sort(key=lambda x: (x[0][0], x[0][1]))

    # aucun fichier trouvé
    if not files:
        print(f"⚠ Aucun fichier {prefix}pageN(.a/.b).xml trouvé dans {in_dir}")
        return

    # conversion de chaque fichier
    for (num, suf), fn in files:

        in_path = os.path.join(in_dir, fn)

        tok = format_page_token(num, suf)

        out_name = f"{prefix}_{tok}.json"

        out_path = os.path.join(out_dir, out_name)

        convert_one(in_path, out_path)


# ============================================================
# Fonction principale
# ============================================================

def main():

    # chemin du dossier scripts/
    here = os.path.dirname(os.path.abspath(__file__))

    # racine du projet
    root = os.path.abspath(os.path.join(here, ".."))

    # dossier contenant les PAGE XML
    in_dir = os.path.join(root, "pagexml")

    # dossier de sortie JSON
    out_dir = os.path.join(root, "assets", "overlays")

    # conversion des trois corpus
    export_series(in_dir, "lane", out_dir)
    export_series(in_dir, "nelson", out_dir)
    export_series(in_dir, "stannard", out_dir)


# ============================================================
# Point d'entrée du script
#
# Permet d'exécuter :
#   python pagexml_to_coords.py
#
# mais évite l'exécution si le fichier est importé ailleurs.
# ============================================================

if __name__ == "__main__":
    main()