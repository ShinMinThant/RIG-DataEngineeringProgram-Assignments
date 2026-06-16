/* =============================================
   ECOMMERCE STORED FUNCTIONS LAB
   Microsoft SQL Server Version
============================================= */

IF DB_ID('ecommerce_db') IS NULL
    CREATE DATABASE ecommerce_db;
GO

USE ecommerce_db;
GO

/* =============================================
   DROP OLD TABLES
============================================= */

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
GO

/* =============================================
   CREATE TABLES
============================================= */

CREATE TABLE customers (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    membership_level VARCHAR(30)
);

CREATE TABLE products (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10,2),
    stock_qty INT
);

CREATE TABLE orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    order_status VARCHAR(30),
    CONSTRAINT FK_orders_customers
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    CONSTRAINT FK_order_items_orders
        FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT FK_order_items_products
        FOREIGN KEY (product_id) REFERENCES products(product_id)
);
GO

/* =============================================
   POPULATE SAMPLE DATA
============================================= */

INSERT INTO customers (customer_name, email, membership_level)
VALUES
('Aung Aung', 'aung@example.com', 'Gold'),
('Su Su', 'su@example.com', 'Silver'),
('Kyaw Kyaw', 'kyaw@example.com', 'Normal'),
('Mya Mya', 'mya@example.com', 'Gold'),
('Ko Ko', 'koko@example.com', 'Silver'),
('Hla Hla', 'hla@example.com', 'Normal'),
('Zaw Zaw', 'zaw@example.com', 'Gold'),
('Ei Ei', 'eiei@example.com', 'Silver'),
('Tun Tun', 'tun@example.com', 'Normal'),
('May May', 'may@example.com', 'Gold');

INSERT INTO products (product_name, category, unit_price, stock_qty)
VALUES
('Laptop', 'Electronics', 1200000, 10),
('Mouse', 'Electronics', 25000, 100),
('Keyboard', 'Electronics', 45000, 50),
('Office Chair', 'Furniture', 180000, 20),
('Desk', 'Furniture', 250000, 15),
('Monitor', 'Electronics', 350000, 25),
('Printer', 'Electronics', 450000, 8),
('USB Keyboard', 'Electronics', 30000, 120),
('Gaming Mouse', 'Electronics', 55000, 75),
('Bookshelf', 'Furniture', 200000, 12),
('Meeting Table', 'Furniture', 650000, 5),
('Headphone', 'Electronics', 85000, 40),
('Webcam', 'Electronics', 95000, 18),
('Air Conditioner', 'Appliances', 1800000, 3),
('Projector', 'Electronics', 950000, 6);

INSERT INTO orders (customer_id, order_date, order_status)
VALUES
(1, '2026-05-01', 'Completed'),
(2, '2026-05-02', 'Completed'),
(3, '2026-05-03', 'Pending'),
(4, '2026-05-04', 'Completed'),
(5, '2026-05-05', 'Pending'),
(6, '2026-05-06', 'Cancelled'),
(7, '2026-05-07', 'Completed'),
(8, '2026-05-08', 'Completed'),
(9, '2026-05-09', 'Pending'),
(10, '2026-05-10', 'Completed');

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES
(1, 1, 1, 1200000),
(1, 2, 2, 25000),
(2, 4, 1, 180000),
(2, 3, 1, 45000),
(3, 5, 1, 250000),
(4, 6, 1, 350000),
(4, 7, 2, 450000),

(5, 8, 1, 30000),
(5, 9, 2, 55000),

(6, 10, 1, 200000),

(7, 11, 1, 650000),
(7, 12, 3, 85000),

(8, 13, 2, 95000),

(9, 14, 1, 1800000),

(10, 15, 1, 950000),

(11, 1, 1, 1200000),
(11, 3, 2, 45000),

(12, 4, 1, 180000),

(13, 5, 1, 250000);
GO
GO

/* =============================================
   DROP OLD FUNCTIONS
============================================= */

DROP FUNCTION IF EXISTS fn_order_subtotal;
DROP FUNCTION IF EXISTS fn_tax_amount;
DROP FUNCTION IF EXISTS fn_membership_discount;
DROP FUNCTION IF EXISTS fn_order_final_total;
DROP FUNCTION IF EXISTS fn_stock_status;
DROP FUNCTION IF EXISTS fn_customer_order_count;
DROP FUNCTION IF EXISTS fn_membership_label;
DROP FUNCTION IF EXISTS fn_shipping_fee;
DROP FUNCTION IF EXISTS fn_order_grand_total;
GO

/* =============================================
   FUNCTION 1: Calculate Order Subtotal
============================================= */

CREATE FUNCTION fn_order_subtotal
(
    @p_order_id INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @v_subtotal DECIMAL(10,2);

    SELECT @v_subtotal = SUM(quantity * unit_price)
    FROM order_items
    WHERE order_id = @p_order_id;

    RETURN ISNULL(@v_subtotal, 0);
END;
GO

SELECT dbo.fn_order_subtotal(1) AS order_subtotal;
GO

/* =============================================
   FUNCTION 2: Calculate Tax Amount
============================================= */

CREATE FUNCTION fn_tax_amount
(
    @p_amount DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @p_amount * 0.05;
END;
GO

SELECT dbo.fn_tax_amount(100000) AS tax_amount;
GO

/* =============================================
   FUNCTION 3: Membership Discount
============================================= */

CREATE FUNCTION fn_membership_discount
(
    @p_amount DECIMAL(10,2),
    @p_membership_level VARCHAR(30)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @v_discount DECIMAL(10,2);

    IF @p_membership_level = 'Gold'
        SET @v_discount = @p_amount * 0.10;
    ELSE IF @p_membership_level = 'Silver'
        SET @v_discount = @p_amount * 0.05;
    ELSE
        SET @v_discount = 0;

    RETURN @v_discount;
END;
GO

SELECT dbo.fn_membership_discount(100000, 'Gold') AS discount_amount;
GO

/* =============================================
   FUNCTION 4: Final Order Total
============================================= */

CREATE FUNCTION fn_order_final_total
(
    @p_order_id INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @v_subtotal DECIMAL(10,2);
    DECLARE @v_tax DECIMAL(10,2);
    DECLARE @v_discount DECIMAL(10,2);
    DECLARE @v_membership VARCHAR(30);
    DECLARE @v_final_total DECIMAL(10,2);

    SELECT @v_membership = c.membership_level
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_id = @p_order_id;

    SET @v_subtotal = dbo.fn_order_subtotal(@p_order_id);
    SET @v_tax = dbo.fn_tax_amount(@v_subtotal);
    SET @v_discount = dbo.fn_membership_discount(@v_subtotal, @v_membership);

    SET @v_final_total = @v_subtotal + @v_tax - @v_discount;

    RETURN ISNULL(@v_final_total, 0);
END;
GO

SELECT dbo.fn_order_final_total(1) AS final_order_total;
GO

/* =============================================
   FUNCTION 5: Stock Status
============================================= */

CREATE FUNCTION fn_stock_status
(
    @p_stock_qty INT
)
RETURNS VARCHAR(30)
AS
BEGIN
    RETURN
        CASE
            WHEN @p_stock_qty = 0 THEN 'Out of Stock'
            WHEN @p_stock_qty < 10 THEN 'Low Stock'
            ELSE 'Available'
        END;
END;
GO

SELECT 
    product_name,
    stock_qty,
    dbo.fn_stock_status(stock_qty) AS stock_status
FROM products;
GO

/* =============================================
   FUNCTION 6: Customer Order Count
============================================= */

CREATE FUNCTION fn_customer_order_count
(
    @p_customer_id INT
)
RETURNS INT
AS
BEGIN
    DECLARE @v_total_orders INT;

    SELECT @v_total_orders = COUNT(*)
    FROM orders
    WHERE customer_id = @p_customer_id;

    RETURN @v_total_orders;
END;
GO

SELECT 
    customer_name,
    dbo.fn_customer_order_count(customer_id) AS total_orders
FROM customers;
GO

/* =============================================
   FUNCTION 7: Membership Label
============================================= */

CREATE FUNCTION fn_membership_label
(
    @p_membership_level VARCHAR(30)
)
RETURNS VARCHAR(100)
AS
BEGIN
    RETURN
        CASE
            WHEN @p_membership_level = 'Gold' THEN 'Gold Member - 10% Discount'
            WHEN @p_membership_level = 'Silver' THEN 'Silver Member - 5% Discount'
            ELSE 'Normal Member - No Discount'
        END;
END;
GO

SELECT 
    customer_name,
    membership_level,
    dbo.fn_membership_label(membership_level) AS membership_description
FROM customers;
GO

/* =============================================
   FUNCTION 8: Shipping Fee
============================================= */

CREATE FUNCTION fn_shipping_fee
(
    @p_amount DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    IF @p_amount >= 500000
        RETURN 0;

    RETURN 5000;
END;
GO

SELECT dbo.fn_shipping_fee(300000) AS shipping_fee;
GO

/* =============================================
   FUNCTION 9: Grand Total
============================================= */

CREATE FUNCTION fn_order_grand_total
(
    @p_order_id INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @v_final_total DECIMAL(10,2);
    DECLARE @v_shipping_fee DECIMAL(10,2);

    SET @v_final_total = dbo.fn_order_final_total(@p_order_id);
    SET @v_shipping_fee = dbo.fn_shipping_fee(@v_final_total);

    RETURN @v_final_total + @v_shipping_fee;
END;
GO

SELECT dbo.fn_order_grand_total(1) AS grand_total;
GO

/* =============================================
   PRACTICAL REPORT QUERY
============================================= */

SELECT 
    o.order_id,
    c.customer_name,
    c.membership_level,
    dbo.fn_order_subtotal(o.order_id) AS subtotal,
    dbo.fn_tax_amount(dbo.fn_order_subtotal(o.order_id)) AS tax_amount,
    dbo.fn_membership_discount(
        dbo.fn_order_subtotal(o.order_id),
        c.membership_level
    ) AS discount_amount,
    dbo.fn_order_final_total(o.order_id) AS final_total,
    dbo.fn_shipping_fee(dbo.fn_order_final_total(o.order_id)) AS shipping_fee,
    dbo.fn_order_grand_total(o.order_id) AS grand_total,
    o.order_status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;
GO

/* =============================================
   SHOW ALL USER FUNCTIONS
============================================= */

SELECT 
    name AS function_name,
    create_date,
    modify_date
FROM sys.objects
WHERE type IN ('FN', 'IF', 'TF')
ORDER BY name;
GO