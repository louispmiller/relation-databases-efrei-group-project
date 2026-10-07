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

