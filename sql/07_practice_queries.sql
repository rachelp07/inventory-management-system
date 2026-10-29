-- Read-only practice/report queries for InventoryDB.
USE InventoryDB;

-- 1. Products with categories
SELECT p.product_id, p.product_name, c.category_name,
       p.unit_price, p.quantity_in_stock
FROM Products AS p
JOIN Categories AS c ON c.category_id = p.category_id
ORDER BY p.product_name;

-- 2. Products requiring restocking
SELECT product_id, product_name, quantity_in_stock, reorder_level
FROM Products
WHERE quantity_in_stock <= reorder_level
ORDER BY quantity_in_stock;

-- 3. Products and their suppliers
SELECT p.product_name, s.supplier_name, sp.supplier_price
FROM SupplierProducts AS sp
JOIN Products AS p ON p.product_id = sp.product_id
JOIN Suppliers AS s ON s.supplier_id = sp.supplier_id
ORDER BY p.product_name, s.supplier_name;

-- 4. Current inventory valuation
SELECT SUM(quantity_in_stock * unit_price) AS inventory_value
FROM Products;

-- 5. Purchase order summary
SELECT * FROM PurchaseOrderSummary ORDER BY order_id;

-- 6. Product movement totals (historical movement rows, not a reconciliation)
SELECT p.product_name,
       SUM(CASE WHEN sm.quantity_changed > 0 THEN sm.quantity_changed ELSE 0 END) AS total_in,
       SUM(CASE WHEN sm.quantity_changed < 0 THEN -sm.quantity_changed ELSE 0 END) AS total_out
FROM Products AS p
LEFT JOIN StockMovements AS sm ON sm.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY p.product_name;
