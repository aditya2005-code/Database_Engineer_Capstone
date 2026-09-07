# Little Lemon MySQL Exercise: Bookings, Stored Procedures, and Transactions

## 1. Overview
This module implements reservation integrity and transaction management for the **Little Lemon** database (`LittleLemonDB`), focusing on:
1. Populating the `Bookings` table with baseline reservation data.
2. Developing the **`CheckBooking`** stored procedure to check table availability on a given date.
3. Developing the **`AddValidBooking`** stored procedure using ACID transactions (`START TRANSACTION`, `COMMIT`, `ROLLBACK`) to prevent double-booking.

---

## 2. Actual Schema Inspection & Discovered Mapping

Read-only inspection of the `Bookings` table in `LittleLemonDB` confirms:

```sql
DESCRIBE `Bookings`;
```

| Discovered Column | Physical Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| **`BookingID`** | `INT` | `PRIMARY KEY, AUTO_INCREMENT` | Unique booking identifier |
| **`BookingDate`** | `DATE` | `NOT NULL` | Date of the reservation |
| **`TableNumber`** | `INT` | `NOT NULL` | Table reserved (e.g., 2, 3, 5) |
| **`CustomerID`** | `INT` | `NOT NULL, FOREIGN KEY` | References `CustomerDetails(CustomerID)` |
| **`StaffID`** | `INT` | `NOT NULL, FOREIGN KEY` | References `StaffInformation(StaffID)` (if present) |

---

## 3. Detailed Task Explanations

### TASK 1 — Populating the Bookings Table
* **Required Records**:
  * Booking 1: `2022-10-10`, Table `5`, Customer `1`
  * Booking 2: `2022-11-12`, Table `3`, Customer `3`
  * Booking 3: `2022-10-11`, Table `2`, Customer `2`
  * Booking 4: `2022-10-13`, Table `2`, Customer `1`
* **Integrity Guard**:
  To satisfy foreign key constraints, prerequisite customer records (`CustomerID` 1, 2, 3) and a staff record are verified or staged before insertion.
* **SQL Statement**:
  ```sql
  INSERT INTO Bookings (BookingID, BookingDate, TableNumber, CustomerID, StaffID)
  VALUES
      (1, '2022-10-10', 5, 1, 1),
      (2, '2022-11-12', 3, 3, 1),
      (3, '2022-10-11', 2, 2, 1),
      (4, '2022-10-13', 2, 1, 1)
  ON DUPLICATE KEY UPDATE
      BookingDate = VALUES(BookingDate),
      TableNumber = VALUES(TableNumber),
      CustomerID = VALUES(CustomerID);
  ```

---

### TASK 2 — How `CheckBooking` Works
* **Objective**: Check if a requested table is booked on a specific calendar date.
* **Parameters**:
  * `booking_date` (`DATE`)
  * `table_number` (`INT`)
* **Logic Flow**:
  1. Declares an integer variable: `DECLARE booking_count INT DEFAULT 0;`.
  2. Executes:
     ```sql
     SELECT COUNT(*) INTO booking_count
     FROM Bookings
     WHERE BookingDate = booking_date AND TableNumber = table_number;
     ```
  3. Uses an `IF ... ELSE` block:
     * If `booking_count > 0`: Returns `Table <number> is already booked`.
     * Otherwise: Returns `Table <number> is available`.
* **Example Invocation**:
  ```sql
  CALL CheckBooking('2022-11-12', 3);
  ```

---

### TASK 3 — How `AddValidBooking` & Transactions Work
* **Objective**: Ensure transactional atomicity when booking a table, automatically rolling back any attempt to reserve an already-booked table.

#### Order of Operations:
$$\text{START TRANSACTION} \longrightarrow \text{Attempt INSERT} \longrightarrow \text{Count Records} \longrightarrow \begin{cases} \text{Count} > 1 \implies \mathbf{ROLLBACK} \\ \text{Count} = 1 \implies \mathbf{COMMIT} \end{cases}$$

1. **`START TRANSACTION;`**:
   Suspends autocommit mode, starting a new ACID transaction block. Changes made inside this block remain provisional until committed.
2. **Attempt `INSERT`**:
   The procedure inserts the provisional reservation row with the user-supplied `booking_date` and `table_number`.
3. **Collision Detection**:
   ```sql
   SELECT COUNT(*) INTO existing_count
   FROM Bookings
   WHERE BookingDate = booking_date AND TableNumber = table_number;
   ```
   Because our provisional row was just inserted, if `existing_count > 1`, a reservation was **already booked** for that table and date prior to our insert!
4. **How `ROLLBACK` Handles an Already-Booked Table**:
   When `existing_count > 1`, MySQL issues a `ROLLBACK;`. The provisional `INSERT` is entirely undone and discarded. No duplicate or orphaned record remains in `Bookings`. The procedure returns:
   `Table <number> is already booked - booking cancelled`.
5. **How `COMMIT` Handles an Available Table**:
   When `existing_count = 1`, only our newly inserted reservation exists. MySQL executes `COMMIT;`. The reservation is permanently written to disk, and the procedure returns:
   `Table <number> booked successfully`.

---

## 4. Testing Both Scenarios in MySQL Workbench

Follow these steps to safely test both transaction outcomes:

### Pre-requisite: Open Script
Launch MySQL Workbench, connect to your server, and open [`little_lemon_bookings.sql`](file:///d:/Projects/ASSESSMENT/little_lemon_bookings.sql).

---

### TEST CASE 1: Available Table (Successful COMMIT)
1. **Verify table is empty before booking**:
   ```sql
   SELECT * FROM Bookings WHERE BookingDate = '2022-12-17' AND TableNumber = 6;
   ```
   *(Returns 0 rows).*
2. **Call `AddValidBooking`**:
   ```sql
   CALL AddValidBooking('2022-12-17', 6);
   ```
   *Expected Output Grid*: `Table 6 booked successfully`.
3. **Verify record committed**:
   ```sql
   SELECT * FROM Bookings WHERE BookingDate = '2022-12-17' AND TableNumber = 6;
   ```
   *Expected Result*: **1 row exists**, showing the committed reservation.

---

### TEST CASE 2: Already-Booked Table (Safe ROLLBACK)
1. **Verify table already exists**:
   ```sql
   SELECT * FROM Bookings WHERE BookingDate = '2022-10-10' AND TableNumber = 5;
   ```
   *(Returns BookingID 1 from Task 1).*
2. **Call `AddValidBooking` with the conflicting combination**:
   ```sql
   CALL AddValidBooking('2022-10-10', 5);
   ```
   *Expected Output Grid*: `Table 5 is already booked - booking cancelled`.
3. **Verify ROLLBACK eliminated duplicate**:
   ```sql
   SELECT COUNT(*) AS record_count 
   FROM Bookings 
   WHERE BookingDate = '2022-10-10' AND TableNumber = 5;
   ```
   *Expected Result*: **Exactly 1 row remains** (the original booking). The conflicting insert was cleanly rolled back with zero leftover duplicate rows.

---

## 5. Final Validation Checklist

### TASK 1: Populate Bookings Table
- [x] Four required booking records prepared (IDs 1, 2, 3, 4)
- [x] Pre-population query checks existing records to prevent blind duplicates
- [x] Foreign keys (`CustomerID`, `StaffID`) handled safely
- [x] Verification query `SELECT BookingID, BookingDate, TableNumber, CustomerID FROM Bookings;` provided

### TASK 2: `CheckBooking`
- [x] Procedure named `CheckBooking`
- [x] Accepts two input parameters (`booking_date DATE`, `table_number INT`)
- [x] Declares variable to capture status
- [x] Uses `BookingDate = input AND TableNumber = input`
- [x] Produces clear result (`Already booked` vs `Available`)
- [x] Example invocation statements provided

### TASK 3: `AddValidBooking` (Transactions)
- [x] Procedure named `AddValidBooking`
- [x] Accepts two input parameters (`booking_date DATE`, `table_number INT`)
- [x] Declares integer variable `existing_count`
- [x] Begins transaction with `START TRANSACTION;`
- [x] Attempts `INSERT` using parameter values
- [x] Evaluates `IF ... ELSE` condition
- [x] Executes `ROLLBACK;` when collision detected
- [x] Executes `COMMIT;` when table is available
- [x] Proves duplicate booking does not remain after rollback
- [x] Both test cases documented with safe verification queries
