-- Recreate the stock movement validation and stock-update triggers.
-- Does not change existing product quantities or movement history.
USE InventoryDB;

DROP TRIGGER IF EXISTS after_stock_movement_insert;
DROP TRIGGER IF EXISTS before_stock_movement_insert;

DELIMITER //

CREATE TRIGGER before_stock_movement_insert
BEFORE INSERT ON StockMovements
FOR EACH ROW
BEGIN
    DECLARE current_stock INT;

    SELECT quantity_in_stock
      INTO current_stock
      FROM Products
     WHERE product_id = NEW.product_id;

    IF NEW.movement_type = 'OUT'
       AND NEW.quantity_changed >= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'OUT movement must have a negative quantity';
    END IF;

    IF NEW.movement_type = 'IN'
       AND NEW.quantity_changed <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'IN movement must have a positive quantity';
    END IF;

    IF current_stock + NEW.quantity_changed < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient stock for this movement';
    END IF;
END//

CREATE TRIGGER after_stock_movement_insert
AFTER INSERT ON StockMovements
FOR EACH ROW
BEGIN
    UPDATE Products
       SET quantity_in_stock = quantity_in_stock + NEW.quantity_changed
     WHERE product_id = NEW.product_id;
END//

DELIMITER ;
