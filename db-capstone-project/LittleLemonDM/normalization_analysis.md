# Normalization Analysis — Little Lemon Database (`LittleLemonDB`)

## 1. Overview
This document evaluates the relational schema design for the **Little Lemon** database project against the three fundamental database normal forms: **First Normal Form (1NF)**, **Second Normal Form (2NF)**, and **Third Normal Form (3NF)**.

The schema comprises:
- `CustomerDetails`
- `StaffInformation`
- `Bookings`
- `MenuItems`
- `Menu`
- `Orders`
- `OrderDeliveryStatus`

---

## 2. First Normal Form (1NF)

### 1NF Criteria
A relation is in **1NF** if and only if:
1. Every table has a designated **Primary Key** that uniquely identifies every tuple/row.
2. Every attribute contains strictly **atomic (indivisible) values**.
3. There are **no repeating groups** or multi-valued attributes (e.g., no comma-separated arrays stored inside a single cell).
4. Each cell contains a single scalar value.

### Little Lemon 1NF Verification
- **Primary Keys**: Every entity has a declared primary key:
  - `CustomerDetails`: `CustomerID` (PK)
  - `StaffInformation`: `StaffID` (PK)
  - `Bookings`: `BookingID` (PK)
  - `MenuItems`: `MenuItemID` (PK)
  - `Menu`: `MenuID` (PK)
  - `Orders`: `OrderID` (PK)
  - `OrderDeliveryStatus`: `DeliveryID` (PK)
- **Atomicity**: No multi-valued strings or repeating arrays exist. For example, instead of storing multiple courses, drinks, and starters in a single string within an order, menu items are modeled as distinct atomic attributes (`CourseName`, `StarterName`, `DesertName`, `DrinkName`) within `MenuItems`, and associated with `Menu` and `Orders` through formal foreign keys.
- **Data Types**: All columns use atomic SQL primitive types (`INT`, `VARCHAR`, `DECIMAL`, `DATE`).

**Conclusion**: **1NF is fully satisfied.**

---

## 3. Second Normal Form (2NF)

### 2NF Criteria
A relation is in **2NF** if and only if:
1. It is already in **1NF**.
2. There are **no partial functional dependencies** (every non-key attribute is fully functionally dependent on the primary key, rather than on any proper subset of a candidate key).

### Little Lemon 2NF Verification
- **Single-Column Primary Keys**:
  In `CustomerDetails`, `StaffInformation`, `Bookings`, `MenuItems`, `Menu`, `Orders`, and `OrderDeliveryStatus`, the primary key consists of a single attribute (`CustomerID`, `StaffID`, `BookingID`, `MenuItemID`, `MenuID`, `OrderID`, `DeliveryID`).
  * **Mathematical Rule**: By definition, a partial dependency can only exist if a table has a composite primary key (a key made up of two or more columns). Because each table's primary key is atomic (single-column), **no partial dependency can possibly exist**. Every non-key attribute depends on the whole primary key.
- **Relational Integrity**:
  - In `Orders`, `OrderDate`, `Quantity`, and `TotalCost` depend entirely on `OrderID`.
  - In `Bookings`, `BookingDate` and `TableNumber` depend entirely on `BookingID`.
  - In `OrderDeliveryStatus`, `DeliveryDate` and `Status` depend entirely on `DeliveryID`.

**Conclusion**: **2NF is fully satisfied.**

---

## 4. Third Normal Form (3NF)

### 3NF Criteria
A relation is in **3NF** if and only if:
1. It is already in **2NF**.
2. There are **no transitive functional dependencies** (no non-key attribute is functionally dependent on another non-key attribute; for every functional dependency $X \to Y$, $X$ must be a superkey or $Y$ must be a prime attribute).

### Little Lemon 3NF Verification
- **Elimination of Transitive Dependencies**:
  1. **Customer Data**: In `Orders`, customer attributes such as `CustomerName` and `ContactDetails` are not stored. Only `CustomerID` (FK) is referenced. This prevents the transitive dependency:
     $$\text{OrderID} \longrightarrow \text{CustomerID} \longrightarrow \text{CustomerName, ContactDetails}$$
  2. **Staff Data**: In `Orders` and `Bookings`, staff salary and roles are not stored. Only `StaffID` (FK) is referenced. This prevents:
     $$\text{OrderID} \longrightarrow \text{StaffID} \longrightarrow \text{Role, Salary}$$
  3. **Menu & Course Data**: In `Orders`, details about food courses and starters are not stored. Only `MenuID` (FK) is referenced. The menu references `MenuItemID` in `MenuItems`, ensuring item details depend solely on `MenuItemID`.
  4. **Delivery Status**: Delivery progress is decoupled into `OrderDeliveryStatus` linked via `OrderID (FK, UNIQUE)` rather than embedding nullable delivery fields into `Orders`.

**Conclusion**: **3NF is fully satisfied.**

---

## 5. Anomaly Elimination Summary

| Anomaly Type | Problem in Unnormalized Design | How 3NF Design Eliminates the Anomaly |
| :--- | :--- | :--- |
| **Insertion Anomaly** | Cannot add a new customer without an order, or cannot create a staff member without a booking. | Independent master tables (`CustomerDetails`, `StaffInformation`) allow inserting records without dependent transactional rows. |
| **Update Anomaly** | Updating a customer's phone number requires changing multiple order records, risking data inconsistency. | Customer contact details exist in a single row in `CustomerDetails`. Updating it takes a single write. |
| **Deletion Anomaly** | Deleting a cancelled order deletes customer history or staff records if stored together. | Deleting a record from `Orders` removes only the transaction; `CustomerDetails` and `StaffInformation` remain intact. |
