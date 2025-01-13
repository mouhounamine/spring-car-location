-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`tour`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`tour` (
                                             `tour_id` INT NOT NULL AUTO_INCREMENT,
                                             `property_id` INT NOT NULL,
                                             `client_id` INT NOT NULL,
                                             `tour_date` DATE NOT NULL,
                                             `tour_time` TIME NOT NULL,
                                             PRIMARY KEY (`tour_id`),
    INDEX `FK_property_id` (`property_id` ASC) INVISIBLE,
    INDEX `FK_client_id` (`client_id` ASC) VISIBLE)
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`property`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`property` (
                                                 `property_id` INT NOT NULL AUTO_INCREMENT,
                                                 `name` VARCHAR(45) NOT NULL,
    `address` TEXT(70) NOT NULL,
    `area` FLOAT NOT NULL,
    `lot_size` FLOAT NOT NULL,
    `type` VARCHAR(45) NOT NULL,
    `condition` VARCHAR(45) NOT NULL,
    `listing_price` DECIMAL(10,2) NOT NULL,
    `status` VARCHAR(45) NOT NULL,
    `availability_date` DATE NOT NULL,
    `exclusivity_tier` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`property_id`),
    CONSTRAINT `fk_property_tour1`
    FOREIGN KEY (`property_id`)
    REFERENCES `mydb`.`tour` (`property_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`property_location`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`property_location` (
                                                          `property_location_id` INT NOT NULL AUTO_INCREMENT,
                                                          `property_id` INT NOT NULL,
                                                          `owner_id` INT NOT NULL,
                                                          `city_id` INT NOT NULL,
                                                          `neighborhood_id` INT NOT NULL,
                                                          PRIMARY KEY (`property_location_id`),
    INDEX `FK_property_id` (`property_id` ASC) INVISIBLE,
    INDEX `FK_owner_id` (`owner_id` ASC) INVISIBLE,
    INDEX `FK_city_id` (`city_id` ASC) INVISIBLE,
    INDEX `FK_neighborhood_id` (`neighborhood_id` ASC) VISIBLE,
    CONSTRAINT `fk_property_location_property`
    FOREIGN KEY (`property_id`)
    REFERENCES `mydb`.`property` (`property_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`owner`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`owner` (
                                              `owner_id` INT NOT NULL AUTO_INCREMENT,
                                              `name` VARCHAR(45) NOT NULL,
    `contact` VARCHAR(45) NOT NULL,
    `address` TEXT(60) NULL,
    PRIMARY KEY (`owner_id`),
    CONSTRAINT `fk_owner_property_location1`
    FOREIGN KEY (`owner_id`)
    REFERENCES `mydb`.`property_location` (`owner_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`city`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`city` (
                                             `city_id` INT NOT NULL AUTO_INCREMENT,
                                             `city_name` VARCHAR(45) NOT NULL,
    `country` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`city_id`),
    CONSTRAINT `fk_city_property_location1`
    FOREIGN KEY (`city_id`)
    REFERENCES `mydb`.`property_location` (`city_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`neighborhood`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`neighborhood` (
                                                     `neighborhood_id` INT NOT NULL AUTO_INCREMENT,
                                                     `neighborhood_name` VARCHAR(45) NOT NULL,
    `neighborhood_type` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`neighborhood_id`),
    CONSTRAINT `fk_neighborhood_property_location1`
    FOREIGN KEY (`neighborhood_id`)
    REFERENCES `mydb`.`property_location` (`neighborhood_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`client`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`client` (
                                               `client_id` INT NOT NULL AUTO_INCREMENT,
                                               `client_name` VARCHAR(45) NOT NULL,
    `client_contact` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`client_id`),
    CONSTRAINT `fk_client_tour1`
    FOREIGN KEY (`client_id`)
    REFERENCES `mydb`.`tour` (`client_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`transaction`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`transaction` (
                                                    `transaction_id` INT NOT NULL AUTO_INCREMENT,
                                                    `property_id` INT NOT NULL,
                                                    `client_id` INT NOT NULL,
                                                    `transaction_date` DATE NOT NULL,
                                                    `amount` DECIMAL(10,2) NOT NULL,
    `commission` DECIMAL(10,2) NOT NULL,
    `transaction_type` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`transaction_id`),
    INDEX `FK_property_id` (`property_id` ASC) INVISIBLE,
    INDEX `FK_client_id` (`client_id` ASC) VISIBLE,
    CONSTRAINT `fk_transaction_property1`
    FOREIGN KEY (`property_id`)
    REFERENCES `mydb`.`property` (`property_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    CONSTRAINT `fk_transaction_client1`
    FOREIGN KEY (`client_id`)
    REFERENCES `mydb`.`client` (`client_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`commission`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`commission` (
                                                   `commission_id` INT NOT NULL AUTO_INCREMENT,
                                                   `fixed_amount` DECIMAL(10,2) NOT NULL,
    `percentage` DECIMAL(10,2) NOT NULL,
    `transaction_id` INT NOT NULL,
    PRIMARY KEY (`commission_id`),
    INDEX `FK_transaction_id` (`transaction_id` ASC) VISIBLE,
    CONSTRAINT `fk_commission_transaction1`
    FOREIGN KEY (`transaction_id`)
    REFERENCES `mydb`.`transaction` (`transaction_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
    ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
