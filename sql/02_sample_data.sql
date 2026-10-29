-- SAMPLE DATA — run only once on a fresh, empty InventoryDB.
-- Do not run against your current populated database.
USE InventoryDB;

INSERT INTO Users (full_name, email, password_hash, role) VALUES
('Admin User', 'admin@inventory.com', 'demo_hash_admin', 'admin'),
('Rahul Sharma', 'rahul@inventory.com', 'demo_hash_rahul', 'staff'),
('Priya Patil', 'priya@inventory.com', 'demo_hash_priya', 'staff');

INSERT INTO Categories (category_name, description) VALUES
('Electronics', 'Electronic devices and accessories'),
('Stationery', 'Office and educational supplies'),
('Accessories', 'Computer and mobile accessories');

INSERT INTO Suppliers
(supplier_name, contact_person, phone, email, address) VALUES
('TechWorld Distributors', 'Amit Shah', '9876543210',
 'sales@techworld.example', 'Sangli'),
('OfficeMart Supplies', 'Neha Joshi', '9876543211',
 'contact@officemart.example', 'Kolhapur'),
('Digital Solutions', 'Karan Desai', '9876543212',
 'info@digitalsolutions.example', 'Pune');

INSERT INTO Products
(category_id, product_name, sku, unit_price,
 quantity_in_stock, reorder_level) VALUES
(1, 'Wireless Mouse', 'ELEC001', 599.00, 25, 10),
(1, 'USB Keyboard', 'ELEC002', 899.00, 8, 10),
(1, 'USB-C Cable', 'ELEC003', 249.00, 5, 15),
(2, 'Notebook', 'STAT001', 60.00, 100, 20),
(2, 'Blue Pen Pack', 'STAT002', 120.00, 12, 15),
(3, 'Laptop Stand', 'ACC001', 799.00, 18, 5),
(3, 'USB Hub', 'ACC002', 499.00, 0, 10);

INSERT INTO SupplierProducts (supplier_id, product_id, supplier_price) VALUES
(1, 1, 420.00),
(1, 2, 650.00),
(1, 3, 150.00),
(2, 4, 35.00),
(2, 5, 75.00),
(3, 1, 440.00),
(3, 6, 550.00),
(3, 7, 320.00);

INSERT INTO PurchaseOrders (supplier_id, user_id, order_date, status) VALUES
(1, 1, '2026-10-15', 'Received'),
(2, 2, '2026-10-17', 'Pending'),
(3, 1, '2026-10-18', 'Pending');

INSERT INTO PurchaseOrderItems (order_id, product_id, quantity, unit_cost) VALUES
(1, 1, 10, 420.00),
(1, 2, 5, 650.00),
(2, 4, 50, 35.00),
(2, 5, 20, 75.00),
(3, 6, 8, 550.00),
(3, 7, 10, 320.00);

-- These are historical demo rows. They were inserted before the stock triggers
-- were created, so they do not retroactively change Products.quantity_in_stock.
INSERT INTO StockMovements
(product_id, user_id, movement_type, quantity_changed, remarks) VALUES
(1, 1, 'IN', 10, 'Stock received'),
(1, 2, 'OUT', -3, 'Items sold'),
(2, 1, 'IN', 5, 'Stock received'),
(3, 2, 'OUT', -2, 'Items sold'),
(4, 1, 'IN', 50, 'Stock received'),
(5, 2, 'ADJUSTMENT', -3, 'Damaged items'),
(7, 1, 'OUT', -5, 'Items sold');
