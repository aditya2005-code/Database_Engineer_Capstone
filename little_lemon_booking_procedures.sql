-- =============================================================================
-- Little Lemon MySQL Exercise: Stored Procedures for Booking Management
-- Target Database: LittleLemonDB
-- Deliverable: little_lemon_booking_procedures.sql
-- =============================================================================

USE `LittleLemonDB`;

-- =============================================================================
-- SECTION 0: SCHEMA INSPECTION
-- Run these read-only statements to inspect the active Bookings schema
-- =============================================================================

-- 0.1 View all tables in the database
SHOW TABLES;

-- 0.2 Inspect the Bookings table columns and data types
DESCRIBE `Bookings`;

-- 0.3 Inspect table constraints and foreign keys on Bookings
SHOW CREATE TABLE `Bookings`;

-- 0.4 Inspect current contents of Bookings
SELECT `BookingID`, `BookingDate`, `TableNumber`, `CustomerID` 
FROM `Bookings`
ORDER BY `BookingID` ASC;


-- =============================================================================
-- TASK 1: AddBooking
-- Purpose: Inserts a new booking record using four input parameters:
--          1. booking_id (INT)
--          2. customer_id (INT)
--          3. booking_date (DATE)
--          4. table_number (INT)
-- =============================================================================

DROP PROCEDURE IF EXISTS `AddBooking`;

DELIMITER //

CREATE PROCEDURE `AddBooking`(
    IN `booking_id` INT,
    IN `customer_id` INT,
    IN `booking_date` DATE,
    IN `table_number` INT
)
BEGIN
    -- Insert new booking record
    -- (Supplies StaffID 1 as fallback if your physical table enforces a StaffID FK)
    INSERT INTO `Bookings` (`BookingID`, `CustomerID`, `BookingDate`, `TableNumber`, `StaffID`)
    VALUES (`booking_id`, `customer_id`, `booking_date`, `table_number`, 1)
    ON DUPLICATE KEY UPDATE
        `CustomerID` = VALUES(`CustomerID`),
        `BookingDate` = VALUES(`BookingDate`),
        `TableNumber` = VALUES(`TableNumber`);

    -- Return user-friendly confirmation
    SELECT 'New booking added' AS `Confirmation`;
END //

DELIMITER ;

-- -----------------------------------------------------------------------------
-- Task 1: Example AddBooking CALL & Verification
-- (Note: Do NOT execute automatically until ready to test with chosen parameters)
-- -----------------------------------------------------------------------------
-- CALL AddBooking(5, 2, '2022-12-30', 4);

-- Verification SELECT for newly inserted booking:
-- SELECT * FROM `Bookings` WHERE `BookingID` = 5;


-- =============================================================================
-- TASK 2: UpdateBooking
-- Purpose: Updates the booking date of an existing booking identified by BookingID.
-- Parameters:
--   1. booking_id (INT)
--   2. booking_date (DATE)
-- =============================================================================

DROP PROCEDURE IF EXISTS `UpdateBooking`;

DELIMITER //

CREATE PROCEDURE `UpdateBooking`(
    IN `booking_id` INT,
    IN `booking_date` DATE
)
BEGIN
    -- Update booking date for the target record
    UPDATE `Bookings`
    SET `BookingDate` = `booking_date`
    WHERE `BookingID` = `booking_id`;

    -- Return user-friendly confirmation
    SELECT CONCAT('Booking ', `booking_id`, ' updated') AS `Confirmation`;
END //

DELIMITER ;

-- -----------------------------------------------------------------------------
-- Task 2: Example UpdateBooking CALL & Verification
-- (Note: Do NOT execute automatically until ready to test with chosen parameters)
-- -----------------------------------------------------------------------------
-- CALL UpdateBooking(5, '2022-12-31');

-- Verification SELECT for updated booking:
-- SELECT * FROM `Bookings` WHERE `BookingID` = 5;


-- =============================================================================
-- TASK 3: CancelBooking
-- Purpose: Permanently deletes a booking record based on BookingID.
-- Parameter:
--   1. booking_id (INT)
-- SAFETY: Do NOT run automatically. Follow the safe pre-check workflow below.
-- =============================================================================

DROP PROCEDURE IF EXISTS `CancelBooking`;

DELIMITER //

CREATE PROCEDURE `CancelBooking`(
    IN `booking_id` INT
)
BEGIN
    -- Delete target booking record
    DELETE FROM `Bookings`
    WHERE `BookingID` = `booking_id`;

    -- Return user-friendly confirmation
    SELECT CONCAT('Booking ', `booking_id`, ' cancelled') AS `Confirmation`;
END //

DELIMITER ;

-- -----------------------------------------------------------------------------
-- Task 3: Safe CancelBooking Testing Workflow
-- -----------------------------------------------------------------------------
-- Step 3.1: Pre-Execution Verification — Confirm target booking exists before deleting
-- SELECT * FROM `Bookings` WHERE `BookingID` = 5;

-- Step 3.2: Execute CancelBooking (Call ONLY after verifying the target BookingID)
-- CALL CancelBooking(5);

-- Step 3.3: Post-Execution Verification — Confirm record has been removed (returns 0 rows)
-- SELECT * FROM `Bookings` WHERE `BookingID` = 5;


-- =============================================================================
-- GENERAL VERIFICATION
-- Inspect all records in Bookings table
-- =============================================================================
SELECT 
    `BookingID`,
    `BookingDate`,
    `TableNumber`,
    `CustomerID`
FROM `Bookings`
ORDER BY `BookingID` ASC;
