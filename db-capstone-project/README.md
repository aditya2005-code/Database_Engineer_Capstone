# Little Lemon Database Capstone Project (`db-capstone-project`)

## 1. Project Overview
Little Lemon is a family-owned Mediterranean restaurant requiring a robust, normalized relational database management system. This project implements a production-grade database named **`LittleLemonDB`** based on the visual relational model **`LittleLemonDM`** designed in **MySQL Workbench**.

The database manages six core operational business areas:
1. **Bookings**: Recording table reservations made by customers.
2. **Orders**: Capturing customer purchase events, order quantities, and total costs.
3. **Order Delivery Status**: Tracking delivery dates and dispatch fulfillment status.
4. **Menu**: Categorizing dining themes and cuisines across courses.
5. **Customer Details**: Storing client identity and contact information.
6. **Staff Information**: Managing restaurant employee roles and compensation.

---

## 2. ER Model Specification (`LittleLemonDM`)

The relational architecture is modeled into 7 normalized tables:

```
CustomerDetails (1) ───< (M) Bookings (M) >─── (1) StaffInformation
       │                                                 │
      (1)                                               (1)
       │                                                 │
       ▼                                                 ▼
     Orders (M) >────────────────────────────────────────┘
       │    │
      (1)  (M)
       │    │
       │    ▼
       │   Menu (1) ───< (M) MenuItems
       ▼
OrderDeliveryStatus (1:1)
```

### Table Definitions & Keys:

| Table | Primary Key | Foreign Keys | Core Attributes | Relationships & Multiplicity |
| :--- | :--- | :--- | :--- | :--- |
| **`CustomerDetails`** | `CustomerID` | None | `CustomerName`, `ContactDetails` | `1:M` to `Bookings`, `1:M` to `Orders` |
| **`StaffInformation`**| `StaffID` | None | `StaffName`, `Role`, `Salary` | `1:M` to `Bookings`, `1:M` to `Orders` |
| **`Bookings`** | `BookingID` | `CustomerID` $\to$ `CustomerDetails`<br>`StaffID` $\to$ `StaffInformation` | `BookingDate`, `TableNumber` | `M:1` to `CustomerDetails`, `M:1` to `StaffInformation` |
| **`MenuItems`** | `MenuItemID` | None | `CourseName`, `StarterName`, `DesertName`, `DrinkName` | `1:M` to `Menu` |
| **`Menu`** | `MenuID` | `MenuItemID` $\to$ `MenuItems` | `MenuName`, `Cuisine` | `M:1` to `MenuItems`, `1:M` to `Orders` |
| **`Orders`** | `OrderID` | `CustomerID` $\to$ `CustomerDetails`<br>`MenuID` $\to$ `Menu`<br>`StaffID` $\to$ `StaffInformation` | `OrderDate`, `Quantity`, `TotalCost` | `M:1` to `CustomerDetails`, `M:1` to `Menu`, `M:1` to `StaffInformation`, `1:1` to `OrderDeliveryStatus` |
| **`OrderDeliveryStatus`**| `DeliveryID`| `OrderID` $\to$ `Orders` (`UNIQUE`) | `DeliveryDate`, `Status` | `1:1` to `Orders` |

---

## 3. Normalization (1NF, 2NF, 3NF)

The database strictly conforms to Third Normal Form (3NF):

### 1NF (First Normal Form)
- Every table has an atomic Primary Key (`CustomerID`, `StaffID`, `BookingID`, `MenuItemID`, `MenuID`, `OrderID`, `DeliveryID`).
- Attributes contain single atomic values (no repeating groups, comma-separated lists, or arrays).
- All columns use standard scalar data types (`INT`, `VARCHAR`, `DECIMAL`, `DATE`).

### 2NF (Second Normal Form)
- Satisfies 1NF.
- All non-key attributes are **fully functionally dependent** on their table's primary key.
- Every primary key consists of a single attribute; therefore, partial functional dependencies are mathematically impossible.

### 3NF (Third Normal Form)
- Satisfies 2NF.
- Zero **transitive dependencies** exist across non-key columns:
  - Customer contact details are not repeated in `Orders` or `Bookings`; only `CustomerID (FK)` is stored.
  - Staff salary and roles reside exclusively in `StaffInformation`; only `StaffID (FK)` is stored in `Orders` and `Bookings`.
  - Dish items reside exclusively in `MenuItems`; `Menu` references `MenuItemID`.
  - Delivery information is isolated into `OrderDeliveryStatus` with a `UNIQUE` foreign key referencing `OrderID`.

---

## 4. MySQL Implementation

The database is implemented using MySQL 8.0 with the **`InnoDB`** engine, ensuring ACID compliance and foreign key enforcement:
- **Database DDL File**: [`LittleLemonDB/LittleLemonDB.sql`](file:///d:/Projects/ASSESSMENT/db-capstone-project/LittleLemonDB/LittleLemonDB.sql)
- **Engine**: `InnoDB`
- **Charset / Collation**: `utf8mb4` / `utf8mb4_unicode_ci`
- **Constraints**:
  - `CHECK (Quantity > 0)` and `CHECK (TotalCost >= 0.00)` on `Orders`.
  - Declarative foreign keys configured with `ON UPDATE CASCADE ON DELETE RESTRICT` (and `CASCADE` for order delivery status).
  - `UNIQUE` constraint on `OrderDeliveryStatus(OrderID)` to strictly enforce the `1:1` relationship.

---

## 5. MySQL Workbench Forward Engineer Workflow

Follow these exact steps in MySQL Workbench to deploy the model to your live MySQL Server:

```
[LittleLemonDM (.mwb)] 
          │
          ▼
[Database Menu] ──► [Forward Engineer Wizard]
                            │
                            ▼
                  [Connect to Localhost:3306]
                            │
                            ▼
                  [Review Generated DDL]
                            │
                            ▼
                  [Commit & Execute on Server]
                            │
                            ▼
                  [Verify LittleLemonDB Schema]
```

1. **Open the Model**: Launch MySQL Workbench $\to$ **File** $\to$ **Open Model...** $\to$ open `LittleLemonDM.mwb` (or create it using [`LittleLemonDM/er_diagram.mermaid`](file:///d:/Projects/ASSESSMENT/db-capstone-project/LittleLemonDM/er_diagram.mermaid)).
2. **Launch Wizard**: Click on the **Database** menu at the top $\to$ select **Forward Engineer...** (or press `Ctrl + G`).
3. **Configure Connection**: Select your local connection (`127.0.0.1:3306`), username (`root` or `little_lemon_admin`).
4. **Options**: Check:
   - [x] *Generate DROP Statements Before Each CREATE Statement*
   - [x] *Generate CREATE INDEX Statements*
5. **Select Objects**: Check **Export MySQL Table Objects** (7 tables selected).
6. **Review SQL**: Inspect the displayed DDL script. Confirm `CREATE DATABASE IF NOT EXISTS LittleLemonDB;`.
7. **Execute**: Click **Next** to run the statements against your MySQL Server.
8. **Commit Progress**: Ensure all execution steps show green checkmarks. Click **Close**.
9. **Verify Existence**: Refresh the Schemas tab in the Navigator and confirm `LittleLemonDB` appears.
10. **Verify Tables**: Confirm that all 7 tables exist.

---

## 6. Database Verification (`SHOW DATABASES;`)

To verify the database in MySQL Workbench SQL Editor:
1. Open MySQL Workbench and connect to your MySQL Server.
2. Open a new SQL tab (**File** $\to$ **New Query Tab** or `Ctrl + T`).
3. Open or paste [`MySQL/show_databases.sql`](file:///d:/Projects/ASSESSMENT/db-capstone-project/MySQL/show_databases.sql):
   ```sql
   SHOW DATABASES;
   ```
4. Execute the query (lightning bolt icon).
5. In the **Result Grid**, verify that **`littlelemondb`** is listed among the databases.
6. Run:
   ```sql
   USE `LittleLemonDB`;
   SHOW FULL TABLES IN `LittleLemonDB`;
   ```
7. Confirm that all 7 tables appear:
   - `Bookings`
   - `CustomerDetails`
   - `Menu`
   - `MenuItems`
   - `OrderDeliveryStatus`
   - `Orders`
   - `StaffInformation`

---

## 7. Project Validation Checklist

### ER Diagram
- [x] All six required business areas represented (`Bookings`, `Orders`, `OrderDeliveryStatus`, `Menu`, `CustomerDetails`, `StaffInformation`)
- [x] Appropriate attributes present
- [x] Primary keys defined for every table
- [x] Foreign keys and cascade rules defined
- [x] 1:1 relationship between `Orders` and `OrderDeliveryStatus` enforced
- [x] Cardinalities logical and verified
- [x] Supporting Mermaid diagram created: [`LittleLemonDM/er_diagram.mermaid`](file:///d:/Projects/ASSESSMENT/db-capstone-project/LittleLemonDM/er_diagram.mermaid)

### Normalization
- [x] **1NF satisfied**: Primary keys, atomic attributes, no repeating groups
- [x] **2NF satisfied**: 1NF compliant, no partial functional dependencies
- [x] **3NF satisfied**: 2NF compliant, no transitive dependencies
- [x] Documentation generated: [`LittleLemonDM/normalization_analysis.md`](file:///d:/Projects/ASSESSMENT/db-capstone-project/LittleLemonDM/normalization_analysis.md)

### MySQL Implementation
- [x] Database named `LittleLemonDB`
- [x] Tables match the ER diagram exactly
- [x] Appropriate data types (`INT`, `VARCHAR`, `DECIMAL(10,2)`, `DATE`)
- [x] Constraints (`PK`, `FK`, `NOT NULL`, `CHECK`, `UNIQUE`)
- [x] Single contained SQL file created: [`LittleLemonDB/LittleLemonDB.sql`](file:///d:/Projects/ASSESSMENT/db-capstone-project/LittleLemonDB/LittleLemonDB.sql)
- [x] Forward Engineer workflow documented

### Task 3 Verification
- [x] `SHOW DATABASES;` verification query created: [`MySQL/show_databases.sql`](file:///d:/Projects/ASSESSMENT/db-capstone-project/MySQL/show_databases.sql)
- [x] Step-by-step Workbench verification instructions provided

### Project Files
- [x] Root project folder named `db-capstone-project`
- [x] Organized strictly according to rubric specification
