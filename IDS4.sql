--| Name: IDS Project 2023/24 - Knihovna1
--|
--| Authors:
--| Čupr Marek: xcuprm01
--| Halva Jindřich: xhalva05
--|
--| Date: 4/2024
--| lang:CZECH


-- čištění ---------------------------------------------------------------------------------------------------

DROP TABLE Kniha CASCADE CONSTRAINTS;
DROP TABLE Exemplar CASCADE CONSTRAINTS;
DROP TABLE Osoba CASCADE CONSTRAINTS;
DROP TABLE Ctenar CASCADE CONSTRAINTS;
DROP TABLE Knihovnik CASCADE CONSTRAINTS;
DROP TABLE Rezervace CASCADE CONSTRAINTS;
DROP TABLE Vypujcka CASCADE CONSTRAINTS;

DROP MATERIALIZED VIEW rezervovane_knihy_m_view;

-- vytvoření databáze------------------------------------------------------------------------------------------

--generalizace:
--Ctenář a Knihovník připojeni pomocí cizích klíčů k entitě Osoba
CREATE TABLE Osoba(
    "rodne_cislo" CHAR(10) PRIMARY KEY CHECK ("rodne_cislo" BETWEEN '0000000000' AND '9999999999'),       --PK
    "jmeno" VARCHAR(50),
    "bydliste" VARCHAR(50),
    "telefon" CHAR(9) CHECK ("telefon" BETWEEN '000000000' AND '999999999'),
    "datum_narozeni" DATE
);

CREATE TABLE Knihovnik(
    "rodne_cislo" CHAR(10) PRIMARY KEY CHECK ("rodne_cislo" BETWEEN '0000000000' AND '9999999999'),       --PK
    "uvazek" VARCHAR(50),
    "zamestnanec_od_roku" DATE,
    CONSTRAINT "FK_rodne_k" FOREIGN KEY ("rodne_cislo") REFERENCES Osoba("rodne_cislo")
);

CREATE TABLE Ctenar(
    "rodne_cislo" CHAR(10) PRIMARY KEY CHECK ("rodne_cislo" BETWEEN '0000000000' AND '9999999999'),
    CONSTRAINT "FK_rodne_c" FOREIGN KEY ("rodne_cislo") REFERENCES Osoba("rodne_cislo")        --PK
);

CREATE TABLE Rezervace(
    "id_r" INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,      --PK
    "datum_provedeni" DATE,
    "datum_vypujcky" DATE,
    "rodne_cislo_c" CHAR(10) CHECK ("rodne_cislo_c" BETWEEN '0000000000' AND '9999999999'),    --FK     --FK
    CONSTRAINT "FK_rod_cislo_cis" FOREIGN KEY ("rodne_cislo_c") REFERENCES Ctenar("rodne_cislo")
);

CREATE TABLE Kniha(
    "id_k" INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,     --PK
    "autor" VARCHAR(50),
    "nazev" VARCHAR(50),
    "zanr" VARCHAR(50),
    "popis" VARCHAR(200),
    "datum vydani" DATE,
    "id_r" INTEGER NULL,        --FK
    CONSTRAINT "FK_id_res" FOREIGN KEY ("id_r") REFERENCES Rezervace("id_r")
);

CREATE TABLE Vypujcka(
    "id_v" INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,      --PK
    "datum_od" DATE,
    "datum_do" DATE,
    "pocet_knih" INTEGER,
    "rodne_cislo_c" CHAR(10),        --FK
    "rodne_cislo_k" CHAR(10),        --FK
    CONSTRAINT "FK_rod_cislo_c" FOREIGN KEY ("rodne_cislo_c") REFERENCES Ctenar("rodne_cislo"),
    CONSTRAINT "FK_rod_cislo_k" FOREIGN KEY ("rodne_cislo_k") REFERENCES Knihovnik("rodne_cislo")
);

CREATE TABLE Exemplar(
    "evidencni_cislo" VARCHAR(30) PRIMARY KEY,      --PK
    "porizovaci_cena" DECIMAL(10,2),
    "stav" VARCHAR(14)CHECK ("stav" IN ('nové', 'dobrý', 'opotřebovaný', 'špatný')),
    "id_k" INTEGER,         --FK
    "id_v" INTEGER NULL,    --FK
    CONSTRAINT "FK_id_k" FOREIGN KEY ("id_k") REFERENCES Kniha("id_k"),
    CONSTRAINT "FK_id_v" FOREIGN KEY ("id_v") REFERENCES Vypujcka("id_v")
);

-- vložení testovacích údajů---------------------------------------------------------------------------------------

INSERT INTO Osoba VALUES('0303073793','Jan Novák','Brno Moravak','000555888', TO_DATE('1992-06-05', 'YYYY-MM-DD'));
INSERT INTO Ctenar VALUES('0303073793');
INSERT INTO Osoba VALUES('0303073713','Marek Nodák','Brno Celni','000565888', TO_DATE('1942-06-05', 'YYYY-MM-DD'));
INSERT INTO Ctenar VALUES('0303073713');
INSERT INTO Osoba VALUES('0383973713','Pavel Nodák','Brno Merhautova','057565888', TO_DATE('1972-09-05', 'YYYY-MM-DD'));
INSERT INTO Ctenar VALUES('0383973713');
INSERT INTO Osoba VALUES('5183973252','Marie Štouračová','Praha Dlouhá','457567867', TO_DATE('2000-01-05', 'YYYY-MM-DD'));
INSERT INTO Ctenar VALUES('5183973252');

INSERT INTO Osoba VALUES('0303179793','Petr Papák','Brno Krpole','000455888', TO_DATE('1982-01-02', 'YYYY-MM-DD'));
INSERT INTO Knihovnik VALUES('0303179793','plný úvazek', TO_DATE('2002-01-02', 'YYYY-MM-DD'));
INSERT INTO Osoba VALUES('9803179793','Vladimír Jan','Polička Masarykova','254455888', TO_DATE('2000-11-12', 'YYYY-MM-DD'));
INSERT INTO Knihovnik VALUES('9803179793','částečný úvazek', TO_DATE('2022-01-02', 'YYYY-MM-DD'));

INSERT INTO Rezervace VALUES(DEFAULT,TO_DATE('2022-01-01', 'YYYY-MM-DD'), TO_DATE('2022-01-02', 'YYYY-MM-DD'), '0303073793');
INSERT INTO Rezervace VALUES(DEFAULT,TO_DATE('2022-01-01', 'YYYY-MM-DD'), TO_DATE('2022-01-02', 'YYYY-MM-DD'), '0383973713');

INSERT INTO Vypujcka VALUES(DEFAULT,TO_DATE('2022-01-02', 'YYYY-MM-DD'), TO_DATE('2022-01-30', 'YYYY-MM-DD'), '2', '0303073713', '0303179793');
INSERT INTO Vypujcka VALUES(DEFAULT,TO_DATE('2022-11-12', 'YYYY-MM-DD'), TO_DATE('2022-12-30', 'YYYY-MM-DD'), '1', '0383973713', '9803179793');
INSERT INTO Vypujcka VALUES(DEFAULT,TO_DATE('2024-01-10', 'YYYY-MM-DD'), TO_DATE('2024-05-20', 'YYYY-MM-DD'), '1', '0383973713', '9803179793');


INSERT INTO Kniha VALUES(DEFAULT, 'JAN PTÁČEK', 'název', 'román', 'nice kniha', TO_DATE('2024-01-01', 'YYYY-MM-DD'), 1);
INSERT INTO Kniha VALUES(DEFAULT, 'ANNA', 'sen', 'román', 'gut kniha', TO_DATE('2022-02-02', 'YYYY-MM-DD'), NULL);
INSERT INTO Kniha VALUES(DEFAULT, 'PAN MAJER', 'život', 'beletrie', 'nic moc kniha', TO_DATE('2012-02-02', 'YYYY-MM-DD'), 2);
INSERT INTO Kniha VALUES(DEFAULT, 'PAN MAJER', 'smutek', 'poezie', 'kniha se dobře čte', TO_DATE('2015-09-22', 'YYYY-MM-DD'), NULL);


INSERT INTO Exemplar VALUES('4454-55-6887-5','558.90', 'nové', 2, 1);
INSERT INTO Exemplar VALUES('57-555-687-55','388.90', 'špatný', 2, 1);
INSERT INTO Exemplar VALUES('1454-55-6887-5','568.90', 'opotřebovaný', 1, NULL);
INSERT INTO Exemplar VALUES('1254-515-6187-5','568.90', 'dobrý', 3, 2);
INSERT INTO Exemplar VALUES('2152-55-1181-69','230.00', 'nové', 4, NULL);
INSERT INTO Exemplar VALUES('2002-05-1081-99','210.90', 'dobrý', 4, 3);

-- Selecty -----------------------------------------------------------------------------------------------------
/*
--(k třetí části projektu)

--Spojení dvou tabulek...
--Zobrazí všechny knihovníky kteří pracují v knihovně na plný úvazek
--(cenní zaměstnanci)
SELECT "jmeno", "rodne_cislo", "zamestnanec_od_roku"
FROM Osoba NATURAL JOIN Knihovnik
WHERE "uvazek" = 'plný úvazek';

--Spojení dvou tabulek...
--Zobrazení konkrétních exemplářů, jež jsou v horším stavu
--(čas na obměnu?)
SELECT "autor", "nazev", "evidencni_cislo"
FROM Kniha NATURAL JOIN Exemplar
WHERE "stav" = 'špatný' OR "stav" = 'opotřebovaný'
ORDER BY "stav";

--Spojení tří tabulek...
--Vypíše vypůjčené exempláře, seřazené podle jména autora
--(vypůjčené)
SELECT "autor", "nazev", "evidencni_cislo"
FROM Kniha NATURAL JOIN Exemplar NATURAL JOIN Vypujcka
WHERE "id_v" IS NOT NULL
ORDER BY "autor";

--GROUP BY a agregacni funkce COUNT...
--Vypíše rezervované knihy, s počtem rezervací na daný titul
--(rezervované knihy)
SELECT "autor", "nazev", COUNT("id_r") AS "pocet_rezervací"
FROM Kniha NATURAL JOIN Rezervace
GROUP BY "autor", "nazev", "datum_provedeni"
ORDER BY "datum_provedeni";

--GROUP BY a agregacni funkce COUNT...
--Zobrazí knihy a počet vlastněných exemplářů dané knihy, seřezeno podle jména autora
--(počet exemplářů)
SELECT  "autor", "nazev", COUNT("id_k") AS "pocet exemplaru"
FROM Kniha NATURAL JOIN Exemplar
GROUP BY "autor", "nazev"
ORDER BY "autor";

--užití EXISTS
--Vypíše levné knihy, jejichž kupní cena se objevila alespoň jednou pod 300,-
--(levné knihy)
SELECT DISTINCT "autor", "nazev"
FROM Kniha
WHERE EXISTS(SELECT "evidencni_cislo" FROM Exemplar WHERE Kniha."id_k" = Exemplar."id_k" AND "porizovaci_cena" < 300.00)
ORDER BY "autor";

--Užití IN(SELECT)
--Vybere všechny čtenáře co nemají údaj o výpůjčce
--(neaktivní účty)
SELECT * FROM Ctenar
WHERE "rodne_cislo" NOT IN (SELECT "rodne_cislo_c" FROM Vypujcka);
*/

-- Select s WITH a CASE -----------------------------------------------------------------------------------------

--WITH založí dočasnou tabulku
--(zaměstnanci hodni odměny)
WITH zamestnanci AS (
    SELECT
        CASE
            WHEN "zamestnanec_od_roku" < TO_DATE('2022-01-01', 'YYYY-MM-DD') THEN 'Dlouhodobí zaměstnanci'
            ELSE 'Nováčci'
        END AS doba_ve_firme
    FROM Knihovnik
)
SELECT doba_ve_firme, COUNT(*) AS "rodne_cislo"
FROM zamestnanci
GROUP BY doba_ve_firme;

-- Triggers -----------------------------------------------------------------------------------------------------

--Trigger č.1 na kontrolu duplicitních hodnot telefonních čísel
CREATE OR REPLACE TRIGGER kontrola_duplicitnich_tel_cisel
    BEFORE INSERT OR UPDATE ON Osoba
    FOR EACH ROW
    DECLARE
        pocet_duplicit NUMBER;
    BEGIN
        --vyhledávání duplicit
        SELECT COUNT(*)
        INTO pocet_duplicit
        FROM Osoba
        WHERE "telefon" = :NEW."telefon";

        IF pocet_duplicit > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Zadané telefonní číslo jíž v databázi existuje (tudíž asi stejná osoba)');
        END IF;
END;
/

-- ukázka funkce triggeru č.1
-- INSERT INTO Osoba VALUES('0303179791','Petr páka','Brno Mendl. náměstí','000455888', TO_DATE('1982-01-02', 'YYYY-MM-DD'));


-- kontroluje pocet vypůjčených knih a validní rodné číslo čtenáře (zda je vedený v systému)
-- Trigger č.2 na kontrolu vypůjčky
CREATE OR REPLACE TRIGGER kontrola_vypujcky_knih
    BEFORE INSERT ON Vypujcka
    FOR EACH ROW
    DECLARE
        --proměnná uchovávající informaci o existenci uživatele
        ctenar_existuje NUMBER;
    BEGIN
        --podmínka: počet knih v intervalu <1, 6>
        IF :NEW."pocet_knih" > 6 OR
           :NEW."pocet_knih" < 1 THEN
            --vyhození chyby...nepovolí vloženi této hodnoty
            RAISE_APPLICATION_ERROR(-20001, 'Počet knih ve výpujčce musí být větší než 0 a menší než 6');
        END IF;

        -- vyhledávání čtenáře
        SELECT COUNT(*)
        INTO ctenar_existuje
        FROM Ctenar
        WHERE "rodne_cislo" = :NEW."rodne_cislo_c";

        -- zda nebyl nelezen žádný čtenář, vyhoď chybu
        IF ctenar_existuje = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Zadaný čtenář není vedený uživatel knihovny');
        END IF;
END;
/

-- ukázka funkce triggeru č.2
--INSERT INTO Vypujcka VALUES(DEFAULT,TO_DATE('2024-04-10', 'YYYY-MM-DD'), TO_DATE('2024-05-20', 'YYYY-MM-DD'), '1', '0083973713', '9803179793');

-- Procedury ----------------------------------------------------------------------------------------------------

SET SERVEROUTPUT ON;

-- procedura č.1
-- (%TYPE : přebírá datový typ původního sloupce v tabulce)
-- následující procedura vkládá do tabulky Kniha nový záznam
CREATE OR REPLACE PROCEDURE nova_kniha (
    autor Kniha."autor"%TYPE,
    nazev Kniha."nazev"%TYPE,
    zanr Kniha."zanr"%TYPE,
    popis Kniha."popis"%TYPE,
    datum_vydani Kniha."datum vydani"%TYPE,
    cislo_rezervace Kniha."id_r"%TYPE)
IS
    kniha_uz_existuje NUMBER := 0;
BEGIN
    -- ověření že kniha ještě v systému neexistuje
    SELECT COUNT(*)
    INTO kniha_uz_existuje
    FROM Kniha
    WHERE "autor" = autor AND "nazev" = nazev;

    --pokud již existuje, vyhodíme chybu
    IF kniha_uz_existuje > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Kniha již v systému existuje');
    END IF;

    -- vložení nové knihy
    INSERT INTO Kniha VALUES(DEFAULT,autor, nazev, zanr, popis, datum_vydani, cislo_rezervace);
-- zachycení výjimek
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Zachycena výjimka u procedury nova_kniha');
END;
/

-- ukázka funkčnosti procedury č.1

--před vložením knihy
SELECT * FROM Kniha;

BEGIN --vložení knihy přes proceduru
    nova_kniha('PEPA','kniha o zivote', 'leporelo', 'docela dobré čtení', TO_DATE('2021-10-25', 'YYYY-MM-DD'), NULL);
END;
/

--po vložení knihy
SELECT * FROM Kniha;
--------------------------------

-- procedura č.2
-- vypíše všechny udáje o knihách v databázi za pomoci kurzoru
CREATE OR REPLACE PROCEDURE vypis_knih
IS
    -- kurzor umožní iterovat přes jednotlivé záznamy
    CURSOR knihy_kurzor IS
        SELECT "autor", "nazev", "zanr", "popis", "datum vydani"
        FROM Kniha;
BEGIN
    --vypsání záznamů
    FOR kniha IN knihy_kurzor LOOP
        DBMS_OUTPUT.PUT_LINE(kniha."autor" || ' | Název: ' || kniha."nazev" || ' | Žánr: ' || kniha."zanr" || ' | Popis: ' || kniha."popis" || ' | Datum vydání: ' || TO_CHAR(kniha."datum vydani", 'YYYY-MM-DD'));
    END LOOP;
END;
/

-- ukázka funkce procedury č.2
BEGIN
    vypis_knih();
END;
/

-- Práva pro druhého člena týmu ---------------------------------------------------------------------------------

GRANT ALL ON Kniha TO XCUPRM01;
GRANT ALL ON Exemplar TO XCUPRM01;
GRANT ALL ON Osoba TO XCUPRM01;
GRANT ALL ON Ctenar TO XCUPRM01;
GRANT ALL ON Knihovnik TO XCUPRM01;
GRANT ALL ON Rezervace TO XCUPRM01;
GRANT ALL ON Vypujcka TO XCUPRM01;

-- Materializovaný pohled ---------------------------------------------------------------------------------------

-- materializovaný pohled na rezervované knihy (rychlý přístup, k často použiváným informacím)
CREATE MATERIALIZED VIEW rezervovane_knihy_m_view
CACHE
REFRESH ON COMMIT
AS
    SELECT "nazev", "autor", "rodne_cislo_c" FROM Kniha k JOIN Rezervace r ON k."id_r"= r."id_r";

--práva k tabulce pro druhého člena týmu
GRANT ALL ON rezervovane_knihy_m_view TO XCUPRM01;

--m_view před vložením
SELECT * FROM rezervovane_knihy_m_view;

--Ukázka práce s m_view:

--přidání rezervace
INSERT INTO Rezervace VALUES(DEFAULT,TO_DATE('2024-02-05', 'YYYY-MM-DD'), TO_DATE('2024-02-09', 'YYYY-MM-DD'), '0383973713');
UPDATE Kniha
SET "id_r" = 3
WHERE "nazev" = 'sen' AND "autor" = 'ANNA';

COMMIT;

--m_view po commitu
SELECT * FROM rezervovane_knihy_m_view;




-- Index a EXPLAIN PLAN --------------------------------------------------------------------------------------------------------
    -- NEIMPLEMENTOVÁNO




-- KONEC SOUBORU -------------------------------------------------------------------------------------------------