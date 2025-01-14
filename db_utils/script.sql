-- ==========================
-- 1) Création du schéma
-- ==========================
DROP SCHEMA IF EXISTS `mydb`;
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8;
USE `mydb`;


-- ==========================
-- 2) Tables de base
-- ==========================

-- -----------------------------------------------------
-- Table: city
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `city` (
  `city_id` INT NOT NULL AUTO_INCREMENT,
  `city_name` VARCHAR(45) NOT NULL,
  `country`   VARCHAR(45) NOT NULL,
  PRIMARY KEY (`city_id`)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table: neighborhood
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `neighborhood` (
  `neighborhood_id`   INT NOT NULL AUTO_INCREMENT,
  `neighborhood_name` VARCHAR(45) NOT NULL,
  `neighborhood_type` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`neighborhood_id`)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table: owner
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `owner` (
  `owner_id` INT NOT NULL AUTO_INCREMENT,
  `name`     VARCHAR(60) NOT NULL,
  `contact`  VARCHAR(60) NOT NULL,
  `address`  VARCHAR(200) NULL,
  CONSTRAINT pk_owner PRIMARY KEY (owner_id)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table: client
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `client` (
  `client_id`       INT NOT NULL AUTO_INCREMENT,
  `client_name`     VARCHAR(60) NOT NULL,
  `client_contact`  VARCHAR(60) NOT NULL,
  CONSTRAINT pk_client PRIMARY KEY (client_id)
) ENGINE = InnoDB;

ALTER TABLE client
ADD CONSTRAINT uq_client_contact
UNIQUE (client_contact);



-- -----------------------------------------------------
-- Table: property
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `property` (
  `property_id`        INT NOT NULL AUTO_INCREMENT,
  `owner_id`           INT NOT NULL,
  `city_id`            INT NOT NULL,
  `neighborhood_id`    INT NOT NULL,

  `name`               VARCHAR(45) NOT NULL,
  `address`            TEXT(70)    NOT NULL,
  `area`               FLOAT       NOT NULL,
  `lot_size`           FLOAT       NOT NULL,

  `type`               VARCHAR(45) NOT NULL,         -- (villa, penthouse, ...)
  `condition`          VARCHAR(45) NOT NULL,         -- (new, excellent, good...)
  `listing_price`      DECIMAL(10,2) NOT NULL,
  `status`             VARCHAR(45) NOT NULL,         -- (For Sale, For Rent, Sold, Rented...)
  `availability_date`  DATE        NOT NULL,
  `exclusivity_tier`   VARCHAR(45) NOT NULL,         -- (premium, standard, limited...)

  PRIMARY KEY (`property_id`),

  -- Quelques CHECK (MySQL 8.0+)
  CHECK (`type` IN ('Manoir','Penthouse','Villa','Apartment','House')),
  CHECK (`condition` IN ('New','Excellent','Good','Needs Renovation')),
  CHECK (`exclusivity_tier` IN ('Premium','Standard','Limited Access')),
  CHECK (`status` IN ('For Sale','For Rent','Sold','Rented')),

  CONSTRAINT `fk_property_owner`
    FOREIGN KEY (`owner_id`)
    REFERENCES `owner` (`owner_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,

  CONSTRAINT `fk_property_city`
    FOREIGN KEY (`city_id`)
    REFERENCES `city` (`city_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,

  CONSTRAINT `fk_property_neighborhood`
    FOREIGN KEY (`neighborhood_id`)
    REFERENCES `neighborhood` (`neighborhood_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table: property_amenity (Pour gérer les annexes)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `property_amenity` (
  `amenity_id`     INT NOT NULL AUTO_INCREMENT,
  `property_id`    INT NOT NULL,
  `amenity_type`   VARCHAR(45) NOT NULL, -- ex: 'Piscine', 'Garage', ...
  `description`    VARCHAR(200),
  `amenity_area`   FLOAT,
  PRIMARY KEY (`amenity_id`),

  CONSTRAINT `fk_amenity_property`
    FOREIGN KEY (`property_id`)
    REFERENCES `property` (`property_id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table: tour (Visite)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `tour` (
  `tour_id`      INT NOT NULL AUTO_INCREMENT,
  `property_id`  INT NOT NULL,
  `client_id`    INT NOT NULL,

  `tour_date`    DATE NOT NULL,
  `tour_time`    TIME NOT NULL,
  PRIMARY KEY (`tour_id`),

  CONSTRAINT `fk_tour_property`
    FOREIGN KEY (`property_id`)
    REFERENCES `property` (`property_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,

  CONSTRAINT `fk_tour_client`
    FOREIGN KEY (`client_id`)
    REFERENCES `client` (`client_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table: transaction
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `transaction` (
  `transaction_id`   INT NOT NULL AUTO_INCREMENT,
  `property_id`      INT NOT NULL,
  `client_id`        INT NOT NULL,
  `transaction_date` DATE NOT NULL,
  `transaction_type` VARCHAR(45) NOT NULL,  -- (Vente, Location)
  `amount`           DECIMAL(10,2) NOT NULL,

  PRIMARY KEY (`transaction_id`),

  CHECK (`transaction_type` IN ('Vente','Location')),

  CONSTRAINT `fk_transaction_property1`
    FOREIGN KEY (`property_id`)
    REFERENCES `property` (`property_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  
  CONSTRAINT `fk_transaction_client1`
    FOREIGN KEY (`client_id`)
    REFERENCES `client` (`client_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table: commission
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `commission` (
  `commission_id` INT NOT NULL AUTO_INCREMENT,
  `transaction_id` INT NOT NULL,

  -- Logique métier: base fixe + pourcentage 3% à 7%.
  `fixed_amount`  DECIMAL(10,2) NOT NULL DEFAULT 5000.00,
  `percentage`    DECIMAL(5,2)  NOT NULL,   -- on veut 0.03 à 0.07
  `commission_total` DECIMAL(10,2),

  PRIMARY KEY (`commission_id`),

  CONSTRAINT `fk_commission_transaction1`
    FOREIGN KEY (`transaction_id`)
    REFERENCES `transaction` (`transaction_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB;

ALTER TABLE commission
ADD CONSTRAINT ck_percentage
CHECK (percentage >= 0.03 AND percentage <= 0.07);



-- -----------------------------------------------------
-- 3) Triggers pour la logique métier
-- -----------------------------------------------------
DELIMITER $$;

--------------------------------------------------------------------------
-- Trigger 1 : Calculer la commission_total avant insertion (déjà fourni)
--------------------------------------------------------------------------
CREATE TRIGGER trg_commission_before_insert
BEFORE INSERT ON `commission`
FOR EACH ROW
BEGIN
  DECLARE v_amount DECIMAL(10,2);

  -- Vérifier la fourchette [3%, 7%]
  IF (NEW.percentage < 0.03 OR NEW.percentage > 0.07) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Commission percentage must be between 3% and 7%.';
  END IF;

  -- Récupérer le montant (amount) de la transaction
  SELECT `amount` INTO v_amount
    FROM `transaction`
    WHERE `transaction_id` = NEW.`transaction_id`;

  -- Calculer la commission : 5000 + (amount * percentage)
  SET NEW.`commission_total` = NEW.`fixed_amount` + (v_amount * NEW.`percentage`);
END$$


--------------------------------------------------------------------------
-- Trigger 2 : Empêcher la suppression d'une propriété si une transaction existe (déjà fourni)
--------------------------------------------------------------------------
CREATE TRIGGER trg_no_delete_property_if_transaction
BEFORE DELETE ON `property`
FOR EACH ROW
BEGIN
  DECLARE v_count INT;

  SELECT COUNT(*) INTO v_count
    FROM `transaction`
    WHERE `property_id` = OLD.`property_id`;

  IF v_count > 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Cannot delete a property that already has transactions.';
  END IF;
END$$


--------------------------------------------------------------------------
-- Trigger 3 : Mettre à jour automatiquement le "status" de la propriété 
--             quand une transaction est insérée (vente/location).
--------------------------------------------------------------------------
CREATE TRIGGER trg_transaction_after_insert
AFTER INSERT ON `transaction`
FOR EACH ROW
BEGIN
  -- Si c'est une vente ("Vente"), on passe la propriété en "Sold".
  -- Si c'est une location ("Location"), on passe la propriété en "Rented".
  -- Adapte les valeurs exactes selon ta colonne `status`.
  IF NEW.transaction_type = 'Vente' THEN
    UPDATE `property`
       SET `status` = 'Sold'
     WHERE `property_id` = NEW.property_id;
  ELSIF NEW.transaction_type = 'Location' THEN
    UPDATE `property`
       SET `status` = 'Rented'
     WHERE `property_id` = NEW.property_id;
  END IF;
END$$


--------------------------------------------------------------------------
-- Trigger 4 : Contrôler la validité de la surface d’une annexe avant insertion
--------------------------------------------------------------------------
CREATE TRIGGER trg_amenity_before_insert
BEFORE INSERT ON `property_amenity`
FOR EACH ROW
BEGIN
  -- Empêcher la surface négative, par exemple
  IF NEW.amenity_area < 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Amenity area cannot be negative.';
  END IF;
END$$


--------------------------------------------------------------------------
-- Trigger 5 : Vérifier que le "listing_price" ne devient pas négatif 
--             lors de la mise à jour d’une propriété
--------------------------------------------------------------------------
CREATE TRIGGER trg_property_before_update
BEFORE UPDATE ON `property`
FOR EACH ROW
BEGIN
  IF NEW.listing_price < 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Listing price cannot be negative.';
  END IF;
END$$

DELIMITER ;


-- ===================================================
-- 4) (Optionnel) Exemples d'INDEX supplémentaires
-- ===================================================
CREATE INDEX idx_property_owner    ON `property` (`owner_id`);
CREATE INDEX idx_property_city     ON `property` (`city_id`);
CREATE INDEX idx_property_neighb   ON `property` (`neighborhood_id`);
CREATE INDEX idx_tour_property     ON `tour` (`property_id`);
CREATE INDEX idx_tour_client       ON `tour` (`client_id`);
CREATE INDEX idx_transaction_prop  ON `transaction` (`property_id`);
CREATE INDEX idx_transaction_cl    ON `transaction` (`client_id`);
