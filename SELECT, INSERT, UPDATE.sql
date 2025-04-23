-- 1) INSERTy
INSERT INTO pacient (jmeno, prijmeni, datum_narozeni, pohlavi, telefon, email, adresa_ulice, adresa_mesto, adresa_psc)
VALUES
  ('Jan',    'Novák',  '1980-05-12', 'M', '+420601234567', 'jan.novak@example.com', 'Květinová 15', 'Praha', '11000'),
  ('Petra',  'Svobodová', '1992-11-03', 'Z', '+420602345678', 'petra.svobodova@example.com', 'Lipová 8', 'Brno', '60200');

INSERT INTO lekar (jmeno, prijmeni, specializace, telefon_sluzba, email_sluzba)
VALUES
  ('Karel', 'Dvořák', 'internista', '+420603456789', 'karel.dvorak@ordinace.cz'),
  ('Eva',   'Horáková', 'dermatolog', '+420604567890', 'eva.horakova@ordinace.cz');

INSERT INTO ordinace (cislo, popis, patro)
VALUES
  ('1A', 'hlavní pracoviště', '1. patro'),
  ('2B', 'kosmetické ošetření', '2. patro');

INSERT INTO navsteva (pacient_id, lekar_id, ordinace_id, datum, cas, stav, poznamka)
VALUES
  (1, 1, 1, '2025-04-20', '09:00:00', 'uskutecněna', 'Vše OK'),
  (1, 2, 2, '2025-04-22', '11:30:00', 'plánována',  NULL),
  (2, 1, 1, '2025-04-21', '14:00:00', 'zrusena',   'Nemoc pacienta');

INSERT INTO diagnoza (navsteva_id, kod_ICD, popis)
VALUES
  (1, 'J06.9', 'Akutní virová infekce dýchacích cest'),
  (3, 'K05.1', 'Kavitační parodontitida');

INSERT INTO predpis (navsteva_id, lek, davkovani, mnozstvi)
VALUES
  (1, 'Paralen', '2× denně, 500 mg', '10 tablet'),
  (1, 'Vitamin C', '1× denně, 1000 mg', '20 tablet'),
  (3, 'Amoksiklav', '3× denně, 875 mg/125 mg', '14 tablet');

-- 2) SELECTy s agregačními funkcemi a řazením

-- a) Všechny návštěvy pacienta č. 1 seřazené podle data sestupně
SELECT *
FROM navsteva
WHERE pacient_id = 1
ORDER BY datum DESC;

-- b) Počet návštěv podle každého lékaře, seřazeno podle nejvytíženějšího
SELECT 
  l.lekar_id,
  CONCAT(l.jmeno, ' ', l.prijmeni) AS lekar,
  COUNT(n.navsteva_id) AS pocet_navstev
FROM lekar l
JOIN navsteva n ON l.lekar_id = n.lekar_id
GROUP BY l.lekar_id
ORDER BY pocet_navstev DESC;

-- c) Průměrný počet návštěv na pacienta
SELECT 
  AVG(pocet_navstev) AS prumer_navstev_na_pacienta
FROM (
  SELECT pacient_id, COUNT(*) AS pocet_navstev
  FROM navsteva
  GROUP BY pacient_id
) AS sub;

-- d) Průměrný počet předpisů vystavených na jednu návštěvu
SELECT 
  AVG(pocet_predpisu) AS prumer_predpisu_na_navstevu
FROM (
  SELECT navsteva_id, COUNT(*) AS pocet_predpisu
  FROM predpis
  GROUP BY navsteva_id
) AS sub;

-- 3) UPDATE příklady

-- a) Označit návštěvu č. 2 jako uskutečněnou a přidat poznámku
UPDATE navsteva
SET stav = 'uskutecněna',
    poznamka = 'Pacient dorazil s mírným zpožděním'
WHERE navsteva_id = 2;

-- b) Změnit telefonní číslo pacientky č. 2
UPDATE pacient
SET telefon = '+420777123456'
WHERE pacient_id = 2;

-- c) Přesunout lékaře č. 1 do jiné ordinace
UPDATE ordinace
SET patro = 'přízemí', popis = 'oddělení interny'
WHERE ordinace_id = 1;
