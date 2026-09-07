-- =============================================================================
-- Little Lemon MySQL Exercise: Virtual Tables, JOINs, and Subqueries
-- Target Database: LittleLemonDB
-- Deliverable: little_lemon_sql_queries.sql
-- =============================================================================

USE `LittleLemonDB`;

-- =============================================================================
-- SECTION 0: READ-ONLY DATABASE INSPECTION QUERIES
-- Run these queries first in MySQL Workbench to inspect your active schema
-- =============================================================================

-- 0.1 Check existing tables in the database
SHOW TABLES;

-- 0.2 Inspect the Orders table structure (verify Quantity and TotalCost/Cost)
DESCRIBE `Orders`;

-- 0.3 Inspect Customers / CustomerDetails table structure
-- (Check whether your table is named CustomerDetails or Customers)
SHOW COLUMNS FROM `CustomerDetails`;
-- If your table is named Customers, run:
-- SHOW COLUMNS FROM `Customers`;

-- 0.4 Inspect Menus / Menu table structure (verify MenuItemID relationship)
SHOW COLUMNS FROM `Menu`;
-- If your table is named Menus, run:
-- SHOW COLUMNS FROM `Menus`;

-- 0.5 Inspect MenuItems table structure
SHOW COLUMNS FROM `MenuItems`;


-- =============================================================================
-- TASK 1: CREATE THE ORDERS VIEW (OrdersView)
-- Purpose: Virtual table returning ONLY OrderID, Quantity, and Cost
--          for all orders where Quantity > 2.
-- =============================================================================

-- Primary Query (matches schema with TotalCost column):
CREATE OR REPLACE VIEW `OrdersView` AS
SELECT 
    `OrderID`,
    `Quantity`,
    `TotalCost` AS `Cost`
FROM `Orders`
WHERE `Quantity` > 2;

-- Alternate Query (if your table already has a column literally named Cost):
-- CREATE OR REPLACE VIEW `OrdersView` AS
-- SELECT 
--     `OrderID`,
--     `Quantity`,
--     `Cost`
-- FROM `Orders`
-- WHERE `Quantity` > 2;

-- Test Query to retrieve data from the virtual table:
SELECT * FROM `OrdersView`;

-- Verification Query (Expected result: 0 rows, proving no orders with Quantity <= 2 exist in the view):
SELECT * FROM `OrdersView` WHERE `Quantity` <= 2;


-- =============================================================================
-- TASK 2: JOIN FOUR TABLES (Orders costing more than $150)
-- Purpose: Retrieve customer, order, menu, and menu item details for orders > $150,
--          sorted by lowest cost first.
-- Tables Joined:
--   1. CustomerDetails (or Customers)
--   2. Orders
--   3. Menu (or Menus)
--   4. MenuItems
-- Relationships:
--   - CustomerDetails.CustomerID = Orders.CustomerID
--   - Orders.MenuID = Menu.MenuID
--   - Menu.MenuItemID = MenuItems.MenuItemID
-- =============================================================================

-- Primary Query (matching LittleLemonDB schema: CustomerDetails, Menu, MenuItems):
SELECT 
    c.`CustomerID` AS `customer_id`,
    c.`CustomerName` AS `full_name`,
    o.`OrderID` AS `order_id`,
    o.`TotalCost` AS `cost`,
    m.`MenuName` AS `menu_name`,
    mi.`CourseName` AS `item_name`,
    mi.`CourseName` AS `category`
FROM `CustomerDetails` c
INNER JOIN `Orders` o 
    ON c.`CustomerID` = o.`CustomerID`
INNER JOIN `Menu` m 
    ON o.`MenuID` = m.`MenuID`
INNER JOIN `MenuItems` mi 
    ON m.`MenuItemID` = mi.`MenuItemID`
WHERE o.`TotalCost` > 150
ORDER BY o.`TotalCost` ASC;

-- Alternate Query (matching course lab variation: Customers, Menus, ItemName):
-- SELECT 
--     c.`CustomerID` AS `customer_id`,
--     c.`FullName` AS `full_name`,
--     o.`OrderID` AS `order_id`,
--     o.`Cost` AS `cost`,
--     m.`MenuName` AS `menu_name`,
--     mi.`CourseName` AS `item_name`,
--     mi.`StarterName` AS `category`
-- FROM `Customers` c
-- INNER JOIN `Orders` o 
--     ON c.`CustomerID` = o.`CustomerID`
-- INNER JOIN `Menus` m 
--     ON o.`MenuID` = m.`MenuID`
-- INNER JOIN `MenuItems` mi 
--     ON m.`MenuItemID` = mi.`MenuItemID`
-- WHERE o.`Cost` > 150
-- ORDER BY o.`Cost` ASC;


-- =============================================================================
-- TASK 3: SUBQUERY USING ANY OPERATOR
-- Purpose: Find all menu items/names for which more than 2 orders have been placed
--          (i.e., order Quantity > 2) using the ANY operator.
-- Requirement: Must use outer query on Menu/Menus and subquery on Orders with ANY.
-- =============================================================================

-- Primary Query (matching LittleLemonDB schema with table 'Menu'):
SELECT `MenuName`
FROM `Menu`
WHERE `MenuID` = ANY (
    SELECT `MenuID`
    FROM `Orders`
    WHERE `Quantity` > 2
);

-- Alternate Query (matching lab variation with table 'Menus'):
-- SELECT `MenuName`
-- FROM `Menus`
-- WHERE `MenuID` = ANY (
--     SELECT `MenuID`
--     FROM `Orders`
--     WHERE `Quantity` > 2
-- );

-- =============================================================================
-- OPTIONAL CONCEPTUAL COMPARISONS FOR TASK 3 (For Understanding):
-- 1. Using IN (equivalent result to = ANY):
--    SELECT MenuName FROM Menu WHERE MenuID IN (SELECT MenuID FROM Orders WHERE Quantity > 2);
-- 2. Using EXISTS:
--    SELECT m.MenuName FROM Menu m WHERE EXISTS (SELECT 1 FROM Orders o WHERE o.MenuID = m.MenuID AND o.Quantity > 2);
-- =============================================================================
