-- ============================================================================
-- 10) VIEW: Detail návštěv s pacientem, lékařem a ordinací
-- Umožňuje rychlý přehled všech návštěv s jmény a místností
-- ============================================================================
CREATE OR REPLACE VIEW vw_navstevy_detail AS
SELECT
  n.navsteva_id,
  DATE_FORMAT(n.datum, '%Y-%m-%d')   AS datum,              -- formátovaný datum
  DATE_FORMAT(n.cas, '%H:%i')        AS cas,                -- formátovaný čas
  CONCAT(p.jmeno, ' ', p.prijmeni)   AS pacient,            -- celé jméno pacienta
  CONCAT(l.jmeno, ' ', l.prijmeni)   AS lekar,              -- celé jméno lékaře
  o.cislo                            AS ordinace,           -- číslo ordinace
  n.stav,                                              -- stav návštěvy
  n.poznamka                                           -- poznámka
FROM navsteva n
JOIN pacient   p ON n.pacient_id   = p.pacient_id
JOIN lekar     l ON n.lekar_id     = l.lekar_id
JOIN ordinace  o ON n.ordinace_id  = o.ordinace_id;

-- ============================================================================
-- 11) VIEW: Počet návštěv na pacienta
-- Agreguje celkový počet návštěv a datum poslední návštěvy
-- ============================================================================
CREATE OR REPLACE VIEW vw_pocet_navstev_pacient AS
SELECT
  p.pacient_id,
  CONCAT(p.jmeno, ' ', p.prijmeni) AS pacient,           -- celé jméno
  COUNT(n.navsteva_id)             AS pocet_navstev,     -- počet návštěv
  MAX(n.datum)                     AS posledni_navsteva  -- datum poslední návštěvy
FROM pacient p
LEFT JOIN navsteva n ON p.pacient_id = n.pacient_id
GROUP BY p.pacient_id;

-- ============================================================================
-- 12) Dotaz: Lékaři a počet plánovaných návštěv
-- Zjistí, kolik mají lékaři naplánovaných schůzek
-- ============================================================================
SELECT
  l.lekar_id,
  CONCAT(l.jmeno, ' ', l.prijmeni)  AS lekar,              -- celé jméno lékaře
  l.specializace,                                     -- jeho specializace
  COUNT(*)                        AS pocet_planovanych     -- počet plánovaných návštěv
FROM navsteva n
JOIN lekar l ON n.lekar_id = l.lekar_id
WHERE n.stav = 'plánována'                            -- jen plánované
GROUP BY l.lekar_id
HAVING COUNT(*) > 0                                   -- alespoň jedna
ORDER BY pocet_planovanych DESC;                      -- seřazeno sestupně

-- ============================================================================
-- 13) Dotaz: Zrušené návštěvy pacientů z Prahy
-- Filtrace podle stavu a města
-- ============================================================================
SELECT
  n.navsteva_id,
  CONCAT(p.jmeno, ' ', p.prijmeni)  AS pacient,         -- jméno pacienta
  n.datum,                                             -- datum zrušené návštěvy
  n.cas,                                               -- čas zrušené návštěvy
  n.poznamka                                           -- důvod zrušení
FROM navsteva n
JOIN pacient p ON n.pacient_id = p.pacient_id
WHERE n.stav = 'zrusena'                               -- jen zrušené návštěvy
  AND p.adresa_mesto = 'Praha'                         -- pacienti bydlící v Praze
ORDER BY n.datum DESC;                                 -- nejnovější první

-- ============================================================================
-- 14) Dotaz: Průměrný počet diagnóz na návštěvu
-- Vypočítá průměr diagnóz označených u jedné návštěvy
-- ============================================================================
SELECT
  AVG(d.count_diag) AS prumerna_diag_na_navstevu       -- výsledek průměru
FROM (
  SELECT
    navsteva_id,
    COUNT(*) AS count_diag                             -- počet diagnóz na každou návštěvu
  FROM diagnoza
  GROUP BY navsteva_id
) AS d;

-- ============================================================================
-- 15) Dotaz: Top 5 pacientů podle počtu receptů
-- Seřadí pacienty dle počtu vystavených receptů, omezí na 5 nejvyšších
-- ============================================================================
SELECT
  p.pacient_id,
  CONCAT(p.jmeno, ' ', p.prijmeni) AS pacient,         -- celé jméno pacienta
  COUNT(pr.predpis_id)             AS pocet_receptu    -- počet receptů
FROM pacient p
JOIN navsteva n ON p.pacient_id = n.pacient_id
JOIN predpis pr ON n.navsteva_id = pr.navsteva_id
GROUP BY p.pacient_id
ORDER BY pocet_receptu DESC                            -- sestupně dle receptů
LIMIT 5;                                               -- pouze 5 nejvyšších

-- ============================================================================
-- 16) Dotaz: Pacienti s návštěvou v příštích 7 dnech
-- Vypíše plánované návštěvy od dneška do sedmi dnů dopředu
-- ============================================================================
SELECT
  CONCAT(p.jmeno, ' ', p.prijmeni) AS pacient,         -- celé jméno
  n.datum,                                             -- datum návštěvy
  n.cas,                                               -- čas návštěvy
  n.stav                                               -- stav (plánována/apod.)
FROM navsteva n
JOIN pacient p ON n.pacient_id = p.pacient_id
WHERE n.datum BETWEEN CURDATE() 
                  AND DATE_ADD(CURDATE(), INTERVAL 7 DAY) -- rozsah příštích 7 dnů
ORDER BY n.datum, n.cas;                               -- řazeno podle data a času

-- ============================================================================
-- 17) Dotaz: Detail receptů s lékařem a pacientem
-- Spojuje tabulky receptů, návštěv, pacientů a lékařů pro úplný detail
-- ============================================================================
SELECT
  pr.predpis_id,
  CONCAT(p.jmeno, ' ', p.prijmeni) AS pacient,         -- pacient, kterému byl recept vystaven
  CONCAT(l.jmeno, ' ', l.prijmeni) AS lekar,           -- lékař, který recept vystavil
  pr.lek,                                              -- název léku
  pr.davkovani,                                        -- dávkování
  pr.mnozstvi,                                         -- množství
  n.datum                                              -- datum vystavení
FROM predpis pr
JOIN navsteva n ON pr.navsteva_id = n.navsteva_id
JOIN pacient p  ON n.pacient_id   = p.pacient_id
JOIN lekar l    ON n.lekar_id     = l.lekar_id
ORDER BY n.datum DESC, pr.predpis_id;                  -- nejnovější recepty první