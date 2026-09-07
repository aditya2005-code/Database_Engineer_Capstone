# Little Lemon MySQL Exercise: Stored Procedures for Booking Management

## 1. Overview
This module implements administrative routines for the **Little Lemon** database (`LittleLemonDB`) to handle complete table reservation lifecycles:
1. **`AddBooking`**: Inserting new customer reservations.
2. **`UpdateBooking`**: Rescheduling reservation dates for an existing booking.
3. **`CancelBooking`**: Safely removing reservation records based on a specific booking ID.

---

## 2. Actual Schema Inspection & Discovered Mapping

Read-only inspection of the target `Bookings` table confirms the following physical schema:

```sql
DESCRIBE `Bookings`;
```

| Discovered Column | Physical Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| **`BookingID`** | `INT` | `PRIMARY KEY, AUTO_INCREMENT` | Unique reservation identifier |
| **`CustomerID`** | `INT` | `NOT NULL, FOREIGN KEY` | Customer account identifier |
| **`BookingDate`** | `DATE` | `NOT NULL` | Calendar date of the reservation |
| **`TableNumber`** | `INT` | `NOT NULL` | Assigned restaurant table number |
| **`StaffID`** | `INT` | `NOT NULL, FOREIGN KEY` | Employee assigned to reservation (if present) |

---

## 3. Stored Procedure Explanations & Signatures

### TASK 1 — `AddBooking`
* **Purpose**: Inserts a new table reservation into the `Bookings` table.
* **Input Parameters (4)**:
  1. `booking_id` (`INT`): The unique ID for the new reservation.
  2. `customer_id` (`INT`): The customer placing the reservation.
  3. `booking_date` (`DATE`): The date of the reservation.
  4. `table_number` (`INT`): The table number being reserved.
* **SQL Implementation**:
  ```sql
  DELIMITER //
  CREATE PROCEDURE AddBooking(
      IN booking_id INT,
      IN customer_id INT,
      IN booking_date DATE,
      IN table_number INT
  )
  BEGIN
      INSERT INTO Bookings (BookingID, CustomerID, BookingDate, TableNumber, StaffID)
      VALUES (booking_id, customer_id, booking_date, table_number, 1)
      ON DUPLICATE KEY UPDATE
          CustomerID = VALUES(CustomerID),
          BookingDate = VALUES(BookingDate),
          TableNumber = VALUES(TableNumber);

      SELECT 'New booking added' AS Confirmation;
  END //
  DELIMITER ;
  ```
* **How to Invoke**:
  ```sql
  CALL AddBooking(5, 2, '2022-12-30', 4);
  ```
* **How to Verify**:
  ```sql
  SELECT * FROM Bookings WHERE BookingID = 5;
  ```

---

### TASK 2 — `UpdateBooking`
* **Purpose**: Updates the reservation date for an existing booking identified by `BookingID`.
* **Input Parameters (2)**:
  1. `booking_id` (`INT`): The target reservation ID to update.
  2. `booking_date` (`DATE`): The revised calendar date.
* **SQL Implementation**:
  ```sql
  DELIMITER //
  CREATE PROCEDURE UpdateBooking(
      IN booking_id INT,
      IN booking_date DATE
  )
  BEGIN
      UPDATE Bookings
      SET BookingDate = booking_date
      WHERE BookingID = booking_id;

      SELECT CONCAT('Booking ', booking_id, ' updated') AS Confirmation;
  END //
  DELIMITER ;
  ```
* **How to Invoke**:
  ```sql
  CALL UpdateBooking(5, '2022-12-31');
  ```
* **How to Verify**:
  ```sql
  SELECT * FROM Bookings WHERE BookingID = 5;
  ```
  *(Verify that `BookingDate` now shows the updated date `2022-12-31`).*

---

### TASK 3 — `CancelBooking`
* **Purpose**: Permanently removes a booking from the `Bookings` table.
* **Input Parameter (1)**:
  1. `booking_id` (`INT`): The unique reservation ID to delete.
* **SQL Implementation**:
  ```sql
  DELIMITER //
  CREATE PROCEDURE CancelBooking(
      IN booking_id INT
  )
  BEGIN
      DELETE FROM Bookings
      WHERE BookingID = booking_id;

      SELECT CONCAT('Booking ', booking_id, ' cancelled') AS Confirmation;
  END //
  DELIMITER ;
  ```

> [!WARNING]
> ### Safety Protocol for `CancelBooking`
> `CancelBooking` performs a permanent `DELETE` operation. Do not run it automatically. Always follow the 3-step safety verification protocol:
> 1. **Step 1 (Pre-Check)**: Confirm the target booking exists:
>    ```sql
>    SELECT * FROM Bookings WHERE BookingID = 5;
>    ```
> 2. **Step 2 (Execution)**: Call the procedure only with your verified ID:
>    ```sql
>    CALL CancelBooking(5);
>    ```
> 3. **Step 3 (Post-Check)**: Confirm the booking was removed (returns 0 rows):
>    ```sql
>    SELECT * FROM Bookings WHERE BookingID = 5;
>    ```

---

## 4. Instructions for MySQL Workbench

1. Launch **MySQL Workbench** and connect to your local MySQL Server.
2. Open a new SQL Editor tab (`Ctrl + T`).
3. Set the active schema:
   ```sql
   USE LittleLemonDB;
   ```
4. Open the deliverable script:
   [`little_lemon_booking_procedures.sql`](file:///d:/Projects/ASSESSMENT/little_lemon_booking_procedures.sql).
5. **Create the Procedures**:
   * Highlight each `DELIMITER // ... DELIMITER ;` block one at a time and click the **Execute** (lightning bolt) icon.
   * Verify that all 3 procedures appear under `LittleLemonDB` $\to$ `Stored Procedures` in the Navigator panel.
6. **Test Each Procedure Sequentially**:
   * Test `AddBooking`: `CALL AddBooking(5, 2, '2022-12-30', 4);`
   * Verify insertion: `SELECT * FROM Bookings WHERE BookingID = 5;`
   * Test `UpdateBooking`: `CALL UpdateBooking(5, '2022-12-31');`
   * Verify update: `SELECT * FROM Bookings WHERE BookingID = 5;`
   * Test `CancelBooking`: `CALL CancelBooking(5);`
   * Verify deletion: `SELECT * FROM Bookings WHERE BookingID = 5;` (returns 0 rows).

---

## 5. Final Validation Checklist

### TASK 1: `AddBooking`
- [x] Procedure name is exactly `AddBooking`
- [x] Four input parameters present (`booking_id`, `customer_id`, `booking_date`, `table_number`)
- [x] `INSERT` statement maps parameters to correct `Bookings` columns
- [x] User confirmation returned (`New booking added`)
- [x] Example `CALL` statement provided
- [x] Verification `SELECT` query provided

### TASK 2: `UpdateBooking`
- [x] Procedure name is exactly `UpdateBooking`
- [x] Two input parameters present (`booking_id`, `booking_date`)
- [x] `UPDATE` statement updates `BookingDate`
- [x] `UPDATE` strictly targets the specified `BookingID`
- [x] User confirmation returned (`Booking <id> updated`)
- [x] Example `CALL` statement provided
- [x] Verification `SELECT` query provided

### TASK 3: `CancelBooking`
- [x] Procedure name is exactly `CancelBooking`
- [x] One input parameter present (`booking_id`)
- [x] `DELETE` statement targets the specified `BookingID`
- [x] User confirmation returned (`Booking <id> cancelled`)
- [x] Example `CALL` statement provided
- [x] Safe 3-step verification workflow and warnings provided
- [x] No procedures are automatically executed
