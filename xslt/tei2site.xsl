<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:f="urn:local:functions"
  exclude-result-prefixes="tei xs f">

  <!--
    Je produis du XHTML (et pas du HTML “loose”) pour :
    - garantir une sérialisation stable (balises toujours bien fermées)
    - éviter les surprises avec SVG (overlays de zones)
    - garder un rendu propre et reproductible
  -->
  <xsl:output method="xhtml" encoding="UTF-8" indent="yes"/>

  <!-- ========================================================= -->
  <!-- PARAMÈTRES (config du build) -->
  <!-- ========================================================= -->

  <!-- Dossier de sortie (où seront écrits index.html, lane.html, etc.) -->
  <xsl:param name="outDir" select="'docs/'"/>

  <!-- Chemin vers les assets (css/js/img) relatif aux pages générées -->
  <xsl:param name="assetsBase" select="'assets'"/>

  <!-- Identité du site -->
  <xsl:variable name="siteTitle" select="'OSCAR WILDE'"/>
  <xsl:variable name="siteSubtitle" select="'LETTRES AUTOUR DE LA PRISON (1894–1897)'"/>

  <!-- ========================================================= -->
  <!-- MÉTADONNÉES DES LETTRES (source “editoriale” interne) -->
  <!-- ========================================================= -->
  <!--
    Je centralise ici les métadonnées des lettres :
    - ça évite la duplication
    - ça permet la génération multipages automatique
    - ça alimente la chronologie de l’accueil
    - ça contrôle la pagination des fac-similés (carrousel)
  -->
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
  <!--
    J’associe des identifiants (xml:id des entités TEI) à des fichiers images.
    Ces mappings servent uniquement à l’affichage dans l’index (et portrait sur certaines lettres).
  -->

  <!-- Personnes (assets/img/persons/) -->
  <xsl:variable name="personPortraits">
    <p id="pers_wilde"    file="oscarwilde.jpeg" />
    <p id="pers_lane"     file="johnlane.jpeg" />
    <p id="pers_stannard" file="henriettastannard.jpeg" />
    <p id="pers_ross"     file="robertross.jpeg" />
    <p id="pers_constance_wilde" file="constancewilde.jpeg" />
    <p id="pers_ricketts" file="charlesricketts.jpeg" />
    <p id="pers_jane_wilde" file="janewilde.jpeg" />
    <!-- pas d’image pour pers_nelson et pers_mathews -->
  </xsl:variable>

  <!-- Lieux (assets/img/persons/ aussi, selon l’arborescence du projet) -->
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

  <!-- Organisations -->
  <xsl:variable name="orgThumbs">
    <p id="org_bodley_head" file="bodleyhead.jpeg"/>
  </xsl:variable>

  <!-- Œuvres (et quelques références bibliographiques) -->
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
  <!--
    Fonctions “lookup” pour retrouver rapidement :
    - le fichier HTML d’une lettre (lane.html, etc.)
    - le titre humain de la lettre
    Elles servent dans l’index pour construire “Cité.e dans : …”.
  -->
  <xsl:function name="f:letter-file" as="xs:string?">
    <xsl:param name="divId" as="xs:string?"/>
    <xsl:sequence select="string(($letters/letter[@divId=$divId]/@file)[1])"/>
  </xsl:function>

  <xsl:function name="f:letter-title" as="xs:string?">
    <xsl:param name="divId" as="xs:string?"/>
    <xsl:sequence select="string(($letters/letter[@divId=$divId]/@title)[1])"/>
  </xsl:function>

  <!--
    Ordre d’importance “éditorial” des personnes.
    Objectif : l’index commence par les figures centrales (Wilde, Lane, etc.)
    plutôt qu’un simple ordre alphabétique.
  -->
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

  <!--
    Je distingue les “pays” des “villes/lieux” pour afficher l’index des lieux en 2 sections.
    Heuristique :
    - absence de settlement = potentiellement pays
    - nom matche une liste de pays pertinents
  -->
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
  <!--
    C’est ici que je “pilote” la génération multipages :
    - je prends la racine TEI en contexte
    - j’écris plusieurs fichiers via xsl:result-document
    - puis je laisse les templates internes fabriquer le contenu
  -->
  <xsl:template match="/tei:TEI">
    <xsl:variable name="root" select="."/>

    <!-- ================= ACCUEIL ================= -->
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
    <!--
      Pour chaque entrée de $letters :
      - je récupère le <div> TEI correspondant via @xml:id
      - je génère une page HTML dédiée
    -->
    <xsl:for-each select="$letters/letter">
      <xsl:variable name="meta" select="."/>
      <xsl:variable name="letterDiv"
        select="$root/tei:text/tei:body/tei:div[@xml:id = $meta/@divId][1]"/>

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
    <xsl:result-document href="{concat($outDir,'mentions-legales.html')}">
      <xsl:call-template name="page-shell">
        <xsl:with-param name="pageTitle" select="'Mentions légales'"/>
        <xsl:with-param name="pageClass" select="'page-legal'"/>
        <xsl:with-param name="content">

          <!--
            Contenu HTML “pur” injecté dans le shell :
            je garde ce bloc entièrement “page-level” (section card)
            pour qu’il n’ait pas besoin d’un template dédié.
          -->
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
  <!--
    page-shell :
    - écrit le HTML complet (head + header/nav + footer)
    - reçoit un fragment “content” en paramètre, inséré dans <main>
    Objectif : éviter de réécrire 10 fois le header/footer.
  -->
  <xsl:template name="page-shell">
    <xsl:param name="pageTitle"/>
    <xsl:param name="content"/>
    <xsl:param name="pageClass" select="''"/>

    <html lang="fr" xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <meta charset="utf-8"/>
        <title><xsl:value-of select="$siteTitle"/> — <xsl:value-of select="$pageTitle"/></title>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>

        <!-- Open Graph : aperçu quand on partage le lien -->
        <meta property="og:title" content="Oscar Wilde — Lettres autour de la prison (1894–1897)"/>
        <meta property="og:description" content="Édition numérique TEI des lettres d’Oscar Wilde autour de son emprisonnement."/>
        <meta property="og:image" content="https://cmartinarchives.github.io/oscar-wilde-et-la-prison/assets/img/social-preview.png"/>
        <meta property="og:image:width" content="1200"/>
        <meta property="og:image:height" content="630"/>
        <meta property="og:type" content="website"/>
        <meta property="og:url" content="https://cmartinarchives.github.io/oscar-wilde-et-la-prison/"/>

        <!-- Twitter / X preview -->
        <meta name="twitter:card" content="summary_large_image"/>
        <meta name="twitter:title" content="Oscar Wilde — Lettres autour de la prison (1894–1897)"/>
        <meta name="twitter:description" content="Édition numérique TEI des lettres d’Oscar Wilde autour de son emprisonnement."/>
        <meta name="twitter:image" content="https://cmartinarchives.github.io/oscar-wilde-et-la-prison/assets/img/social-preview.png"/>

        <!-- favicon -->
        <link rel="icon" type="image/png" sizes="32x32" href="{$assetsBase}/img/favicon32.png"/>

        <link rel="stylesheet" href="{$assetsBase}/css/style.css"/>
        <script src="{$assetsBase}/js/site.js" defer="defer"></script>
      </head>

      <body class="{$pageClass}">
        <header class="site-header">
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

        <main class="container">
          <!-- Insertion du contenu spécifique à la page -->
          <xsl:sequence select="$content"/>
        </main>

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
                Édition numérique : fac-similés, transcription, index d’entités nommées
              </p>
              <p class="footer-meta">
                Encodage TEI-XML / Transformation XSLT / Mise en page CSS
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
  <!--
    home-page :
    - présente le contexte historique
    - affiche une “chronologie des lettres” alimentée par $letters
    - donne des repères chronologiques et des sources
  -->
  <xsl:template name="home-page">

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

      <div class="home-actions" role="navigation" aria-label="Accès rapides">
        <a class="btn" href="lane.html">Commencer la lecture</a>
        <a class="btn btn--ghost" href="index-entities.html">Explorer l’index</a>
        <a class="btn btn--ghost" href="methodologie.html">Méthodologie</a>
      </div>
    </section>

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
  <!--
    letter-page :
    - affiche le header de lettre (titre/date/desc + portrait si dispo)
    - affiche une zone manuscrit (carrousel)
    - affiche un panneau texte (tabs transcription/traduction si traduction existe)
    - ajoute un nav prev/next en bas
  -->
  <xsl:template name="letter-page">
    <xsl:param name="meta"/>
    <xsl:param name="letterDiv"/>

    <xsl:choose>
      <xsl:when test="empty($letterDiv)">
        <section class="card">
          <h1>Erreur</h1>
          <p>Lettre introuvable dans le corpus.</p>
        </section>
      </xsl:when>

      <xsl:otherwise>
        <section class="card letter-header">

          <!--
            Portrait de la page lettre :
            je ne l’affiche que pour Lane et Stannard (images disponibles),
            Nelson n’a pas d’image dans le mapping.
          -->
          <xsl:variable name="pid">
            <xsl:choose>
              <xsl:when test="string($meta/@key)='lane'">pers_lane</xsl:when>
              <xsl:when test="string($meta/@key)='stannard'">pers_stannard</xsl:when>
              <xsl:otherwise/>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="portraitFile" select="string($personPortraits/p[@id=$pid]/@file)"/>

          <h1 class="page-title">
            <xsl:value-of select="$meta/@title"/>
            <span class="muted"> — <xsl:value-of select="$meta/@date"/></span>
          </h1>
          <p class="lead"><xsl:value-of select="$meta/@desc"/></p>

          <xsl:if test="$portraitFile != ''">
            <img class="letter-portrait"
                 src="{$assetsBase}/img/persons/{$portraitFile}"
                 alt="Portrait"
                 loading="lazy"/>
          </xsl:if>
        </section>

        <section class="ms-layout manuscript-layout">
          <aside class="card ms-panel viewer">
            <div class="ms-panel-head">
              <h2>Manuscrit</h2>
              <p class="muted ms-hint">Survole les zones pour afficher le texte reconnu.</p>
            </div>

            <xsl:call-template name="images-carousel">
              <xsl:with-param name="meta" select="$meta"/>
            </xsl:call-template>
          </aside>

          <article class="card ms-textPanel">
            <xsl:call-template name="text-panel">
              <xsl:with-param name="meta" select="$meta"/>
              <xsl:with-param name="letterDiv" select="$letterDiv"/>
            </xsl:call-template>
          </article>
        </section>

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
  <!--
    text-panel :
    - isole les nœuds de transcription (= tout sauf div[@type='translation'])
    - récupère la traduction si elle existe
    - si traduction : affiche des tabs radio (EN/FR)
    - sinon : transcription seule
  -->
  <xsl:template name="text-panel">
    <xsl:param name="meta"/>
    <xsl:param name="letterDiv"/>

    <!--
      transcriptionNodes :
      Objectif : récupérer tout ce qui constitue la “transcription”,
      c’est-à-dire tout le contenu de $letterDiv SAUF le div de traduction.

      Pourquoi node() et pas * ?
      - node() prend aussi les nœuds texte (espaces, retours) entre éléments,
        ce qui peut compter pour la mise en forme (et évite parfois des concaténations “trop serrées”).
      - * ne prend que les éléments, donc peut lisser certains espacements.

      Filtre :
        [not(self::tei:div[@type='translation'])]
      → on exclut uniquement le bloc de traduction TEI.
      Le reste (opener, paragraphs, closer, notes, etc.) reste dans la transcription.
    -->
    <xsl:variable name="transcriptionNodes"
      select="$letterDiv/node()[not(self::tei:div[@type='translation'])]"/>

    <!--
      translationDiv :
      je prends uniquement le premier div TEI de type translation.
      [1] est une sécurité si, par erreur, plusieurs blocs de traduction existaient.
    -->
    <xsl:variable name="translationDiv"
  select="(root($letterDiv)//tei:div[@type='translation']
            [tokenize(normalize-space(@corresp), '\s+') = concat('#', $letterDiv/@xml:id)]
          )[1]"/>

    <header class="ms-textHead">
      <h2>Texte</h2>
      <xsl:if test="exists($translationDiv)">
        <p class="muted ms-hint">Choisis l’affichage : Transcription (EN) ou Traduction (FR).</p>
      </xsl:if>
    </header>

    <xsl:choose>
      <xsl:when test="exists($translationDiv)">
        <xsl:variable name="tabName" select="concat('tabs-', string($meta/@key))"/>
        <xsl:variable name="idEn" select="concat('tab-en-', string($meta/@key))"/>
        <xsl:variable name="idFr" select="concat('tab-fr-', string($meta/@key))"/>

        <div class="tabs ms-tabs">
          <input class="tab-input" type="radio" name="{$tabName}" id="{$idEn}" checked="checked"/>
          <input class="tab-input" type="radio" name="{$tabName}" id="{$idFr}"/>

          <div class="tab-bar">
            <label class="tab-btn" for="{$idEn}">Transcription (EN)</label>
            <label class="tab-btn" for="{$idFr}">Traduction (FR)</label>
          </div>

          <div class="tab-panels">
            <div class="tab-panel tab-panel--t">
              <section class="ms-col ms-col--transcription">
                <h3 class="ms-colTitle">Transcription</h3>
                <div class="tei-text">
                  <xsl:apply-templates select="$transcriptionNodes"/>
                </div>
              </section>
            </div>

            <div class="tab-panel tab-panel--fr">
              <section class="ms-col ms-col--translation">
                <h3 class="ms-colTitle">Traduction (FR)</h3>
                <div class="tei-text tei-text--translation">
                  <xsl:apply-templates select="$translationDiv/node()"/>
                </div>
              </section>
            </div>
          </div>
        </div>
      </xsl:when>

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
  <!-- VIEWER IMAGES : CARROUSEL + THUMBS -->
  <!-- ========================================================= -->
  <!--
    images-carousel :
    - tokenise @pages (“01 02a 02b …”)
    - construit une slide par page (img + svg overlay)
    - construit une rangée de miniatures (thumbs)
    Les overlays SVG sont initialisés côté JS via data-overlay="…".
  -->
  <xsl:template name="images-carousel">
    <xsl:param name="meta"/>

    <xsl:variable name="pages" select="tokenize(normalize-space(string($meta/@pages)),'\s+')"/>

    <div class="ms-carousel" data-carousel="{string($meta/@key)}">
      <div class="ms-stageWrap">
        <button class="ms-navBtn ms-prev" type="button" aria-label="Page précédente">‹</button>
        <button class="ms-navBtn ms-next" type="button" aria-label="Page suivante">›</button>

        <div class="ms-stage" role="region" aria-label="Visionneuse manuscrit">
          <xsl:for-each select="$pages">
            <xsl:variable name="tok" select="normalize-space(.)"/>
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
  <!--
    entities-page :
    - affiche un sommaire (ancres)
    - construit 4 sections : personnes / lieux / organisations / œuvres
    - pour chaque entité : titre + note + liens “Cité.e dans : …”
    - quand une image existe dans les mappings (*Thumbs / Portraits), elle est affichée

    Important :
    Le bloc <xsl:if test="exists($hits)"> NE PEUT PAS être “tout seul” au début du template.
    $hits et $pid sont des variables locales, déclarées à l’intérieur des boucles (for-each)
    qui parcourent chaque entité. Donc ce bloc doit être placé *dans* le <xsl:for-each>
    correspondant (person/place/org/bibl), après la déclaration de $hits et de l’identifiant.

    Sinon :
    - $hits n’existe pas (variable hors scope)
    - $pid / $plid / $oid / $wid n’existent pas non plus
    → erreurs XPST0008 “Variable has not been declared”.
  -->
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

          <!-- Tri : d’abord l’ordre d’importance, puis alphabétique -->
          <xsl:sort select="f:person-rank(string(@xml:id))"
                    data-type="number" order="ascending"/>
          <xsl:sort select="lower-case(normalize-space(string-join(.//tei:persName[1]//text(),' ')))"/>

          <xsl:variable name="pid" select="string(@xml:id)"/>
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
                <div class="entity-portrait entity-portrait--placeholder" aria-hidden="true"></div>
              </xsl:otherwise>
            </xsl:choose>

            <div class="entity-content">

              <div class="entity-title">
                <xsl:value-of select="normalize-space(string-join(.//tei:persName[1]//text(),' '))"/>
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

              <!--
                Liens “Cité.e dans : …” (group-by lettre)
                Note technique :
                le mécanisme d’ancres (occId) repose sur generate-id() et l’identité des nœuds.
                Il fonctionne tant que :
                - les pages lettres et l’index sont produits dans la même exécution XSLT
                - les occurrences utilisées pour construire les liens proviennent du document source
                  (pas de duplication des nœuds via copy-of dans un arbre temporaire).
              -->
              <xsl:variable name="hits"
                select="/tei:TEI/tei:text//tei:persName[@ref = concat('#',$pid)]"/>

              <xsl:if test="exists($hits)">
                <p class="entity-note">
                  <strong>Cité.e dans :</strong><xsl:text> </xsl:text>

                  <xsl:for-each-group
                    select="$hits"
                    group-by="string((ancestor::tei:div[@type='letter'][1]/@xml:id)[1])">

                    <!--
                      Je regroupe toutes les occurrences ($hits) par lettre.
                      Pour chaque occurrence (persName/placeName/orgName/title) je remonte
                      au <div type="letter"> ancêtre le plus proche et je prends son @xml:id.

                      Résultat : une seule “entrée” par lettre, même si l’entité apparaît 12 fois.
                    -->
                    <xsl:variable name="letterDivId" select="current-grouping-key()"/>
                    <xsl:variable name="file" select="f:letter-file($letterDivId)"/>
                    <xsl:variable name="label" select="f:letter-title($letterDivId)"/>
                    <xsl:variable name="firstHit" select="current-group()[1]"/>

                    <!--
                      occId (côté index) :

                      Ici, l’objectif est de construire une ancre qui existe déjà dans la page lettre.
                      Dans la page lettre, l’id est calculé comme :
                          concat('occ-', $idEntité, '-', generate-id(.))
                      où "." = nœud occurrence (tei:persName, etc.)

                      Dans l’index :
                      - $firstHit = première occurrence de l’entité dans cette lettre
                      - $firstHit est le même nœud TEI que celui qui était "." côté lettre
                      donc :
                          generate-id($firstHit) == generate-id(.) (dans la lettre)
                      et l’ancre matche exactement.
                    -->
                    <xsl:variable name="occId"
                      select="concat('occ-',$pid,'-',generate-id($firstHit))"/>

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
    <!-- LIEUX (Pays / Villes) -->
    <!-- ====================== -->
    <section class="card" id="places">
      <h2>Lieux</h2>

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
<!--
  methodologie-page :
  - page “statique” en HTML pur (dans le shell)
  - intro + navigation interne + sections
-->

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

    <!-- Navigation interne -->
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
  <!--
    Je définis ici des templates “match=tei:*” :
    - chaque élément TEI devient une structure HTML cohérente
    - certains éléments (entités) deviennent des liens vers l’index
    - les retours à la ligne TEI (lb) sont gérés finement selon le contexte
  -->

  <!-- fw (letterhead) -->
  <xsl:template match="tei:fw[@type='letterhead']">
    <div class="tei-note letterhead">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- Paragraphes -->
  <xsl:template match="tei:p">
    <p>
      <xsl:if test="@rend='indentation' or @type='indentation'">
        <xsl:attribute name="class">indent</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <!-- lb : br uniquement pour en-têtes + opener ; sinon espace -->
  <xsl:template match="tei:lb">

    <!--
      lb = line break en TEI.
      Dans un manuscrit, ça peut être :
      - un vrai retour à la ligne “visuel” (entête, adresse, ouverture)
      - ou juste une contrainte de mise en page du manuscrit (fin de ligne)
      Ici, je choisis de conserver le <br/> uniquement dans les zones
      où la mise en forme en lignes a un sens éditorial (letterhead / opener).
      Ailleurs, je remplace par un espace pour éviter des cassures artificielles.
    -->

    <xsl:choose>

      <!--
        Cas 1 : deux lb consécutifs → je n’ajoute rien.
        Objectif : éviter d’empiler des espaces ou des <br/> redondants.
        (C’est une sorte de “nettoyage” minimal.)
      -->
      <xsl:when test="following-sibling::*[1][self::tei:lb]">
        <xsl:text></xsl:text>
      </xsl:when>

      <!--
        Cas 2 : letterhead (en-tête de lettre)
        Ici le rendu “en lignes” est important → <br/>.
      -->
      <xsl:when test="ancestor::tei:fw[@type='letterhead']">
        <br/>
      </xsl:when>

      <!--
        Cas 3 : note de type letterhead
        Même logique : on garde le retour à la ligne.
      -->
      <xsl:when test="ancestor::tei:note[@type='letterhead']">
        <br/>
      </xsl:when>

      <!--
        Cas 4 : opener (lieu/date/salutation)
        On conserve la disposition en lignes → <br/>.
      -->
      <xsl:when test="ancestor::tei:opener">
        <br/>
      </xsl:when>

      <!--
        Cas 5 : closer (formules de politesse, signature)
        Ici, les retours de ligne TEI reflètent souvent une mise en page manuscrite.
        Pour éviter des cassures bizarres en HTML (“I remain” / “truly” séparés),
        je transforme en espace.
      -->
      <xsl:when test="ancestor::tei:closer">
        <xsl:text> </xsl:text>
      </xsl:when>

      <!--
        Cas par défaut : ailleurs dans le texte courant,
        je considère lb comme une fin de ligne manuscrite sans valeur sémantique,
        donc espace.
      -->
      <xsl:otherwise>
        <xsl:text> </xsl:text>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:template>

  <!-- hi underline -->
  <xsl:template match="tei:hi[@rend='underline']">
    <span class="u"><xsl:apply-templates/></span>
  </xsl:template>

  <!-- foreign -->
  <xsl:template match="tei:foreign">
    <span class="foreign"><xsl:apply-templates/></span>
  </xsl:template>

  <!-- supplied -->
  <xsl:template match="tei:supplied">
    <span class="supplied"><xsl:apply-templates/></span>
  </xsl:template>

  <!-- term -->
  <xsl:template match="tei:term">
    <span class="term"><xsl:apply-templates/></span>
  </xsl:template>

  <!-- pc -->
  <xsl:template match="tei:pc">
    <span class="pc"><xsl:apply-templates/></span>
  </xsl:template>

  <!-- note letterhead -->
  <xsl:template match="tei:note[@type='letterhead']">
    <div class="tei-note letterhead">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- note -->
  <xsl:template match="tei:note">
    <div class="tei-note">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- opener / closer -->
  <xsl:template match="tei:opener|tei:closer">
    <div class="tei-block">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="tei:salute">
    <p class="tei-salute"><xsl:apply-templates/></p>
  </xsl:template>

  <xsl:template match="tei:signed">
    <p class="tei-signed"><xsl:apply-templates/></p>
  </xsl:template>

  <!-- seg -->
  <xsl:template match="tei:seg">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- addName -->
  <xsl:template match="tei:addName">
    <span class="addName"><xsl:apply-templates/></span>
  </xsl:template>

  <!-- date -->
  <xsl:template match="tei:date">
    <time>
      <xsl:if test="@when">
        <xsl:attribute name="datetime"><xsl:value-of select="@when"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </time>
  </xsl:template>

  <!-- choice -> expan/reg -->
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

  <!-- Œuvres : lien si @ref -->
  <xsl:template match="tei:title[@type='work' and @ref]">
    <xsl:variable name="t" select="string(@ref)"/>
    <xsl:variable name="id" select="substring-after($t,'#')"/>

    <!--
      occId :
      identifiant HTML placé sur l’occurrence dans la page lettre.
      Il sera reconstruit dans l’index à partir de la première occurrence ($firstHit).
    -->
    <xsl:variable name="occId" select="concat('occ-',$id,'-',generate-id(.))"/>

    <a class="entity-link" id="{$occId}" href="{concat('index-entities.html',$t)}">
      <em><xsl:apply-templates/></em>
    </a>
  </xsl:template>

  <xsl:template match="tei:title[@type='work']">
    <em><xsl:apply-templates/></em>
  </xsl:template>

  <!-- persName -->
  <xsl:template match="tei:persName[@ref]">

    <!--
      @ref contient normalement une référence interne TEI du type "#pers_wilde".
      Je la stocke telle quelle dans $t pour réutiliser aussi la version “#id”.
    -->
    <xsl:variable name="t" select="string(@ref)"/>

    <!--
      Je récupère la partie après le '#':
      "#pers_wilde" -> "pers_wilde"
    -->
    <xsl:variable name="id" select="substring-after($t,'#')"/>

    <!--
      occId :
      identifiant HTML placé SUR l’occurrence dans la page lettre.

      Important :
      - generate-id(.) est calculé sur le nœud courant TEI (cette occurrence précise).
      - ce même nœud pourra être retrouvé depuis l’index via $hits,
        donc l’index pourra reconstruire exactement le même identifiant
        (en utilisant generate-id($firstHit)).

      Résultat :
      index → lien lane.html#occ-pers_wilde-...
      → scroll sur la première occurrence dans la lettre.
    -->
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

  <!-- placeName -->
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

  <!-- orgName -->
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

  <!-- ref target="#..." : renvoi index si ancre ; sinon lien externe -->
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

  <!-- fallback entités sans @ref -->
  <xsl:template match="tei:persName|tei:placeName|tei:orgName">
    <span class="entity"><xsl:apply-templates/></span>
  </xsl:template>

  <!-- Par défaut : div = conteneur, je laisse descendre -->
  <xsl:template match="tei:div">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Texte brut -->
  <xsl:template match="text()">
    <xsl:value-of select="."/>
  </xsl:template>

</xsl:stylesheet>
