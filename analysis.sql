-- 1. Explorer les produits

-- Afficher la list de produits:
SELECT nom, categorie, prix, stock
FROM produit; 

-- Identifiez les produits dont le prix est supérieur à 100 €.
SELECT nom, categorie, prix, stock
FROM produit
WHERE prix > 100; -- Pour la demande d'identification de produits à plus de 100 euros

 /* 
 Produits concernés: 
 Clavier 1
 Clavier 2
 Souris 1
 Souris 2
 Écran 1
 Webcam 1
 Webcam 2
 Casque 2
 Disque dur 1
 Hub USB 1
 Hub USB 2
 Lampe 1
 Lampe 2
 Bouilloire 1
 Bouilloire 2
 Cafetière 1
 Plaid 1
 Plaid 2
 Tapis de yoga 1
 Tapis de yoga 2
 Gourde 1
 Haltères 1
 Haltères 2
 Sac de sport 1
 Sac de sport 2
 Ballon 1
 Ballon 2
 Montre sport 1
 Montre sport 2
 T-shirt 1
 Sweat 2
 Jean 1
 Veste 2
 Casquette 2
 Sac à dos 1
 Sac à dos 2
 Enceinte 1
 Écouteurs 1
 Écouteurs 2
 Microphone 2
 Barre de son 2
 Imprimante 1
 Platine vinyle 1
 */



-- 2. Explorer les clients

-- Afficher les clients habitant dans une ville donnée
SELECT id, nom, prenom, email, ville, date_inscription
FROM client
WHERE ville = 'Lyon';

-- Déterminer combien de clients sont enregistrés dans chaque ville.
SELECT ville, COUNT(*) AS nombre_clients
FROM client
GROUP BY ville
ORDER BY nombre_clients DESC;

-- 3. Explorer les commandes
SELECT 
    commande.id AS commande_id,
    commande.date_commande,
    commande.statut,
    client.id AS client_id,
    client.nom,
    client.prenom,
    client.email,
    client.ville,
    client.date_inscription
FROM commande
JOIN client ON commande.client_id = client.id;

-- 4. Calculer le montant d'une ligne

SELECT 
    id,
    commande_id,
    produit_id,
    quantite,
    prix_unitaire,
    quantite * prix_unitaire AS montant
FROM ligne_commande;

-- 5. Calculer le montant des commandes
SELECT 
    c.id AS commande_id,
    c.date_commande,
    c.statut,
    SUM(lc.quantite * lc.prix_unitaire) AS montant_total
FROM commande c
JOIN ligne_commande lc ON c.id = lc.commande_id
GROUP BY c.id
ORDER BY c.id;

-- 6. Chiffre d'affaires par catégorie
SELECT
    p.categorie,
    SUM(lc.quantite * lc.prix_unitaire) AS chiffre_affaires,
    SUM(lc.quantite) AS quantite_totale_vendue
FROM produit p
JOIN ligne_commande lc ON p.id = lc.produit_id
GROUP BY p.categorie
ORDER BY p.categorie;

-- 7. Produits les plus vendus
SELECT
    p.nom AS produit,
    p.categorie,
    SUM(lc.quantite) AS quantite_totale_vendue
FROM produit p
JOIN ligne_commande lc ON p.id = lc.produit_id
GROUP BY p.id
ORDER BY quantite_totale_vendue DESC 
LIMIT 10;

-- 8. Produits générant le plus de chiffres d'affaires
SELECT
    p.nom AS produit,
    p.categorie,
    SUM(lc.quantite * lc.prix_unitaire) AS chiffre_daffaires
FROM produit p
JOIN ligne_commande lc ON p.id = lc.produit_id
GROUP BY p.id
ORDER BY chiffre_daffaires DESC;

-- 9. Clients
SELECT
    c.id AS client_id,
    c.nom,
    c.prenom,
    COUNT(co.id) AS nombre_commandes,
    COALESCE(SUM(lc.quantite * lc.prix_unitaire), 0) AS montant_total_depense
FROM client c
LEFT JOIN commande co ON c.id = co.client_id
LEFT JOIN ligne_commande lc ON co.id = lc.commande_id
GROUP BY c.id
ORDER BY c.id ASC;

-- 10. Panier moyen

-- Panier moyen total de la plateforme
SELECT SUM(lc.quantite * lc.prix_unitaire) / COUNT(DISTINCT c.id) AS panier_moyen
FROM commande c
JOIN ligne_commande lc ON c.id = lc.commande_id;

-- Panier moyen par mois
SELECT
    DATE_TRUNC('month', c.date_commande) AS mois,
    SUM(lc.quantite * lc.prix_unitaire) / COUNT(DISTINCT c.id) AS panier_moyen
FROM commande c
JOIN ligne_commande lc ON c.id = lc.commande_id
GROUP BY DATE_TRUNC('month', c.date_commande)
ORDER BY mois;

-- Le panier moyen ne correspond pas au nombre de commandes et est indépendant. C'est en combinant le nombre de commandes et le panier moyen que nous obtenons le chiffre d'affaires




-- ============================================================
-- Partie 4 — Transformation des données
-- ============================================================

-- 11. Catégoriser les commandes

-- Catégorie de chaque commande selon son montant total
SELECT
    c.id AS commande_id,
    c.date_commande,
    c.statut,
    ROUND(SUM(lc.quantite * lc.prix_unitaire)::NUMERIC, 2) AS montant_total,
    CASE
        WHEN SUM(lc.quantite * lc.prix_unitaire) < 500 THEN 'Petit panier'
        WHEN SUM(lc.quantite * lc.prix_unitaire) < 1500 THEN 'Panier moyen'
        ELSE 'Gros panier'
    END AS categorie_panier
FROM commande c
JOIN ligne_commande lc ON c.id = lc.commande_id
GROUP BY c.id
ORDER BY c.id;

-- Répartition des commandes (hors annulées) par catégorie de panier
WITH montants AS (
    SELECT
        c.id,
        SUM(lc.quantite * lc.prix_unitaire) AS montant_total
    FROM commande c
    JOIN ligne_commande lc ON c.id = lc.commande_id
    WHERE c.statut <> 'annulée'
    GROUP BY c.id
)
SELECT
    CASE
        WHEN montant_total < 500 THEN 'Petit panier'
        WHEN montant_total < 1500 THEN 'Panier moyen'
        ELSE 'Gros panier'
    END AS categorie_panier,
    COUNT(*) AS nombre_commandes,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pourcentage_commandes,
    ROUND(SUM(montant_total)::NUMERIC, 2) AS chiffre_affaires,
    ROUND((100.0 * SUM(montant_total) / SUM(SUM(montant_total)) OVER ())::NUMERIC, 1) AS pourcentage_ca
FROM montants
GROUP BY categorie_panier
ORDER BY MIN(montant_total);

/*
 Répartition (hors commandes annulées, 484 commandes) :
 - Petit panier  :  99 commandes (20,5 %) ->  29 995,75 € (4,9 % du CA)
 - Panier moyen  : 201 commandes (41,5 %) -> 192 525,62 € (31,2 % du CA)
 - Gros panier   : 184 commandes (38,0 %) -> 394 973,39 € (64,0 % du CA)
 Les gros paniers représentent un peu plus d'un tiers des commandes mais près des deux tiers
 du chiffre d'affaires : l'activité repose fortement sur les commandes de 1 500 € ou plus.
*/

-- 12. Analyse temporelle

-- Chiffre d'affaires par mois, rang et évolution par rapport au mois précédent
WITH ca_mensuel AS (
    SELECT
        DATE_TRUNC('month', c.date_commande)::DATE AS mois,
        COUNT(DISTINCT c.id) AS nombre_commandes,
        SUM(lc.quantite * lc.prix_unitaire)::NUMERIC AS chiffre_affaires
    FROM commande c
    JOIN ligne_commande lc ON c.id = lc.commande_id
    WHERE c.statut <> 'annulée'
    GROUP BY DATE_TRUNC('month', c.date_commande)
)
SELECT
    TO_CHAR(mois, 'YYYY-MM') AS mois,
    nombre_commandes,
    ROUND(chiffre_affaires, 2) AS chiffre_affaires,
    RANK() OVER (ORDER BY chiffre_affaires DESC) AS rang_ca,
    ROUND(chiffre_affaires - LAG(chiffre_affaires) OVER (ORDER BY mois), 2) AS evolution_vs_mois_precedent,
    ROUND(100 * (chiffre_affaires - LAG(chiffre_affaires) OVER (ORDER BY mois))
          / LAG(chiffre_affaires) OVER (ORDER BY mois), 1) AS evolution_pct,
    ROUND(SUM(chiffre_affaires) OVER (ORDER BY mois), 2) AS ca_cumule
FROM ca_mensuel
ORDER BY mois;

-- Chiffre d'affaires par trimestre (vision plus lissée)
SELECT
    'T' || EXTRACT(QUARTER FROM c.date_commande) AS trimestre,
    COUNT(DISTINCT c.id) AS nombre_commandes,
    ROUND(SUM(lc.quantite * lc.prix_unitaire)::NUMERIC, 2) AS chiffre_affaires
FROM commande c
JOIN ligne_commande lc ON c.id = lc.commande_id
WHERE c.statut <> 'annulée'
GROUP BY EXTRACT(QUARTER FROM c.date_commande)
ORDER BY trimestre;

/*
 Périodes les plus importantes : mai (68 841,64 €), août (65 441,63 €), décembre (60 655,34 €).
 Périodes les moins importantes : janvier (34 765,36 €), avril (35 932,15 €), septembre (40 578,54 €).
 Évolution générale : activité irrégulière d'un mois à l'autre (de -38 % à +92 %), mais tendance
 globalement haussière : T1 = 126 281 €, puis T2, T3 et T4 entre 161 000 et 166 000 €.
 Le premier trimestre est nettement le plus faible ; le reste de l'année est stable à un niveau plus élevé.
 CA annuel 2025 (hors annulées) : 617 494,76 €.
*/

-- ============================================================
-- Partie 5 — Qualité des données
-- ============================================================

-- 13. Détecter une incohérence : commande antérieure à l'inscription du client

SELECT
    co.id AS commande_id,
    cl.id AS client_id,
    co.date_commande,
    cl.date_inscription,
    cl.date_inscription - co.date_commande AS ecart_jours
FROM commande co
JOIN client cl ON co.client_id = cl.id
WHERE co.date_commande < cl.date_inscription
ORDER BY co.id;

-- Nombre d'anomalies détectées
SELECT COUNT(*) AS nombre_anomalies
FROM commande co
JOIN client cl ON co.client_id = cl.id
WHERE co.date_commande < cl.date_inscription;

/*
 30 anomalies détectées, concernant 12 clients (13, 41, 49, 57, 61, 63, 67, 68, 73, 76, 77, 89).
 Tous ces clients se sont inscrits en 2025 ; l'écart va de 2 à 194 jours.
 Hypothèses : date d'inscription écrasée lors d'une mise à jour du compte, commandes passées
 en tant qu'invité puis rattachées au compte, ou erreur de saisie / d'import.
 Ces commandes sont conservées dans les calculs de CA (la vente a bien eu lieu), mais
 l'incohérence doit être signalée et corrigée à la source.
*/

-- 14. Produits sans vente

SELECT
    p.nom AS produit,
    p.categorie,
    p.prix,
    p.stock
FROM produit p
LEFT JOIN ligne_commande lc ON p.id = lc.produit_id
WHERE lc.id IS NULL
ORDER BY p.categorie, p.nom;

/*
 5 produits jamais vendus (ids 61 à 65), un par catégorie :
 Platine vinyle 1 (Audio, 279 €, stock 18), Imprimante 1 (Informatique, 189,90 €, stock 42),
 Grille-pain 1 (Maison, 44,90 €, stock 65), Chemise 1 (Mode, 49,90 €, stock 80),
 Corde à sauter 1 (Sport, 19,90 €, stock 120).
 Intérêt pour l'entreprise :
 - 325 unités immobilisées en stock : coût de stockage et capital bloqué ;
 - signal d'un problème de visibilité (référencement, fiche produit), de prix ou d'adéquation à la demande ;
 - aide à la décision : promotion, mise en avant, vente groupée avec un produit populaire, ou retrait du catalogue.
*/

-- ============================================================
-- Partie 6 — Tableau de bord en SQL
-- ============================================================

-- 15. Indicateurs clés

-- A. Exploration

-- Nombre de lignes de chaque table
SELECT 'client' AS table_name, COUNT(*) AS nombre_lignes FROM client
UNION ALL
SELECT 'produit', COUNT(*) FROM produit
UNION ALL
SELECT 'commande', COUNT(*) FROM commande
UNION ALL
SELECT 'ligne_commande', COUNT(*) FROM ligne_commande;

-- Colonnes et types de données
SELECT
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('client', 'produit', 'commande', 'ligne_commande')
ORDER BY table_name, ordinal_position;

-- Valeurs manquantes (COUNT(*) - COUNT(colonne) = nombre de NULL)
SELECT 'client' AS table_name,
       COUNT(*) - COUNT(nom) AS nom_null,
       COUNT(*) - COUNT(prenom) AS prenom_null,
       COUNT(*) - COUNT(email) AS email_null,
       COUNT(*) - COUNT(ville) AS ville_null,
       COUNT(*) - COUNT(date_inscription) AS date_inscription_null
FROM client;

SELECT 'produit' AS table_name,
       COUNT(*) - COUNT(nom) AS nom_null,
       COUNT(*) - COUNT(categorie) AS categorie_null,
       COUNT(*) - COUNT(prix) AS prix_null,
       COUNT(*) - COUNT(stock) AS stock_null
FROM produit;

SELECT 'commande' AS table_name,
       COUNT(*) - COUNT(client_id) AS client_id_null,
       COUNT(*) - COUNT(date_commande) AS date_commande_null,
       COUNT(*) - COUNT(statut) AS statut_null
FROM commande;

SELECT 'ligne_commande' AS table_name,
       COUNT(*) - COUNT(commande_id) AS commande_id_null,
       COUNT(*) - COUNT(produit_id) AS produit_id_null,
       COUNT(*) - COUNT(quantite) AS quantite_null,
       COUNT(*) - COUNT(prix_unitaire) AS prix_unitaire_null
FROM ligne_commande;

/*
 client : 100 lignes, produit : 65, commande : 500, ligne_commande : 1 547.
 Aucune valeur manquante dans les colonnes des quatre tables.
 Remarque : la plupart des colonnes sont nullable (is_nullable = YES) dans le schéma actuel ;
 ajouter des contraintes NOT NULL garantirait que cela reste vrai pour les futures données.
*/

-- B. Analyse commerciale

-- CA total, nombre de commandes, panier moyen et clients actifs (hors annulées) en une requête
SELECT
    ROUND(SUM(lc.quantite * lc.prix_unitaire)::NUMERIC, 2) AS chiffre_affaires_total,
    COUNT(DISTINCT c.id) AS nombre_commandes,
    ROUND((SUM(lc.quantite * lc.prix_unitaire) / COUNT(DISTINCT c.id))::NUMERIC, 2) AS panier_moyen,
    COUNT(DISTINCT c.client_id) AS clients_actifs
FROM commande c
JOIN ligne_commande lc ON c.id = lc.commande_id
WHERE c.statut <> 'annulée';

-- Taux d'annulation des commandes
SELECT
    COUNT(*) FILTER (WHERE statut = 'annulée') AS commandes_annulees,
    COUNT(*) AS commandes_totales,
    ROUND(100.0 * COUNT(*) FILTER (WHERE statut = 'annulée') / COUNT(*), 2) AS taux_annulation_pct
FROM commande;

/*
 CA total : 617 494,76 € | 484 commandes | panier moyen : 1 275,82 € | 90 clients actifs.
 Taux d'annulation : 16 commandes annulées sur 500, soit 3,20 %.
 Les 10 clients restants (ids 91 à 100) sont inscrits mais n'ont jamais commandé.
*/

-- C. Analyse des clients : top 10 des clients par chiffre d'affaires

SELECT
    cl.id AS client_id,
    cl.nom,
    cl.prenom,
    cl.ville,
    COUNT(DISTINCT co.id) AS nombre_commandes,
    ROUND(SUM(lc.quantite * lc.prix_unitaire)::NUMERIC, 2) AS chiffre_affaires
FROM client cl
JOIN commande co ON cl.id = co.client_id
JOIN ligne_commande lc ON co.id = lc.commande_id
WHERE co.statut <> 'annulée'
GROUP BY cl.id
ORDER BY chiffre_affaires DESC
LIMIT 10;

/*
 Top 3 : Alice Dubois (Nice, 17 169,00 €), Sarah Bernard (Paris, 15 432,22 €),
 Nathan Bernard (Lyon, 15 324,36 €).
 Les 10 meilleurs clients génèrent chacun plus de 11 000 € avec 7 à 11 commandes :
 ce sont des clients fidèles à cibler en priorité (programme de fidélité, offres dédiées).
*/

-- D. Synthèse mensuelle

DROP TABLE IF EXISTS synthese_mensuelle;

CREATE TABLE synthese_mensuelle AS
SELECT
    DATE_TRUNC('month', c.date_commande)::DATE AS mois,
    COUNT(DISTINCT c.id) AS nombre_commandes,
    ROUND(SUM(lc.quantite * lc.prix_unitaire)::NUMERIC, 2) AS chiffre_affaires,
    ROUND((SUM(lc.quantite * lc.prix_unitaire) / COUNT(DISTINCT c.id))::NUMERIC, 2) AS panier_moyen
FROM commande c
JOIN ligne_commande lc ON c.id = lc.commande_id
WHERE c.statut <> 'annulée'
GROUP BY DATE_TRUNC('month', c.date_commande);

SELECT * FROM synthese_mensuelle ORDER BY mois;

/*
 La table synthese_mensuelle permet de suivre, mois par mois, les trois indicateurs ensemble
 et de comprendre l'origine des variations du CA (CA = nombre de commandes × panier moyen) :
 - mai et août : CA élevé porté par un fort volume de commandes (54 et 50) ;
 - octobre et décembre : volume modeste mais panier moyen élevé (1 578,81 € et 1 444,17 €) ;
 - février : beaucoup de commandes (44) mais panier moyen le plus faible (1 015,31 €) ;
 - janvier et avril : faible volume et panier moyen bas -> mois les plus faibles.
 Le panier moyen tend à augmenter au second semestre, ce qui explique la hausse du CA
 malgré un nombre de commandes qui ne progresse pas.
*/
