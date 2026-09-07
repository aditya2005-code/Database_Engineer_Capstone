-- =============================================================================
-- Little Lemon: Task 3 — Show All Databases Script
-- Target DBMS: MySQL 8.0+
-- Purpose: Query the active MySQL Server instance to list all available
--          databases and verify the deployment of LittleLemonDB.
-- =============================================================================

-- Query 1: Show all databases on the MySQL Server
SHOW DATABASES;

-- Query 2: Verify that LittleLemonDB is active and inspect its tables
USE `LittleLemonDB`;
SHOW FULL TABLES IN `LittleLemonDB`;

-- Query 3: Verify the structure of each table
DESCRIBE `CustomerDetails`;
DESCRIBE `StaffInformation`;
DESCRIBE `Bookings`;
DESCRIBE `MenuItems`;
DESCRIBE `Menu`;
DESCRIBE `Orders`;
DESCRIBE `OrderDeliveryStatus`;
