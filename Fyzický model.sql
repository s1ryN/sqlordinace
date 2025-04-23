-- 1) Vytvoření databáze
CREATE DATABASE IF NOT EXISTS ordinace;
USE ordinace;

-- 2) Tabulka pacientů
CREATE TABLE pacient (
  pacient_id       INT         AUTO_INCREMENT  PRIMARY KEY,
  jmeno            VARCHAR(50) NOT NULL,
  prijmeni         VARCHAR(50) NOT NULL,
  datum_narozeni   DATE        NOT NULL,
  pohlavi          ENUM('M','Z') NOT NULL,
  telefon          VARCHAR(20),
  email            VARCHAR(100) UNIQUE,
  adresa_ulice     VARCHAR(100),
  adresa_mesto     VARCHAR(50),
  adresa_psc       VARCHAR(10),
  poznamka         TEXT
);

-- 3) Tabulka lékařů
CREATE TABLE lekar (
  lekar_id         INT            AUTO_INCREMENT PRIMARY KEY,
  jmeno            VARCHAR(50)    NOT NULL,
  prijmeni         VARCHAR(50)    NOT NULL,
  specializace     VARCHAR(100),
  telefon_sluzba   VARCHAR(20),
  email_sluzba     VARCHAR(100) UNIQUE,
  poznamka         TEXT
);

-- 4) Tabulka ordinací (pro označení místnosti nebo pracoviště)
CREATE TABLE ordinace (
  ordinace_id      INT         AUTO_INCREMENT PRIMARY KEY,
  cislo            VARCHAR(10) NOT NULL,
  popis            VARCHAR(100),
  patro            VARCHAR(20)
);

-- 5) Tabulka návštěv (objednávek/pacientských sezení)
CREATE TABLE navsteva (
  navsteva_id      INT         AUTO_INCREMENT PRIMARY KEY,
  pacient_id       INT         NOT NULL,
  lekar_id         INT         NOT NULL,
  ordinace_id      INT         NOT NULL,
  datum            DATE        NOT NULL,
  cas              TIME        NOT NULL,
  stav             ENUM('plánována','uskutecněna','zrusena') NOT NULL DEFAULT 'plánována',
  vytvoreno        TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  poznamka         TEXT,
  FOREIGN KEY (pacient_id)  REFERENCES pacient(pacient_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (lekar_id)    REFERENCES lekar(lekar_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (ordinace_id) REFERENCES ordinace(ordinace_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 6) Tabulka diagnóz z jednotlivých návštěv
CREATE TABLE diagnoza (
  diagnoza_id      INT         AUTO_INCREMENT PRIMARY KEY,
  navsteva_id      INT         NOT NULL,
  kod_ICD           VARCHAR(10),
  popis            VARCHAR(255) NOT NULL,
  FOREIGN KEY (navsteva_id) REFERENCES navsteva(navsteva_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- 7) Tabulka předpisů (receptů) vystavených při návštěvě
CREATE TABLE predpis (
  predpis_id       INT         AUTO_INCREMENT PRIMARY KEY,
  navsteva_id      INT         NOT NULL,
  lek              VARCHAR(100) NOT NULL,
  davkovani        VARCHAR(100),
  mnozstvi         VARCHAR(50),
  poznamka         TEXT,
  FOREIGN KEY (navsteva_id) REFERENCES navsteva(navsteva_id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- 8) Volitelné: tabulka uživatelů systému pro přihlášení
CREATE TABLE uzivatel (
  uzivatel_id      INT         AUTO_INCREMENT PRIMARY KEY,
  username         VARCHAR(50) NOT NULL UNIQUE,
  heslo_hash       CHAR(60)    NOT NULL,
  role             ENUM('admin','lekar','sestra') NOT NULL DEFAULT 'sestra',
  lekar_id         INT,
  FOREIGN KEY (lekar_id) REFERENCES lekar(lekar_id)
    ON DELETE SET NULL ON UPDATE CASCADE
);
