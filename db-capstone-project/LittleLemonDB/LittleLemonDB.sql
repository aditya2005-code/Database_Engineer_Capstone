-- =============================================================================
-- Little Lemon Relational Database Implementation
-- Model: LittleLemonDM
-- Database: LittleLemonDB
-- Target DBMS: MySQL 8.0+
-- Storage Engine: InnoDB
-- Character Set: utf8mb4 / Collation: utf8mb4_unicode_ci
-- =============================================================================

-- 1. Create Database Schema
CREATE DATABASE IF NOT EXISTS `LittleLemonDB`
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE `LittleLemonDB`;

-- Disable foreign key checks during initial table drop/creation
SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS = 0;

-- Drop tables in reverse dependency order if re-executing
DROP TABLE IF EXISTS `OrderDeliveryStatus`;
DROP TABLE IF EXISTS `Orders`;
DROP TABLE IF EXISTS `Menu`;
DROP TABLE IF EXISTS `MenuItems`;
DROP TABLE IF EXISTS `Bookings`;
DROP TABLE IF EXISTS `StaffInformation`;
DROP TABLE IF EXISTS `CustomerDetails`;

-- =============================================================================
-- Table: CustomerDetails
-- Purpose: Stores customer identity and contact information
-- =============================================================================
CREATE TABLE `CustomerDetails` (
    `CustomerID` INT NOT NULL AUTO_INCREMENT,
    `CustomerName` VARCHAR(100) NOT NULL,
    `ContactDetails` VARCHAR(100) NOT NULL,
    CONSTRAINT `pk_customer_details` PRIMARY KEY (`CustomerID`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =============================================================================
-- Table: StaffInformation
-- Purpose: Stores employee roles and salary details
-- =============================================================================
CREATE TABLE `StaffInformation` (
    `StaffID` INT NOT NULL AUTO_INCREMENT,
    `StaffName` VARCHAR(100) NOT NULL,
    `Role` VARCHAR(50) NOT NULL,
    `Salary` DECIMAL(10,2) NOT NULL,
    CONSTRAINT `pk_staff_information` PRIMARY KEY (`StaffID`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =============================================================================
-- Table: Bookings
-- Purpose: Records restaurant table reservations
-- =============================================================================
CREATE TABLE `Bookings` (
    `BookingID` INT NOT NULL AUTO_INCREMENT,
    `BookingDate` DATE NOT NULL,
    `TableNumber` INT NOT NULL,
    `CustomerID` INT NOT NULL,
    `StaffID` INT NOT NULL,
    CONSTRAINT `pk_bookings` PRIMARY KEY (`BookingID`),
    CONSTRAINT `fk_bookings_customer` FOREIGN KEY (`CustomerID`)
        REFERENCES `CustomerDetails` (`CustomerID`)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT `fk_bookings_staff` FOREIGN KEY (`StaffID`)
        REFERENCES `StaffInformation` (`StaffID`)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =============================================================================
-- Table: MenuItems
-- Purpose: Stores item-level details (Course, Starter, Dessert, Drink)
-- =============================================================================
CREATE TABLE `MenuItems` (
    `MenuItemID` INT NOT NULL AUTO_INCREMENT,
    `CourseName` VARCHAR(100) NOT NULL,
    `StarterName` VARCHAR(100) NOT NULL,
    `DesertName` VARCHAR(100) NOT NULL,
    `DrinkName` VARCHAR(100) NOT NULL,
    CONSTRAINT `pk_menu_items` PRIMARY KEY (`MenuItemID`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =============================================================================
-- Table: Menu
-- Purpose: Groups menu offerings by cuisine and ties to menu items
-- =============================================================================
CREATE TABLE `Menu` (
    `MenuID` INT NOT NULL AUTO_INCREMENT,
    `MenuItemID` INT NOT NULL,
    `MenuName` VARCHAR(100) NOT NULL,
    `Cuisine` VARCHAR(50) NOT NULL,
    CONSTRAINT `pk_menu` PRIMARY KEY (`MenuID`),
    CONSTRAINT `fk_menu_menuitems` FOREIGN KEY (`MenuItemID`)
        REFERENCES `MenuItems` (`MenuItemID`)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =============================================================================
-- Table: Orders
-- Purpose: Records customer order transactions
-- =============================================================================
CREATE TABLE `Orders` (
    `OrderID` INT NOT NULL AUTO_INCREMENT,
    `OrderDate` DATE NOT NULL,
    `Quantity` INT NOT NULL,
    `TotalCost` DECIMAL(10,2) NOT NULL,
    `CustomerID` INT NOT NULL,
    `MenuID` INT NOT NULL,
    `StaffID` INT NOT NULL,
    CONSTRAINT `pk_orders` PRIMARY KEY (`OrderID`),
    CONSTRAINT `chk_orders_quantity` CHECK (`Quantity` > 0),
    CONSTRAINT `chk_orders_cost` CHECK (`TotalCost` >= 0.00),
    CONSTRAINT `fk_orders_customer` FOREIGN KEY (`CustomerID`)
        REFERENCES `CustomerDetails` (`CustomerID`)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT `fk_orders_menu` FOREIGN KEY (`MenuID`)
        REFERENCES `Menu` (`MenuID`)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT `fk_orders_staff` FOREIGN KEY (`StaffID`)
        REFERENCES `StaffInformation` (`StaffID`)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =============================================================================
-- Table: OrderDeliveryStatus
-- Purpose: Tracks delivery dates and status for orders (1:1 with Orders)
-- =============================================================================
CREATE TABLE `OrderDeliveryStatus` (
    `DeliveryID` INT NOT NULL AUTO_INCREMENT,
    `OrderID` INT NOT NULL,
    `DeliveryDate` DATE NOT NULL,
    `Status` VARCHAR(50) NOT NULL,
    CONSTRAINT `pk_order_delivery_status` PRIMARY KEY (`DeliveryID`),
    CONSTRAINT `uq_order_delivery_order` UNIQUE (`OrderID`),
    CONSTRAINT `fk_delivery_order` FOREIGN KEY (`OrderID`)
        REFERENCES `Orders` (`OrderID`)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- Restore foreign key checks
SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
