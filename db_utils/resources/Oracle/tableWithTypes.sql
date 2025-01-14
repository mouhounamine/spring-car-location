-------------------------------------------------------------------------------
-- 1) Type address_t
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE address_t AS OBJECT (
    street   VARCHAR2(100),
    city     VARCHAR2(100),
    zip_code VARCHAR2(10),
    country  VARCHAR2(50)
);
/

-------------------------------------------------------------------------------
-- 2) Type owner_t
-- Un propriétaire, avec un ID et ses coordonnées.
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE owner_t AS OBJECT (
    owner_id     NUMBER,
    owner_name   VARCHAR2(100),
    contact_info VARCHAR2(150)
);
/

-------------------------------------------------------------------------------
-- 3) Type property_t
-- Un bien immobilier générique (pas FINAL, on va créer des sous-types).
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE property_t AS OBJECT (
    property_id       NUMBER,
    address           address_t,      -- attribut de type address_t
    property_type     VARCHAR2(50),
    listing_price     NUMBER
) NOT FINAL;
/

-------------------------------------------------------------------------------
-- 4) Type facility_t
-- Représente une installation annexe (garage, piscine, etc.).
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE facility_t AS OBJECT (
    facility_id   NUMBER,
    facility_type VARCHAR2(50),
    description   VARCHAR2(200)
);
/

-------------------------------------------------------------------------------
-- 5) Type transaction_t
-- Représente une transaction (vente ou location).
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE transaction_t AS OBJECT (
    transaction_id     NUMBER,
    property_id        NUMBER,
    transaction_date   DATE,
    transaction_amount NUMBER,
    commission_amount  NUMBER
);
/


-------------------------------------------------------------------------------
-- Sous-type villa_t
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE villa_t UNDER property_t (
    number_of_floors  NUMBER,
    has_garden        CHAR(1)     -- 'Y' or 'N'
);
/

-------------------------------------------------------------------------------
-- Sous-type apartment_t
-------------------------------------------------------------------------------
CREATE OR REPLACE TYPE apartment_t UNDER property_t (
    floor_level       NUMBER,
    has_elevator      CHAR(1)     -- 'Y' or 'N'
);
/


CREATE TABLE OWNER_OBJ_TAB OF owner_t (
    CONSTRAINT owner_obj_tab_pk PRIMARY KEY (owner_id)
)
OBJECT IDENTIFIER IS PRIMARY KEY;

CREATE TABLE PROPERTY_OBJ_TAB OF property_t (
    CONSTRAINT property_obj_tab_pk PRIMARY KEY (property_id)
)
OBJECT IDENTIFIER IS PRIMARY KEY;

CREATE TABLE VILLA_OBJ_TAB OF villa_t
  UNDER PROPERTY_OBJ_TAB
  (
    CONSTRAINT villa_obj_tab_pk PRIMARY KEY (property_id)
  );


CREATE TABLE APARTMENT_OBJ_TAB OF apartment_t
  UNDER PROPERTY_OBJ_TAB
  (
    CONSTRAINT apt_obj_tab_pk PRIMARY KEY (property_id)
  );


CREATE TABLE FACILITY_OBJ_TAB OF facility_t (
    CONSTRAINT facility_obj_tab_pk PRIMARY KEY (facility_id)
)
OBJECT IDENTIFIER IS PRIMARY KEY;

CREATE TABLE TRANSACTION_OBJ_TAB OF transaction_t (
    CONSTRAINT transaction_obj_tab_pk PRIMARY KEY (transaction_id)
)
OBJECT IDENTIFIER IS PRIMARY KEY;


INSERT INTO OWNER_OBJ_TAB VALUES(
  owner_t(
    101,
    'John Doe',
    'john.doe@luxury.com'
  )
);

INSERT INTO OWNER_OBJ_TAB VALUES(
  owner_t(
    102,
    'Jane Smith',
    'jane.smith@luxury.com'
  )
);

INSERT INTO PROPERTY_OBJ_TAB VALUES(
  property_t(
    1001,
    address_t('1 Rue Royale', 'Paris', '75008', 'France'),
    'mansion',
    3000000
  )
);

INSERT INTO VILLA_OBJ_TAB VALUES(
  villa_t(
    2001,
    address_t('Chemin du Paradis', 'Nice', '06000', 'France'),
    'villa',             -- property_type (hérité)
    2500000,            -- listing_price (hérité)
    2,                  -- number_of_floors
    'Y'                 -- has_garden
  )
);

INSERT INTO APARTMENT_OBJ_TAB VALUES(
  apartment_t(
    3001,
    address_t('5 Boulevard Haussmann', 'Paris', '75009', 'France'),
    'apartment',
    1200000,
    5,   -- floor_level
    'Y'  -- has_elevator
  )
);

INSERT INTO FACILITY_OBJ_TAB VALUES(
  facility_t(
    501,
    'pool',
    'Indoor heated swimming pool'
  )
);

INSERT INTO FACILITY_OBJ_TAB VALUES(
  facility_t(
    502,
    'garage',
    'Large garage for 3 cars'
  )
);

INSERT INTO TRANSACTION_OBJ_TAB VALUES(
  transaction_t(
    10001,
    1001,           -- property_id = 1001 (celui de la PROPERTY_OBJ_TAB)
    DATE '2025-01-05',
    1800000,
    0               -- commission_amount (pour l'instant on le met à 0)
  )
);

UPDATE PROPERTY_OBJ_TAB p
   SET p.listing_price = 3200000
 WHERE p.property_id = 1001;

UPDATE PROPERTY_OBJ_TAB p
   SET p.address.zip_code = '75001'
 WHERE p.property_id = 1001;

UPDATE VILLA_OBJ_TAB v
   SET v.has_garden = 'N'
 WHERE v.property_id = 2001;
