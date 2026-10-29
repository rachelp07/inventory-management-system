
# InventoryDB - Schema Plan

## 1. Users
- user_id: INT, Primary Key, Auto Increment
- full_name: VARCHAR(100)
- email: VARCHAR(150), Unique
- password_hash: VARCHAR(255)
- role: VARCHAR(30)
- created_at: TIMESTAMP

## 2. Categories
- category_id: INT, Primary Key, Auto Increment
- category_name: VARCHAR(100), Unique
- description: VARCHAR(255)

## 3. Suppliers
- supplier_id: INT, Primary Key, Auto Increment
- supplier_name: VARCHAR(150)
- contact_person: VARCHAR(100)
- phone: VARCHAR(20)
- email: VARCHAR(150)
- address: VARCHAR(255)

## 4. Products
- product_id: INT, Primary Key, Auto Increment
- category_id: INT, Foreign Key
- product_name: VARCHAR(150)
- sku: VARCHAR(50), Unique
- unit_price: DECIMAL(10,2)
- quantity_in_stock: INT
- reorder_level: INT
- created_at: TIMESTAMP

## 5. SupplierProducts
- supplier_id: INT, Foreign Key
- product_id: INT, Foreign Key
- supplier_price: DECIMAL(10,2)
- Primary Key: supplier_id, product_id

## 6. PurchaseOrders
- order_id: INT, Primary Key, Auto Increment
- supplier_id: INT, Foreign Key
- user_id: INT, Foreign Key
- order_date: DATE
- status: VARCHAR(30)

## 7. PurchaseOrderItems
- order_item_id: INT, Primary Key, Auto Increment
- order_id: INT, Foreign Key
- product_id: INT, Foreign Key
- quantity: INT
- unit_cost: DECIMAL(10,2)

## 8. StockMovements
- movement_id: INT, Primary Key, Auto Increment
- product_id: INT, Foreign Key
- user_id: INT, Foreign Key
- movement_type: VARCHAR(30)
- quantity_changed: INT
- movement_date: TIMESTAMP
- remarks: VARCHAR(255)
