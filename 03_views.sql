-- Create or replace the three reporting views.
USE InventoryDB;

CREATE OR REPLACE VIEW InventoryReport AS
SELECT
    p.product_id,
    p.product_name,
    p.sku,
    c.category_name,
    p.unit_price,
    p.quantity_in_stock,
    p.reorder_level,
    p.quantity_in_stock * p.unit_price AS stock_value
FROM Products AS p
INNER JOIN Categories AS c
    ON p.category_id = c.category_id;

CREATE OR REPLACE VIEW LowStockProducts AS
SELECT
    product_id,
    product_name,
    sku,
    quantity_in_stock,
    reorder_level
FROM Products
WHERE quantity_in_stock <= reorder_level;

CREATE OR REPLACE VIEW PurchaseOrderSummary AS
SELECT
    po.order_id,
    s.supplier_name,
    po.order_date,
    po.status,
    COALESCE(SUM(poi.quantity * poi.unit_cost), 0) AS order_total
FROM PurchaseOrders AS po
INNER JOIN Suppliers AS s
    ON po.supplier_id = s.supplier_id
LEFT JOIN PurchaseOrderItems AS poi
    ON po.order_id = poi.order_id
GROUP BY
    po.order_id,
    s.supplier_name,
    po.order_date,
    po.status;
