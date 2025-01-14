-------------------------------------------------------------------------------
-- PACKAGE SPEC
-------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE PKG_PROPERTY_MGT AS

    -- 1) Procédure pour insérer un nouveau propriétaire
    PROCEDURE create_owner(
        p_owner_name   IN  VARCHAR2,
        p_contact_info IN  VARCHAR2,
        p_new_id       OUT NUMBER
    );

    -- 2) Procédure pour mettre à jour les coordonnées d’un propriétaire
    PROCEDURE update_owner_contact(
        p_owner_id     IN NUMBER,
        p_new_contact  IN VARCHAR2
    );

    -- 3) Procédure pour créer une nouvelle propriété
    PROCEDURE create_property(
        p_owner_id           IN NUMBER,
        p_address            IN VARCHAR2,
        p_property_type      IN VARCHAR2,
        p_listing_price      IN NUMBER,
        p_property_id        OUT NUMBER
    );

    -- 4) Procédure pour ajouter une installation annexe (ancillary facility)
    PROCEDURE add_ancillary_facility(
        p_property_id  IN NUMBER,
        p_facility_type IN VARCHAR2,
        p_description  IN VARCHAR2,
        p_facility_id  OUT NUMBER
    );

    -- 5) Procédure pour calculer et mettre à jour la commission d’une transaction
    PROCEDURE calc_and_update_commission(
        p_transaction_id IN NUMBER,
        p_percentage     IN NUMBER DEFAULT 5
    );

END PKG_PROPERTY_MGT;
/


-------------------------------------------------------------------------------
-- PACKAGE BODY
-------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY PKG_PROPERTY_MGT AS

    ----------------------------------------------------------------------------
    -- 1) create_owner
    -- Insère un nouveau propriétaire dans la table OWNER
    -- et renvoie l'ID généré (p_new_id) via un paramètre OUT
    ----------------------------------------------------------------------------
    PROCEDURE create_owner(
        p_owner_name   IN  VARCHAR2,
        p_contact_info IN  VARCHAR2,
        p_new_id       OUT NUMBER
    ) IS
    BEGIN
        INSERT INTO OWNER (owner_id, owner_name, contact_info)
        VALUES (DEFAULT, p_owner_name, p_contact_info)
        RETURNING owner_id INTO p_new_id;

        -- Optionnel : affichage console (DBMS_OUTPUT) pour debug
        DBMS_OUTPUT.PUT_LINE('create_owner - Nouvel owner_id=' || p_new_id);
    END create_owner;

    ----------------------------------------------------------------------------
    -- 2) update_owner_contact
    -- Met à jour le champ contact_info du propriétaire p_owner_id
    ----------------------------------------------------------------------------
    PROCEDURE update_owner_contact(
        p_owner_id    IN NUMBER,
        p_new_contact IN VARCHAR2
    ) IS
    BEGIN
        UPDATE OWNER
           SET contact_info = p_new_contact
         WHERE owner_id = p_owner_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20010, 
                'Aucun propriétaire trouvé avec owner_id=' || p_owner_id
            );
        END IF;

        DBMS_OUTPUT.PUT_LINE('update_owner_contact - Update OK pour owner_id=' || p_owner_id);
    END update_owner_contact;

    ----------------------------------------------------------------------------
    -- 3) create_property
    -- Crée une nouvelle propriété associée à un owner_id existant
    -- et renvoie l'ID généré (p_property_id) via un paramètre OUT
    ----------------------------------------------------------------------------
    PROCEDURE create_property(
        p_owner_id      IN NUMBER,
        p_address       IN VARCHAR2,
        p_property_type IN VARCHAR2,
        p_listing_price IN NUMBER,
        p_property_id   OUT NUMBER
    ) IS
    BEGIN
        -- Vérification (simplifiée) : l'owner doit exister
        DECLARE
            v_count NUMBER;
        BEGIN
            SELECT COUNT(*) INTO v_count 
              FROM OWNER
             WHERE owner_id = p_owner_id;

            IF v_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20011, 'Le propriétaire n''existe pas !');
            END IF;
        END;

        INSERT INTO PROPERTY (
            property_id, 
            owner_id, 
            address, 
            property_type, 
            listing_price
        )
        VALUES (
            DEFAULT,
            p_owner_id,
            p_address,
            p_property_type,
            p_listing_price
        )
        RETURNING property_id INTO p_property_id;

        DBMS_OUTPUT.PUT_LINE('create_property - Nouvelle propriété=' || p_property_id);
    END create_property;

    ----------------------------------------------------------------------------
    -- 4) add_ancillary_facility
    -- Ajoute une facility (garage, piscine, etc.) à une propriété existante
    ----------------------------------------------------------------------------
    PROCEDURE add_ancillary_facility(
        p_property_id  IN NUMBER,
        p_facility_type IN VARCHAR2,
        p_description  IN VARCHAR2,
        p_facility_id  OUT NUMBER
    ) IS
    BEGIN
        INSERT INTO ANCILLARY_FACILITY (
            facility_id,
            property_id,
            facility_type,
            description
        )
        VALUES (
            DEFAULT,
            p_property_id,
            p_facility_type,
            p_description
        )
        RETURNING facility_id INTO p_facility_id;

        DBMS_OUTPUT.PUT_LINE('add_ancillary_facility - Nouvelle facility=' || p_facility_id);
    END add_ancillary_facility;

    ----------------------------------------------------------------------------
    -- 5) calc_and_update_commission
    -- Calcule la commission dans LUX_TRANSACTION
    -- = 5000 + (transaction_amount * p_percentage / 100)
    -- et met à jour la ligne
    ----------------------------------------------------------------------------
    PROCEDURE calc_and_update_commission(
        p_transaction_id IN NUMBER,
        p_percentage     IN NUMBER DEFAULT 5
    ) IS
        v_amount NUMBER;
        v_comm   NUMBER;
    BEGIN
        -- On récupère transaction_amount
        SELECT transaction_amount
          INTO v_amount
          FROM LUX_TRANSACTION
         WHERE transaction_id = p_transaction_id;

        -- Commission = 5000 + (p_percentage% du prix)
        v_comm := 5000 + (v_amount * p_percentage / 100);

        UPDATE LUX_TRANSACTION
           SET commission_amount = v_comm
         WHERE transaction_id = p_transaction_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20012,
                'calc_and_update_commission : transaction_id=' || p_transaction_id || ' introuvable.'
            );
        END IF;

        DBMS_OUTPUT.PUT_LINE('calc_and_update_commission - commission=' || v_comm 
                             || ' mise à jour pour transaction_id=' || p_transaction_id);
    END calc_and_update_commission;

END PKG_PROPERTY_MGT;
/
