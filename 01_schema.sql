-- Inventory & Supplier Management System
-- Schema creation. Does not drop or reset existing tables.
CREATE DATABASE IF NOT EXISTS InventoryDB;
USE InventoryDB;

CREATE TABLE IF NOT EXISTS Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(30) NOT NULL DEFAULT 'staff',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS Suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(150) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(150),
    address VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    sku VARCHAR(50) NOT NULL UNIQUE,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity_in_stock INT NOT NULL DEFAULT 0,
    reorder_level INT NOT NULL DEFAULT 10,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id) REFERENCES Categories(category_id),
    CONSTRAINT chk_products_unit_price CHECK (unit_price >= 0),
    CONSTRAINT chk_products_quantity CHECK (quantity_in_stock >= 0),
    CONSTRAINT chk_products_reorder CHECK (reorder_level >= 0)
);

CREATE TABLE IF NOT EXISTS SupplierProducts (
    supplier_id INT NOT NULL,
    product_id INT NOT NULL,
    supplier_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (supplier_id, product_id),
    CONSTRAINT fk_supplierproducts_supplier
        FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id),
    CONSTRAINT fk_supplierproducts_product
        FOREIGN KEY (product_id) REFERENCES Products(product_id),
    CONSTRAINT chk_supplierproducts_price CHECK (supplier_price >= 0)
);

CREATE TABLE IF NOT EXISTS PurchaseOrders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    user_id INT NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    CONSTRAINT fk_purchaseorders_supplier
        FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id),
    CONSTRAINT fk_purchaseorders_user
        FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE IF NOT EXISTS PurchaseOrderItems (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_poi_order
        FOREIGN KEY (order_id) REFERENCES PurchaseOrders(order_id),
    CONSTRAINT fk_poi_product
        FOREIGN KEY (product_id) REFERENCES Products(product_id),
    CONSTRAINT chk_poi_quantity CHECK (quantity > 0),
    CONSTRAINT chk_poi_unit_cost CHECK (unit_cost >= 0),
    CONSTRAINT uq_poi_order_product UNIQUE (order_id, product_id)
);

CREATE TABLE IF NOT EXISTS StockMovements (
    movement_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    movement_type VARCHAR(30) NOT NULL,
    quantity_changed INT NOT NULL,
    movement_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    remarks VARCHAR(255),
    CONSTRAINT fk_stockmovements_product
        FOREIGN KEY (product_id) REFERENCES Products(product_id),
    CONSTRAINT fk_stockmovements_user
        FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT chk_stockmovements_nonzero CHECK (quantity_changed <> 0)
);
