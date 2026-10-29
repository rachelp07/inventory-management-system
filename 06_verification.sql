-- Read-only checks for the existing InventoryDB.
USE InventoryDB;

-- List tables
SHOW TABLES;

-- Exact record counts
SELECT 'Users' AS table_name, COUNT(*) AS records FROM Users
UNION ALL SELECT 'Categories', COUNT(*) FROM Categories
UNION ALL SELECT 'Suppliers', COUNT(*) FROM Suppliers
UNION ALL SELECT 'Products', COUNT(*) FROM Products
UNION ALL SELECT 'SupplierProducts', COUNT(*) FROM SupplierProducts
UNION ALL SELECT 'PurchaseOrders', COUNT(*) FROM PurchaseOrders
UNION ALL SELECT 'PurchaseOrderItems', COUNT(*) FROM PurchaseOrderItems
UNION ALL SELECT 'StockMovements', COUNT(*) FROM StockMovements;

-- Test the views
SELECT * FROM InventoryReport;
SELECT * FROM LowStockProducts;
SELECT * FROM PurchaseOrderSummary;

-- Inspect triggers and procedures
SHOW TRIGGERS FROM InventoryDB;
SHOW PROCEDURE STATUS
WHERE Db = 'InventoryDB'
  AND Name IN ('GetLowStockProducts', 'ReceiveStock', 'IssueStock');

-- Current inventory and stock history
SELECT product_id, product_name, quantity_in_stock, reorder_level
FROM Products
ORDER BY product_id;

SELECT movement_id, product_id, movement_type, quantity_changed,
       movement_date, remarks
FROM StockMovements
ORDER BY movement_id;

-- Current inventory valuation (based on current quantity x selling price)
SELECT SUM(quantity_in_stock * unit_price) AS inventory_value
FROM Products;
