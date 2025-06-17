# 🏥 Databáze Ordinace

Tento projekt obsahuje návrh databáze pro evidenci pacientů, lékařů, návštěv, diagnóz a předpisů v ambulanci nebo menším zdravotnickém zařízení.

## 📂 Struktura databáze

Databáze se jmenuje `ordinace` a obsahuje následující tabulky:

### 1. `pacient`
Evidence pacientů.

| Sloupec         | Typ               | Popis                          |
|-----------------|------------------|--------------------------------|
| pacient_id      | `INT`            | Primární klíč                  |
| jmeno           | `VARCHAR(50)`    | Jméno                          |
| prijmeni        | `VARCHAR(50)`    | Příjmení                       |
| datum_narozeni  | `DATE`           | Datum narození                 |
| pohlavi         | `ENUM('M','Z')`  | Pohlaví (Muž/Žena)             |
| telefon         | `VARCHAR(20)`    | Telefon                        |
| email           | `VARCHAR(100)`   | Email (unikátní)               |
| adresa_ulice    | `VARCHAR(100)`   | Ulice                          |
| adresa_mesto    | `VARCHAR(50)`    | Město                          |
| adresa_psc      | `VARCHAR(10)`    | PSČ                            |
| poznamka        | `TEXT`           | Volitelná poznámka             |

### 2. `lekar`
Seznam lékařů a jejich specializací.

| Sloupec         | Typ               | Popis                          |
|-----------------|------------------|--------------------------------|
| lekar_id        | `INT`            | Primární klíč                  |
| jmeno           | `VARCHAR(50)`    | Jméno                          |
| prijmeni        | `VARCHAR(50)`    | Příjmení                       |
| specializace    | `VARCHAR(100)`   | Specializace                   |
| telefon_sluzba  | `VARCHAR(20)`    | Telefon                        |
| email_sluzba    | `VARCHAR(100)`   | Email (unikátní)               |
| poznamka        | `TEXT`           | Volitelná poznámka             |

### 3. `ordinace`
Seznam ordinací (místností).

| Sloupec     | Typ             | Popis                          |
|-------------|------------------|--------------------------------|
| ordinace_id | `INT`            | Primární klíč                  |
| cislo       | `VARCHAR(10)`    | Číslo ordinace                 |
| popis       | `VARCHAR(100)`   | Popis                          |
| patro       | `VARCHAR(20)`    | Patro                          |

### 4. `navsteva`
Záznamy o návštěvách pacientů.

| Sloupec     | Typ                     | Popis                          |
|-------------|--------------------------|--------------------------------|
| navsteva_id | `INT`                    | Primární klíč                  |
| pacient_id  | `INT`                    | FK na `pacient`                |
| lekar_id    | `INT`                    | FK na `lekar`                  |
| ordinace_id | `INT`                    | FK na `ordinace`               |
| datum       | `DATE`                   | Datum návštěvy                 |
| cas         | `TIME`                   | Čas návštěvy                   |
| stav        | `ENUM`                   | Stav (`plánována`, `uskutečněna`, `zrušena`) |
| vytvoreno   | `TIMESTAMP`              | Datum vytvoření                |
| poznamka    | `TEXT`                   | Poznámka                       |

### 5. `diagnoza`
Diagnózy přiřazené k návštěvám.

| Sloupec       | Typ             | Popis                          |
|---------------|------------------|--------------------------------|
| diagnoza_id   | `INT`            | Primární klíč                  |
| navsteva_id   | `INT`            | FK na `navsteva`               |
| kod_ICD       | `VARCHAR(10)`    | Kód diagnózy                   |
| popis         | `VARCHAR(255)`   | Popis diagnózy                 |

### 6. `predpis`
Předpisy (léky) vystavené při návštěvě.

| Sloupec     | Typ             | Popis                          |
|-------------|------------------|--------------------------------|
| predpis_id  | `INT`            | Primární klíč                  |
| navsteva_id | `INT`            | FK na `navsteva`               |
| lek         | `VARCHAR(100)`   | Název léku                     |
| davkovani   | `VARCHAR(100)`   | Dávkování                      |
| mnozstvi    | `VARCHAR(50)`    | Množství                       |
| poznamka    | `TEXT`           | Volitelná poznámka             |

### 7. `uzivatel`
Uživatelé systému pro přístup (např. lékaři, sestry, administrátor).

| Sloupec       | Typ                      | Popis                          |
|---------------|---------------------------|--------------------------------|
| uzivatel_id   | `INT`                     | Primární klíč                  |
| username      | `VARCHAR(50)`             | Přihlašovací jméno (unikátní) |
| heslo_hash    | `CHAR(60)`                | Heslo (bcrypt hash)           |
| role          | `ENUM('admin','lekar','sestra')` | Role uživatele       |
| lekar_id      | `INT`                     | FK na `lekar` (volitelné)     |
