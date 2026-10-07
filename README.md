# EFREI — Projet de groupe : analyse des données d'une plateforme e-commerce

Analyse de l'activité commerciale d'une plateforme e-commerce, réalisée entièrement en SQL (PostgreSQL).

## Contenu du dépôt

| Fichier | Rôle |
| --- | --- |
| `create_schema.sql` | Création des tables (`client`, `produit`, `commande`, `ligne_commande`) et du type `statut` |
| `seed_ecommerce.sql` | Données fournies (100 clients, 65 produits, 500 commandes, 1 547 lignes de commande) |
| `analysis.sql` | Toutes les requêtes d'analyse (exercices 1 à 15) avec leurs interprétations en commentaire |
| `Projet équipe_SQL.docx` | Sujet complet |

## Modèle de données

```
client 1 ──── N commande 1 ──── N ligne_commande N ──── 1 produit
```

* `client` : nom, prénom, email, ville, date d'inscription.
* `produit` : nom, catégorie, prix actuel, stock.
* `commande` : client (clé étrangère), date, statut.
  Le statut est un type `ENUM` (`payée`, `expédiée`, `livrée`, `annulée`) : aucune autre valeur n'est acceptée.
* `ligne_commande` : commande et produit (clés étrangères), quantité, **prix unitaire effectivement payé**
  (distinct du prix actuel du produit, pour conserver les promotions et l'historique des prix).

Chaque table a une clé primaire `id SERIAL`. Un client peut n'avoir aucune commande et un produit peut n'avoir jamais été vendu.

## Installation et exécution

Prérequis : PostgreSQL installé et `psql` / `createdb` accessibles dans le terminal.

1. **Créer la base**

```bash
createdb -U {username} ecommerce_db
```

2. **Créer les tables**

```bash
psql -U {username} -d ecommerce_db -f create_schema.sql
```

Le script supprime d'abord les tables existantes : il peut être relancé pour repartir d'une base vide.

3. **Charger les données** (obligatoirement **après** la création des tables)

```bash
psql -U {username} -d ecommerce_db -f seed_ecommerce.sql
```

Vérification rapide :

```sql
SELECT (SELECT COUNT(*) FROM client)         AS clients,         -- 100
       (SELECT COUNT(*) FROM produit)        AS produits,        -- 65
       (SELECT COUNT(*) FROM commande)       AS commandes,       -- 500
       (SELECT COUNT(*) FROM ligne_commande) AS lignes_commande; -- 1 547
```

4. **Exécuter les analyses**

```bash
psql -U {username} -d ecommerce_db -f analysis.sql
```

Les requêtes peuvent aussi être lancées une par une depuis `psql` ou un client graphique (pgAdmin, DBeaver…).
`analysis.sql` crée la table `synthese_mensuelle` (exercice 15 D).

## Règles de calcul

* Montant d'une ligne = `quantite × prix_unitaire` (prix effectivement payé).
* Les commandes au statut `annulée` sont exclues du chiffre d'affaires, des quantités vendues et du panier moyen.
* Panier moyen = chiffre d'affaires / nombre de commandes.

## Principales conclusions

**Indicateurs clés (2025, hors commandes annulées)**

* Chiffre d'affaires : **617 494,76 €** sur **484 commandes**.
* Panier moyen : **1 275,82 €**.
* **90 clients actifs** ; 10 clients inscrits (ids 91 à 100) n'ont jamais commandé.
* Taux d'annulation : **3,20 %** (16 commandes sur 500).

**Taille des paniers**

* Les gros paniers (≥ 1 500 €) représentent 38 % des commandes mais **64 % du CA**.
* Les petits paniers (< 500 €) représentent 20,5 % des commandes et seulement 4,9 % du CA.
* L'activité repose donc fortement sur les commandes de montant élevé.

**Évolution dans le temps**

* Meilleurs mois : mai (68 842 €), août (65 442 €), décembre (60 655 €).
* Mois les plus faibles : janvier (34 765 €), avril (35 932 €), septembre (40 579 €).
* Le 1er trimestre est nettement le plus faible (126 281 €) ; T2, T3 et T4 sont stables entre 161 000 et 166 000 €.
* La hausse du CA au second semestre vient surtout d'un **panier moyen plus élevé**, pas d'un plus grand nombre de commandes.

**Clients**

* Les 10 meilleurs clients génèrent chacun plus de 11 000 € avec 7 à 11 commandes.
  Top 3 : Alice Dubois (Nice), Sarah Bernard (Paris), Nathan Bernard (Lyon).
  Ces clients fidèles sont à cibler en priorité (programme de fidélité, offres dédiées).

**Qualité des données**

* Aucune valeur manquante dans les quatre tables.
* **30 commandes** sont datées avant l'inscription de leur client (12 clients concernés, écart de 2 à 194 jours).
  Elles restent comptées dans le CA (la vente a eu lieu) mais l'incohérence doit être corrigée à la source.
* **5 produits jamais vendus** (un par catégorie, 325 unités en stock) : capital immobilisé.
  Pistes : promotion, mise en avant, vente groupée ou retrait du catalogue.
