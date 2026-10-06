-- Retire les tables si elles existent
DROP TABLE IF EXISTS Lignes_De_Commande;
DROP TABLE IF EXISTS Commandes;
DROP TABLE IF EXISTS Produits;
DROP TABLE IF EXISTS Clients;
DROP TYPE IF EXISTS statut;


CREATE TABLE Clients ( -- Les clients
    client_id SERIAL PRIMARY KEY,
    nom VARCHAR(255),
    prenom VARCHAR(255),
    email VARCHAR(255),
    ville VARCHAR(255),
    inscription DATE
);

CREATE TABLE Produits ( -- Les produits
    Produit_id SERIAL PRIMARY KEY,
    nom VARCHAR(255),
    categorie VARCHAR(255),
    prix INT,
    stock INT
);

CREATE TYPE statut AS ENUM ( -- Statuts enum définis pour avoir uniquement celles attendues
    'payée',
    'expédiée',
    'livrée',
    'annulée'
);

CREATE TABLE Commandes ( -- Les commandes
    Commande_id SERIAL PRIMARY KEY,
    client_id INT REFERENCES Clients(client_id), -- 1:N
    date_commande DATE,
    statut_commande statut NOT NULL
);

CREATE TABLE Lignes_De_Commande ( -- Les Lignes de Commandes
    Lignes_De_Commande_id SERIAL PRIMARY KEY,
    Produit_id INT REFERENCES Produits(Produit_id), -- 1:N
    Commande_id INT REFERENCES Commandes(Commande_id), -- 1:N
    quantite INT,
    prix_unitaire_paye REAL
);