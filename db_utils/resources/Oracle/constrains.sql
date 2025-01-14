-- 1) CHECK pour property_type
ALTER TABLE PROPERTY
ADD CONSTRAINT CHK_PROPERTY_TYPE
CHECK (property_type IN ('mansion','penthouse','villa','apartment'));

-- 2) CHECK pour commission_amount non-négatif
ALTER TABLE LUX_TRANSACTION
ADD CONSTRAINT CHK_COMMISSION_POSITIVE
CHECK (commission_amount >= 0);

-- 3) UNIQUE sur contact_info d'un OWNER (exemple)
ALTER TABLE OWNER
ADD CONSTRAINT UQ_OWNER_CONTACT
UNIQUE (contact_info);

-- 4) CHECK sur la condition de la propriété
ALTER TABLE PROPERTY
ADD CONSTRAINT CHK_PROPERTY_CONDITION
CHECK (property_condition IN ('new','excellent','good','needs_renovation'));

-- 5) (Optionnel) si vous avez un champ pourcent_commission, ex. dans LUX_TRANSACTION
--    alors vous faites :
-- ALTER TABLE LUX_TRANSACTION
-- ADD CONSTRAINT CHK_COMMISSION_RANGE
-- CHECK (pourcent_commission BETWEEN 3 AND 7);
