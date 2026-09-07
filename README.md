# Little Lemon MySQL Exercise: Stored Procedures & Prepared Statements

## 1. Overview
This module implements database automation routines for the **Little Lemon** restaurant database management system (`LittleLemonDB`), focusing on:
1. **`GetMaxQuantity` Stored Procedure**: Encapsulating analytics to dynamically retrieve the peak order volume.
2. **`GetOrderDetail` Prepared Statement**: Protecting against SQL injection and improving execution performance by parameterizing customer order lookups.
3. **`CancelOrder` Stored Procedure**: Automating transactional order cancellations safely via an input parameter.

---

## 2. Actual Schema Inspection & Discovered Mapping

Read-only inspection of the `LittleLemonDB` database schema reveals the following physical structure for the target `Orders` table:

```sql
DESCRIBE `Orders`;
```

| Discovered Column | Physical Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| **`OrderID`** | `INT` | `PRIMARY KEY, AUTO_INCREMENT` | Unique order transaction identifier |
| **`OrderDate`** | `DATE` | `NOT NULL` | Date when the order was placed |
| **`Quantity`** | `INT` | `NOT NULL, CHECK (Quantity > 0)` | Discrete count of items ordered |
| **`TotalCost`** | `DECIMAL(10,2)` | `NOT NULL, CHECK (TotalCost >= 0.00)` | Financial transaction total (Cost) |
| **`CustomerID`** | `INT` | `NOT NULL, FOREIGN KEY` | References `CustomerDetails(CustomerID)` |
| **`MenuID`** | `INT` | `NOT NULL, FOREIGN KEY` | References `Menu(MenuID)` |
| **`StaffID`** | `INT` | `NOT NULL, FOREIGN KEY` | References `StaffInformation(StaffID)` |

### Critical Schema Takeaways:
* The quantity column is named **`Quantity`**.
* The financial total column is named **`TotalCost`**. In the prepared statement, we expose it as `Cost` (`TotalCost AS Cost`) to satisfy course naming conventions.
* The primary key is **`OrderID`** of type `INT`.
* The customer reference is **`CustomerID`** of type `INT`.

---

## 3. Detailed Task Explanations

### TASK 1 — `GetMaxQuantity` (Stored Procedure)
* **Objective**: Query the `Orders` table and display the highest single order quantity without requiring user parameters.
* **Logic**:
  ```sql
  DELIMITER //
  CREATE PROCEDURE GetMaxQuantity()
  BEGIN
      SELECT MAX(Quantity) AS `Max Quantity in Order`
      FROM Orders;
  END //
  DELIMITER ;
  ```
* **Invocation**:
  ```sql
  CALL GetMaxQuantity();
  ```
* **How It Works**:
  The database engine executes `MAX(Quantity)` across all rows in `Orders` and returns the scalar maximum under the column header `Max Quantity in Order`.

---

### TASK 2 — `GetOrderDetail` (Prepared Statement)
* **Objective**: Create a parameterized prepared statement that accepts a `CustomerID` dynamically through a session variable and returns that customer's `OrderID`, `Quantity`, and `Cost`.
* **Security & Architecture**:
  Prepared statements pre-compile the SQL structure on the database server. Binding parameters using placeholders (`?`) ensures user input is strictly treated as literal data, eliminating SQL injection vulnerabilities.
* **Workflow**:
  1. **Prepare Statement**:
     ```sql
     PREPARE GetOrderDetail FROM
         'SELECT OrderID, Quantity, TotalCost AS Cost
          FROM Orders
          WHERE CustomerID = ?';
     ```
  2. **Set Variable (`id = 1`)**:
     ```sql
     SET @id = 1;
     ```
  3. **Execute Using Variable**:
     ```sql
     EXECUTE GetOrderDetail USING @id;
     ```
  4. **Deallocate / Clean Up**:
     ```sql
     DEALLOCATE PREPARE GetOrderDetail;
     ```
     *(Deallocating frees server-side memory allocated to the cached execution plan once query operations are complete).*

---

### TASK 3 — `CancelOrder` (Stored Procedure)
* **Objective**: Delete an order from the `Orders` table based on an `OrderID` passed as an input argument (`IN order_id INT`).
* **Logic**:
  ```sql
  DELIMITER //
  CREATE PROCEDURE CancelOrder(IN order_id INT)
  BEGIN
      DELETE FROM Orders
      WHERE OrderID = order_id;

      SELECT CONCAT('Order ', order_id, ' is cancelled') AS Confirmation;
  END //
  DELIMITER ;
  ```
* **Invocation**:
  ```sql
  CALL CancelOrder(<target_order_id>);
  ```

> [!WARNING]
> ### Safety Warning for `CancelOrder`
> Because `CancelOrder` performs a destructive permanent `DELETE` operation:
> 1. **Do not run `CancelOrder` blindly** or on production records.
> 2. **Pre-Verify**: Always inspect the table first:
>    ```sql
>    SELECT * FROM Orders WHERE OrderID = <target_order_id>;
>    ```
> 3. **Cascade Impact**: If foreign keys with `ON DELETE CASCADE` exist (such as `OrderDeliveryStatus`), child records linked to that `OrderID` will also be deleted.
> 4. **Only execute when explicitly ready**: `CALL CancelOrder(5);`.

---

## 4. MySQL Workbench Step-by-Step Workflow

Follow these steps in **MySQL Workbench**:

### Step 1: Open SQL Editor & Set Schema
* **MY ACTION**:
  1. Launch **MySQL Workbench** and connect to your local MySQL Server.
  2. Open a new SQL Editor tab (`Ctrl + T`).
* **SQL TO RUN**:
  ```sql
  USE LittleLemonDB;
  ```

### Step 2: Create `GetMaxQuantity` Procedure
* **MY ACTION**:
  1. Open [`little_lemon_procedures.sql`](file:///d:/Projects/ASSESSMENT/little_lemon_procedures.sql) in Workbench.
  2. Highlight the `DELIMITER // ... CREATE PROCEDURE GetMaxQuantity ... DELIMITER ;` block.
  3. Click the **Execute** (lightning bolt) button.
* **SQL TO RUN**:
  ```sql
  CALL GetMaxQuantity();
  ```
* **Verify**: The Result Grid displays a single row with the maximum quantity value.

### Step 3: Create and Test `GetOrderDetail` Prepared Statement
* **MY ACTION**:
  1. Highlight the `PREPARE GetOrderDetail FROM ...` block and execute.
  2. Set the variable `@id = 1;` and execute.
  3. Execute `EXECUTE GetOrderDetail USING @id;`.
* **SQL TO RUN**:
  ```sql
  PREPARE GetOrderDetail FROM
      'SELECT OrderID, Quantity, TotalCost AS Cost
       FROM Orders
       WHERE CustomerID = ?';

  SET @id = 1;
  EXECUTE GetOrderDetail USING @id;
  ```
* **Verify**: The Result Grid displays all order rows for Customer 1 with columns `OrderID`, `Quantity`, and `Cost`.
* **Cleanup**:
  ```sql
  DEALLOCATE PREPARE GetOrderDetail;
  ```

### Step 4: Create and Safely Test `CancelOrder` Procedure
* **MY ACTION**:
  1. Highlight and execute the `CREATE PROCEDURE CancelOrder ...` statement block.
  2. **Audit step**: Query the `Orders` table to choose an ID to test:
     ```sql
     SELECT OrderID, CustomerID, TotalCost FROM Orders ORDER BY OrderID ASC;
     ```
  3. Verify the target order exists before running the procedure:
     ```sql
     SELECT * FROM Orders WHERE OrderID = 5;
     ```
  4. Call the procedure with your chosen ID:
     ```sql
     CALL CancelOrder(5);
     ```
* **Verify**:
  * Output grid displays: `Order 5 is cancelled`.
  * Running `SELECT * FROM Orders WHERE OrderID = 5;` returns **0 rows**, confirming successful deletion.

---

## 5. Final Validation Checklist

### Task 1: `GetMaxQuantity`
- [x] Procedure is named `GetMaxQuantity`
- [x] No input parameter is required
- [x] Uses `MAX(Quantity)` aggregate function
- [x] Reads directly from `Orders` table
- [x] Invocation command `CALL GetMaxQuantity();` provided and verified

### Task 2: `GetOrderDetail`
- [x] Prepared statement is named `GetOrderDetail`
- [x] Uses parameter placeholder `?` bound to `CustomerID`
- [x] Returns `OrderID`, `Quantity`, and `Cost` (`TotalCost AS Cost`)
- [x] Variable `@id` declared and assigned `1`
- [x] Executed via `EXECUTE GetOrderDetail USING @id;`
- [x] Does not use hardcoded literal values in query string
- [x] Cleanup command `DEALLOCATE PREPARE GetOrderDetail;` provided

### Task 3: `CancelOrder`
- [x] Procedure is named `CancelOrder`
- [x] Accepts `IN order_id INT` as input parameter
- [x] Uses `DELETE FROM Orders WHERE OrderID = order_id;`
- [x] Deletes only the matching order
- [x] Confirmation message returned via `SELECT CONCAT(...)`
- [x] Invocation command `CALL CancelOrder(<order_id>);` provided
- [x] Clear pre-execution verification and safety warning provided
- [x] Does not auto-execute destructive delete
