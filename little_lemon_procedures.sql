-- =============================================================================
-- Little Lemon MySQL Exercise: Stored Procedures and Prepared Statements
-- Target Database: LittleLemonDB
-- Deliverable: little_lemon_procedures.sql
-- =============================================================================

USE `LittleLemonDB`;

-- =============================================================================
-- SECTION 0: READ-ONLY SCHEMA INSPECTION COMMANDS
-- Run these queries in MySQL Workbench to verify table and column names
-- =============================================================================

-- Check table presence in LittleLemonDB
SHOW TABLES;

-- Inspect the Orders table structure
DESCRIBE `Orders`;

-- Show full DDL statement for Orders (inspecting PK, FKs, and constraints)
SHOW CREATE TABLE `Orders`;


-- =============================================================================
-- TASK 1: GetMaxQuantity STORED PROCEDURE
-- Purpose: Query the Orders table, retrieve the maximum ordered quantity,
--          and display the result. Requires NO input parameters.
-- =============================================================================

DROP PROCEDURE IF EXISTS `GetMaxQuantity`;

DELIMITER //

CREATE PROCEDURE `GetMaxQuantity`()
BEGIN
    SELECT MAX(`Quantity`) AS `Max Quantity in Order`
    FROM `Orders`;
END //

DELIMITER ;

-- -----------------------------------------------------------------------------
-- Task 1: Invocation Command
-- -----------------------------------------------------------------------------
CALL `GetMaxQuantity`();


-- =============================================================================
-- TASK 2: GetOrderDetail PREPARED STATEMENT
-- Purpose: Retrieve OrderID, Quantity, and Cost for a specific customer.
--          Accepts CustomerID dynamically through a session variable parameter.
--          Avoids SQL injection and hardcoded values.
-- =============================================================================

-- Step 2.1: Prepare the statement with a parameter placeholder (?)
PREPARE `GetOrderDetail` FROM
    'SELECT `OrderID`, `Quantity`, `TotalCost` AS `Cost`
     FROM `Orders`
     WHERE `CustomerID` = ?';

-- Step 2.2: Declare and initialize the customer ID variable (@id)
SET @id = 1;

-- Step 2.3: Execute the prepared statement using the @id variable
EXECUTE `GetOrderDetail` USING @id;

-- Step 2.4: Deallocate/Clean up the prepared statement (run after testing)
DEALLOCATE PREPARE `GetOrderDetail`;


-- =============================================================================
-- TASK 3: CancelOrder STORED PROCEDURE
-- Purpose: Delete a specific order from the Orders table based on OrderID
--          passed as an input parameter. Returns confirmation feedback.
-- =============================================================================

DROP PROCEDURE IF EXISTS `CancelOrder`;

DELIMITER //

CREATE PROCEDURE `CancelOrder`(IN `order_id` INT)
BEGIN
    -- Delete the order record matching the supplied parameter
    DELETE FROM `Orders`
    WHERE `OrderID` = `order_id`;

    -- Return confirmation message
    SELECT CONCAT('Order ', `order_id`, ' is cancelled') AS `Confirmation`;
END //

DELIMITER ;

-- =============================================================================
-- TASK 3: SAFE TESTING & EXECUTION WORKFLOW
-- IMPORTANT: Do NOT call CancelOrder without first verifying the record!
-- =============================================================================

-- Step 3.1: Pre-Execution Verification — Inspect existing orders to choose an OrderID
SELECT `OrderID`, `OrderDate`, `CustomerID`, `Quantity`, `TotalCost`
FROM `Orders`
ORDER BY `OrderID` ASC;

-- Step 3.2: Verify the specific record that would be deleted (e.g. OrderID = 5 or your chosen ID)
-- SELECT * FROM `Orders` WHERE `OrderID` = 5;

-- Step 3.3: Invocation Command (Execute ONLY after verifying the target OrderID)
-- CALL CancelOrder(5);

-- Step 3.4: Post-Execution Verification — Confirm the record was deleted
-- SELECT * FROM `Orders` WHERE `OrderID` = 5;
