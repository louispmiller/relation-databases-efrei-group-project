-- Retire les tables si elles existent
DROP TABLE IF EXISTS ligne_commande;
DROP TABLE IF EXISTS commande;
DROP TABLE IF EXISTS produit;
DROP TABLE IF EXISTS client;
DROP TYPE IF EXISTS statut;


CREATE TABLE client ( 
    id SERIAL PRIMARY KEY,
    nom VARCHAR(255),
    prenom VARCHAR(255),
    email VARCHAR(255),
    ville VARCHAR(255),
    date_inscription DATE
);

CREATE TABLE produit ( 
    id SERIAL PRIMARY KEY,
    nom VARCHAR(255),
    categorie VARCHAR(255),
    prix REAL,
    stock INT
);

CREATE TYPE statut AS ENUM ( -- Statuts enum définis pour avoir uniquement celles attendues
    'payée',
    'expédiée',
    'livrée',
    'annulée'
);

CREATE TABLE commande ( -- Les commandes 
    id SERIAL PRIMARY KEY,
    client_id INT REFERENCES client(id), -- 1:N
    date_commande DATE,
    statut statut NOT NULL
);

CREATE TABLE ligne_commande ( -- Les Lignes de Commandes id, commande_id, produit_id, quantite, prix_unitaire
    id SERIAL PRIMARY KEY,
    commande_id INT REFERENCES commande(id), -- 1:N
    produit_id INT REFERENCES produit(id), -- 1:N
    quantite INT,
    prix_unitaire REAL
);