# Oscar Wilde et la prison (1894–1897)

Édition numérique de trois lettres d’Oscar Wilde autour de la période de son incarcération et de sa libération (1894–1897).
Le projet associe fac-similés de manuscrits, transcription encodée en **TEI-XML**, traduction française et **index d’entités nommées**.

Site publié via **GitHub Pages**.

---

## Présentation du projet

Ce site propose une édition numérique explorant trois lettres d’Oscar Wilde :

* Lettre à **John Lane** (août 1894)
* Lettre au **Major Nelson** (mai 1897)
* Lettre à **Henrietta Stannard** (mai 1897)

Ces documents permettent de suivre l’évolution de Wilde entre la période précédant son incarcération et la sortie de prison, moment marqué par la solitude, la gratitude envers certains soutiens et le départ pour l’exil.

Chaque lettre est présentée avec :

* le **fac-similé du manuscrit**
* la **transcription encodée en TEI**
* une **traduction française**
* un système de **navigation par entités nommées** (personnes, lieux, organisations, œuvres)

---

## Objectifs du projet

Le projet poursuit plusieurs objectifs :

* expérimenter les méthodes d’**édition numérique en humanités numériques**
* structurer un corpus textuel avec **TEI-XML**
* générer un **site web multipages automatiquement avec XSLT**
* proposer une interface permettant de lire les lettres **au plus près du manuscrit**

---

## Structure du projet

```
oscar-wilde-et-la-prison/
│
├── assets/
│   ├── css/
│   │   └── style.css
│   ├── js/
│   │   └── site.js
│   └── img/
│       ├── persons/
│       ├── manuscripts/
│       └── favicon.png
│
├── data/
│   └── corpus.xml
│
├── xslt/
│   └── site.xsl
│
├── out/
│   ├── index.html
│   ├── lane.html
│   ├── nelson.html
│   ├── stannard.html
│   ├── index-entities.html
│   ├── methodologie.html
│   └── mentions-legales.html
│
└── README.md
```

---

## Technologies utilisées

* **TEI-XML** – encodage du corpus
* **XSLT 2.0** – transformation et génération multipages
* **HTML5**
* **CSS**
* **JavaScript**
* **GitHub Pages** – publication du site

---

## Fonctionnalités

Le site propose plusieurs fonctionnalités :

* visionneuse de **fac-similés de manuscrits**
* **carrousel d’images**
* affichage parallèle **transcription / traduction**
* **index d’entités nommées**
* navigation entre les lettres
* liens dynamiques entre le texte et l’index

---

## Sources des manuscrits

* **The Morgan Library & Museum** – lettre à John Lane
* **The New York Public Library** – lettre au Major Nelson
* **Trinity College Dublin** – lettre à Henrietta Stannard

---

## Références bibliographiques

* Holland, Merlin & Hart-Davis, Rupert (éd.), *The Complete Letters of Oscar Wilde*, Fourth Estate, 2000.
* Wilde, Oscar, *The Soul of Man, and Prison Writings*, éd. Isobel Murray, Oxford University Press, 1990.
* Ellmann, Richard, *Oscar Wilde*, Knopf, 1988.

---

## Auteur

Projet réalisé par **Clara Martin**
M2 *Technologies numériques appliquées à l’histoire*
École nationale des chartes – PSL

Dans le cadre de l’enseignement :

**Technique et chaîne de publication électronique avec XSLT**

Encadrement : **Jean-Damien Généro**

---

## Licence

© 2026 Clara Martin — pour l’édition numérique, la structuration des données et la réalisation du site.

Les images de manuscrits appartiennent aux institutions patrimoniales qui les conservent.
