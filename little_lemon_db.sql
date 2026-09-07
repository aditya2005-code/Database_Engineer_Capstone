-- =============================================================================
-- Little Lemon Relational Database Management System
-- Target DBMS: MySQL 8.0+
-- Storage Engine: InnoDB
-- Character Set: utf8mb4 / Collation: utf8mb4_unicode_ci
-- =============================================================================

CREATE DATABASE IF NOT EXISTS `LittleLemonDB`
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE `LittleLemonDB`;

SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `Order_Delivery_Status`;
DROP TABLE IF EXISTS `Orders`;
DROP TABLE IF EXISTS `Menu_has_MenuItems`;
DROP TABLE IF EXISTS `MenuItems`;
DROP TABLE IF EXISTS `Menus`;
DROP TABLE IF EXISTS `Bookings`;
DROP TABLE IF EXISTS `Staff`;
DROP TABLE IF EXISTS `Customers`;

-- 1. Customers Table
CREATE TABLE `Customers` (
    `CustomerID` INT NOT NULL AUTO_INCREMENT,
    `FullName` VARCHAR(100) NOT NULL,
    `ContactNumber` VARCHAR(25) NOT NULL,
    `Email` VARCHAR(100) DEFAULT NULL,
    CONSTRAINT `pk_customers` PRIMARY KEY (`CustomerID`)
) ENGINE = InnoDB;

-- 2. Staff Table
CREATE TABLE `Staff` (
    `StaffID` INT NOT NULL AUTO_INCREMENT,
    `FullName` VARCHAR(100) NOT NULL,
    `Role` VARCHAR(50) NOT NULL,
    `Salary` DECIMAL(10,2) NOT NULL,
    `ContactNumber` VARCHAR(25) DEFAULT NULL,
    CONSTRAINT `pk_staff` PRIMARY KEY (`StaffID`)
) ENGINE = InnoDB;

-- 3. Bookings Table
CREATE TABLE `Bookings` (
    `BookingID` INT NOT NULL AUTO_INCREMENT,
    `BookingDate` DATE NOT NULL,
    `TableNumber` INT NOT NULL,
    `CustomerID` INT NOT NULL,
    `StaffID` INT NOT NULL,
    CONSTRAINT `pk_bookings` PRIMARY KEY (`BookingID`),
    CONSTRAINT `fk_bookings_customer` FOREIGN KEY (`CustomerID`)
        REFERENCES `Customers` (`CustomerID`)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_bookings_staff` FOREIGN KEY (`StaffID`)
        REFERENCES `Staff` (`StaffID`)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- 4. Menus Table
CREATE TABLE `Menus` (
    `MenuID` INT NOT NULL AUTO_INCREMENT,
    `MenuName` VARCHAR(100) NOT NULL,
    `Cuisine` VARCHAR(50) NOT NULL,
    CONSTRAINT `pk_menus` PRIMARY KEY (`MenuID`)
) ENGINE = InnoDB;

-- 5. MenuItems Table
CREATE TABLE `MenuItems` (
    `MenuItemID` INT NOT NULL AUTO_INCREMENT,
    `CourseName` VARCHAR(50) NOT NULL,
    `ItemName` VARCHAR(100) NOT NULL,
    `Price` DECIMAL(10,2) NOT NULL,
    CONSTRAINT `pk_menuitems` PRIMARY KEY (`MenuItemID`)
) ENGINE = InnoDB;

-- 6. Menu_has_MenuItems Table (Resolves M:N relationship)
CREATE TABLE `Menu_has_MenuItems` (
    `MenuID` INT NOT NULL,
    `MenuItemID` INT NOT NULL,
    CONSTRAINT `pk_menu_has_menuitems` PRIMARY KEY (`MenuID`, `MenuItemID`),
    CONSTRAINT `fk_menu_has_menu` FOREIGN KEY (`MenuID`)
        REFERENCES `Menus` (`MenuID`)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT `fk_menu_has_items` FOREIGN KEY (`MenuItemID`)
        REFERENCES `MenuItems` (`MenuItemID`)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- 7. Orders Table
CREATE TABLE `Orders` (
    `OrderID` INT NOT NULL AUTO_INCREMENT,
    `OrderDate` DATE NOT NULL,
    `Quantity` INT NOT NULL,
    `TotalCost` DECIMAL(10,2) NOT NULL,
    `CustomerID` INT NOT NULL,
    `MenuID` INT NOT NULL,
    `StaffID` INT NOT NULL,
    CONSTRAINT `pk_orders` PRIMARY KEY (`OrderID`),
    CONSTRAINT `fk_orders_customer` FOREIGN KEY (`CustomerID`)
        REFERENCES `Customers` (`CustomerID`)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_orders_menu` FOREIGN KEY (`MenuID`)
        REFERENCES `Menus` (`MenuID`)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_orders_staff` FOREIGN KEY (`StaffID`)
        REFERENCES `Staff` (`StaffID`)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- 8. Order_Delivery_Status Table (1:1 with Orders)
CREATE TABLE `Order_Delivery_Status` (
    `DeliveryID` INT NOT NULL AUTO_INCREMENT,
    `OrderID` INT NOT NULL,
    `DeliveryDate` DATE NOT NULL,
    `Status` VARCHAR(50) NOT NULL,
    CONSTRAINT `pk_order_delivery_status` PRIMARY KEY (`DeliveryID`),
    CONSTRAINT `uq_order_delivery_orderid` UNIQUE (`OrderID`),
    CONSTRAINT `fk_delivery_orders` FOREIGN KEY (`OrderID`)
        REFERENCES `Orders` (`OrderID`)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
