# Urban Pedal — SQL Project (Unit 7 · RA4)

Database project based on a bicycle retail chain called **Urban Pedal**. The script covers INSERT, DELETE, UPDATE and TRANSACTION operations on a relational schema including tables for customers, products, orders, staff, suppliers and stock.

---

## Database Diagram

The schema includes the following main tables:

- **CUSTOMER** — store customers
- **ORDERS / ORDER_DETAILS** — customer orders and their line items
- **PRODUCT** — bicycle catalogue, with brand and category
- **BRAND / CATEGORY** — auxiliary classification tables
- **STAFF** — employees and their commissions
- **STORE** — physical store locations
- **STOCK** — inventory per store and product
- **SUPPLIER / ORDERS_SUPPLIER / DETAILS_SUPPLIER** — suppliers and restocking orders

---

## Exercises

### INSERT

#### 1. `ANNUAL_FINANCIAL_REPORT`
Creates and inserts a record with the financial summary for 2024:
- **Total_Spent**: money spent on purchases from suppliers
- **T_Sold**: revenue obtained from sales
- **Profit**: net profit (T_Sold - Total_Spent)

#### 2. `ANNUAL_COMMISSION`
Creates and inserts the total commission each employee is to receive for all sales made during 2024.

#### 3. `ANNUAL_CUSTOMERS_AWARDS`
Creates and inserts the customers who receive a voucher in 2024 based on their total spending and number of invoices:
| Condition | Voucher |
|---|---|
| Spending > €10,000 and 3 or more invoices | €200 |
| Spending > €5,000 and 2 or more invoices | €100 |
| Spending > €4,000 | €50 |

---

### DELETE

#### 4. Customers with no purchases
Deletes customers registered in the database who have never placed an order.

#### 5. Products not sold in 2024
Deletes products that were not sold during 2024. The deletion is performed in cascade respecting foreign key constraints:
`STOCK` → `ORDER_DETAILS` → `DETAILS_SUPPLIER` → `PRODUCT`

#### 6. Suppliers with no supply orders in 2024
Deletes suppliers that did not supply any goods throughout 2024. The deletion is also performed in cascade:
`DETAILS_SUPPLIER` → `ORDERS_SUPPLIER` → `SUPPLIER`

---

### UPDATE

#### 7. Price of the 3 best-selling products (+15%)
Increases the price of the 3 best-selling bicycles in 2024 (by units sold) by 15%.

#### 8. Employee commissions based on units sold
Updates employee commissions based on units sold during 2024:
| Units sold | Increase |
|---|---|
| 250 or more | +0.2% |
| Between 100 and 249 | +0.1% |

> **Note:** The `Commission` column was defined as `DECIMAL(3,2)`, which did not allow storing increments of 0.002. It has been altered to `DECIMAL(10,4)` using a prior `ALTER TABLE` statement.

---

### TRANSACTION

#### 9. Product sale → STOCK update
Inserts a line into `ORDER_DETAILS` and decreases the corresponding unit from `STOCK` within a transaction:
- Product: Trek 820 - 2016
- OrderID: 635 · Quantity: 1 · Discount: 10%

> **Note:** The exercise sheet lists the product name as `Trek 820-216`, but the actual name in the database is `Trek 820 - 2016`.

#### 10. Supplier delivery → STOCK update
Records a supplier delivery in `DETAILS_SUPPLIER` and adds the units to `STOCK` within a transaction:
- Product: Trek 820 - 2016
- OrderSupID: 41 · Quantity: 15 · PriceCost: €520

> **Note:** The exercise sheet requested an INSERT, but the record already existed in the database with the same values, which caused a duplicate primary key error. An UPDATE was used instead.

---

## Technology

- **SQL Server**
- **SQL Server Management Studio (SSMS)**
