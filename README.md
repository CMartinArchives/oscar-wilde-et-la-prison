# Oscar Wilde et la prison (1894–1897)  
### Édition numérique de trois lettres d’Oscar Wilde

Site web :  
https://cmartinarchives.github.io/oscar-wilde-et-la-prison/

Projet réalisé dans le cadre du cours  
**« Technique et chaîne de publication électronique avec XSLT »**  
à l’**École nationale des chartes – PSL**.

Encadrement pédagogique : **Jean-Damien Généro**

Auteur : **Clara Martin**

---

# Présentation du projet

Ce projet propose une **édition numérique de trois lettres d’Oscar Wilde** rédigées entre **1894 et 1897**, autour de la période de son emprisonnement.

Le site associe :

- les **fac-similés des manuscrits**
- une **transcription encodée en TEI-XML**
- une **traduction française**
- un **index des entités nommées** (personnes, lieux, organisations, œuvres)

Le corpus permet d’observer l’évolution de Wilde :

1. **Avant la prison** : stratégie éditoriale et publication de ses œuvres
2. **Après la condamnation de 1895**
3. **Après la libération en 1897 et l’exil en France**

Ces lettres témoignent du basculement entre la vie littéraire londonienne et l’expérience carcérale.

---

# Contexte historique

Oscar Wilde (1854-1900) est l’un des écrivains majeurs de la fin de l’époque victorienne.

Après le succès de ses comédies :

- *Lady Windermere’s Fan* (1892)
- *A Woman of No Importance* (1893)
- *An Ideal Husband* (1895)
- *The Importance of Being Earnest* (1895)

il est poursuivi en justice en 1895 pour **« gross indecency »** selon l’amendement Labouchere (Criminal Law Amendment Act, 1885).

Il est condamné à :

**deux ans de travaux forcés**

et incarcéré notamment à :

- Pentonville
- Wandsworth
- **Reading Gaol**

Après sa libération en **mai 1897**, Wilde quitte l’Angleterre et s’installe en France sous le nom :

**Sebastian Melmoth**

Les lettres présentées dans cette édition couvrent cette période charnière.

---

# Corpus

Le corpus comprend trois lettres :

### 1 — Lettre à John Lane  
**Worthing, août 1894**

Destinataire :  
éditeur britannique et fondateur de **The Bodley Head**.

Sujet :

- correction d’épreuves
- publication de ses pièces
- questions de copyright américain
- stratégie éditoriale

Institution conservatrice :

**The Morgan Library & Museum (New York)**  
https://www.themorgan.org/collection/oscar-wilde/manuscripts-letters/45

---

### 2 — Lettre au Major Nelson  
**Berneval-sur-Mer, 28 mai 1897**

Destinataire :

gouverneur de **Reading Gaol**.

Sujet :

- gratitude pour le traitement reçu en prison
- réflexion morale sur la détention
- critique du système carcéral

Institution conservatrice :

**New York Public Library**  
https://www.nypl.org/events/exhibitions/galleries/other-peoples-mail/item/14910

---

### 3 — Lettre à Henrietta Stannard  
**Berneval-sur-Mer, mai 1897**

Destinataire :

romancière britannique.

Sujet :

- sa situation après la prison
- sa solitude en France
- l’adoption du pseudonyme **Sebastian Melmoth**

Institution conservatrice :

**Trinity College Dublin – Digital Collections**

https://digitalcollections.tcd.ie/concern/works/z316q211n

---

# Objectifs scientifiques

Le projet répond à plusieurs objectifs :

### édition numérique

présenter une édition lisible et structurée des lettres

### modélisation des données textuelles

utiliser **TEI-XML** pour représenter :

- structure des lettres
- entités nommées
- phénomènes textuels

### publication web automatisée

transformer le corpus en site web grâce à **XSLT**

### navigation documentaire

permettre une exploration par :

- entités nommées
- index
- liens internes

---

# Encodage TEI

Le corpus est encodé selon les recommandations de la Text Encoding Initiative (TEI).

Structure principale du document TEI :

TEI
├── teiHeader
│   ├── fileDesc
│   │   ├── titleStmt
│   │   ├── publicationStmt
│   │   └── sourceDesc
│   │
│   ├── profileDesc
│   │   └── textClass
│   │
│   └── revisionDesc
│
└── text
    └── body
        ├── div type="letter" xml:id="lane"
        │   ├── opener
        │   │   ├── dateline
        │   │   └── salute
        │   │
        │   ├── p
        │   │   ├── persName
        │   │   ├── placeName
        │   │   ├── orgName
        │   │   └── title
        │   │
        │   └── closer
        │
        ├── div type="letter" xml:id="nelson"
        │   └── structure similaire
        │
        └── div type="letter" xml:id="stannard"
            └── structure similaire

Les entités nommées sont définies dans des listes d’autorité :

listPerson
listPlace
listOrg
listBibl

Les occurrences dans le texte utilisent des références :

persName ref="#pers_wilde"
placeName ref="#place_berneval"
orgName ref="#org_bodley_head"
title ref="#work_mr_wh"

Ce système permet de générer automatiquement :

- l’index des entités
- les liens internes entre pages
- les notices descriptives des personnes, lieux et œuvres.

# Transformation XSLT

Le site web est généré automatiquement à partir du corpus TEI grâce à une feuille de transformation XSLT.

Chaîne de publication :

TEI XML → XSLT → HTML multipages → site web

La transformation utilise notamment :

- XPath pour interroger la structure TEI
- xsl:result-document pour générer plusieurs pages HTML
- des templates réutilisables pour la structure commune du site

Structure simplifiée du projet :

oscar-wilde-et-la-prison/
├── corpus.xml
├── xslt/
│   └── tei2site.xsl
│
├── assets/
│   ├── css/
│   │   └── style.css
│   │
│   ├── js/
│   │   └── site.js
│   │
│   └── img/
│
└── out/
    ├── index.html
    ├── lane.html
    ├── nelson.html
    ├── stannard.html
    └── index-entities.html


# Compétences mobilisées

Ce projet met en œuvre :

- TEI-XML  
- XPath  
- XSLT 2.0  
- HTML  
- CSS  
- JavaScript  
- édition numérique  
- structuration de corpus


# Bibliographie

- Ellmann, Richard.  
*Oscar Wilde*. Knopf, 1988.

- Holland, Merlin & Hart-Davis, Rupert (eds.).  
*The Complete Letters of Oscar Wilde*. Fourth Estate, 2000.

- Murray, Isobel (ed.).  
*The Soul of Man and Prison Writings*. Oxford University Press, 1990.

- Wilde, Oscar.  
*The Ballad of Reading Gaol*. 1898.


# Licence

Encodage TEI, transformation XSLT et site web :  
© 2026 Clara Martin

Les images de manuscrits appartiennent aux institutions de conservation.