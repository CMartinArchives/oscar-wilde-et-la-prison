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

Le corpus permet d’observer l’évolution de la situation personnelle et littéraire d’Oscar Wilde à travers trois moments distincts de sa vie.

1. **Avant la prison : stratégie éditoriale et publication de ses œuvres**  
   Avant son procès, Wilde est au sommet de sa carrière littéraire et mondaine à Londres. Il entretient une relation étroite avec plusieurs éditeurs et correspondants afin d’assurer la diffusion de ses œuvres et de contrôler leur publication. Les lettres témoignent de ses préoccupations éditoriales, de ses négociations avec les maisons d’édition et de sa place dans la vie culturelle londonienne de la fin de l’époque victorienne.

2. **Après la condamnation de 1895 : emprisonnement et rupture sociale**  
   Après sa condamnation, la situation de Wilde change radicalement. Incarcéré dans plusieurs prisons britanniques — notamment à **Reading Gaol** — il est confronté aux conditions très dures du système pénitentiaire victorien. Les lettres de cette période témoignent de son isolement, de ses difficultés matérielles et de la rupture avec le monde littéraire qui avait jusque-là soutenu sa carrière.

3. **Après la libération en 1897 et l’exil en France : reconstruction et marginalisation**  
   À sa sortie de prison, Wilde quitte l’Angleterre et s’installe principalement en France sous le pseudonyme **Sebastian Melmoth**. Cette période est marquée par l’exil, des difficultés financières et une tentative de reconstruire sa vie littéraire. Les lettres révèlent les réseaux de soutien qui subsistent et les efforts de Wilde pour continuer à écrire et publier malgré sa marginalisation sociale.

Ces correspondances témoignent ainsi du basculement brutal entre la vie littéraire londonienne et l’expérience carcérale, puis de la période d’exil qui suit sa libération.

---

## Contexte historique

**Oscar Wilde (1854–1900)** est l’un des écrivains majeurs de la fin de l’époque victorienne. Dramaturge, essayiste et romancier, il connaît un grand succès dans les années 1890 grâce à plusieurs comédies devenues emblématiques :

- *Lady Windermere’s Fan* (1892)  
- *A Woman of No Importance* (1893)  
- *An Ideal Husband* (1895)  
- *The Importance of Being Earnest* (1895)

---

## Pourquoi Wilde est condamné

En 1895, Wilde est poursuivi pour **« gross indecency »**, une infraction définie par l’amendement Labouchere du *Criminal Law Amendment Act* (1885).

Cette loi criminalise les relations sexuelles entre hommes, même lorsqu’elles ont lieu en privé.

Le procès trouve son origine dans le conflit entre Wilde et le marquis de Queensberry, père de son compagnon **Lord Alfred Douglas**. Queensberry accuse publiquement Wilde d’entretenir des relations homosexuelles. Wilde engage d’abord une action en diffamation contre lui, mais cette procédure se retourne contre lui lorsque les avocats de Queensberry produisent des témoignages concernant ses relations avec plusieurs jeunes hommes.

Après deux procès retentissants en 1895, Wilde est reconnu coupable et condamné à **deux ans de travaux forcés**, la peine maximale prévue par la loi.

Il est incarcéré successivement dans les prisons de Pentonville, Wandsworth et **Reading Gaol**.

---

## Après la prison

À sa libération en **mai 1897**, Wilde quitte l’Angleterre et s’installe principalement en France sous le nom de **Sebastian Melmoth**, où il vit jusqu’à sa mort en 1900.

Les lettres présentées dans cette édition couvrent cette période charnière de sa vie, marquée par la chute sociale, l’expérience carcérale et l’exil.

---

# Corpus

Le corpus comprend trois lettres :

### 1 — Lettre à John Lane  
**Worthing, août 1894**

Destinataire : éditeur britannique et fondateur de **The Bodley Head**.

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

Destinataire : gouverneur de **Reading Gaol**.

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

Destinataire : romancière britannique.

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
