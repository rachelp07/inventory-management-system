-- Stored procedures for reporting and stock operations.
-- Re-running this file replaces the procedures but does not call them.
USE InventoryDB;

DROP PROCEDURE IF EXISTS GetLowStockProducts;
DROP PROCEDURE IF EXISTS ReceiveStock;
DROP PROCEDURE IF EXISTS IssueStock;

DELIMITER //

CREATE PROCEDURE GetLowStockProducts()
BEGIN
    SELECT
        product_id,
        product_name,
        quantity_in_stock,
        reorder_level
    FROM Products
    WHERE quantity_in_stock <= reorder_level
    ORDER BY quantity_in_stock ASC;
END//

CREATE PROCEDURE ReceiveStock(
    IN p_product_id INT,
    IN p_user_id INT,
    IN p_quantity INT,
    IN p_remarks VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_quantity IS NULL OR p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Received quantity must be greater than zero';
    END IF;

    START TRANSACTION;

    INSERT INTO StockMovements
        (product_id, user_id, movement_type, quantity_changed, remarks)
    VALUES
        (p_product_id, p_user_id, 'IN', p_quantity, p_remarks);

    -- The AFTER INSERT trigger updates Products.quantity_in_stock.
    COMMIT;
END//

CREATE PROCEDURE IssueStock(
    IN p_product_id INT,
    IN p_user_id INT,
    IN p_quantity INT,
    IN p_remarks VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_quantity IS NULL OR p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Issued quantity must be greater than zero';
    END IF;

    START TRANSACTION;

    INSERT INTO StockMovements
        (product_id, user_id, movement_type, quantity_changed, remarks)
    VALUES
        (p_product_id, p_user_id, 'OUT', -p_quantity, p_remarks);

    -- The BEFORE INSERT trigger checks available stock; the AFTER INSERT
    -- trigger updates Products.quantity_in_stock.
    COMMIT;
END//

DELIMITER ;

-- Run these separately to test:
-- CALL GetLowStockProducts();
-- CALL ReceiveStock(1, 1, 2, 'Procedure test - received');
-- CALL IssueStock(1, 1, 2, 'Procedure test - issued');
