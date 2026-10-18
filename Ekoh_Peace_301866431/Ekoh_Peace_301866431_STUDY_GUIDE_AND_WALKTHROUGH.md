# My Complete Study Guide — MIT 8103 Advanced Database Systems
## Written in Plain English So I Can Understand Every Step
**My Name:** Peace Ekoh | **My Student ID:** 301866431  
**My Project:** NovaMart Online Store Database Portfolio  

---

> **How to use this guide:** Read it like a story. Each section explains what we did, WHY we did it, and what the results looked like. No heavy grammar. If you can explain this to a friend, you can explain it to the lecturer.

---

# PART 1: THE BIG PICTURE — What is the Whole Project About?

## The Simple Story

Imagine a company called **NovaMart**. NovaMart is like a Nigerian version of Amazon or Jumia — it sells phones, laptops, fridges, clothes, and groceries online. 

Now imagine millions of customers using this app every day:
- People browsing products
- People adding items to their cart
- People clicking "Buy Now" and making payments
- The warehouse receiving orders and packing goods
- Managers looking at sales reports

For all of this to work smoothly, NovaMart needs a **database**. But not just one database — multiple databases working together, each one doing what it is best at.

**This portfolio is the proof that Peace Ekoh knows how to design, build, test, and explain that entire database system.**

---

## Why NovaMart? Why Not Just a Simple Example?

The lecturer asked for a realistic, complex business scenario. An online store is perfect because:
- It has **money involved** (we need strict rules so nobody loses funds)
- It has **many users at the same time** (two people can try to buy the last phone in stock)
- It has **complex product information** (a laptop has RAM and processor; a dress has size and color; rice has weight and origin — all different!)
- It has **huge data volume** (thousands of orders per day, millions of rows in the database)
- It is something **everyone can immediately understand**

---

## The Three Databases We Used and Why (Polyglot Persistence)

We used **three different types of databases** in this project. This approach is called *Polyglot Persistence* — a fancy phrase that simply means "using the right tool for the right job."

### Database 1: MySQL 8.0 (The Strict, Trustworthy Banker)
Think of MySQL like a very strict bank teller. When you transfer money, the bank teller:
- Makes sure the money leaves your account
- Makes sure the money arrives in the other account
- If anything fails in the middle (power cut, network problem), it cancels the whole thing

That is exactly what MySQL does for NovaMart. We used it for:
- **Customers** (names, emails, phones, addresses)
- **Orders** (what was ordered, when, by who)
- **Payments** (how much was paid, which gateway, was it successful?)
- **Products** (prices, stock levels)
- **Inventory Audit Log** (every time stock goes up or down)

### Database 2: MongoDB (The Flexible Filing Cabinet)
Think of MongoDB like a filing cabinet where you can throw in any kind of document. You can have a folder for a laptop that contains "RAM, Processor, Battery" and another folder for a dress that contains "Size, Color, Material" — each folder looks completely different from the other, and that is perfectly fine.

We used it for:
- **Product Catalog with dynamic specifications** (each product type has different details)
- **Customer Reviews** (embedded directly inside the product document — no need to join tables just to show star ratings)

### Database 3: Redis (The Super-Fast Sticky Notes Board)
Think of Redis like a whiteboard in your office where staff quickly write notes that expire after a few days. It lives entirely in RAM (computer memory), so it is thousands of times faster than a disk-based database.

We used it for:
- **Shopping Carts** (a customer's cart is stored in Redis and automatically disappears if they don't check out within 7 days)
- **Instant Stock Counters** (during a Black Friday flash sale, instead of asking MySQL "how many phones are left?" thousands of times per second, we ask Redis in microseconds)

---

# PART 2: HOW WE SET UP THE COMPUTER (Before Writing Any Code)

## Step 1: Checking What Tools Are on the Computer

The first thing we did was run commands to check what was already installed on this computer. We found:

| Tool | Where It Is | Version | What We Use It For |
| :--- | :--- | :--- | :--- |
| **MySQL** | `C:\laragon\bin\mysql\mysql-8.0.30-winx64` | 8.0.30 | Main relational database |
| **Python** | `C:\laragon\bin\python\python-3.10` | 3.10 | Running automation scripts |
| **Node.js** | `C:\laragon\bin\nodejs\node-v18` | v18.8.0 | JavaScript execution |
| **Git** | `C:\laragon\bin\git` | 2.56 | Version control and commits |
| **Microsoft Edge** | `C:\Program Files (x86)\Microsoft\Edge` | Latest | Converting HTML report to PDF |

## Step 2: Making Sure MySQL Was Actually Running

We tested the MySQL connection by asking it to print its own version number. It responded with `8.0.30`, which confirmed it was running and accepting connections. The full command was:
```
"C:\laragon\bin\mysql\mysql-8.0.30-winx64\bin\mysql.exe" -u root -e "SELECT VERSION();"
```
Result: `8.0.30` ✅

## Step 3: Setting Up Git and the 5 Folders

The assignment required 5 specific folders. We created them all at once:
1. `portfolio-1-database-design`
2. `portfolio-2-query-optimisation`
3. `portfolio-3-transactions-concurrency`
4. `portfolio-4-nosql`
5. `portfolio-5-distributed-cloud`

We also set up Git (version control) so every time we finished a task, we saved it as a checkpoint (a commit). The lecturer specifically says: **"Don't upload everything at the last minute."** Progressive commits show you actually built it step by step.

We told Git who was making the commits:
```
git config user.name "Peace Ekoh"
git config user.email "301866431@miva.university"
```

---

# PART 3: PORTFOLIO 1 — The Blueprint (Database Design)

## The Goal of Portfolio 1
Design the tables (the blueprint of our database) and prove that the design is clean, organized, and follows academic rules (Normalization).

Think of it like designing the floor plan of a house before you start building. If the plan is bad, the whole house will have problems.

---

## The 8 Tables We Created

### Table 1: `customers`
This stores the customer account information.

**Why it exists:** Every person who shops on NovaMart needs an account. We need to know who they are.

**Key columns:**
- `customer_id` — A unique number given to each customer (1, 2, 3, 4...). We made this auto-generate (MySQL picks the next number automatically).
- `email` — Marked as UNIQUE, meaning no two customers can share an email address.
- `phone` — Also UNIQUE.
- `loyalty_points` — How many reward points the customer has earned. We added a rule: `loyalty_points >= 0` — this means it can never go negative. That is called a **Check Constraint**.

---

### Table 2: `customer_addresses`
This stores delivery addresses for each customer.

**Why a separate table?** Because one customer can have multiple addresses (home address, office address, family member's house). If we put addresses inside the customers table, we would have to write `address1`, `address2`, `address3` columns — very messy. A separate table is clean.

**Key Design:**
- `customer_id` is a **Foreign Key** pointing to `customers.customer_id`. This means: "This address belongs to this specific customer."
- `ON DELETE CASCADE` — If a customer is deleted, all their addresses are automatically deleted too. No orphaned address records.

---

### Table 3: `categories`
This stores the product categories like "Electronics", "Smartphones", "Laptops", "Home & Kitchen", etc.

**The interesting design here: Self-Referencing Foreign Key.**
Categories can have parent categories. "Smartphones" is a child of "Electronics". "Gaming Laptops" can be a child of "Laptops".

We achieved this by having `parent_category_id` point back to `category_id` in the same table. This allows an unlimited category tree without creating separate tables for each level.

---

### Table 4: `products`
This is the master product catalog. Every product sold on NovaMart lives here.

**Key columns:**
- `sku` — Stock Keeping Unit. A unique code like `SKU-SMP-001` that identifies this exact product. UNIQUE constraint.
- `unit_price` — The price we sell it for. Rule: `unit_price > 0`.
- `cost_price` — The price we bought it for (to calculate profit). Rule: `cost_price > 0`.
- `stock_quantity` — How many units are left in the warehouse. Rule: `stock_quantity >= 0`. This prevents negative stock.
- `reorder_level` — When stock drops to this number, the system should alert for restocking.
- `category_id` — Foreign Key to `categories` table. `ON DELETE RESTRICT` means: you cannot delete a category if products still belong to it.

---

### Table 5: `orders`
The order header. When a customer clicks "Confirm Order", one row is created here.

**Key columns:**
- `order_status` — Uses an ENUM (a fixed list of allowed values): `PENDING`, `CONFIRMED`, `PROCESSING`, `SHIPPED`, `DELIVERED`, `CANCELLED`. The database rejects anything not on this list.
- `subtotal_amount` — Price before shipping fee.
- `shipping_fee` — Delivery cost.
- `total_amount` — Final amount the customer pays.
- `customer_id` — Foreign Key to `customers`.
- `shipping_address_id` — Foreign Key to `customer_addresses`. We store the specific address for this delivery (because the customer might change their address later, but this order's address should never change).

---

### Table 6: `order_items`
The individual items inside each order. This is the "shopping list" for each order.

**Why separate from orders?** Because one order can have multiple products. We cannot store "Product A, Product B, Product C" inside one row of the orders table — that would break the first rule of database normalization.

**The smart design here:**
- **Composite UNIQUE constraint:** `UNIQUE(order_id, product_id)` — This means the same product cannot appear twice as separate rows in the same order.
- **Stored Generated Column:** `line_total AS (quantity * unit_price) STORED` — MySQL automatically calculates and stores `quantity × unit_price`. We never have to manually maintain this value.
- **Historical price protection:** We store the `unit_price` at the time of purchase. Even if the product price changes tomorrow, this order's price stays fixed forever.

---

### Table 7: `payments`
Records the payment transaction for each order.

**Key design:**
- `order_id` is UNIQUE — Meaning one order has exactly one payment record. This enforces a One-to-One relationship.
- `payment_reference` is UNIQUE — Every payment gets a unique reference code from the payment gateway. No duplicates allowed.
- `payment_status` ENUM: `INITIATED`, `SUCCESSFUL`, `FAILED`, `REFUNDED`.

---

### Table 8: `inventory_logs`
An immutable audit trail. Every time stock changes (new stock arrives, order shipped, item returned, damaged write-off), one row is added here.

**Why it matters:** If the warehouse manager asks "why does our iPhone stock show only 10 units when we received 30 last month?" — we can trace every change through this log. It is like a CCTV recording for inventory.

---

## The Normalization Story: How We Cleaned Up the Database Design

### What is Normalization?
Normalization is the process of organizing a database so that data is stored in the cleanest, most logical way — no unnecessary repetition, no risk of conflicting data, no messy updates.

There are 3 levels (called Normal Forms). You have to pass through them in order:

---

### The Starting Mess (Unnormalized Form)
Imagine if NovaMart originally kept everything in one giant spreadsheet with columns like this:

```
OrderID | Date | CustomerName | CustomerEmail | CustomerAddress | Product1Name | Product1Price | Product1Qty | Product2Name | Product2Price | Product2Qty | PayRef | PayStatus
```

**Problems with this:**
1. If a customer appears in 500 orders, their email address is repeated 500 times. Update one character and you need to update 500 rows.
2. There are repeating groups (Product1, Product2, Product3...). What if someone buys 15 items?
3. If you delete an order, you lose the customer's contact information.

This is the mess we fix through Normalization.

---

### First Normal Form (1NF): Make Everything Atomic
**The Rule:** Every cell in the table must contain ONE single value. No lists, no repeating groups.

**What we changed:**
- We pulled the repeating product columns into a new table called `order_items`. Now each product in an order gets its own dedicated row.
- We pulled out multi-valued addresses (home, office, delivery) into `customer_addresses`.
- We split "Full Name" into `first_name` and `last_name` (atomic values).

**After 1NF:** No more repeating groups. ✅

---

### Second Normal Form (2NF): Every Column Must Need the Whole Key
**The Rule:** We're in 2NF if we're in 1NF AND every non-key column depends on the ENTIRE primary key, not just part of it.

**The problem we found:** In `order_items`, the primary key is a combination of `(order_id, product_id)`. But `product_name` and `category_name` and `base_price` only depend on `product_id` — they do NOT depend on `order_id`. This is called a **Partial Dependency** and it is a problem.

**Example:** If you store `product_name` in `order_items`, you now have the same product name repeated in every order it appears in. If you rename the product, you have to update hundreds of order rows.

**What we changed:** We removed product descriptions and category names from `order_items` and kept them only in `products`. The `order_items` table now only stores what is unique per transaction: `quantity` and `unit_price` at time of purchase.

**After 2NF:** No more partial dependencies. ✅

---

### Third Normal Form (3NF): No One Column Should Depend on Another Non-Key Column
**The Rule:** We're in 3NF if we're in 2NF AND no non-key column depends on another non-key column.

This is called a **Transitive Dependency** and it causes update anomalies.

**The problems we found:**
1. In `products`: `product_id` determines `category_id`, which in turn determines `category_name`. So `category_name` is transitively dependent on `product_id` through `category_id`. If you change a category name, you have to update every product row.
2. In `orders`: `order_id` determines `customer_id`, which determines `customer_email`. If a customer changes their email, you'd have to update every order they ever placed.

**What we changed:**
- Moved category information into a dedicated `categories` table. Products now store only `category_id` (a reference).
- Moved customer information into `customers`. Orders now store only `customer_id` (a reference).

**After 3NF/BCNF:** For every relationship between columns, the left side is always a primary key. Zero transitive dependencies. ✅

---

### Seeding the Database (Putting Real Data In)
After creating the tables, we ran `seed_data.sql` which added:
- **10 customers** with Nigerian names, addresses across Lagos, Abuja, PH, Ibadan, and other cities
- **12 products** across 6 categories (iPhones, MacBooks, Dell laptops, Samsung fridges, suits, rice, olive oil)
- **10 orders** with different statuses (DELIVERED, CONFIRMED, PROCESSING, PENDING)
- **10 payments** with different methods (CARD, BANK_TRANSFER, WALLET)

We then verified everything was inserted correctly. Result:
```
customers: 10 rows ✅
products:  12 rows ✅  
orders:    10 rows ✅
```

---

# PART 4: PORTFOLIO 2 — The Speed Test (Query Optimization)

## The Goal of Portfolio 2
Prove that you can write complex, meaningful business queries, then prove you can make them run faster using database indexes.

Think of it like this: a query without an index is like looking for someone's phone number by reading every name in a 1,000-page phonebook from the beginning. A query with an index is like opening the phonebook to the letter 'E' directly.

---

## Why We First Generated 9,000+ Orders

You cannot test query performance on only 10 rows of data. With 10 rows, the query will be instant even if it is badly written — because the data fits in a single memory page.

We wrote a **Stored Procedure** (a saved SQL program) called `PopulateBulkOrders(5000)` that automatically created 5,000 orders with random customers, products, dates, and payment records.

Final database size after bulk generation:
- **9,010 orders** 
- **9,015 order items**
- **9,010 payments**

Now, with this much data, the difference between a slow query and a fast query becomes clear and measurable.

---

### The Real Engineering Bug We Hit and Fixed
When the stored procedure was inserting orders with random dates, it crashed with this error:
```
ERROR 1292 (22007): Incorrect datetime value: '2026-03-29 01:09:56'
```

**Why did this happen?** Because `2026-03-29 01:00 AM` is the exact moment when Europe sets clocks forward one hour for Daylight Saving Time (summer time). The clock literally jumps from 12:59 AM to 02:00 AM — so 01:09 AM **does not exist** in the local timezone! MySQL refused to insert a time that does not exist.

**The Fix:** We told MySQL to use UTC (Coordinated Universal Time) — a worldwide standard time that never has this problem:
```sql
SET time_zone = '+00:00';
```

After this fix, all 9,000 orders inserted without errors.

---

## The 3 Business Analytics Queries

### Query 1: Category Sales Performance & Profit Margins
**What the business wants to know:** Which product categories earn the most money? Which categories have the highest profit margins?

**What this query does:** Joins 4 tables (categories, products, order_items, orders), filters for only DELIVERED orders, groups results by category, calculates revenue, profit, and percentage.

**Results:**
| Category | Total Orders | Units Sold | Revenue (NGN) | Profit Margin |
| :--- | :---: | :---: | :---: | :---: |
| Laptops & Computers | 954 | 1,863 | ₦4.38 Billion | 13.16% |
| Smartphones & Tablets | 986 | 1,965 | ₦2.46 Billion | 13.99% |
| Home & Kitchen | 626 | 1,271 | ₦1.14 Billion | 14.25% |
| Fashion & Apparel | 648 | 1,326 | ₦262.5 Million | **29.09%** |
| Groceries & Provisions | 592 | 1,173 | ₦63.1 Million | 16.87% |

**Interesting insight:** Fashion & Apparel has the highest profit margin (29%) even though its total revenue is lowest. Laptops make the most money overall but at a lower margin.

---

### Query 2: High-Value Customer Profiling (VIP Customers)
**What the business wants to know:** Who are our most valuable customers in the last 6 months? How much have they spent? When did they last order?

**What this query does:** Filters customers with at least 300 loyalty points, who placed successful DELIVERED orders in the last 180 days, then ranks them by total spend.

**Results:**
| Customer | Loyalty Points | Orders | Total Spent | Days Since Last Order |
| :--- | :---: | :---: | :---: | :---: |
| Chinedu Okafor | 450 | 229 | ₦506.7 Million | 2 |
| Emeka Nwosu | 310 | 232 | ₦457.6 Million | 0 |
| Blessing Johnson | 950 | 200 | ₦443 Million | 1 |

---

### Query 3: Inventory Velocity & Restock Priority
**What the business wants to know:** Which products are selling fastest? Which ones need restocking urgently?

**What this query does:** Uses a **Window Function** (`DENSE_RANK() OVER (ORDER BY units_sold DESC)`) to rank products from fastest-selling to slowest. Flags items as OPTIMAL STOCK, WARNING: REORDER REQUIRED, or CRITICAL: OUT OF STOCK.

Window functions are one of the most powerful advanced SQL features. They let you run calculations across groups of rows without collapsing them into a single result — like RANK, ROW_NUMBER, LAG, LEAD, SUM OVER a partition.

---

## The Index Optimization Experiment

### The Target Query (What We're Trying to Speed Up)
This is a query a NovaMart customer would trigger when they open their "Order History" page:
```sql
SELECT o.order_id, o.order_date, o.order_status, o.total_amount,
       c.first_name, c.last_name, c.email
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'DELIVERED'
  AND o.order_date BETWEEN '2026-06-01' AND '2026-10-01'
ORDER BY o.order_date DESC;
```

This kind of query might run hundreds of times per minute on a real platform.

---

### Stage 1: Before Any Index (The Slow Way)
We ran `EXPLAIN ANALYZE` — a MySQL command that tells you exactly how it executed the query and how long each step took.

**What EXPLAIN ANALYZE revealed:**
```
Sort: o.order_date DESC  (cost=204.93) ← EXPENSIVE STEP!
  Filter: (o.order_date between '2026-06-01' and '2026-10-01')
    Index lookup on o using idx_order_status (order_status='DELIVERED')
      → Inspected 3,802 rows
```

**In plain English:**
1. MySQL found all "DELIVERED" rows — 3,802 of them.
2. It then looked through all 3,802 rows to find which ones were in the date range.
3. Then it had to SORT all 1,280 matching rows by date in memory (the Filesort step — very expensive).

**Total cost: 915.60 | Total time: 25.47 milliseconds**

---

### Stage 2: After Composite Index (The Smart Way)
We created a **Composite B-Tree Index** on two columns together:
```sql
CREATE INDEX idx_orders_status_date ON orders(order_status, order_date DESC);
```

**Why this specific index design?**

B-Tree indexes follow a left-to-right rule:
- Put the **equality filter** first (`order_status = 'DELIVERED'`).
- Put the **range/sort column** second (`order_date`).

This means the index is pre-sorted exactly the way the query needs it. MySQL jumps directly to "DELIVERED" and then reads dates in descending order — no separate sorting step needed!

**What EXPLAIN ANALYZE showed after:**
```
Index range scan on o using idx_orders_status_date  (cost=194.39)
  → Only inspected 1,280 rows (already in ORDER BY date order!)
```

**The Filesort was COMPLETELY ELIMINATED!**

**After Composite Index:**
- Rows inspected: **1,280** (down from 3,802 = **66.3% fewer**)
- Total cost: **652.86** (down from 915.60 = **28.7% cheaper**)
- Execution time: **14.74ms** (down from 25.47ms = **42.1% faster**)

---

### Stage 3: Covering Index (The Even Smarter Way)
We then tried a **Covering Index** — this means we include all the columns that the query needs right inside the index itself:
```sql
CREATE INDEX idx_orders_covering ON orders(order_status, order_date DESC, customer_id, total_amount);
```

When an index "covers" all the columns a query needs, the database engine never has to go back and look up the actual table rows. It finds everything it needs in the index alone.

**Result:** Index scan completed in just **3.07ms** — that is 77.9% faster than the original scan!

---

### Summary Table of Optimization Gains

| Metric | No Good Index | Composite Index | Covering Index |
| :--- | :---: | :---: | :---: |
| Rows Inspected | 3,802 | 1,280 | 1,280 |
| Filesort Required? | **YES (Slow!)** | **NO** | **NO** |
| Query Cost | 915.60 | 652.86 | 708.07 |
| Total Execution Time | **25.47 ms** | **14.74 ms** | **14.65 ms** |
| Index Scan Time | 13.94 ms | 10.57 ms | **3.07 ms** |

---

# PART 5: PORTFOLIO 3 — Money & Safety (Transactions & Concurrency)

## The Goal of Portfolio 3
Prove that the database can handle real money and multiple users at the same time without mistakes, lost funds, or double-selling.

---

## What ACID Means in Real Life

**A — Atomicity: "All or Nothing"**
Imagine buying a phone on NovaMart. These 4 things must happen together:
1. Stock decreases by 1
2. Order record is created
3. Order items are recorded
4. Payment is recorded

If step 3 fails because of a network problem, the database must cancel steps 1 and 2 as well. If only step 1 happened and the rest failed, NovaMart would lose a phone from inventory but have no record of the sale.

**Atomicity guarantees: Everything succeeds together, or everything is cancelled together.**

**C — Consistency: "Rules Are Never Broken"**
All constraints we defined (stock cannot go negative, email must be unique, price must be > 0) are enforced at all times. Even inside a transaction, if you try to insert `stock_quantity = -5`, MySQL refuses.

**I — Isolation: "Transactions Don't Spy on Each Other"**
If Customer A is in the middle of buying a phone (transaction not yet committed), Customer B cannot see the half-finished change. Isolation keeps transactions private from each other until they are complete.

**D — Durability: "Once Saved, Always Saved"**
Once you click "Confirm Payment" and MySQL says COMMIT, that record is written to the hard disk. Even if the power goes out one millisecond later, the transaction is preserved. MySQL writes every committed transaction to a Write-Ahead Log before confirming success.

---

## Demonstration 1: The Happy Path (Successful Checkout)

Amina Bello (Customer 2) buys an Apple iPhone 15 Pro (₦1,450,000).

**What happened step by step:**
```sql
START TRANSACTION;

-- Step 1: Decrease stock by 1 (only if stock is available)
UPDATE products SET stock_quantity = stock_quantity - 1 
WHERE product_id = 1 AND stock_quantity >= 1;

-- Step 2: Create the order header
INSERT INTO orders (...) VALUES (2, 3, 'CONFIRMED', 1450000, 5000, 1455000);

-- Step 3: Record the line item
INSERT INTO order_items (...) VALUES (@order_id, 1, 1, 1450000);

-- Step 4: Record the payment
INSERT INTO payments (...) VALUES (@order_id, 'CARD', 'PAY-ACID-SUCCESS-9388', 1455000, 'SUCCESSFUL');

COMMIT; -- Save everything permanently
```

**Verified Result:**
- Stock: went from **25 to 24** ✅
- Order 9388 created with status CONFIRMED ✅
- Payment reference PAY-ACID-SUCCESS-9388 recorded ✅

---

## Demonstration 2: Payment Fails — Rollback Saves the Day

Ngozi Eze tries to buy a MacBook Pro (₦2,850,000). Her card is declined.

**What happened:**
- MySQL started a transaction, decremented stock, created order...
- Then the payment gateway returned FAILED.
- We issued `ROLLBACK`.

**Verified Result:**
- Stock: stayed at **10 units** (the decrement was undone) ✅
- Orphaned orders in the database: **0** (the order record was wiped) ✅

This proves that no "ghost orders" can exist on NovaMart's database.

---

## Demonstration 3: Savepoint — Partial Recovery

A customer attempts checkout with their digital wallet. The wallet has insufficient balance. Instead of cancelling the entire cart, we:

1. Start transaction
2. Create order and order items
3. **Set SAVEPOINT before_payment_attempt** (create a recovery checkpoint)
4. Attempt wallet payment — it FAILS
5. **ROLLBACK TO SAVEPOINT** (undo only the payment step, keep the order)
6. Try Credit Card instead — it SUCCEEDS
7. COMMIT

**Verified Result:** Order 9390 confirmed with method CARD, reference PAY-FALLBACK-CARD-9390 ✅

---

## The Concurrency Simulation: Two People, One Product

**The Business Problem:** NovaMart has exactly 6 Samsung Refrigerators left in stock (Product 8). At the exact same millisecond, two different customers click "Buy Now."

Without locking, here is what could go wrong:
1. Customer A's transaction reads: stock = 6
2. Customer B's transaction reads: stock = 6 (same value!)
3. Customer A writes: stock = 5
4. Customer B writes: stock = 5 (overwriting Customer A's write!)
5. Result: Two customers paid for one fridge, but stock only went down by 1.

This is called a **Lost Update / Race Condition**. It is real, common, and disastrous for e-commerce.

**The Solution: `SELECT ... FOR UPDATE` (Pessimistic Row-Level Locking)**

When a transaction reads a row with `FOR UPDATE`, MySQL puts an exclusive lock on that row. No other transaction can read or write it until the first transaction commits.

### The Live Multi-Threaded Proof

We wrote a Python script (`simulate_concurrency.py`) that opened two parallel database connections at the same time:

**Session 1 (Thread 1):**
```python
Session 1 started transaction at 13:42:59.191
Session 1 issued: SELECT ... WHERE product_id = 8 FOR UPDATE
Session 1 now holds exclusive lock on Product 8
Session 1 sleeps for 3 seconds (simulating payment processing)...
Session 1 decrements stock from 6 to 5
Session 1 COMMITS at 13:43:02.323
```

**Session 2 (Thread 2, started 0.5s later):**
```python
Session 2 started at 13:42:59.692
Session 2 tried: SELECT ... WHERE product_id = 8 FOR UPDATE
⏳ SESSION 2 IS BLOCKED — WAITING IN LOCK QUEUE...
⏳ Still waiting...
⏳ Still waiting...
Session 1 committed! Lock released!
Session 2 reads stock = 5 (the correct updated value)
Session 2 decrements from 5 to 4
Session 2 COMMITS at 13:43:02.327
```

**The Evidence Captured in Real Logs:**
```
[13:42:59.192] SESSION 1: Requesting exclusive lock on Product 8...
[13:42:59.692] SESSION 2: Attempting concurrent access (Expect lock wait)...
[13:43:02.323] SESSION 1: COMMITTED. Lock released.
[13:43:02.327] SESSION 2: Finished after 2.64s wait (Lock blocked Session 2!)
FINAL STOCK: Product 8 = 4 units (Serial, consistent, race condition ELIMINATED!)
```

**Why this matters:** Session 2 waited **2.64 seconds**. During that wait, it was blocked by MySQL's row-level lock. After Session 1 committed, Session 2 received the already-updated value of 5 and safely decremented to 4. **No double-selling happened.**

---

# PART 6: PORTFOLIO 4 — The Flexible Database (NoSQL & MongoDB)

## The Goal of Portfolio 4
Demonstrate that relational databases (MySQL) are not always the best tool, and that for certain parts of the business — specifically the product catalog — a NoSQL document database (MongoDB) is far better.

---

## The Problem with MySQL for Product Catalogs

### Option 1: The Wide Sparse Table (Bad Idea)
Add every possible attribute as a column:

```
product_id | ram_gb | processor | storage | color | fabric | grain_length | expiry_date | rim_size | ...
-----------|--------|-----------|---------|-------|--------|--------------|-------------|---------|---
iPhone 15  | NULL   | A17 Pro   | 256     | NULL  | NULL   | NULL         | NULL        | NULL    | ...
Wool Suit  | NULL   | NULL      | NULL    | Navy  | Wool   | NULL         | NULL        | NULL    | ...
Basmati    | NULL   | NULL      | NULL    | NULL  | NULL   | 8.4          | 12/2028     | NULL    | ...
```

Thousands of NULL values. Adding a new category requires a database schema change (ALTER TABLE) which can lock the table during peak hours. Very messy.

### Option 2: EAV Tables (Even Worse Idea)
Create separate tables for attributes and values:
```sql
product_attributes (product_id, attribute_name, attribute_value)
```
Finding all attributes of one product requires 6+ joins. Very slow and complex.

---

## The MongoDB Solution: Rich, Self-Describing Documents

In MongoDB, each product is a complete, self-contained JSON document that can have any structure it needs:

**Laptop Document:**
```json
{
  "_id": "PROD-TECH-001",
  "product_name": "Apple iPhone 15 Pro",
  "specifications": {
    "display": "6.1-inch Super Retina XDR OLED 120Hz",
    "processor": "Apple A17 Pro (3nm)",
    "storage_gb": 256,
    "ram_gb": 8,
    "battery_mah": 3274
  },
  "reviews": [
    { "customer": "Chinedu", "rating": 5, "comment": "Build quality is incredible" },
    { "customer": "Tari", "rating": 4.5, "comment": "Great but battery could be better" }
  ]
}
```

**Rice Document:**
```json
{
  "_id": "PROD-GROC-001",
  "product_name": "Premium Basmati Rice 25kg",
  "specifications": {
    "net_weight_kg": 25,
    "grain_length_mm": 8.4,
    "aging_period": "2 Years Aged",
    "origin": "Punjab, India"
  },
  "reviews": [
    { "customer": "Blessing", "rating": 5, "comment": "Grains double when cooked, no clumping" }
  ]
}
```

**No NULL values. Each product tells its own story. Adding a car tire with `rim_diameter` and `aspect_ratio` requires zero schema changes.**

---

## The Embedded Reviews Design

In MySQL, showing reviews on a product page requires joining:
```sql
SELECT * FROM products p
JOIN reviews r ON p.product_id = r.product_id
WHERE p.product_id = 1;
```

In MongoDB, the reviews are already inside the product document. Reading one product gives you all its reviews automatically — **one single database read, no joins**.

### The Atomic Review Update
When Zainab Dahiru posts a new 5-star review:
```javascript
db.products.updateOne(
  { "_id": "PROD-TECH-001" },
  {
    $push: { "reviews": { rating: 5, comment: "Camera in low light is mind blowing" } },
    $inc: { "review_summary.total_reviews": 1 },
    $set: { "review_summary.average_rating": 4.88 }
  }
);
```

**Before update:** Reviews Count = 3, Avg Rating = 4.8  
**After update:** Reviews Count = 4, Avg Rating = 4.88  
**New review appended:** "Camera in low light is mind blowing" by Zainab Dahiru ✅

All three changes (add review, increment counter, update rating) happen atomically in one operation.

---

## The Redis Shopping Cart & Flash Sale Guard

### Shopping Carts
Instead of saving every cart to MySQL (which would flood the database with millions of unconfirmed records), we store carts in Redis:
```
HSET cart:session:cust_001  "PROD-TECH-001"  1
HSET cart:session:cust_001  "PROD-GROC-001"  2
EXPIRE cart:session:cust_001  604800  ← Auto-delete after 7 days
```

If the customer abandons their cart, it silently disappears after 7 days. Zero manual cleanup required.

### Instant Flash Sale Stock Check
During a Black Friday sale, 50,000 people hit "Buy" on the same laptop simultaneously. Asking MySQL each time would kill the server. Instead:
```
SET stock:cache:PROD-TECH-001  25         ← Set initial stock in RAM
DECRBY stock:cache:PROD-TECH-001  1       ← Atomic decrement (microseconds)
```
Redis handles this in sub-millisecond speed from RAM. Only when an order is actually confirmed does it go to MySQL to be permanently stored.

---

# PART 7: PORTFOLIO 5 — The Big Scale Architecture (Distributed & Cloud)

## The Goal of Portfolio 5
Explain how NovaMart's database would survive and thrive at massive scale — handling millions of users, surviving server failures, and serving customers in multiple countries with low latency.

---

## Why One Database Server Is Not Enough

**Single Server Problems:**
1. **Single Point of Failure:** If the one MySQL server crashes, the entire platform goes down. Imagine NovaMart going offline on Black Friday!
2. **Read/Write Bottleneck:** When 50,000 customers browse products and 5,000 place orders simultaneously, one server CPU gets maxed out. Reads and writes compete for the same resources.
3. **Geographic Latency:** A customer in Nairobi, Kenya accessing a database in Lagos, Nigeria experiences 100-200ms round-trip delay per query. A product search makes dozens of queries.

---

## Solution 1: Primary-Replica Replication (Master-Slave)

**The Idea:** One server handles all WRITE operations (Primary Master). Multiple other servers receive copies of everything that changes and handle all READ operations (Read Replicas).

```
Customers browsing catalog → → → → READ REPLICA 1 (Lagos)
                                    READ REPLICA 2 (Abuja)
Customers placing orders → → → → PRIMARY MASTER (writes only)
                                    ↕
                              (copies changes automatically)
                                    ↕
                            READ REPLICA 1 & 2
```

**Why GTID (Global Transaction Identifiers)?**
Without GTID, replicas tracked replication using binary log file names and position numbers (like bookmarks in a book). If the primary failed, administrators had to manually figure out the correct position to resume from.

With GTID, every transaction gets a globally unique ID like `550e8400-e29b-4d5f:1234`. The replica just tells the primary "I already have up to transaction 1234, send me everything after that." Automated, reliable, no manual intervention.

**Semi-Synchronous Replication:**
- Normal async replication: Primary writes, tells replicas to copy, then immediately confirms to the customer. If the primary crashes before replicas get the data, that data is lost.
- Semi-sync replication: Primary writes, waits until AT LEAST ONE replica has written to its relay log, THEN confirms to the customer. Recovery Point Objective = **0 data lost**.

---

## Solution 2: Horizontal Sharding (Dividing Data Across Servers)

When one server cannot hold all the data or handle all the write traffic (even after adding replicas for reads), you split the data itself across multiple servers. This is called **Sharding**.

**Our Sharding Strategy: Entity-Based Sharding by `customer_id`**

We chose `customer_id` as the shard key. Every customer and all their related data (addresses, orders, payments, delivery history) lives on the same shard.

**The Hashing Algorithm:**
```
Shard Number = MurmurHash3(customer_id) ÷ NumberOfShards (remainder)
```

For example:
- Customer 1 (Chinedu) → Hash → Shard A
- Customer 4 (Ngozi) → Hash → Shard B
- Customer 7 (Emeka) → Hash → Shard A again

**Why this is smart:** When Chinedu checks his order history, all his data is on Shard A. The query never needs to touch Shard B. This means **98% of customer portal queries are single-shard operations** — fast, contained, not requiring cross-server communication.

---

## Solution 3: High Availability & Automated Failover

**The Setup:** The Primary Master and two Read Replicas are placed in three separate physical buildings/data centers (called Availability Zones).

- AZ-A: Lagos Data Center (Primary Master)
- AZ-B: Abuja Data Center (Read Replica 1)
- AZ-C: Port Harcourt Data Center (Read Replica 2)

**Health Monitoring:**
- A heartbeat check pings the Primary Master every 1,000 milliseconds.
- If it fails to respond 3 consecutive times (3 seconds), the automated failover system kicks in.

**Quorum Consensus (Preventing Split-Brain):**
Before promoting a replica to become the new Primary Master, more than 50% of health monitors must agree that the old primary is truly dead (not just temporarily unreachable due to a network blip). This prevents the catastrophic "split-brain" scenario where two servers both think they are the master and start accepting conflicting writes simultaneously.

**Failover Targets:**
- Recovery Time Objective (RTO): < 30 seconds (time for system to come back up)
- Recovery Point Objective (RPO): 0 (zero transactions lost)

---

## The CAP Theorem: Every Distributed System Has Trade-offs

The CAP Theorem states that in a distributed system with network partitions, you can only fully guarantee TWO out of THREE properties:

**C = Consistency:** Every read returns the most recent write.  
**A = Availability:** The system always responds, even if some nodes are down.  
**P = Partition Tolerance:** The system continues to work even when network connections between servers break.

Since network partitions (P) are unavoidable in real-world distributed systems, you must always choose between C and A when a partition happens.

### NovaMart's Choice:

| Subsystem | Choice | Why |
| :--- | :---: | :--- |
| **Orders & Payments (Checkout)** | **CP** | If payment data is temporarily unavailable due to a network issue, we would rather pause checkout than risk recording a payment twice or showing the wrong balance. Money must always be consistent. |
| **Product Catalog & Reviews** | **AP** | If a product's updated price or a new review takes 200 milliseconds to synchronize to all replicas, shoppers can still browse. Seeing a slightly stale rating is far better than seeing a 503 error page. |

---

## The Docker Compose File: Our Distributed Cluster Blueprint

We wrote `docker-compose-distributed.yml` — a configuration file that defines and launches the entire distributed cluster with a single command:

```yaml
mysql-primary:    # Primary writer node with GTID binary logging
mysql-replica:    # Read-only replica with relay log enabled
redis-cache:      # In-memory cache with LRU eviction policy
```

All three services are connected on the same private network (`novamart-net`), just like real data center servers connected on a private LAN.

---

# PART 8: THE SUBMISSION PACKAGE

## Two Things to Submit

### 1. GitHub Repository (Code Proof)
The GitHub repository (`advanced-database-portfolio`) contains all the SQL scripts, Python simulations, JSON documents, Docker configurations, and README documentation organized into 5 folders.

**Progressive Git Commits (7 total):**
```
9dbcd2b  Portfolio 1: 3NF database design, relational DDL, seed data, and ER model
8c4fd0a  Portfolio 2: analytical queries, bulk generation, EXPLAIN ANALYZE, composite index
4d4660a  Portfolio 3: ACID transactions, rollback, savepoints, concurrency row-lock simulation
f5efda9  Portfolio 4: NoSQL document model, MongoDB queries, aggregation pipeline, Redis cache
138468c  Portfolio 5: distributed architecture, GTID replication, sharding, HA, docker-compose
56e233b  Final documentation: 3-page report, technical reflection, AI-use declaration
6fe8e0e  Study guide: complete implementation walkthrough and viva preparation manual
```

### 2. LMS PDF Report (Official 3-Page Summary)
The official submission document is located at:
`Ekoh_Peace_301866431/Ekoh_Peace_301866431_Portfolio_Report.pdf`

It follows the exact naming convention specified by MIVA University: `Surname_Firstname_StudentID_DocumentType`.

---

# PART 9: VIVA PREPARATION — Questions & Answers

If the lecturer calls you in for an oral verification, here are the most likely questions and exactly how to answer them:

---

**Q1: "Why did you choose NovaMart as your case study?"**

*Answer:*
> "I chose NovaMart because an online retail platform is complex enough to naturally require all five portfolio components. It needs strict ACID compliance for financial transactions, complex analytical SQL for business intelligence, pessimistic row-level locking to prevent inventory race conditions, NoSQL document modeling for polymorphic product specifications, and a distributed architecture to survive peak traffic events like Black Friday. I also chose it because it is immediately relatable — it works exactly like Jumia or Amazon."

---

**Q2: "Explain the difference between 2NF and 3NF in your database."**

*Answer:*
> "In Second Normal Form, I eliminated partial key dependencies. In the order_items table, the composite primary key is (order_id, product_id). Product descriptions and catalog prices only depended on product_id, not on the full composite key. I removed them to the products table. This solved 2NF. In Third Normal Form, I eliminated transitive dependencies. In the products table, product_id determined category_id, and category_id determined category_name. The category name was transitively dependent on the product through the category. I separated categories into their own table. For every functional dependency in my final schema, the left-hand side is a superkey."

---

**Q3: "What is an execution plan and what did EXPLAIN ANALYZE show you?"**

*Answer:*
> "EXPLAIN ANALYZE is a MySQL command that actually runs the query and reports how every step was executed, how many rows were scanned, and how long each step took. In my experiment, the baseline query without a composite index had to scan 3,802 rows to find 1,280 matching rows, and then had to sort them in memory — a step called a Filesort costing 204.93. After creating a composite B-Tree index on (order_status, order_date DESC), the Filesort was eliminated completely because the index already stored rows in the sorted order the query needed. Rows scanned dropped to 1,280 and the execution time improved from 25.47 milliseconds to 14.74 milliseconds — a 42.1% speedup."

---

**Q4: "What is a Deadlock and how does MySQL handle it?"**

*Answer:*
> "A deadlock happens when two transactions create a circular lock dependency. Transaction A holds a lock on Row 1 and is waiting for Row 2. Transaction B holds a lock on Row 2 and is waiting for Row 1. Neither can proceed, and they wait forever. MySQL InnoDB has a background Deadlock Detector that continuously monitors the wait-for graph. When it detects a circular dependency, it automatically selects the transaction that has modified the fewest rows as the victim, rolls it back with error code 1213, and releases its locks. The other transaction can then proceed. In application code, we handle this with exponential backoff retry logic."

---

**Q5: "Why is MongoDB better than MySQL for the product catalog?"**

*Answer:*
> "MySQL forces a rigid, uniform schema — every row in a table must have the same columns. For a product catalog with laptops (RAM, processor, battery), suits (fabric, fit type, chest size), and rice (grain length, aging period, origin), MySQL would require either an extremely sparse table with thousands of NULL values or a complex Entity-Attribute-Value pattern that makes queries extremely slow. MongoDB's document model allows each product to have exactly the attributes it needs — no more, no less. Additionally, embedding customer reviews directly inside the product document means the entire product detail page can be served from a single database read instead of multiple join queries."

---

**Q6: "What is the CAP Theorem and how did you apply it?"**

*Answer:*
> "The CAP Theorem states that a distributed database system can only guarantee two of three properties simultaneously: Consistency (every read reflects the latest write), Availability (the system always responds), and Partition Tolerance (the system functions even when network connections between nodes break). Since network partitions are unavoidable in real distributed systems, the real choice is between Consistency and Availability during a partition. For NovaMart's financial checkout, I chose CP — Consistency plus Partition Tolerance. If a network split occurs, I would rather pause checkout than risk double-charging or overselling. For the product catalog and reviews, I chose AP — Availability plus Partition Tolerance, with Eventual Consistency. Shoppers can browse even if a review takes 200 milliseconds to propagate to all replicas."

---

**Q7: "If I ran your schema.sql right now, would it work? Walk me through it."**

*Answer:*
> "Yes, absolutely. The first command is DROP DATABASE IF EXISTS novamart_db, which cleans up any previous version. Then CREATE DATABASE creates a fresh database with UTF-8 character encoding. The USE novamart_db switches the connection into that database. The tables are created in dependency order — customers first, then customer_addresses (which references customers), then categories, then products (which references categories), then orders (which references both customers and customer_addresses), then order_items (which references both orders and products), then payments (which references orders), and finally inventory_logs (which references products). If the tables were created in the wrong order, the foreign key constraints would fail because they'd reference tables that don't exist yet."

---

*This guide was written to accompany the MIT 8103 Advanced Database Systems Practical Portfolio by Peace Ekoh (ID: 301866431). Every query, simulation, and measurement described here was executed and verified on MySQL 8.0.30 and Python 3.10 locally.*
