<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:f="urn:local:functions"
  exclude-result-prefixes="tei xs f">

  <!-- Feuille XSLT du projet
    Cette feuille sert à transformer un document TEI-XML en plusieurs pages XHTML :
    - index.html
    - lane.html
    - nelson.html
    - stannard.html
    - index-entities.html
    - methodologie.html
    - mentions-legales.html -->

  <xsl:output method="xhtml" encoding="UTF-8" indent="yes"/>

  <!-- ========================================================= -->
  <!-- PARAMÈTRES -->
  <!-- ========================================================= -->

  <!-- Paramètre de sortie
    $outDir indique le dossier où seront écrites les pages HTML générées (ici : docs/) -->
  <xsl:param name="outDir" select="'docs/'"/>

  <!-- Base des assets (css/js/images) utilisée dans les pages générées
    Exemple :
      si $assetsBase = 'assets'
      alors : assets/css/style.css -->
  <xsl:param name="assetsBase" select="'assets'"/>

  <!-- Titre principal du site (variable fixe) -->
  <xsl:variable name="siteTitle" select="'OSCAR WILDE'"/>

  <!-- Sous-titre du site -->
  <xsl:variable name="siteSubtitle" select="'LETTRES AUTOUR DE LA PRISON (1894–1897)'"/>

  <!-- ========================================================= -->
  <!-- MÉTADONNÉES DES LETTRES -->
  <!-- ========================================================= -->

  <!-- Je centralise les métadonnées des lettres
    Chaque <letter> contient :
    - key       : identifiant court interne
    - divId     : xml:id du <div> TEI correspondant dans le corpus
    - file      : nom du fichier HTML à générer
    - title     : titre affiché
    - date      : date lisible affichée
    - desc      : résumé éditorial
    - imgPrefix : préfixe des images de fac-similé
    - pages     : liste des pages manuscrites -->
  <xsl:variable name="letters">
    <letter key="lane" divId="lane-letter" file="lane.html"
            title="John Lane" date="Août 1894"
            desc="Lettre adressée à son éditeur au sujet de corrections d’épreuves et
de la stratégie de publication. Wilde y discute la diffusion de ses œuvres,
notamment entre les marchés britannique et américain, ainsi que les questions
de droits et d’édition."
            imgPrefix="lane_"
            pages="01 02a 02b 03 04 05a 05b 06"/>

    <letter key="nelson" divId="nelson-letter" file="nelson.html"
            title="Major Nelson" date="Fin mai 1897"
            desc="Lettre adressée au gouverneur de Reading Gaol, peu après la
libération de Wilde le 17 mai 1897. L’écrivain y exprime sa gratitude pour
l’attention et la bienveillance dont Nelson fit preuve pendant sa détention."
            imgPrefix="nelson_"
            pages="01 02 03 04 05 06 07 08"/>

    <letter key="stannard" divId="stannard-letter" file="stannard.html"
            title="Henrietta Stannard" date="Fin mai 1897"
            desc="Lettre adressée à son amie écrivaine et journaliste après la
libération de Wilde en 1897. L’auteur évoque sa situation après la prison et
son retrait progressif de la vie publique."
            imgPrefix="stannard_"
            pages="01 02 03 04"/>
  </xsl:variable>

  <!-- ========================================================= -->
  <!-- PORTRAITS / VIGNETTES (INDEX) -->
  <!-- ========================================================= -->

  <!-- Ces variables servent à associer des identifiants TEI à des fichiers image.
    Dans le TEI, une personne a un xml:id comme "pers_wilde" et je dis quelle image lui correspond
    (affichage de l’index et parfois affichage des pages de lettres) -->

  <!-- Portraits des personnes (dossier assets/img/persons/) -->
  <xsl:variable name="personPortraits">
    <p id="pers_wilde"    file="oscarwilde.jpeg" />
    <p id="pers_lane"     file="johnlane.jpeg" />
    <p id="pers_stannard" file="henriettastannard.jpeg" />
    <p id="pers_ross"     file="robertross.jpeg" />
    <p id="pers_constance_wilde" file="constancewilde.jpeg" />
    <p id="pers_ricketts" file="charlesricketts.jpeg" />
    <p id="pers_jane_wilde" file="janewilde.jpeg" />
  </xsl:variable>

  <!--  Miniatures des lieux (même dossier d’images) -->
  <xsl:variable name="placeThumbs">
    <p id="place_worthing"      file="worthing.jpeg"/>
    <p id="place_berneval"      file="berneval.jpeg"/>
    <p id="place_dieppe"        file="dieppe.jpeg"/>
    <p id="place_reading_gaol"  file="readinggaol.jpeg"/>
    <p id="place_france"        file="france.jpeg"/>
    <p id="place_america"       file="usa.jpeg"/>
    <p id="place_newyork"       file="newyork.jpeg"/>
    <p id="place_liverpool"     file="liverpool.jpeg"/>
  </xsl:variable>

  <!-- Miniatures des organisations -->
  <xsl:variable name="orgThumbs">
    <p id="org_bodley_head" file="bodleyhead.jpeg"/>
  </xsl:variable>

  <!-- Miniatures ou images des œuvres -->
  <xsl:variable name="workThumbs">
    <p id="work_mr_wh"               file="portraitofmrwh.jpeg"/>
    <p id="work_woman_no_importance" file="womanofnoimportance.jpeg"/>
    <p id="work_lady_windermere"     file="ladywindermerefan.jpeg"/>
    <p id="work_oscariana"           file="oscarwilde.jpeg"/>
    <p id="bibl_warder_martin"       file="readinggaol.jpeg"/>
    <p id="work_de_profundis"        file="deprofundis.jpeg"/>
    <p id="work_ballad_reading_gaol" file="balladofreadinggaol.jpeg"/>
  </xsl:variable>

  <!-- ========================================================= -->
  <!-- FONCTIONS UTILITAIRES -->
  <!-- ========================================================= -->

  <!-- Cette partie contient des fonctions XSLT.
    Elles servent à :
    - retrouver le fichier HTML d’une lettre
    - retrouver le titre lisible d’une lettre
    - définir un ordre de tri
    - distinguer les pays des autres lieux -->

  <!-- f:letter-file() : sert dans l’index pour fabriquer les liens “Cité.e dans : ...”
    Entrée : un identifiant de div de lettre (divId)
    Sortie : nom du fichier HTML correspondant (ex. lane.html) -->
  <xsl:function name="f:letter-file" as="xs:string?">
    <xsl:param name="divId" as="xs:string?"/>
    <xsl:sequence select="string(($letters/letter[@divId=$divId]/@file)[1])"/>
  </xsl:function>

  <!-- f:letter-title() : ex lane-letter -> John Lane
    Entrée : l’identifiant TEI de la lettre
    Sortie : le titre humain / lisible de la lettre -->
  <xsl:function name="f:letter-title" as="xs:string?">
    <xsl:param name="divId" as="xs:string?"/>
    <xsl:sequence select="string(($letters/letter[@divId=$divId]/@title)[1])"/>
  </xsl:function>

  <!-- f:person-rank() : sert à définir un ordre d’importance éditorial des personnes
    L’index commence par les figures les plus centrales pour le corpus : Wilde, Lane, Nelson, Stannard, etc
    Plus le nombre renvoyé est petit, plus la personne passe tôt dans la liste
    Si une personne n’est pas prévue, je mets 999 pour qu’elle arrive à la fin -->
  <xsl:function name="f:person-rank" as="xs:integer">
    <xsl:param name="pid" as="xs:string"/>
    <xsl:sequence select="
      if ($pid='pers_wilde') then 1
      else if ($pid='pers_lane') then 2
      else if ($pid='pers_nelson') then 3
      else if ($pid='pers_stannard') then 4
      else if ($pid='pers_ross') then 5
      else if ($pid='pers_constance_wilde') then 6
      else if ($pid='pers_mathews') then 7
      else if ($pid='pers_ricketts') then 8
      else if ($pid='pers_jane_wilde') then 9
      else 999
    "/>
  </xsl:function>

  <!-- f:is-country-place() : sert à distinguer les pays des villes ou autres lieux
    et donc de faire deux sous-parties dans l’index des lieux

    1) si le lieu n’a pas de settlement, il peut être un pays
    2) on vérifie aussi que son nom correspond à une petite liste de pays attendus -->
  <xsl:function name="f:is-country-place" as="xs:boolean">
    <xsl:param name="place" as="element(tei:place)"/>
    <xsl:variable name="n" select="normalize-space(string(($place/tei:placeName)[1]))"/>
    <xsl:sequence select="
      (not(exists($place/tei:location/tei:settlement)))
      and matches($n,'^(France|United States of America|United Kingdom|Ireland)$','i')
    "/>
  </xsl:function>

  <!-- ========================================================= -->
  <!-- POINT D’ENTRÉE : /tei:TEI -->
  <!-- ========================================================= -->

  <!-- Quand le processeur rencontre la racine /tei:TEI :
    - il garde cette racine dans une variable ($root)
    - il génère plusieurs fichiers avec xsl:result-document
    - dans chaque fichier, il appelle un template qui produit le contenu
    un XML d’entrée -> plusieurs fichiers HTML en sortie -->
  <xsl:template match="/tei:TEI">

    <!-- Je stocke la racine TEI dans $root.
      pour y revenir plus loin (par exemple dans la boucle qui fabrique les pages de lettres) -->
    <xsl:variable name="root" select="."/>


    <!-- ================= ACCUEIL ================= -->

    <!-- Génération de la page d’accueil : docs/index.html -->
    <xsl:result-document href="{concat($outDir,'index.html')}">
      <xsl:call-template name="page-shell">
        <xsl:with-param name="pageTitle" select="'Accueil'"/>
        <xsl:with-param name="pageClass" select="''"/>
        <xsl:with-param name="content">
          <xsl:call-template name="home-page"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:result-document>


    <!-- ================= LETTRES ================= -->

    <!-- Pour chaque entrée de $letters :
      - je prends les métadonnées
      - je retrouve le <div> TEI correspondant grâce à @xml:id
      - je crée une page HTML dédiée
      1 entrée <letter> dans la variable = 1 page HTML générée -->
    <xsl:for-each select="$letters/letter">

      <!-- $meta = la lettre “courante” dans la boucle (métadonnées internes XSLT) -->
      <xsl:variable name="meta" select="."/>

      <!-- $letterDiv = le div TEI correspondant à cette lettre, trouvé dans le corps du texte.

        Explication du chemin :
        - $root/tei:text/tei:body : on va dans le corps du document
        - tei:div[@xml:id = $meta/@divId] : on prend le div dont l’xml:id
          correspond à celui annoncé dans les métadonnées internes
        - [1] : sécurité, on garde le premier trouvé -->
      <xsl:variable name="letterDiv"
        select="$root/tei:text/tei:body/tei:div[@xml:id = $meta/@divId][1]"/>

      <!-- Création du fichier HTML de la lettre. (ex : docs/lane.html) -->
      <xsl:result-document href="{concat($outDir,$meta/@file)}">
        <xsl:call-template name="page-shell">
          <xsl:with-param name="pageTitle" select="$meta/@title"/>
          <xsl:with-param name="pageClass" select="'page-letter'"/>
          <xsl:with-param name="content">
            <xsl:call-template name="letter-page">
              <xsl:with-param name="meta" select="$meta"/>
              <xsl:with-param name="letterDiv" select="$letterDiv"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:result-document>
    </xsl:for-each>


    <!-- ================= INDEX ================= -->

    <!-- Génération de la page d’index des entités -->
    <xsl:result-document href="{concat($outDir,'index-entities.html')}">
      <xsl:call-template name="page-shell">
        <xsl:with-param name="pageTitle" select="'Index'"/>
        <xsl:with-param name="pageClass" select="''"/>
        <xsl:with-param name="content">
          <xsl:call-template name="entities-page"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:result-document>


    <!-- ================= MÉTHODOLOGIE ================= -->

    <!-- Génération de la page de méthodologie -->
    <xsl:result-document href="{concat($outDir,'methodologie.html')}">
      <xsl:call-template name="page-shell">
        <xsl:with-param name="pageTitle" select="'Méthodologie'"/>
        <xsl:with-param name="pageClass" select="''"/>
        <xsl:with-param name="content">
          <xsl:call-template name="methodologie-page"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:result-document>


    <!-- ================= MENTIONS LÉGALES ================= -->

    <!-- Génération de la page des mentions légales.
      Ici je n’appelle pas un template séparé mais j’injecte le contenu HTML dans le paramètre "content" -->
    <xsl:result-document href="{concat($outDir,'mentions-legales.html')}">
      <xsl:call-template name="page-shell">
        <xsl:with-param name="pageTitle" select="'Mentions légales'"/>
        <xsl:with-param name="pageClass" select="'page-legal'"/>
        <xsl:with-param name="content">

          <!-- Contenu HTML injecté dans le shell pour qu’il n’ait pas besoin d’un template dédié (page statique)-->
          <section class="card">

            <h1 class="page-title">Mentions légales</h1>

            <h2>Éditeur du site</h2>
            <p>
              <strong>Clara Martin</strong><br/>
              Étudiante en M2 « Technologies numériques appliquées à l’histoire » à l’École nationale des chartes – PSL.<br/>
              © 2026 Clara Martin.
            </p>

            <h2>Encadrement pédagogique</h2>
            <p>
              Projet réalisé dans le cadre de l’enseignement
              « Technique et chaîne de publication électronique avec XSLT »
              à l’École nationale des chartes – PSL.<br/>
              Encadrement : <strong>Jean-Damien Généro</strong>.
            </p>

            <h2>Établissement</h2>
            <p>
              École nationale des chartes – PSL<br/>
              65 rue de Richelieu<br/>
              75002 Paris – France<br/>
              <a href="https://www.chartes.psl.eu/" target="_blank" rel="noopener">
                https://www.chartes.psl.eu/
              </a>
            </p>

            <h2>Objet du site</h2>
            <p>
              Ce site constitue une édition numérique expérimentale de trois lettres
              d’Oscar Wilde. Il associe la reproduction de fac-similés de manuscrits,
              une transcription encodée en <strong>TEI-XML</strong>, une traduction française
              et un appareil d’indexation des entités nommées (personnes, lieux, œuvres).
            </p>

            <p>
              Le site vise un objectif pédagogique et scientifique dans le cadre
              de l’apprentissage des méthodes d’édition numérique et de
              modélisation des données textuelles en humanités numériques.
            </p>

            <h2>Sources des manuscrits</h2>
            <p>
              Les images de manuscrits utilisées dans cette édition proviennent
              d’institutions patrimoniales. Les droits relatifs aux images
              appartiennent aux institutions détentrices.
            </p>

            <ul>
              <li>
                <strong>The Morgan Library &amp; Museum</strong> (New York) –
                Lettre d’Oscar Wilde à John Lane.
              </li>
              <li>
                <strong>The New York Public Library</strong> –
                Lettre d’Oscar Wilde au Major J. O. Nelson.
              </li>
              <li>
                <strong>Trinity College Dublin</strong> –
                Lettre d’Oscar Wilde à Henrietta Stannard.
              </li>
            </ul>

            <h2>Droits d’édition</h2>
            <p>
              L’encodage TEI-XML, la transcription, la structuration des données,
              les transformations XSLT et la mise en forme du site relèvent du
              travail éditorial de Clara Martin.
            </p>

            <p>
              © 2026 Clara Martin pour l’édition numérique et les contenus
              éditoriaux originaux.
            </p>

            <h2>Données personnelles</h2>
            <p>
              Ce site ne collecte pas de données personnelles et n’utilise pas
              de cookies de suivi. Aucun formulaire ou système de collecte
              d’informations nominatives n’est présent.
            </p>

            <h2>Responsabilité</h2>
            <p>
              Le contenu de ce site est fourni à des fins pédagogiques et
              scientifiques. Malgré le soin apporté à la transcription et
              à l’encodage des documents, des erreurs ou omissions peuvent
              subsister.
            </p>

            <p>
              Les liens externes présents sur le site renvoient vers des
              ressources dont l’éditeur du site n’est pas responsable.
            </p>

          </section>

        </xsl:with-param>
      </xsl:call-template>
    </xsl:result-document>

  </xsl:template>


  <!-- ========================================================= -->
  <!-- SHELL HTML (structure commune à toutes les pages) -->
  <!-- ========================================================= -->

  <!-- page-shell :
    - écrit le HTML complet (head + header/nav + footer)
    - reçoit “content” en paramètre, qui est inséré dans <main> -->
  <xsl:template name="page-shell">

    <!-- pageTitle : titre propre à la page courante (Accueil, John Lane, Index...) -->
    <xsl:param name="pageTitle"/>

    <!-- content : contenu spécifique à la page qui sera injecté dans la balise <main> -->
    <xsl:param name="content"/>

    <!-- pageClass : classe CSS optionnelle placée sur <body> pour permettre des styles différents selon les pages -->
    <xsl:param name="pageClass" select="''"/>

    <html lang="fr" xmlns="http://www.w3.org/1999/xhtml">
      <head>

        <!-- Encodage de la page HTML -->
        <meta charset="utf-8"/>

        <!-- Titre de l’onglet du navigateur (OSCAR WILDE — Accueil etc.) -->
        <title><xsl:value-of select="$siteTitle"/> — <xsl:value-of select="$pageTitle"/></title>

        <!-- Adaptation mobile -->
        <meta name="viewport" content="width=device-width, initial-scale=1"/>

        <!-- Icône du site (favicon) -->
        <link rel="icon" type="image/png" sizes="32x32" href="{$assetsBase}/img/favicon32.png"/>

        <!-- Feuille CSS principale du site -->
        <link rel="stylesheet" href="{$assetsBase}/css/style.css"/>

        <!-- JavaScript principal du site
          defer="defer" : le script est chargé sans bloquer le parsing du HTML et s’exécute après -->
        <script src="{$assetsBase}/js/site.js" defer="defer"></script>
      </head>

      <!-- Le body reçoit une classe propre à la page -->
      <body class="{$pageClass}">
        <header class="site-header">

          <!-- En-tête visuel du site : logo / signature + titre + sous-titre -->
          <div class="masthead">
            <a href="index.html" class="brand">
              <img src="{$assetsBase}/img/Oscar_Wilde_Signature.png"
                   alt="Signature d’Oscar Wilde" class="sig"/>
              <div class="brand-titles">
                <div class="brand-title"><xsl:value-of select="$siteTitle"/></div>
                <div class="brand-subtitle"><xsl:value-of select="$siteSubtitle"/></div>
              </div>
            </a>
          </div>

          <!-- Navigation principale, répétée sur toutes les pages grâce au shell -->
          <nav class="main-nav">
            <ul class="nav-list">
              <li><a class="nav-link" href="index.html">Accueil</a></li>

              <li class="nav-item has-dropdown">
                <a class="nav-link" href="lane.html">Lettres</a>
                <ul class="dropdown">
                  <li><a href="lane.html">Lane (1894)</a></li>
                  <li><a href="nelson.html">Nelson (1897)</a></li>
                  <li><a href="stannard.html">Stannard (1897)</a></li>
                </ul>
              </li>

              <li class="nav-item has-dropdown">
                <a class="nav-link" href="index-entities.html">Index</a>
                <ul class="dropdown">
                  <li><a href="index-entities.html#persons">Individus</a></li>
                  <li><a href="index-entities.html#places">Lieux</a></li>
                  <li><a href="index-entities.html#orgs">Organisations</a></li>
                  <li><a href="index-entities.html#works">Œuvres</a></li>
                </ul>
              </li>

              <li><a class="nav-link" href="methodologie.html">Méthodologie</a></li>
            </ul>
          </nav>
        </header>

        <!-- Zone principale du contenu où on insère le contenu spécifique à chaque page -->
        <main class="container">

          <!-- Insertion du contenu spécifique à la page -->
          <xsl:sequence select="$content"/>
        </main>

        <!-- Pied de page -->
        <footer class="site-footer">
          <div class="container footer-grid footer-grid--compact">
            <div class="footer-col footer-col--left footer-col--logo">
              <a class="footer-logoLink"
                 href="https://www.chartes.psl.eu/"
                 target="_blank" rel="noopener">
                <img src="{$assetsBase}/img/logo-chartes-psl-coul.png"
                     alt="École nationale des chartes – PSL"
                     class="footer-logo"/>
              </a>
            </div>

            <div class="footer-col footer-col--center footer-col--identity">
              <p class="footer-title">
                <strong><xsl:value-of select="$siteTitle"/></strong>
              </p>
              <p class="footer-subtitle">
                <xsl:value-of select="$siteSubtitle"/>
              </p>

              <p class="footer-legalLink">
                <a href="mentions-legales.html">Mentions légales</a>
              </p>

              <p class="footer-copy">© 2026 Clara Martin</p>
            </div>

            <div class="footer-col footer-col--right footer-col--project">
              <p class="footer-meta">
                Édition numérique des lettres d’Oscar Wilde autour de la prison (1894-1897).
              </p>
              <p class="footer-meta">
                Fac-similés des manuscrits, transcription et traduction accompagnées d’un index d’entités nommées.
              </p>
            </div>
          </div>
        </footer>
      </body>
    </html>
  </xsl:template>

  <!-- ========================================================= -->
  <!-- ACCUEIL -->
  <!-- ========================================================= -->

  <!-- home-page :
    - présente le contexte historique
    - affiche une chronologie des lettres alimentée par $letters
    - donne des repères chronologiques et bibliographiques
    C’est un template surtout éditorial donc il contient beaucoup de HTML écrit directement dans la feuille XSLT -->
  <xsl:template name="home-page">

    <!-- Carte d’introduction de la page d’accueil -->
    <section class="card home-intro">
      <h1 class="hero-title">Oscar Wilde et la prison (1894–1897)</h1>

      <p class="muted" style="margin:0 0 10px 0;">
        <strong>Édition numérique</strong> : fac-similés des manuscrits, transcription et traduction françaises, accompagnées d’un index d’entités nommées pour naviguer dans le corpus.
      </p>

      <p class="lead-intro">
        Cette édition numérique explore, à travers trois lettres, le basculement d’Oscar Wilde :
        de la vie littéraire et mondaine à l’expérience carcérale, puis à la sortie de prison et à l’exil.
      </p>

      <p>
        En 1895, Oscar Wilde est poursuivi et condamné pour <em>gross indecency</em>,
        une infraction introduite dans le droit britannique par l’amendement Labouchere
        du <em>Criminal Law Amendment Act</em> de 1885. Cette disposition criminalise
        les relations sexuelles entre hommes, même lorsqu’elles relèvent de la sphère privée.
      </p>

      <p>
        À l’issue d’une série de procès très médiatisés, Wilde est condamné à
        deux ans de travaux forcés. La prison — d’abord à Pentonville et Wandsworth,
        puis à Reading Gaol — transforme durablement sa santé, sa situation matérielle
        et sa manière d’écrire.
      </p>

      <p>
        À sa libération en 1897, il quitte l’Angleterre et s’installe en France
        sous le nom de <em>Sebastian Melmoth</em>, cherchant à se soustraire
        à la stigmatisation sociale qui suit sa condamnation.
      </p>

      <p>
        Le projet propose une lecture “au plus près” des documents :
        <strong>fac-similés</strong> des manuscrits, <strong>transcription</strong>
        et <strong>traduction</strong>, accompagnés d’un <strong>index d’entités nommées</strong>
        (personnes, lieux, organisations, œuvres) permettant de naviguer dans les réseaux
        biographiques et culturels évoqués dans les lettres.
      </p>

      <!-- Liens d’action principaux de la page d’accueil -->
      <div class="home-actions" role="navigation" aria-label="Accès rapides">
        <a class="btn" href="lane.html">Commencer la lecture</a>
        <a class="btn btn--ghost" href="index-entities.html">Explorer l’index</a>
        <a class="btn btn--ghost" href="methodologie.html">Méthodologie</a>
      </div>
    </section>

    <!-- Bloc chronologie, qui se remplit automatiquement grâce à la variable $letters. -->
    <section class="card">
      <h2>Chronologie des lettres</h2>

      <p class="muted">
        Chaque carte renvoie à une page dédiée : fac-similés, transcription et traduction en français.
      </p>

      <p>
        Ces lettres dessinent un arc narratif :
        <em>avant</em> la prison (logiques éditoriales, stratégie de publication),
        puis <em>après</em> (gratitude, lucidité, solitude, besoin d’anonymat).
        Elles montrent aussi la manière dont Wilde se situe face à ses proches, à ses soutiens,
        et face à l’Europe continentale — notamment la France, perçue comme un refuge.
      </p>

      <div class="timeline">

        <!-- Pour chaque lettre définie dans $letters, je crée une carte chronologique cliquable -->
        <xsl:for-each select="$letters/letter">
          <a class="tl-item" href="{@file}">
            <span class="tl-dot"></span>
            <span class="tl-date"><xsl:value-of select="@date"/></span>
            <span class="tl-title"><xsl:value-of select="@title"/></span>
            <span class="tl-desc"><xsl:value-of select="@desc"/></span>
          </a>
        </xsl:for-each>
      </div>
    </section>

    <!-- Image d’illustration sur la page d’accueil -->
    <figure class="home-hero-image viewer">
      <img src="{$assetsBase}/img/WildeTrial1.jpg" alt="Oscar Wilde au procès"/>
      <figcaption>
        <span class="muted">The Trial of Oscar Wilde and Alfred Taylor — Illustrated Police News, 20 avril 1895. </span>
        <span class="muted caption-sub">Un tournant décisif qui conduit à l’incarcération (1895) puis à l’exil.</span>
      </figcaption>
    </figure>

    <section class="card">
      <h2>Une édition pour lire… et pour comprendre</h2>

      <p>
        Ce site propose deux manières de lire : une lecture continue des lettres, et une lecture “documentaire”,
        attentive au manuscrit. Chaque lettre est présentée sous forme de page autonome, avec ses fac-similés,
        sa transcription (d’après l’encodage TEI), et sa traduction française.
      </p>

      <p>
        L’objectif n’est pas seulement de “montrer des images”, mais de donner des repères :
        qui écrit, à qui, quand, depuis où, et dans quel contexte. L’index d’entités nommées
        (personnes, lieux, organisations, œuvres) permet de passer du texte aux notices,
        puis de revenir immédiatement à l’endroit exact où l’entité est citée.
      </p>

      <p>
        Enfin, la page <a class="pill pill--cta" href="methodologie.html">Méthodologie</a> documente le travail d’édition :
        choix d’encodage, transformation XSLT multipages, et principes de mise en page (CSS/JS)
        — de façon à rendre le projet reproductible et vérifiable.
      </p>
    </section>

    <section class="card">
      <h2>Repères chronologiques</h2>
      <p class="muted">
        Quelques dates pour situer le corpus dans la trajectoire de Wilde et l’histoire juridique qui encadre sa condamnation.
      </p>

      <ul class="home-milestones">
        <li><strong>1854</strong> — Naissance d’Oscar Wilde à Dublin (16 octobre).</li>
        <li><strong>1884</strong> — Mariage avec Constance Lloyd.</li>
        <li><strong>1885</strong> — <em>Criminal Law Amendment Act</em> : l’amendement Labouchere (“gross indecency”) entre en vigueur au Royaume-Uni.</li>
        <li><strong>1885</strong> — Naissance de Cyril Wilde.</li>
        <li><strong>1886</strong> — Naissance de Vyvyan Wilde.</li>
        <li><strong>1891</strong> — Publication de <em>The Picture of Dorian Gray</em> (version en volume).</li>
        <li><strong>1891</strong> — Rencontre avec Lord Alfred Douglas (“Bosie”).</li>
        <li><strong>1892</strong> — Première de <em>Lady Windermere’s Fan</em>.</li>
        <li><strong>1893</strong> — Première de <em>A Woman of No Importance</em>.</li>
        <li><strong>1895</strong> — Première de <em>An Ideal Husband</em> et de <em>The Importance of Being Earnest</em>.</li>
        <li><strong>Avr.–mai 1895</strong> — Procès et condamnation de Wilde à deux ans de travaux forcés.</li>
        <li><strong>1895–1897</strong> — Détention (Pentonville, Wandsworth, Reading Gaol).</li>
        <li><strong>Mai 1897</strong> — Libération et départ pour la France ; usage du nom “Sebastian Melmoth”.</li>
        <li><strong>1900</strong> — Mort d’Oscar Wilde à Paris (30 novembre).</li>
      </ul>
    </section>

    <section class="card">
      <h2>Sources et repères bibliographiques</h2>
      <p class="muted">
        Ressources institutionnelles (fac-similés) et éditions de référence pour situer les lettres, la prison et Reading Gaol.
      </p>

      <h3 class="ms-colTitle">Fac-similés (institutions)</h3>
      <ul class="home-sources">
        <li>
          <strong>Lettre à John Lane (août 1894)</strong> — The Morgan Library &amp; Museum :
          <a href="https://www.themorgan.org/collection/oscar-wilde/manuscripts-letters/45" target="_blank" rel="noopener">notice et images</a>.
        </li>
        <li>
          <strong>Lettre au Major Nelson (fin mai 1897)</strong> — The New York Public Library :
          <a href="https://www.nypl.org/events/exhibitions/galleries/other-peoples-mail/item/14910" target="_blank" rel="noopener">notice</a>.
        </li>
        <li>
          <strong>Lettre à Henrietta Stannard (fin mai 1897)</strong> — Trinity College Dublin (Digital Collections) :
          <a href="https://digitalcollections.tcd.ie/concern/works/z316q211n?locale=en" target="_blank" rel="noopener">notice</a>.
        </li>
      </ul>

      <h3 class="ms-colTitle">Éditions et travaux de référence</h3>
      <ul class="home-sources">
        <li>
          <strong>Merlin Holland &amp; Rupert Hart-Davis</strong> (éd.), <em>The Complete Letters of Oscar Wilde</em>,
          Fourth Estate, 2000.
        </li>
        <li>
          <strong>Oscar Wilde</strong>, <em>The Soul of Man, and Prison Writings</em>,
          éd. <strong>Isobel Murray</strong>, Oxford University Press (Oxford World’s Classics), 1990.
        </li>
        <li>
          <strong>Oscar Wilde</strong>, <em>The Ballad of Reading Gaol</em>, 1898 (texte issu de l’expérience carcérale).
        </li>
        <li>
          <strong>Richard Ellmann</strong>, <em>Oscar Wilde</em>, Knopf, 1988 (biographie de référence).
        </li>
      </ul>
    </section>

  </xsl:template>


  <!-- ========================================================= -->
  <!-- PAGE LETTRE -->
  <!-- ========================================================= -->

  <!-- letter-page :
    - affiche le header de lettre (titre/date/desc + portrait si dispo)
    - affiche une zone manuscrit (carrousel)
    - affiche un panneau texte (tabs transcription/traduction si traduction existe)
    - ajoute une navigation prev/next en bas -->
  <xsl:template name="letter-page">
    <xsl:param name="meta"/>
    <xsl:param name="letterDiv"/>

    <!-- Je vérifie que le <div> TEI de la lettre a bien été trouvé
      Si $letterDiv est vide je montre un message d’erreur dans la page
      Sinon je construis normalement la page lettre -->
    <xsl:choose>
      <xsl:when test="empty($letterDiv)">
        <section class="card">
          <h1>Erreur</h1>
          <p>Lettre introuvable dans le corpus.</p>
        </section>
      </xsl:when>

      <xsl:otherwise>
        <section class="card letter-header">

          <!-- Portrait de la page lettre (que pour Lane et Stannard (images disponibles)
            Je fabrique d’abord un identifiant de personne ($pid),
            puis je regarde si une image existe dans $personPortraits -->
          <xsl:variable name="pid">
            <xsl:choose>
              <xsl:when test="string($meta/@key)='lane'">pers_lane</xsl:when>
              <xsl:when test="string($meta/@key)='stannard'">pers_stannard</xsl:when>
              <xsl:otherwise/>
            </xsl:choose>
          </xsl:variable>

          <!-- Recherche du fichier image correspondant -->
          <xsl:variable name="portraitFile" select="string($personPortraits/p[@id=$pid]/@file)"/>

          <h1 class="page-title">
            <xsl:value-of select="$meta/@title"/>
            <span class="muted"> — <xsl:value-of select="$meta/@date"/></span>
          </h1>

          <!-- Résumé éditorial de la lettre -->
          <p class="lead"><xsl:value-of select="$meta/@desc"/></p>

          <!-- J’affiche le portrait si un nom de fichier existe -->
          <xsl:if test="$portraitFile != ''">
            <img class="letter-portrait"
                 src="{$assetsBase}/img/persons/{$portraitFile}"
                 alt="Portrait"
                 loading="lazy"/>
          </xsl:if>
        </section>

        <!-- Grande zone en deux parties :
          - manuscrit à gauche / ou dans un panneau
          - texte à droite / ou dans un autre panneau -->
        <section class="ms-layout manuscript-layout">
          <aside class="card ms-panel viewer">
            <div class="ms-panel-head">
              <h2>Manuscrit</h2>
              <p class="muted ms-hint">Survole les zones pour afficher le texte reconnu.</p>
            </div>

            <!-- Carrousel d’images -->
            <xsl:call-template name="images-carousel">
              <xsl:with-param name="meta" select="$meta"/>
            </xsl:call-template>
          </aside>

          <article class="card ms-textPanel">

            <!-- Appel du panneau de texte : transcription + éventuellement traduction -->
            <xsl:call-template name="text-panel">
              <xsl:with-param name="meta" select="$meta"/>
              <xsl:with-param name="letterDiv" select="$letterDiv"/>
            </xsl:call-template>
          </article>
        </section>

        <!-- Navigation entre les lettres (dépend de la lettre courante) -->
        <nav class="letter-nav" aria-label="Navigation entre les lettres">
          <xsl:choose>
            <xsl:when test="string($meta/@key)='lane'">
              <span class="letter-nav-spacer"></span>
              <a class="letter-next" href="nelson.html">
                Lettre suivante → Nelson (mai 1897)
              </a>
            </xsl:when>

            <xsl:when test="string($meta/@key)='nelson'">
              <a class="letter-prev" href="lane.html">
                ← Lettre précédente : Lane (1894)
              </a>
              <a class="letter-next" href="stannard.html">
                Lettre suivante → Stannard (mai 1897)
              </a>
            </xsl:when>

            <xsl:when test="string($meta/@key)='stannard'">
              <a class="letter-prev" href="nelson.html">
                ← Lettre précédente : Nelson (mai 1897)
              </a>
              <span class="letter-nav-spacer"></span>
            </xsl:when>

            <xsl:otherwise>
              <span class="letter-nav-spacer"></span>
              <span class="letter-nav-spacer"></span>
            </xsl:otherwise>
          </xsl:choose>
        </nav>

      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- ========================================================= -->
  <!-- TEXTE + TRADUCTION (ONGLETS EN/FR) -->
  <!-- ========================================================= -->

  <!-- text-panel :
    - isole les nœuds de transcription (= tout sauf div[@type='translation'])
    - si traduction : affiche des onglets radio (EN/FR) -->
  <xsl:template name="text-panel">
    <xsl:param name="meta"/>
    <xsl:param name="letterDiv"/>

    <!-- transcriptionNodes : pour récupérer tout ce qui constitue la transcription 
      (contenu de $letterDiv SAUF le div de traduction)

      node() prend aussi les nœuds texte (espaces, retours) entre éléments et pas que les éléments
      [not(self::tei:div[@type='translation'])] (enlève seulement le bloc de traduction) -->
    <xsl:variable name="transcriptionNodes"
      select="$letterDiv/node()[not(self::tei:div[@type='translation'])]"/>

    <!-- translationDiv : cherche le premier div de traduction correspondant à cette lettre
      - root($letterDiv)//tei:div[@type='translation'] : cherche tous les div de traduction dans le document source
      - [tokenize(normalize-space(@corresp), '\s+') = concat('#', $letterDiv/@xml:id)] :
      garde celui qui renvoie à cette lettre précise via @corresp
      - [1] : si plusieurs blocs existent, je prends le premier -->
    <xsl:variable name="translationDiv"
  select="(root($letterDiv)//tei:div[@type='translation']
            [tokenize(normalize-space(@corresp), '\s+') = concat('#', $letterDiv/@xml:id)]
          )[1]"/>

    <header class="ms-textHead">
      <h2>Texte</h2>

      <!-- Le message d’aide n’apparaît que si une traduction existe -->
      <xsl:if test="exists($translationDiv)">
        <p class="muted ms-hint">Choisis l’affichage : Transcription (EN) ou Traduction (FR).</p>
      </xsl:if>
    </header>

    <xsl:choose>

      <!-- Cas 1 : il existe une traduction donc je construis un système d’onglets -->
      <xsl:when test="exists($translationDiv)">

        <!-- Je crée des identifiants uniques pour les boutons radio et labels,
        à partir de la clé de la lettre (lane, nelson, stannard). -->
        <xsl:variable name="tabName" select="concat('tabs-', string($meta/@key))"/>
        <xsl:variable name="idEn" select="concat('tab-en-', string($meta/@key))"/>
        <xsl:variable name="idFr" select="concat('tab-fr-', string($meta/@key))"/>

        <div class="tabs ms-tabs">
          <!-- Deux boutons radio :
            - EN par défaut
            - FR pour la traduction -->
          <input class="tab-input" type="radio" name="{$tabName}" id="{$idEn}" checked="checked"/>
          <input class="tab-input" type="radio" name="{$tabName}" id="{$idFr}"/>

          <!-- Barre d’onglets visible -->
          <div class="tab-bar">
            <label class="tab-btn" for="{$idEn}">Transcription (EN)</label>
            <label class="tab-btn" for="{$idFr}">Traduction (FR)</label>
          </div>

          <!-- Panneaux de contenu -->
          <div class="tab-panels">

            <!--  Onglet transcription -->
            <div class="tab-panel tab-panel--t">
              <section class="ms-col ms-col--transcription">
                <h3 class="ms-colTitle">Transcription</h3>
                <div class="tei-text">

                  <!-- On applique les templates TEI -> HTML au contenu de transcription -->
                  <xsl:apply-templates select="$transcriptionNodes"/>
                </div>
              </section>
            </div>

            <!-- Onglet traduction -->
            <div class="tab-panel tab-panel--fr">
              <section class="ms-col ms-col--translation">
                <h3 class="ms-colTitle">Traduction (FR)</h3>
                <div class="tei-text tei-text--translation">

                  <!-- On applique les templates au contenu de la traduction -->
                  <xsl:apply-templates select="$translationDiv/node()"/>
                </div>
              </section>
            </div>
          </div>
        </div>
      </xsl:when>

      <!-- Cas 2 : pas de traduction donc on affiche seulement la transcription -->
      <xsl:otherwise>
        <section class="ms-col ms-col--transcription">
          <h3 class="ms-colTitle">Transcription</h3>
          <div class="tei-text">
            <xsl:apply-templates select="$transcriptionNodes"/>
          </div>
        </section>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- ========================================================= -->
  <!-- VIEWER IMAGES : CARROUSEL ET THUMBS -->
  <!-- ========================================================= -->

  <!-- images-carousel :
    - tokenise @pages (“01 02a 02b …”)
    - construit une slide par page (img + svg overlay)
    - construit une rangée de miniatures (thumbs)

    Les overlays SVG sont initialisés côté JavaScript via l’attribut data-overlay="..." -->
  <xsl:template name="images-carousel">
    <xsl:param name="meta"/>

    <!-- Je découpe la chaîne @pages en une séquence de tokens
      "01 02a 02b 03" devient "01", "02a", "02b", "03" -->
    <xsl:variable name="pages" select="tokenize(normalize-space(string($meta/@pages)),'\s+')"/>

    <!-- data-carousel permet au JavaScript de savoir quel carrousel il manipule -->
    <div class="ms-carousel" data-carousel="{string($meta/@key)}">
      <div class="ms-stageWrap">
        <button class="ms-navBtn ms-prev" type="button" aria-label="Page précédente">‹</button>
        <button class="ms-navBtn ms-next" type="button" aria-label="Page suivante">›</button>

        <div class="ms-stage" role="region" aria-label="Visionneuse manuscrit">

          <!-- Pour chaque page manuscrite :
            - je crée une figure
            - j’ajoute l’image
            - j’ajoute un SVG vide qui recevra les zones interactives -->
          <xsl:for-each select="$pages">
            <xsl:variable name="tok" select="normalize-space(.)"/>

            <!-- Clé utilisée pour les overlays (lane_01, lane_02a) -->
            <xsl:variable name="key" select="concat($meta/@imgPrefix,$tok)"/>

            <figure class="fig ms-slide">
              <div class="ms-wrap" data-overlay="{$key}">
                <img src="{$assetsBase}/img/{concat($meta/@imgPrefix,$tok,'.jpg')}" alt="Fac-similé"/>
                <svg class="ms-svg" aria-hidden="true" xmlns="http://www.w3.org/2000/svg"></svg>
              </div>
              <figcaption class="caption">Page <xsl:value-of select="$tok"/></figcaption>
            </figure>
          </xsl:for-each>
        </div>
      </div>

      <!-- Rangée de miniatures permettant d’aller vite à une page donnée -->
      <div class="ms-thumbs" aria-label="Miniatures">
        <xsl:for-each select="$pages">
          <xsl:variable name="tok" select="normalize-space(.)"/>
          <button class="ms-thumb" type="button" data-slide="{position()-1}">
            <img src="{$assetsBase}/img/{concat($meta/@imgPrefix,$tok,'.jpg')}" alt="Miniature"/>
          </button>
        </xsl:for-each>
      </div>
    </div>
  </xsl:template>


  <!-- ========================================================= -->
  <!-- INDEX ENTITÉS -->
  <!-- ========================================================= -->

  <!-- entities-page :
    - affiche un sommaire (ancres)
    - 4 sections : personnes / lieux / organisations / œuvres
    - pour chaque entité : titre + note + liens "Cité.e dans : blabla"
    - quand une image existe dans les mappings (*Thumbs / Portraits), elle est affichée -->
  <xsl:template name="entities-page">

    <!-- ======= En-tête page index ======= -->
    <section class="card">
      <h1 class="page-title">Index des entités</h1>
      <p class="lead">Repères biographiques, lieux, organisations et œuvres cités dans les lettres.</p>
      <p class="index-toplinks">
        <a class="pill" href="#persons">Individus</a>
        <a class="pill" href="#places">Lieux</a>
        <a class="pill" href="#orgs">Organisations</a>
        <a class="pill" href="#works">Œuvres</a>
      </p>
    </section>

    <!-- ====================== -->
    <!-- PERSONNES -->
    <!-- ====================== -->
    <section class="card" id="persons">
      <h2>Individus</h2>

      <ul class="entity-list">
        <xsl:for-each select="//tei:listPerson/tei:person">

          <!-- Tri
            1) d’abord l’ordre éditorial défini dans f:person-rank()
            2) ensuite l’ordre alphabétique -->
          <xsl:sort select="f:person-rank(string(@xml:id))"
                    data-type="number" order="ascending"/>
          <xsl:sort select="lower-case(normalize-space(string-join(.//tei:persName[1]//text(),' ')))"/>

          <!-- Identifiant XML de la personne -->
          <xsl:variable name="pid" select="string(@xml:id)"/>

          <!-- Fichier portrait -->
          <xsl:variable name="portraitFile" select="string($personPortraits/p[@id=$pid]/@file)"/>

          <li class="entity-item entity-item--withPortrait" id="{$pid}">
            <xsl:choose>
              <xsl:when test="$portraitFile != ''">
                <img class="entity-portrait"
                     src="{$assetsBase}/img/persons/{$portraitFile}"
                     alt="Portrait"
                     loading="lazy"/>
              </xsl:when>
              <xsl:otherwise>

                <!-- Si pas d’image : placeholder vide -->
                <div class="entity-portrait entity-portrait--placeholder" aria-hidden="true"></div>
              </xsl:otherwise>
            </xsl:choose>

            <div class="entity-content">

              <!-- Nom affiché de la personne (premier persName) -->
              <div class="entity-title">
                <xsl:value-of select="normalize-space(string-join(.//tei:persName[1]//text(),' '))"/>
              </div>

              <!-- Petite notice et priorité à la note française si elle existe -->
              <p class="entity-note">
                <xsl:choose>
                  <xsl:when test="exists(.//tei:note[starts-with(@xml:lang,'fr')][1])">
                    <xsl:value-of select="normalize-space(string(.//tei:note[starts-with(@xml:lang,'fr')][1]))"/>
                  </xsl:when>
                  <xsl:when test="exists(.//tei:note[1])">
                    <xsl:value-of select="normalize-space(string(.//tei:note[1]))"/>
                  </xsl:when>
                  <xsl:otherwise/>
                </xsl:choose>
              </p>

              <!-- Liens “Cité.e dans : …”
                Je cherche toutes les occurrences de cette personne dans le texte :
                /tei:TEI/tei:text//tei:persName[@ref = concat('#',$pid)]
                si $pid = "pers_wilde" alors je cherche @ref = "#pers_wilde" -->
              <xsl:variable name="hits"
                select="/tei:TEI/tei:text//tei:persName[@ref = concat('#',$pid)]"/>

              <!-- On n’affiche la ligne “Cité.e dans : ...” que s’il existe au moins une occurrence -->
              <xsl:if test="exists($hits)">
                <p class="entity-note">
                  <strong>Cité.e dans :</strong><xsl:text> </xsl:text>

                  <xsl:for-each-group
                    select="$hits"
                    group-by="string((ancestor::tei:div[@type='letter'][1]/@xml:id)[1])">

                    <!-- Ici je groupe les occurrences par lettre (regroupement par xml:id de la lettre ancêtre) -->
                    <xsl:variable name="letterDivId" select="current-grouping-key()"/>

                    <!-- Nom du fichier HTML correspondant à cette lettre -->
                    <xsl:variable name="file" select="f:letter-file($letterDivId)"/>

                    <!-- Titre "humain" de cette lettre -->
                    <xsl:variable name="label" select="f:letter-title($letterDivId)"/>

                    <!-- Première occurrence de l’entité dans cette lettre pur reconstruire l’ancre vers la page de lettre -->
                    <xsl:variable name="firstHit" select="current-group()[1]"/>

                    <!-- occId : identifiant d’ancre calculé exactement comme dans la page lettre.
                    generate-id($firstHit) est calculé sur le même nœud source que dans le template de rendu des occurrences -->
                    <xsl:variable name="occId"
                      select="concat('occ-',$pid,'-',generate-id($firstHit))"/>

                    <!-- Si un fichier existe, je crée le lien -->
                    <xsl:if test="$file != ''">
                      <a class="entity-link" href="{concat($file,'#',$occId)}">
                        <xsl:value-of select="$label"/>
                      </a>

                      <!-- Séparateur entre plusieurs lettres -->
                      <xsl:if test="position() != last()">
                        <xsl:text> · </xsl:text>
                      </xsl:if>
                    </xsl:if>

                  </xsl:for-each-group>
                </p>
              </xsl:if>

            </div>
          </li>

        </xsl:for-each>
      </ul>
    </section>

    <!-- ====================== -->
    <!-- LIEUX (Pays / Villes) -->
    <!-- ====================== -->
    <section class="card" id="places">
      <h2>Lieux</h2>

      <!-- Première sous-partie : les pays -->
      <h3 class="ms-colTitle">Pays</h3>
      <ul class="entity-list">
        <xsl:for-each select="//tei:listPlace/tei:place[f:is-country-place(.)]">
          <xsl:sort select="lower-case(normalize-space(string((.//tei:placeName)[1])))"/>

          <xsl:variable name="plid" select="string(@xml:id)"/>
          <xsl:variable name="thumb" select="string($placeThumbs/p[@id=$plid]/@file)"/>

          <li class="entity-item entity-item--withPortrait" id="{$plid}">
            <xsl:choose>
              <xsl:when test="$thumb != ''">
                <img class="entity-portrait"
                     src="{$assetsBase}/img/persons/{$thumb}"
                     alt="Lieu"
                     loading="lazy"/>
              </xsl:when>
              <xsl:otherwise>
                <div class="entity-portrait entity-portrait--placeholder" aria-hidden="true"></div>
              </xsl:otherwise>
            </xsl:choose>

            <div class="entity-content">
              <div class="entity-title">
                <xsl:value-of select="normalize-space(string((.//tei:placeName)[1]))"/>
              </div>

              <p class="entity-note">
                <xsl:choose>
                  <xsl:when test="exists(.//tei:note[starts-with(@xml:lang,'fr')][1])">
                    <xsl:value-of select="normalize-space(string(.//tei:note[starts-with(@xml:lang,'fr')][1]))"/>
                  </xsl:when>
                  <xsl:when test="exists(.//tei:note[1])">
                    <xsl:value-of select="normalize-space(string(.//tei:note[1]))"/>
                  </xsl:when>
                  <xsl:otherwise/>
                </xsl:choose>
              </p>

              <!-- Toutes les occurrences de ce lieu dans le texte -->
              <xsl:variable name="hits"
                select="/tei:TEI/tei:text//tei:placeName[@ref = concat('#',$plid)]"/>

              <xsl:if test="exists($hits)">
                <p class="entity-note">
                  <strong>Cité.e dans :</strong><xsl:text> </xsl:text>

                  <xsl:for-each-group
                    select="$hits"
                    group-by="string((ancestor::tei:div[@type='letter'][1]/@xml:id)[1])">

                    <xsl:variable name="letterDivId" select="current-grouping-key()"/>
                    <xsl:variable name="file" select="f:letter-file($letterDivId)"/>
                    <xsl:variable name="label" select="f:letter-title($letterDivId)"/>
                    <xsl:variable name="firstHit" select="current-group()[1]"/>

                    <!-- Reconstruction de l’ancre vers la première occurrence -->
                    <xsl:variable name="occId"
                      select="concat('occ-',$plid,'-',generate-id($firstHit))"/>

                    <xsl:if test="$file != ''">
                      <a class="entity-link" href="{concat($file,'#',$occId)}">
                        <xsl:value-of select="$label"/>
                      </a>
                      <xsl:if test="position() != last()">
                        <xsl:text> · </xsl:text>
                      </xsl:if>
                    </xsl:if>

                  </xsl:for-each-group>
                </p>
              </xsl:if>

            </div>
          </li>

        </xsl:for-each>
      </ul>

      <!-- Deuxième sous-partie : villes et autres lieux -->
      <h3 class="ms-colTitle">Villes et lieux</h3>
      <ul class="entity-list">
        <xsl:for-each select="//tei:listPlace/tei:place[not(f:is-country-place(.))]">
          <xsl:sort select="lower-case(normalize-space(string((.//tei:placeName)[1])))"/>

          <xsl:variable name="plid" select="string(@xml:id)"/>
          <xsl:variable name="thumb" select="string($placeThumbs/p[@id=$plid]/@file)"/>

          <li class="entity-item entity-item--withPortrait" id="{$plid}">
            <xsl:choose>
              <xsl:when test="$thumb != ''">
                <img class="entity-portrait"
                     src="{$assetsBase}/img/persons/{$thumb}"
                     alt="Lieu"
                     loading="lazy"/>
              </xsl:when>
              <xsl:otherwise>
                <div class="entity-portrait entity-portrait--placeholder" aria-hidden="true"></div>
              </xsl:otherwise>
            </xsl:choose>

            <div class="entity-content">
              <div class="entity-title">
                <xsl:value-of select="normalize-space(string((.//tei:placeName)[1]))"/>
              </div>

              <p class="entity-note">
                <xsl:choose>
                  <xsl:when test="exists(.//tei:note[starts-with(@xml:lang,'fr')][1])">
                    <xsl:value-of select="normalize-space(string(.//tei:note[starts-with(@xml:lang,'fr')][1]))"/>
                  </xsl:when>
                  <xsl:when test="exists(.//tei:note[1])">
                    <xsl:value-of select="normalize-space(string(.//tei:note[1]))"/>
                  </xsl:when>
                  <xsl:otherwise/>
                </xsl:choose>
              </p>

              <xsl:variable name="hits"
                select="/tei:TEI/tei:text//tei:placeName[@ref = concat('#',$plid)]"/>

              <xsl:if test="exists($hits)">
                <p class="entity-note">
                  <strong>Cité.e dans :</strong><xsl:text> </xsl:text>

                  <xsl:for-each-group
                    select="$hits"
                    group-by="string((ancestor::tei:div[@type='letter'][1]/@xml:id)[1])">

                    <xsl:variable name="letterDivId" select="current-grouping-key()"/>
                    <xsl:variable name="file" select="f:letter-file($letterDivId)"/>
                    <xsl:variable name="label" select="f:letter-title($letterDivId)"/>
                    <xsl:variable name="firstHit" select="current-group()[1]"/>

                    <xsl:variable name="occId"
                      select="concat('occ-',$plid,'-',generate-id($firstHit))"/>

                    <xsl:if test="$file != ''">
                      <a class="entity-link" href="{concat($file,'#',$occId)}">
                        <xsl:value-of select="$label"/>
                      </a>
                      <xsl:if test="position() != last()">
                        <xsl:text> · </xsl:text>
                      </xsl:if>
                    </xsl:if>

                  </xsl:for-each-group>
                </p>
              </xsl:if>

            </div>
          </li>

        </xsl:for-each>
      </ul>
    </section>

    <!-- ====================== -->
    <!-- ORGANISATIONS -->
    <!-- ====================== -->
    <section class="card" id="orgs">
      <h2>Organisations</h2>

      <ul class="entity-list">
        <xsl:for-each select="//tei:listOrg/tei:org">
          <xsl:sort select="lower-case(normalize-space(string((.//tei:orgName)[1])))"/>

          <xsl:variable name="oid" select="string(@xml:id)"/>
          <xsl:variable name="thumb" select="string($orgThumbs/p[@id=$oid]/@file)"/>

          <li class="entity-item entity-item--withPortrait" id="{$oid}">
            <xsl:choose>
              <xsl:when test="$thumb != ''">
                <img class="entity-portrait"
                     src="{$assetsBase}/img/persons/{$thumb}"
                     alt="Organisation"
                     loading="lazy"/>
              </xsl:when>
              <xsl:otherwise>
                <div class="entity-portrait entity-portrait--placeholder" aria-hidden="true"></div>
              </xsl:otherwise>
            </xsl:choose>

            <div class="entity-content">
              <div class="entity-title">
                <xsl:value-of select="normalize-space(string((.//tei:orgName)[1]))"/>
              </div>

              <p class="entity-note">
                <xsl:choose>
                  <xsl:when test="exists(.//tei:note[starts-with(@xml:lang,'fr')][1])">
                    <xsl:value-of select="normalize-space(string(.//tei:note[starts-with(@xml:lang,'fr')][1]))"/>
                  </xsl:when>
                  <xsl:when test="exists(.//tei:note[1])">
                    <xsl:value-of select="normalize-space(string(.//tei:note[1]))"/>
                  </xsl:when>
                  <xsl:otherwise/>
                </xsl:choose>
              </p>

              <xsl:variable name="hits"
                select="/tei:TEI/tei:text//tei:orgName[@ref = concat('#',$oid)]"/>

              <xsl:if test="exists($hits)">
                <p class="entity-note">
                  <strong>Cité.e dans :</strong><xsl:text> </xsl:text>

                  <xsl:for-each-group
                    select="$hits"
                    group-by="string((ancestor::tei:div[@type='letter'][1]/@xml:id)[1])">

                    <xsl:variable name="letterDivId" select="current-grouping-key()"/>
                    <xsl:variable name="file" select="f:letter-file($letterDivId)"/>
                    <xsl:variable name="label" select="f:letter-title($letterDivId)"/>
                    <xsl:variable name="firstHit" select="current-group()[1]"/>

                    <xsl:variable name="occId"
                      select="concat('occ-',$oid,'-',generate-id($firstHit))"/>

                    <xsl:if test="$file != ''">
                      <a class="entity-link" href="{concat($file,'#',$occId)}">
                        <xsl:value-of select="$label"/>
                      </a>
                      <xsl:if test="position() != last()">
                        <xsl:text> · </xsl:text>
                      </xsl:if>
                    </xsl:if>

                  </xsl:for-each-group>
                </p>
              </xsl:if>

            </div>
          </li>

        </xsl:for-each>
      </ul>
    </section>

    <!-- ====================== -->
    <!-- ŒUVRES -->
    <!-- ====================== -->
    <section class="card" id="works">
      <h2>Œuvres</h2>

      <ul class="entity-list">
        <xsl:for-each select="//tei:listBibl/tei:bibl">

          <!-- Tri : priorité au titre anglais si disponible -->
          <xsl:sort select="lower-case(normalize-space(string((.//tei:title[@xml:lang='en'])[1])))"/>
          <xsl:sort select="lower-case(normalize-space(string((.//tei:title)[1])))"/>

          <xsl:variable name="wid" select="string(@xml:id)"/>
          <xsl:variable name="thumb" select="string($workThumbs/p[@id=$wid]/@file)"/>

          <li class="entity-item entity-item--withPortrait" id="{$wid}">
            <xsl:choose>
              <xsl:when test="$thumb != ''">
                <img class="entity-portrait"
                     src="{$assetsBase}/img/persons/{$thumb}"
                     alt="Œuvre"
                     loading="lazy"/>
              </xsl:when>
              <xsl:otherwise>
                <div class="entity-portrait entity-portrait--placeholder" aria-hidden="true"></div>
              </xsl:otherwise>
            </xsl:choose>

            <div class="entity-content">

              <div class="entity-title">
                <xsl:choose>
                  <xsl:when test="exists(.//tei:title[@xml:lang='en'][1])">
                    <xsl:value-of select="normalize-space(string((.//tei:title[@xml:lang='en'])[1]))"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="normalize-space(string((.//tei:title)[1]))"/>
                  </xsl:otherwise>
                </xsl:choose>
              </div>

              <p class="entity-note">
                <xsl:choose>
                  <xsl:when test="exists(.//tei:note[starts-with(@xml:lang,'fr')][1])">
                    <xsl:value-of select="normalize-space(string(.//tei:note[starts-with(@xml:lang,'fr')][1]))"/>
                  </xsl:when>
                  <xsl:when test="exists(.//tei:note[1])">
                    <xsl:value-of select="normalize-space(string(.//tei:note[1]))"/>
                  </xsl:when>
                  <xsl:otherwise/>
                </xsl:choose>
              </p>

              <!-- Toutes les occurrences de cette œuvre dans le texte -->
              <xsl:variable name="hits"
                select="/tei:TEI/tei:text//tei:title[@ref = concat('#',$wid)]"/>

              <xsl:if test="exists($hits)">
                <p class="entity-note">
                  <strong>Cité.e dans :</strong><xsl:text> </xsl:text>

                  <xsl:for-each-group
                    select="$hits"
                    group-by="string((ancestor::tei:div[@type='letter'][1]/@xml:id)[1])">

                    <xsl:variable name="letterDivId" select="current-grouping-key()"/>
                    <xsl:variable name="file" select="f:letter-file($letterDivId)"/>
                    <xsl:variable name="label" select="f:letter-title($letterDivId)"/>
                    <xsl:variable name="firstHit" select="current-group()[1]"/>

                    <xsl:variable name="occId"
                      select="concat('occ-',$wid,'-',generate-id($firstHit))"/>

                    <xsl:if test="$file != ''">
                      <a class="entity-link" href="{concat($file,'#',$occId)}">
                        <xsl:value-of select="$label"/>
                      </a>
                      <xsl:if test="position() != last()">
                        <xsl:text> · </xsl:text>
                      </xsl:if>
                    </xsl:if>

                  </xsl:for-each-group>
                </p>
              </xsl:if>

            </div>
          </li>

        </xsl:for-each>
      </ul>
    </section>

  </xsl:template>

<!-- ========================================================= -->
<!-- MÉTHODOLOGIE -->
<!-- ========================================================= -->

<!-- methodologie-page :
  - page statique en HTML pur (dans le shell)
  - intro + navigation interne + sections -->
<xsl:template name="methodologie-page">

  <section class="card">

    <h1 class="page-title">Méthodologie</h1>

    <p>
      Cette édition numérique a été réalisée intégralement par <strong>Clara Martin</strong>, étudiante en M2
      « Technologies numériques appliquées à l’histoire » à l’École nationale des chartes – PSL.
      Le travail comprend l’encodage TEI-XML du corpus, la structuration des entités nommées,
      l’intégration des fac-similés et la génération des pages HTML à l’aide d’une feuille
      de transformation XSLT multipages. La mise en forme typographique (CSS) et les
      fonctionnalités interactives (JavaScript) ont également été développées pour ce site.
    </p>

    <p>
      Le projet cherche à concilier deux approches complémentaires : une lecture accessible,
      grâce à des pages structurées et une navigation claire, et une lecture documentaire
      permettant de revenir au manuscrit grâce aux fac-similés, aux repères éditoriaux
      et à un index d’entités nommées.
    </p>

    <!-- Navigation interne à la page Méthodologie (ancres HTML) -->
    <nav class="method-tabs" aria-label="Sommaire méthodologie">
      <a class="pill" href="#meth-corpus">Corpus</a>
      <a class="pill" href="#meth-tei">Encodage TEI</a>
      <a class="pill" href="#meth-xslt">Transformation XSLT</a>
      <a class="pill" href="#meth-ui">Interface (HTML/CSS/JS)</a>
      <a class="pill" href="#meth-sources">Sources</a>
    </nav>

  </section>


  <section class="card" id="meth-corpus">

    <h2>1) Corpus et constitution des données</h2>

    <p>
      Le corpus réunit trois lettres d’Oscar Wilde rédigées entre 1894 et 1897 et
      conservées dans des institutions patrimoniales. Les fac-similés ont été
      intégrés au site et associés aux transcriptions correspondantes afin de
      permettre une lecture parallèle du manuscrit et du texte encodé.
    </p>

    <p>
      La lettre adressée à Henrietta Stannard (fin mai 1897) a fait l’objet d’une
      transcription diplomatique réalisée à partir du manuscrit conservé au
      Trinity College Dublin. Cette transcription a ensuite été encodée en
      TEI-XML afin de permettre la génération automatique des pages,
      l’indexation des entités nommées et la navigation interne au sein du site.
    </p>

  </section>


  <section class="card" id="meth-tei">

    <h2>2) Encodage TEI-XML</h2>

    <p>
      Le corpus est encodé selon les recommandations de la
      <em>Text Encoding Initiative (TEI)</em>, standard international utilisé
      dans les humanités numériques pour représenter des textes de manière
      structurée et interopérable.
    </p>

    <p>
      L’encodage distingue les différentes composantes d’une lettre
      (ouverture, paragraphes, clôture, signatures) et prend en compte
      plusieurs phénomènes textuels utiles à l’édition critique :
      mots étrangers, soulignements, abréviations développées,
      ajouts ou interventions éditoriales.
      Cette structuration garantit une transformation fiable vers le web
      tout en conservant les informations textuelles du document original.
    </p>

    <p>
      Les entités nommées (personnes, lieux, organisations et œuvres)
      sont balisées dans le texte et reliées à des listes d’autorité
      (<code>listPerson</code>, <code>listPlace</code>, <code>listOrg</code>,
      <code>listBibl</code>). Cette organisation permet de générer
      automatiquement un index et d’établir des liens entre les occurrences
      du texte et leurs notices explicatives.
    </p>

  </section>


  <section class="card" id="meth-xslt">

    <h2>3) Transformation XSLT (génération multipages)</h2>

    <p>
      Une feuille de transformation XSLT (version 2.0) convertit le document
      TEI-XML en un site HTML multipages. La génération des différentes pages
      repose sur l’instruction <code>xsl:result-document</code>, qui permet
      de produire plusieurs fichiers HTML à partir d’une seule source XML.
    </p>

    <p>
      La transformation génère notamment :
    </p>

    <ul>
      <li>une page d’accueil présentant le corpus ;</li>
      <li>une page dédiée à chacune des lettres ;</li>
      <li>une page d’index des entités nommées ;</li>
      <li>les pages éditoriales (méthodologie et mentions légales).</li>
    </ul>

    <p>
      Les transformations utilisent XPath pour sélectionner les différentes
      parties du corpus et convertir les éléments TEI en HTML.
      Les occurrences d’entités nommées sont automatiquement reliées
      à leurs notices dans l’index.
    </p>

  </section>


  <section class="card" id="meth-ui">

    <h2>4) Interface (HTML / CSS / JavaScript)</h2>

    <p>
      Les pages générées reposent sur une structure HTML sémantique
      (titres, sections, listes). La mise en page est assurée par une
      feuille CSS dédiée qui définit la typographie, la grille de lecture,
      l’adaptation aux différents écrans et un mode nuit.
    </p>

    <p>
      Le JavaScript ajoute plusieurs fonctionnalités : activation d’un mode
      nuit mémorisé, navigation entre les pages manuscrites par carrousel,
      zoom des images et recherche dynamique dans l’index des entités.
    </p>

    <p>
      Les fac-similés sont enrichis par des zones interactives superposées
      aux images. Au survol, le texte correspondant apparaît afin de faciliter
      la lecture du manuscrit. Les zones de texte ont été délimitées et
      renseignées dans l’interface de transcription <strong>Transkribus</strong>,
      où les rectangles correspondant aux lignes manuscrites ont été tracés
      et le texte saisi manuellement. Les données ont ensuite été exportées
      au format PageXML, converties en fichiers JSON, puis affichées sur le
      site sous forme de calque SVG généré par le script JavaScript.
</p>

  </section>


  <section class="card" id="meth-sources">

    <h2>Sources</h2>

    <h3 class="ms-colTitle">Fac-similés (institutions)</h3>

    <ul>
      <li>
        <strong>Lettre à John Lane (août 1894)</strong> —
        The Morgan Library &amp; Museum
      </li>

      <li>
        <strong>Lettre au Major Nelson (fin mai 1897)</strong> —
        The New York Public Library
      </li>

      <li>
        <strong>Lettre à Henrietta Stannard (fin mai 1897)</strong> —
        Trinity College Dublin (Digital Collections)
      </li>
    </ul>

    <h3 class="ms-colTitle">Éditions de référence</h3>

    <ul>
      <li>
        Merlin Holland &amp; Rupert Hart-Davis (éd.),
        <em>The Complete Letters of Oscar Wilde</em>,
        Fourth Estate, 2000.
      </li>

      <li>
        Oscar Wilde,
        <em>The Soul of Man, and Prison Writings</em>,
        éd. Isobel Murray,
        Oxford University Press, 1990.
      </li>

      <li>
        Richard Ellmann,
        <em>Oscar Wilde</em>,
        Knopf, 1988.
      </li>
    </ul>

  </section>

</xsl:template>

  <!-- ========================================================= -->
  <!-- TEI -> HTML (rendu des éléments TEI dans le panneau texte) -->
  <!-- ========================================================= -->

  <!-- Je définis les templates de transformation des balises TEI en HTML.
    - chaque élément TEI important reçoit un rendu HTML
    - certaines entités deviennent des liens vers l’index
    - certains éléments sont juste enveloppés dans une balise HTML utile -->

  <!-- fw = front matter / here used as letterhead (je rends l’en-tête de lettre dans un bloc HTML dédié) -->
  <xsl:template match="tei:fw[@type='letterhead']">
    <div class="tei-note letterhead">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- Paragraphe TEI -> paragraphe HTML
    Si le paragraphe possède un attribut d’indentation, j’ajoute une classe CSS "indent" -->
  <xsl:template match="tei:p">
    <p>
      <xsl:if test="@rend='indentation' or @type='indentation'">
        <xsl:attribute name="class">indent</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <!-- tei:lb = line break
    - dans l’en-tête ou l’ouverture : je garde la ligne
    - dans le texte courant : je mets souvent juste un espace -->
  <xsl:template match="tei:lb">

    <!-- lb = line break en TEI
      J'ai choisi de conserver le <br/> uniquement dans les zones
      où la mise en forme en lignes a un sens éditorial (letterhead / opener) -->

    <xsl:choose>

      <!-- Cas 1 : deux lb consécutifs -> je n’ajoute rien (sinon redondance) -->
      <xsl:when test="following-sibling::*[1][self::tei:lb]">
        <xsl:text></xsl:text>
      </xsl:when>
 
      <!-- Cas 2 : dans un letterhead -> vrai <br/> -->
      <xsl:when test="ancestor::tei:fw[@type='letterhead']">
        <br/>
      </xsl:when>

      <!-- Cas 3 : dans une note de type letterhead -> vrai <br/> -->
      <xsl:when test="ancestor::tei:note[@type='letterhead']">
        <br/>
      </xsl:when>

      <!-- Cas 4 : dans l’opener -> vrai <br/> -->
      <xsl:when test="ancestor::tei:opener">
        <br/>
      </xsl:when>

      <!-- Cas 5 : dans le closer -> je préfère un espace (pour éviter des coupures trop dures en HTML) -->
      <xsl:when test="ancestor::tei:closer">
        <xsl:text> </xsl:text>
      </xsl:when>

      <!-- Cas par défaut : -> espace simple -->
      <xsl:otherwise>
        <xsl:text> </xsl:text>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:template>

  <!-- Soulignement TEI -> span avec classe CSS "u" -->
  <xsl:template match="tei:hi[@rend='underline']">
    <span class="u"><xsl:apply-templates/></span>
  </xsl:template>

  <!-- Mot étranger -->
  <xsl:template match="tei:foreign">
    <span class="foreign"><xsl:apply-templates/></span>
  </xsl:template>

  <!-- supplied = ajout éditorial -->
  <xsl:template match="tei:supplied">
    <span class="supplied"><xsl:apply-templates/></span>
  </xsl:template>

  <!-- term = terme mis à part -->
  <xsl:template match="tei:term">
    <span class="term"><xsl:apply-templates/></span>
  </xsl:template>

  <!-- pc = ponctuation balisée -->
  <xsl:template match="tei:pc">
    <span class="pc"><xsl:apply-templates/></span>
  </xsl:template>

  <!-- note de type letterhead -->
  <xsl:template match="tei:note[@type='letterhead']">
    <div class="tei-note letterhead">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- note générique -->
  <xsl:template match="tei:note">
    <div class="tei-note">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- opener et closer (je les rends dans un bloc HTML générique) -->
  <xsl:template match="tei:opener|tei:closer">
    <div class="tei-block">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- Salutation -->
  <xsl:template match="tei:salute">
    <p class="tei-salute"><xsl:apply-templates/></p>
  </xsl:template>

  <!-- Signature -->
  <xsl:template match="tei:signed">
    <p class="tei-signed"><xsl:apply-templates/></p>
  </xsl:template>

  <!-- seg : je ne crée pas de balise spéciale mais je laisse juste passer le contenu -->
  <xsl:template match="tei:seg">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- addName : nom ajouté/mention ajoutée -->
  <xsl:template match="tei:addName">
    <span class="addName"><xsl:apply-templates/></span>
  </xsl:template>

  <!-- date : une balise HTML <time> et si @when existe, je le mets dans l’attribut datetime -->
  <xsl:template match="tei:date">
    <time>
      <xsl:if test="@when">
        <xsl:attribute name="datetime"><xsl:value-of select="@when"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </time>
  </xsl:template>

  <!-- choice :
    je préfère afficher :
    - expan si elle existe
    - sinon reg si elle existe
    - sinon le contenu brut -->
  <xsl:template match="tei:choice">
    <xsl:choose>
      <xsl:when test="tei:expan">
        <xsl:apply-templates select="tei:expan/node()"/>
      </xsl:when>
      <xsl:when test="tei:reg">
        <xsl:apply-templates select="tei:reg/node()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- ====== ENTITÉS (liens vers index) ====== -->

  <!-- si un titre possède @ref="#quelquechose" alors il devient un lien vers : index-entities.html#quelquechose
    Et j’ajoute un id d’ancre local sur l’occurrence pour que l’index puisse renvoyer précisément vers cette occurrence -->

  <!-- Œuvres : lien vers l’index si @ref -->
  <xsl:template match="tei:title[@ref]">

    <xsl:variable name="t" select="string(@ref)"/>
    <xsl:variable name="id" select="substring-after($t,'#')"/>

    <!-- identifiant unique pour créer un lien direct vers cette occurrence -->
    <xsl:variable name="occId" select="concat('occ-',$id,'-',generate-id(.))"/>

    <xsl:choose>

      <!-- si la référence est interne (#work_...) -->
      <xsl:when test="starts-with($t,'#')">
        <a class="entity-link" id="{$occId}" href="{concat('index-entities.html',$t)}">
          <em><xsl:apply-templates/></em>
        </a>
      </xsl:when>

      <!-- sinon simple italique -->
      <xsl:otherwise>
        <em><xsl:apply-templates/></em>
      </xsl:otherwise>

    </xsl:choose>

  </xsl:template>

  <!-- Œuvres sans référence : italique simple -->
  <xsl:template match="tei:title[@type='work' and not(@ref)]">
    <em><xsl:apply-templates/></em>
  </xsl:template>

  <!-- persName avec @ref : je transforme l’occurrence en lien vers l’index
  si @ref est une référence interne (commence par #) -->
  <xsl:template match="tei:persName[@ref]">

    <!-- @ref contient normalement une référence interne TEI du type "#pers_wilde"
      Je la stocke dans $t -->
    <xsl:variable name="t" select="string(@ref)"/>

    <!-- Je récupère la partie après le '#': "#pers_wilde" -> "pers_wilde" -->
    <xsl:variable name="id" select="substring-after($t,'#')"/>

    <!-- occId : identifiant HTML placé sur l’occurrence dans la page lettre -->
    <xsl:variable name="occId" select="concat('occ-',$id,'-',generate-id(.))"/>

    <xsl:choose>
      <xsl:when test="starts-with($t,'#')">
        <a class="entity-link" id="{$occId}" href="{concat('index-entities.html',$t)}">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span class="entity"><xsl:apply-templates/></span>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- placeName avec @ref : pareil que pour les personnes -->
  <xsl:template match="tei:placeName[@ref]">
    <xsl:variable name="t" select="string(@ref)"/>
    <xsl:variable name="id" select="substring-after($t,'#')"/>
    <xsl:variable name="occId" select="concat('occ-',$id,'-',generate-id(.))"/>

    <xsl:choose>
      <xsl:when test="starts-with($t,'#')">
        <a class="entity-link" id="{$occId}" href="{concat('index-entities.html',$t)}">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span class="entity"><xsl:apply-templates/></span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- orgName avec @ref : pareil -->
  <xsl:template match="tei:orgName[@ref]">
    <xsl:variable name="t" select="string(@ref)"/>
    <xsl:variable name="id" select="substring-after($t,'#')"/>
    <xsl:variable name="occId" select="concat('occ-',$id,'-',generate-id(.))"/>

    <xsl:choose>
      <xsl:when test="starts-with($t,'#')">
        <a class="entity-link" id="{$occId}" href="{concat('index-entities.html',$t)}">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span class="entity"><xsl:apply-templates/></span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ref avec @target :
    - si la cible commence par # -> lien vers l’index
    - sinon -> lien externe ou autre lien direct -->
  <xsl:template match="tei:ref[@target]">
    <xsl:variable name="t" select="string(@target)"/>
    <xsl:choose>
      <xsl:when test="starts-with($t,'#')">
        <a class="entity-link" href="{concat('index-entities.html',$t)}">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <a class="entity-link" href="{$t}">
          <xsl:apply-templates/>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Fallback pour les entités sans @ref : elles ne deviennent pas des liens, mais restent stylées comme entités. -->
  <xsl:template match="tei:persName|tei:placeName|tei:orgName">
    <span class="entity"><xsl:apply-templates/></span>
  </xsl:template>

  <!-- div TEI : par défaut je ne crée pas de wrapper HTML spécial ici, je laisse juste descendre vers les enfants. -->
  <xsl:template match="tei:div">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Texte brut : copie telle quelle -->
  <xsl:template match="text()">
    <xsl:value-of select="."/>
  </xsl:template>

</xsl:stylesheet>
