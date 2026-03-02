-- PROJET - Analyse du Marché Immobilier Français 2022-2024
-- Auteur : Bryan Poiraudeau
-- Outil : PostgreSQL

-- Requête 1 : Exploration des types de transactions
SELECT 
    nature_mutation,
    COUNT(*) AS nombre_transactions,
    MIN(date_mutation) AS premiere_date,
    MAX(date_mutation) AS derniere_date
FROM transactions
WHERE nature_mutation IS NOT NULL
GROUP BY nature_mutation
ORDER BY nombre_transactions DESC;

-- Requête 2 : Prix moyen par département
-- Première version, révèle des anomalies sur certains départements
-- Contrainte technique, PostgreSQL ne reconnaissant la virgule comme séparateur
-- J'ai importé toutes les colonnes en TEXT et utilisé REPLACE pour convertir les valeurs au moment des requêtes/
SELECT 
    code_departement,
    COUNT(*) AS nombre_ventes,
    ROUND(AVG(REPLACE(valeur_fonciere, ',', '.')::NUMERIC), 0) AS prix_moyen
FROM transactions
WHERE nature_mutation = 'Vente'
AND valeur_fonciere IS NOT NULL
AND valeur_fonciere != ''
GROUP BY code_departement
ORDER BY prix_moyen DESC
LIMIT 20;

-- Requête 2 corrigée : filtrage des valeurs aberrantes
-- Le département 56 ressortait à 54M de moyenne, j'ai donc
-- filtré les prix entre 10 000 et 5 000 000 euros
SELECT 
    code_departement,
    COUNT(*) AS nombre_ventes,
    ROUND(AVG(REPLACE(valeur_fonciere, ',', '.')::NUMERIC), 0) AS prix_moyen
FROM transactions
WHERE nature_mutation = 'Vente'
AND valeur_fonciere IS NOT NULL
AND valeur_fonciere != ''
AND REPLACE(valeur_fonciere, ',', '.')::NUMERIC BETWEEN 10000 AND 5000000
GROUP BY code_departement
ORDER BY prix_moyen DESC
LIMIT 20;

-- Requête 3 : Evolution annuelle sur les grands marchés
SELECT 
    EXTRACT(YEAR FROM date_mutation::DATE) AS annee,
    code_departement,
    COUNT(*) AS nombre_ventes,
    ROUND(AVG(REPLACE(valeur_fonciere, ',', '.')::NUMERIC), 0) AS prix_moyen
FROM transactions
WHERE nature_mutation = 'Vente'
AND valeur_fonciere IS NOT NULL
AND valeur_fonciere != ''
AND REPLACE(valeur_fonciere, ',', '.')::NUMERIC BETWEEN 10000 AND 5000000
AND code_departement IN ('75', '92', '69', '13', '33')
GROUP BY annee, code_departement
ORDER BY code_departement, annee;