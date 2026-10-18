-- ============================================================================
-- MIT 8103: Advanced Database Systems - Portfolio 3
-- Student Name: Peace Ekoh | Student ID: 301866431
-- Case Study: NovaMart Retail Logistics & Storefront
-- File: deadlock_simulation.sql (Deadlock Analysis & Prevention Script)
-- Engine: MySQL 8.0 (InnoDB)
-- ============================================================================

USE novamart_db;

-- ----------------------------------------------------------------------------
-- PART A: THE DEADLOCK ANATOMY (Circular Dependency)
-- ----------------------------------------------------------------------------
-- In high-concurrency order processing, multi-item checkout can induce deadlocks
-- if locks are acquired in arbitrary or non-deterministic sequences.
--
-- SCENARIO:
-- Cart A contains Product 1 (iPhone) and Product 2 (Samsung S24).
-- Cart B contains Product 2 (Samsung S24) and Product 1 (iPhone).
--
-- TIMELINE OF CONFLICT:
-- Time T1: Session A locks Product 1
--          SELECT * FROM products WHERE product_id = 1 FOR UPDATE;
--
-- Time T2: Session B locks Product 2
--          SELECT * FROM products WHERE product_id = 2 FOR UPDATE;
--
-- Time T3: Session A attempts to lock Product 2 (BLOCKED, waits for Session B)
--          SELECT * FROM products WHERE product_id = 2 FOR UPDATE;
--
-- Time T4: Session B attempts to lock Product 1 (BLOCKED, waits for Session A)
--          SELECT * FROM products WHERE product_id = 1 FOR UPDATE;
--
-- INNODB RESOLUTION:
-- A cycle is detected in the internal lock wait-for graph.
-- InnoDB terminates the cycle by choosing the transaction with the smallest
-- undo log footprint as the victim and returns:
-- "ERROR 1213 (40001): Deadlock found when trying to get lock; try restarting transaction"

-- ----------------------------------------------------------------------------
-- PART B: DETERMINISTIC RESOURCE ORDERING (DEADLOCK ELIMINATION)
-- ----------------------------------------------------------------------------
-- Mathematical Proof: Deadlock requires a circular wait (Coffman condition).
-- If all concurrent transactions request resources according to a strict global
-- linear order (e.g. sorted by primary key product_id ASC), circular wait is
-- impossible, and deadlocks are 100% prevented by design.

-- IMPLEMENTATION IN NOVAMART:
-- When a cart with items [product_id = 4, product_id = 1] is checked out:
-- The application sorts the IDs into [1, 4] BEFORE executing locks.

SELECT '--- DEMONSTRATING DETERMINISTIC ORDERED LOCKING ---' AS status;

START TRANSACTION;

-- Lock items in deterministic sorted order (product_id ASC)
SELECT product_id, product_name, stock_quantity
FROM products
WHERE product_id IN (1, 4)
ORDER BY product_id ASC
FOR UPDATE;

-- Deduct stock safely with zero risk of circular wait
UPDATE products SET stock_quantity = stock_quantity - 1 WHERE product_id = 1;
UPDATE products SET stock_quantity = stock_quantity - 1 WHERE product_id = 4;

COMMIT;

-- Verify updated stock
SELECT product_id, product_name, stock_quantity
FROM products
WHERE product_id IN (1, 4);

-- ----------------------------------------------------------------------------
-- PART C: INSPECTING INNODB DEADLOCK LOGS
-- ----------------------------------------------------------------------------
-- To inspect the latest deadlock details in MySQL:
-- SHOW ENGINE INNODB STATUS\G;
