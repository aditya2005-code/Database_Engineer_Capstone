-- =============================================================================
-- Little Lemon MySQL Exercise: Bookings, Stored Procedures, and Transactions
-- Target Database: LittleLemonDB
-- Deliverable: little_lemon_bookings.sql
-- =============================================================================

USE `LittleLemonDB`;

-- =============================================================================
-- SECTION 0: READ-ONLY SCHEMA INSPECTION COMMANDS
-- Run these queries in MySQL Workbench to verify table structure and constraints
-- =============================================================================

-- 0.1 Check table existence in LittleLemonDB
SHOW TABLES;

-- 0.2 Inspect the Bookings table structure (column names, types, nullability)
DESCRIBE `Bookings`;

-- 0.3 Inspect full DDL and foreign keys on Bookings
SHOW CREATE TABLE `Bookings`;

-- 0.4 Verify whether customer records exist for foreign key compliance
SELECT `CustomerID`, `CustomerName` FROM `CustomerDetails`;


-- =============================================================================
-- TASK 1: POPULATE BOOKINGS TABLE
-- Insert 4 required records into Bookings.
-- Required records:
--   BookingID: 1 | 2022-10-10 | Table 5 | Customer 1
--   BookingID: 2 | 2022-11-12 | Table 3 | Customer 3
--   BookingID: 3 | 2022-10-11 | Table 2 | Customer 2
--   BookingID: 4 | 2022-10-13 | Table 2 | Customer 1
-- =============================================================================

-- Step 1.1: Ensure prerequisite customer records exist (avoids FK constraint failure)
INSERT IGNORE INTO `CustomerDetails` (`CustomerID`, `CustomerName`, `ContactDetails`)
VALUES 
    (1, 'Vanessa McCarthy', 'vanessa@example.com'),
    (2, 'Marcos Sanchez', 'marcos@example.com'),
    (3, 'Diana Pinto', 'diana@example.com');

-- Step 1.2: Ensure prerequisite staff record exists (if schema defines StaffID FK)
INSERT IGNORE INTO `StaffInformation` (`StaffID`, `StaffName`, `Role`, `Salary`)
VALUES 
    (1, 'Mario Gollini', 'Manager', 45000.00);

-- Step 1.3: Check if Bookings already exist before inserting (prevent duplicates)
SELECT * FROM `Bookings` WHERE `BookingID` IN (1, 2, 3, 4);

-- Step 1.4: Insert the 4 required booking records
-- (Note: If your Bookings table includes a StaffID column, StaffID 1 is supplied)
INSERT INTO `Bookings` (`BookingID`, `BookingDate`, `TableNumber`, `CustomerID`, `StaffID`)
VALUES
    (1, '2022-10-10', 5, 1, 1),
    (2, '2022-11-12', 3, 3, 1),
    (3, '2022-10-11', 2, 2, 1),
    (4, '2022-10-13', 2, 1, 1)
ON DUPLICATE KEY UPDATE
    `BookingDate` = VALUES(`BookingDate`),
    `TableNumber` = VALUES(`TableNumber`),
    `CustomerID` = VALUES(`CustomerID`);

-- If your Bookings table does NOT have a StaffID column, use this standard statement:
-- INSERT INTO `Bookings` (`BookingID`, `BookingDate`, `TableNumber`, `CustomerID`)
-- VALUES
--     (1, '2022-10-10', 5, 1),
--     (2, '2022-11-12', 3, 3),
--     (3, '2022-10-11', 2, 2),
--     (4, '2022-10-13', 2, 1)
-- ON DUPLICATE KEY UPDATE
--     `BookingDate` = VALUES(`BookingDate`),
--     `TableNumber` = VALUES(`TableNumber`),
--     `CustomerID` = VALUES(`CustomerID`);

-- Step 1.5: Verification Query
SELECT 
    `BookingID`,
    `BookingDate`,
    `TableNumber`,
    `CustomerID`
FROM `Bookings`
ORDER BY `BookingID` ASC;


-- =============================================================================
-- TASK 2: CREATE CheckBooking STORED PROCEDURE
-- Purpose: Checks whether a table is already booked on a given date.
-- Parameters:
--   1. booking_date (DATE)
--   2. table_number (INT)
-- Output: Reports whether table is 'Already booked' or 'Available'.
-- =============================================================================

DROP PROCEDURE IF EXISTS `CheckBooking`;

DELIMITER //

CREATE PROCEDURE `CheckBooking`(
    IN `booking_date` DATE, 
    IN `table_number` INT
)
BEGIN
    DECLARE `booking_count` INT DEFAULT 0;

    -- Query Bookings table to check for existing reservations
    SELECT COUNT(*) INTO `booking_count`
    FROM `Bookings`
    WHERE `BookingDate` = `booking_date`
      AND `TableNumber` = `table_number`;

    -- Evaluate status and return clear feedback
    IF `booking_count` > 0 THEN
        SELECT CONCAT('Table ', `table_number`, ' is already booked') AS `Booking status`;
    ELSE
        SELECT CONCAT('Table ', `table_number`, ' is available') AS `Booking status`;
    END IF;
END //

DELIMITER ;

-- -----------------------------------------------------------------------------
-- Task 2: Example Invocations
-- -----------------------------------------------------------------------------
-- Example 2.1: Test an already-booked table (Nov 12, 2022, Table 3 from Task 1)
CALL `CheckBooking`('2022-11-12', 3);
-- Expected output: Table 3 is already booked

-- Example 2.2: Test an available table (Nov 12, 2022, Table 9)
CALL `CheckBooking`('2022-11-12', 9);
-- Expected output: Table 9 is available


-- =============================================================================
-- TASK 3: CREATE AddValidBooking STORED PROCEDURE (TRANSACTIONS)
-- Purpose: Prevents double-booking a table on the same date using a transaction.
-- Required Sequence:
--   START TRANSACTION
--   -> attempt INSERT
--   -> check whether requested table/date is already booked (count > 1)
--   -> IF already booked:
--          ROLLBACK
--   -> ELSE:
--          COMMIT
-- Parameters:
--   1. booking_date (DATE)
--   2. table_number (INT)
-- =============================================================================

DROP PROCEDURE IF EXISTS `AddValidBooking`;

DELIMITER //

CREATE PROCEDURE `AddValidBooking`(
    IN `booking_date` DATE,
    IN `table_number` INT
)
BEGIN
    DECLARE `existing_count` INT DEFAULT 0;

    -- 1. Begin the transaction
    START TRANSACTION;

    -- 2. Attempt the insertion of the new booking reservation
    -- (Uses default CustomerID 1 and StaffID 1 for the automated booking entry)
    INSERT INTO `Bookings` (`BookingDate`, `TableNumber`, `CustomerID`, `StaffID`)
    VALUES (`booking_date`, `table_number`, 1, 1);

    -- 3. Check whether the requested table is already booked on that date
    -- (Since we already inserted, a count > 1 proves a prior conflicting booking existed!)
    SELECT COUNT(*) INTO `existing_count`
    FROM `Bookings`
    WHERE `BookingDate` = `booking_date`
      AND `TableNumber` = `table_number`;

    -- 4. Conditional evaluation with Rollback / Commit
    IF `existing_count` > 1 THEN
        -- Conflicting booking detected: cancel and discard insertion
        ROLLBACK;
        SELECT CONCAT('Table ', `table_number`, ' is already booked - booking cancelled') AS `Booking status`;
    ELSE
        -- No conflicting booking: commit and persist insertion
        COMMIT;
        SELECT CONCAT('Table ', `table_number`, ' booked successfully') AS `Booking status`;
    END IF;
END //

DELIMITER ;


-- =============================================================================
-- TESTING & VERIFICATION WORKFLOW
-- Instructions for safely testing both transaction branches in MySQL Workbench
-- =============================================================================

-- -----------------------------------------------------------------------------
-- TEST CASE 1: AVAILABLE TABLE (SHOULD COMMIT)
-- -----------------------------------------------------------------------------
-- Step T1.1: Verify the table/date combination is currently empty
SELECT * FROM `Bookings` 
WHERE `BookingDate` = '2022-12-17' AND `TableNumber` = 6;

-- Step T1.2: Call AddValidBooking with the available table
CALL `AddValidBooking`('2022-12-17', 6);
-- Expected message: Table 6 booked successfully

-- Step T1.3: Verify the record was committed and persists in the table
SELECT * FROM `Bookings` 
WHERE `BookingDate` = '2022-12-17' AND `TableNumber` = 6;


-- -----------------------------------------------------------------------------
-- TEST CASE 2: ALREADY BOOKED TABLE (SHOULD ROLLBACK)
-- -----------------------------------------------------------------------------
-- Step T2.1: Verify that Table 5 on 2022-10-10 already exists (BookingID 1 from Task 1)
SELECT * FROM `Bookings` 
WHERE `BookingDate` = '2022-10-10' AND `TableNumber` = 5;

-- Step T2.2: Call AddValidBooking with the conflicting table/date
CALL `AddValidBooking`('2022-10-10', 5);
-- Expected message: Table 5 is already booked - booking cancelled

-- Step T2.3: Verify that ROLLBACK occurred: exactly 1 record remains, NO duplicate
SELECT COUNT(*) AS `record_count_remains_one` 
FROM `Bookings` 
WHERE `BookingDate` = '2022-10-10' AND `TableNumber` = 5;
