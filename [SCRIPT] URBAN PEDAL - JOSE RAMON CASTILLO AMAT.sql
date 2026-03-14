/* EJERCICIO 1. TABLA: ANNUAL_FINANCIAL_REPORT */
CREATE TABLE ANNUAL_FINANCIAL_REPORT (
YearF INT
, Total_Spent money
, T_Sold money
, Profit money
)

INSERT INTO ANNUAL_FINANCIAL_REPORT
    SELECT 2024,
    (SELECT SUM(Quantity * PriceCost) 
    FROM DETAILS_SUPPLIER
    JOIN ORDERS_SUPPLIER 
    ON DETAILS_SUPPLIER.OrderSupID = ORDERS_SUPPLIER.OrderSupID 
    WHERE YEAR(ORDERS_SUPPLIER.OrderDate) = 2024),

    (SELECT SUM(Quantity * Price * (1 - Discount)) 
    FROM ORDER_DETAILS
    JOIN ORDERS
    ON ORDER_DETAILS.OrderID = ORDERS.OrderID 
    WHERE YEAR(ORDERS.OrderDate) = 2024),

    (SELECT SUM(Quantity * Price * (1 - Discount)) 
    FROM ORDER_DETAILS
    JOIN ORDERS
    ON ORDER_DETAILS.OrderID = ORDERS.OrderID 
    WHERE YEAR(ORDERS.OrderDate) = 2024) - (SELECT SUM(Quantity * PriceCost) 
                                            FROM DETAILS_SUPPLIER
                                            JOIN ORDERS_SUPPLIER
                                            ON DETAILS_SUPPLIER.OrderSupID = ORDERS_SUPPLIER.OrderSupID 
                                            WHERE YEAR(ORDERS_SUPPLIER.OrderDate) = 2024)
SELECT * FROM ANNUAL_FINANCIAL_REPORT


/* EJERCICIO 2. TABLA: ANNUAL_COMMISSION */
CREATE TABLE ANNUAL_COMMISSION (
YearC INT NOT NULL
, Nombre_Empleado VARCHAR(100) NOT NULL
, Total_Commission DECIMAL(18,2) NOT NULL
)

INSERT INTO ANNUAL_COMMISSION
    SELECT 2024 AS YearC, CONCAT(FirstName, ' ', LastName) AS Nombre_Empleado, SUM(Quantity * Price * (1 - Discount) * Commission) AS Total_Commission
    FROM STAFF
    JOIN ORDERS 
    ON STAFF.StaffID = ORDERS.StaffID
    JOIN ORDER_DETAILS
    ON ORDERS.OrderID = ORDER_DETAILS.OrderID
    WHERE YEAR(ORDERS.OrderDate) = 2024
    GROUP BY STAFF.StaffID, FirstName, LastName

SELECT * FROM ANNUAL_COMMISSION


/* EJERCICIO 3. TABLA: ANNUAL_CUSTOMERS_AWARDS */
CREATE TABLE ANNUAL_CUSTOMERS_AWARDS (
YearC INT NOT NULL
, NameCustomer VARCHAR(100) NOT NULL
, Voucher INT NOT NULL
)

INSERT INTO ANNUAL_CUSTOMERS_AWARDS
    SELECT 2024, CONCAT(FirstName, ' ', LastName),
    CASE 
        WHEN SUM(Quantity * Price * (1 - Discount)) > 10000 AND COUNT(DISTINCT ORDERS.OrderID) >= 3 THEN 200
        WHEN SUM(Quantity * Price * (1 - Discount)) > 5000 AND COUNT(DISTINCT ORDERS.OrderID) >= 2 THEN 100
        WHEN SUM(Quantity * Price * (1 - Discount)) > 4000 THEN 50
    END
    FROM CUSTOMER
    JOIN ORDERS 
    ON CUSTOMER.CustomerID = ORDERS.CustomerID
    JOIN ORDER_DETAILS 
    ON ORDERS.OrderID = ORDER_DETAILS.OrderID
    WHERE YEAR(ORDERS.OrderDate) = 2024
    GROUP BY FirstName, LastName
    HAVING SUM(ORDER_DETAILS.Quantity * ORDER_DETAILS.Price * (1 - ORDER_DETAILS.Discount)) > 4000

SELECT * FROM ANNUAL_CUSTOMERS_AWARDS


/* EJERCICIO 4. Borrar clientes que nunca han comprado nada */
SELECT * FROM CUSTOMER
BEGIN TRANSACTION

DELETE FROM CUSTOMER 
WHERE CustomerID NOT IN (SELECT DISTINCT CustomerID FROM ORDERS)

SELECT * FROM CUSTOMER
ROLLBACK


/* EJERCICIO 5. Borrar bicicletas (productos) no vendidas en 2024 */ --REVISAR
SELECT * FROM PRODUCT
SELECT COUNT(*) FROM PRODUCT
BEGIN TRANSACTION

-- 1. Borrar de STOCK
DELETE FROM STOCK
WHERE ProductID NOT IN 
    (SELECT ORDER_DETAILS.ProductID 
    FROM ORDER_DETAILS
    JOIN ORDERS ON ORDER_DETAILS.OrderID = ORDERS.OrderID 
    WHERE YEAR(ORDERS.OrderDate) = 2024)

-- 2. Borrar de ORDER_DETAILS
DELETE FROM ORDER_DETAILS
WHERE ProductID NOT IN 
    (SELECT ORDER_DETAILS.ProductID 
    FROM ORDER_DETAILS
    JOIN ORDERS ON ORDER_DETAILS.OrderID = ORDERS.OrderID 
    WHERE YEAR(ORDERS.OrderDate) = 2024)

-- 3. Borrar de DETAILS_SUPPLIER
DELETE FROM DETAILS_SUPPLIER
WHERE ProductID NOT IN 
    (SELECT ORDER_DETAILS.ProductID 
    FROM ORDER_DETAILS
    JOIN ORDERS ON ORDER_DETAILS.OrderID = ORDERS.OrderID 
    WHERE YEAR(ORDERS.OrderDate) = 2024)

-- 4. Finalmente borrar de PRODUCT
DELETE FROM PRODUCT
WHERE ProductID NOT IN 
    (SELECT ORDER_DETAILS.ProductID 
    FROM ORDER_DETAILS
    JOIN ORDERS ON ORDER_DETAILS.OrderID = ORDERS.OrderID 
    WHERE YEAR(ORDERS.OrderDate) = 2024)

SELECT * FROM PRODUCT
SELECT COUNT(*) FROM PRODUCT
ROLLBACK


/* EJERCICIO 6. Borrar proveedores que no han suministrado nada en 2024 */
SELECT * FROM SUPPLIER
BEGIN TRANSACTION

-- 1. Borrar de DETAILS_SUPPLIER
DELETE FROM DETAILS_SUPPLIER 
WHERE OrderSupID IN 
    (SELECT OrderSupID 
    FROM ORDERS_SUPPLIER 
    WHERE SupplierID NOT IN 
        (SELECT SupplierID 
        FROM ORDERS_SUPPLIER 
        WHERE YEAR(OrderDate) = 2024))

-- 2. Borrar de ORDERS_SUPPLIER
DELETE FROM ORDERS_SUPPLIER 
WHERE SupplierID NOT IN 
    (SELECT SupplierID 
    FROM ORDERS_SUPPLIER 
    WHERE YEAR(OrderDate) = 2024)

-- 3. Finalmente borrar de SUPPLIER
DELETE FROM SUPPLIER 
WHERE SupplierID NOT IN 
    (SELECT DISTINCT SupplierID 
    FROM ORDERS_SUPPLIER 
    WHERE YEAR(OrderDate) = 2024)

SELECT * FROM SUPPLIER
ROLLBACK


/* EJERCICIO 7. Actualizar precios de las 3 bicicletas más vendidas en 2024 (+15%) */
SELECT * FROM PRODUCT
BEGIN TRANSACTION

UPDATE PRODUCT
SET Price = Price * 1.15
WHERE ProductID IN 
    (SELECT TOP 3 ORDER_DETAILS.ProductID
    FROM ORDER_DETAILS
    JOIN ORDERS 
    ON ORDER_DETAILS.OrderID = ORDERS.OrderID
    WHERE YEAR(ORDERS.OrderDate) = 2024
    GROUP BY ORDER_DETAILS.ProductID
    ORDER BY SUM(ORDER_DETAILS.Quantity) DESC)

SELECT * FROM PRODUCT
ROLLBACK


/* EJERCICIO 8. Actualizar comisión de vendedores según unidades vendidas en 2024 */
SELECT * FROM STAFF
BEGIN TRANSACTION

ALTER TABLE STAFF
ALTER COLUMN Commission DECIMAL(10, 4)

UPDATE STAFF
SET Commission = Commission + 0.002
WHERE StaffID IN 
    (SELECT ORDERS.StaffID
    FROM ORDERS
    JOIN ORDER_DETAILS 
    ON ORDERS.OrderID = ORDER_DETAILS.OrderID
    WHERE YEAR(OrderDate) = 2024
    GROUP BY StaffID
    HAVING SUM(Quantity) >= 250)
AND Commission IS NOT NULL

UPDATE STAFF
SET Commission = Commission + 0.001
WHERE StaffID IN 
    (SELECT ORDERS.StaffID
    FROM ORDERS
    JOIN ORDER_DETAILS
    ON ORDERS.OrderID = ORDER_DETAILS.OrderID
    WHERE YEAR(OrderDate) = 2024
    GROUP BY StaffID
    HAVING SUM(Quantity) >= 100
    AND SUM(Quantity) < 250)
AND Commission IS NOT NULL

SELECT * FROM STAFF
ROLLBACK


/* EJERCICIO 9. Transacción: Venta de producto y actualización de STOCK */
-- NOTA: El enunciado indica el producto 'Trek 820-216' pero ese nombre
-- no existe en la base de datos. El nombre real del producto es 
-- 'Trek 820 - 2016' (con espacios y año completo), así que se ha usado
-- ese nombre para que la transacción funcione correctamente.
-- Además, el IF/ELSE hace ROLLBACK en ambos casos ya que es una prueba,
-- en producción real el COMMIT iría en el bloque de éxito.
BEGIN TRANSACTION

DECLARE @productName VARCHAR(100) = 'Trek 820 - 2016'
DECLARE @idproduct INT = (SELECT ProductID FROM PRODUCT WHERE ProductName = @productName)
DECLARE @quantity int = 1
DECLARE @idorder INT = 635
DECLARE @price money = (SELECT Price FROM PRODUCT WHERE ProductID = @idproduct)
DECLARE @discount decimal(4,2) = 0.1
DECLARE @idstore INT = (SELECT StoreID FROM ORDERS WHERE OrderID = @idorder)

INSERT INTO ORDER_DETAILS VALUES (@idorder, @idproduct, @quantity, @price, @discount)

UPDATE STOCK
SET Quantity = Quantity - @quantity
WHERE ProductID = @idproduct
    AND StoreID = @idstore

IF @@ERROR = 0
BEGIN
COMMIT TRANSACTION
    PRINT 'Transaction completed successfully'
END
ELSE
BEGIN
    ROLLBACK TRANSACTION
    PRINT 'Transaction failed'
END


/* EJERCICIO 10. Transacción: Compra a proveedor y actualización de STOCK */
/* NOTA: El enunciado pide hacer un INSERT en DETAILS_SUPPLIER, pero el registro
con OrderSupID=41 y ProductID=1 (Trek 820 - 2016) ya existe en la base de datos
con exactamente los mismos valores (Quantity=15, PriceCost=520), por lo que
el INSERT daría error de clave primaria duplicada.
Por eso se ha usado UPDATE en su lugar, que consigue el mismo resultado. */
BEGIN TRANSACTION

DECLARE @productName2 VARCHAR(100) = 'Trek 820 - 2016'
DECLARE @idproduct2 INT = (SELECT ProductID FROM PRODUCT WHERE ProductName = @productName2)
DECLARE @quantity2 INT = 15
DECLARE @pricecost MONEY = 520
DECLARE @idordersup INT = 41
DECLARE @idstore2 INT = (SELECT StoreID FROM ORDERS_SUPPLIER WHERE OrderSupID = @idordersup)

UPDATE DETAILS_SUPPLIER
SET Quantity = Quantity + @quantity2,
    PriceCost = @pricecost
WHERE OrderSupID = @idordersup 
AND ProductID = @idproduct2

UPDATE STOCK
SET Quantity = Quantity + @quantity2
WHERE ProductID = @idproduct2
    AND StoreID = @idstore2

IF @@ERROR = 0
BEGIN
    COMMIT TRANSACTION
    PRINT 'Transaction completed successfully'
END
ELSE
BEGIN
    ROLLBACK TRANSACTION
    PRINT 'Transaction failed'
END
