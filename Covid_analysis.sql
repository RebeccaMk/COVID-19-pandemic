-- création des tables / tables creation
DROP TABLE IF EXISTS covid_dep;  
 CREATE TABLE covid_dep (
    date TEXT,         
    dep TEXT,         
    lib_dep TEXT,     
    tx_incid REAL,    
    tx_pos REAL,      
    hosp INTEGER,     
    rea INTEGER,      
    dc INTEGER       
);

DROP TABLE IF EXISTS covid_france;
CREATE TABLE covid_france (
    date TEXT,       
    tx_incid REAL,   
    tx_pos REAL,     
    hosp INTEGER,    
    rea INTEGER,     
    dc INTEGER       
);

-- Vérifier que les données sont bien présentes après l'importation. / Check that data is present after import.
SELECT * FROM covid_dep LIMIT 10;

SELECT * FROM covid_france LIMIT 10;


-- ANALYSER LES DONNÉES / DATA ANALYSIS


-- Total d’hospitalisations par régions / Total hospitalizations by region :
SELECT lib_reg, SUM(hosp) AS total_hospitalisations
FROM covid_dep
GROUP BY lib_reg
ORDER BY total_hospitalisations DESC;


-- Tendances annuelles d'hospitalisation / Annual hospitalization trends :
SELECT 
    substr(date, 1, 4) AS year, 
    SUM(hosp) AS total_hosp,  
    SUM(rea) AS total_rea,  
    AVG(hosp) AS avg_hosp,  
    AVG(rea) AS avg_rea  
FROM covid_dep
WHERE substr(date, 1, 4) IN ('2020', '2021', '2022', '2023')  
GROUP BY year  
ORDER BY year ASC; 


-- Comparer les hospitalisations par départements / Compare hospitalizations by department :
SELECT
	substr(date, 1, 4) AS year,
    lib_dep, 
    SUM(hosp) AS total_hosp, 
    SUM(rea) AS total_rea,
    ROUND((SUM(rea) * 100.0) / NULLIF(SUM(hosp), 0), 2) AS perc_rea
FROM covid_dep
GROUP BY lib_dep
ORDER BY total_hosp DESC


-- Comparaison des hospitalisations et réanimations d'avril à décembre 2020 / Comparison of hospitalizations and resuscitations from April to December 2020 :
SELECT date, SUM(hosp) AS total_hosp, SUM(rea) AS total_rea
FROM covid_dep
WHERE date BETWEEN '2020-04-01' AND '2020-12-31'
GROUP BY date
ORDER BY date ASC;


-- Nombre total de décès hospitalisés par année et par département / Total number of hospitalized deaths by year and department :
SELECT 
    substr(date, 1, 4) AS year,  -- Extraction de l'année depuis la colonne "date"                       
    lib_dep,                    
    dchosp AS total_dchosp       -- Somme des décès par année et département
FROM covid_dep
WHERE dchosp IS NOT NULL             -- On exclut les valeurs nulles
GROUP BY year, lib_dep
ORDER BY year ASC, total_dchosp DESC;

-- Comparaison de la proportion des hospitalisations d’un département par rapport au total national par an / Comparison of the proportion of hospital admissions in a département compared with the national total per year :
WITH national_hosp AS (
    SELECT substr(date, 1, 4) AS year, SUM(hosp) AS total_hosp_fr
    FROM covid_france
    WHERE substr(date, 1, 4) IN ('2020', '2021', '2022', '2023')
    GROUP BY year
)
SELECT 
    substr(c.date, 1, 4) AS year, 
    c.dep, 
    c.lib_dep, 
    SUM(c.hosp) AS total_hosp_dep, 
    n.total_hosp_fr, 
    ROUND((SUM(c.hosp) * 100.0) / NULLIF(n.total_hosp_fr, 0), 2) AS perc_hosp_dep
FROM covid_dep c
JOIN national_hosp n ON substr(c.date, 1, 4) = n.year
GROUP BY year, c.dep, c.lib_dep, n.total_hosp_fr
ORDER BY year ASC, perc_hosp_dep DESC;

