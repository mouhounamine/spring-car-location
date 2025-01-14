-- 1) Insérer une transaction sans transaction_date
INSERT INTO LUX_TRANSACTION (transaction_id, property_id, transaction_amount, commission_amount, fiscal_period)
VALUES (9999, 1001, 500000, NULL, '2025-Q1');

-- 2) Vérifier que la date a bien été mise à SYSDATE
SELECT transaction_id, transaction_date
FROM LUX_TRANSACTION
WHERE transaction_id = 9999;

-- 1) Insérer une transaction (avec transaction_date facultatif)
INSERT INTO LUX_TRANSACTION (transaction_id, property_id, transaction_amount, fiscal_period)
VALUES (9998, 1001, 500000, '2025-Q1');

-- 2) Contrôler la commission_amount
SELECT transaction_id, transaction_amount, commission_amount
FROM LUX_TRANSACTION
WHERE transaction_id = 9998;

-- 1) Tentative d'insertion avec listing_price négatif
INSERT INTO PROPERTY (property_id, owner_id, listing_price)
VALUES (9000, 101, -1000);

UPDATE PROPERTY
   SET listing_price = -500
 WHERE property_id = 1001;

-- 1) Insertion d'une nouvelle visite dans TOUR
INSERT INTO TOUR (tour_id, property_id, client_id, tour_date, comments)
VALUES (8888, 1001, 201, SYSDATE, 'Test Tour trigger');

-- 2) Vérifier la table de logs TOUR_LOG
SELECT log_id, tour_id, log_date, message
FROM TOUR_LOG
WHERE tour_id = 8888;

-- 1) Insertion d'une transaction sur un property_id inconnu
INSERT INTO LUX_TRANSACTION (transaction_id, property_id, transaction_amount, fiscal_period)
VALUES (7777, 9999, 50000, '2025-Q2');

-- 2) Attendu : Erreur, car 9999 n'existe pas dans PROPERTY ou n'a pas de propriétaire

-- Essayer de mettre un property_type non valide
UPDATE PROPERTY
   SET property_type = 'UnknownType'
 WHERE property_id = 1001;
-- Attendu : Violation de contrainte

-- Essayer de forcer un commission_amount négatif
UPDATE LUX_TRANSACTION
   SET commission_amount = -500
 WHERE transaction_id = 9998;
-- Attendu : Violation de contrainte (commission_amount >= 0)

-- Insérer un OWNER avec contact_info déjà utilisé par un autre OWNER
INSERT INTO OWNER (owner_id, owner_name, contact_info)
VALUES (202, 'Duplicate Contact', 'john.doe@luxury.com');
-- Attendu : Violation de contrainte UNIQUE

-- Insérer ou mettre à jour un property_condition hors liste (new, excellent, good, needs_renovation)
INSERT INTO PROPERTY (property_id, owner_id, property_condition)
VALUES (888, 101, 'random_condition');
-- Attendu : Violation de contrainte

-- Si vous avez un champ pourcent_commission :
INSERT INTO LUX_TRANSACTION (transaction_id, property_id, transaction_amount, pourcent_commission)
VALUES (6666, 1001, 10000, 10);
-- Attendu : Erreur, si la contrainte impose que ce pourcentage soit entre 3 et 7

-- Activer DBMS_OUTPUT si vous voulez voir les PUT_LINE :
SET SERVEROUTPUT ON;

DECLARE
  v_new_owner_id NUMBER;
BEGIN
  PKG_PROPERTY_MGT.create_owner(
    p_owner_name   => 'New Owner',
    p_contact_info => 'owner.new@luxprop.com',
    p_new_id       => v_new_owner_id
  );
  DBMS_OUTPUT.PUT_LINE('Proc create_owner - Nouveau owner_id=' || v_new_owner_id);
END;
/

-- update_owner_contact
BEGIN
  PKG_PROPERTY_MGT.update_owner_contact(
    p_owner_id    => 101,
    p_new_contact => 'john.doe-updated@luxury.com'
  );
END;
/

-- Vérifier ensuite :
SELECT * FROM OWNER WHERE owner_id = 101;

-- create_property
DECLARE
  v_prop_id NUMBER;
BEGIN
  PKG_PROPERTY_MGT.create_property(
    p_owner_id      => 101, 
    p_address       => '123 New St, SomeCity, 12345, MyCountry',
    p_property_type => 'villa',
    p_listing_price => 950000,
    p_property_id   => v_prop_id
  );
  DBMS_OUTPUT.PUT_LINE('Proc create_property - Nouveau property_id=' || v_prop_id);
END;
/

-- add_ancillary_facility
DECLARE
  v_fac_id NUMBER;
BEGIN
  PKG_PROPERTY_MGT.add_ancillary_facility(
    p_property_id   => 1001,     -- un property_id existant
    p_facility_type => 'wine_cellar',
    p_description   => 'Underground wine cellar with 1000 bottles capacity',
    p_facility_id   => v_fac_id
  );
  DBMS_OUTPUT.PUT_LINE('Proc add_ancillary_facility - Nouvelle facility_id=' || v_fac_id);
END;
/


-- calc_and_update_commission
BEGIN
  PKG_PROPERTY_MGT.calc_and_update_commission(
    p_transaction_id => 9998,  -- la transaction qu'on a insérée plus haut
    p_percentage     => 7      -- on veut tester 7%
  );
END;
/

-- Vérifier :
SELECT transaction_id, transaction_amount, commission_amount
FROM LUX_TRANSACTION
WHERE transaction_id = 9998;


-- Insérer un objet "property_t" dans la table PROPERTY_OBJ_TAB
INSERT INTO PROPERTY_OBJ_TAB VALUES(
  property_t(
    1234,
    address_t('22 Avenue de la Liberté', 'LuxCity', '12345', 'Luxembourg'),
    'mansion',
    4000000
  )
);

-- Vérifier
SELECT p.property_id, p.address.country, p.listing_price
FROM PROPERTY_OBJ_TAB p
WHERE p.property_id = 1234;

-- Insérer un "villa_t" (héritage) dans VILLA_OBJ_TAB
INSERT INTO VILLA_OBJ_TAB VALUES(
  villa_t(
    2345,
    address_t('Route de la Plage', 'Cannes', '06400', 'France'),
    'villa',
    2800000,
    2,   -- number_of_floors
    'Y' -- has_garden
  )
);

-- Vérifier
SELECT v.property_id, v.property_type, v.number_of_floors, v.has_garden
FROM VILLA_OBJ_TAB v
WHERE v.property_id = 2345;

