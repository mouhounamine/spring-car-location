------------------------------------------------------------------------------
-- Trigger 1 : TRG_SET_DEFAULT_DATE
-- Si on insère une transaction sans date, on met SYSDATE.
------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_SET_DEFAULT_DATE
BEFORE INSERT ON LUX_TRANSACTION
FOR EACH ROW
BEGIN
    IF :NEW.transaction_date IS NULL THEN
        :NEW.transaction_date := SYSDATE;
    END IF;
END;
/

------------------------------------------------------------------------------
-- Trigger 2 : TRG_COMMISSION_CALC
-- Calcule la commission = 5000 + (pourcent * transaction_amount / 100)
-- Admettons qu'on stocke un pourcent par défaut ou qu'on détermine la fourchette
------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_COMMISSION_CALC
BEFORE INSERT OR UPDATE ON LUX_TRANSACTION
FOR EACH ROW
DECLARE
    v_percent NUMBER := 5;  -- Valeur par défaut 5%
BEGIN
    -- Commission = 5000 + (v_percent% du prix)
    IF :NEW.transaction_amount IS NOT NULL THEN
        :NEW.commission_amount := 5000 + (:NEW.transaction_amount * v_percent/100);
    END IF;
END;
/

------------------------------------------------------------------------------
-- Trigger 3 : TRG_NO_NEGATIVE_LISTING_PRICE
-- Empêche un listing_price négatif à l'insertion ou à la mise à jour.
------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_NO_NEGATIVE_LISTING_PRICE
BEFORE INSERT OR UPDATE ON PROPERTY
FOR EACH ROW
BEGIN
    IF :NEW.listing_price < 0 THEN
        RAISE_APPLICATION_ERROR(
            -20000,
            'Impossible d''insérer ou de modifier un prix de listing négatif !'
        );
    END IF;
END;
/


------------------------------------------------------------------------------
-- Trigger 4 : TRG_LOG_NEW_TOUR
-- Lorsqu'on insère une nouvelle visite, on log l'opération dans TOUR_LOG
------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_LOG_NEW_TOUR
AFTER INSERT ON TOUR
FOR EACH ROW
BEGIN
    INSERT INTO TOUR_LOG (tour_id, log_date, message)
    VALUES (
        :NEW.tour_id,
        SYSDATE,
        'Nouvelle visite insérée: tour_id=' || :NEW.tour_id
    );
END;
/


------------------------------------------------------------------------------
-- Trigger 5 : TRG_CHECK_PROPERTY_OWNER
-- Avant de créer une transaction, on vérifie que le PROPERTY a bien un OWNER.
------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_CHECK_PROPERTY_OWNER
BEFORE INSERT ON LUX_TRANSACTION
FOR EACH ROW
DECLARE
    v_owner_id NUMBER;
BEGIN
    -- Récupérer l'owner_id du bien concerné
    SELECT owner_id
      INTO v_owner_id
      FROM PROPERTY
     WHERE property_id = :NEW.property_id;
     
    -- Si on ne trouve pas de propriétaire (cas improbable si la FK est bien définie),
    -- on lève une exception.
    IF v_owner_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'La propriété associée n''a pas de propriétaire !');
    END IF;
END;
/
