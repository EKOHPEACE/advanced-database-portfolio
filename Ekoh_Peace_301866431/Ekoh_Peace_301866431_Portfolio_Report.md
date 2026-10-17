# MIT 8103: Advanced Database Systems
## Practical Database Portfolio — Final Documentation & Technical Reflection

**Institution:** MIVA Open University  
**School:** School of Postgraduate Studies  
**Programme:** Master of Information Technology (MIT)  
**Academic Session:** 2026/2027 Academic Session — First Semester Continuous Assessment (CA)  
**Student Name:** Peace Ekoh  
**Student ID:** 301866431  
**Submission Identifier:** `Ekoh_Peace_301866431`  
**GitHub Repository URL:** `https://github.com/peace-ekoh/advanced-database-portfolio`  

---

## 1. Executive Summary & Selected Case Study

### 1.1 Business Context: NovaMart Retail Logistics & Storefront
**NovaMart** is an omnichannel e-commerce retail enterprise operating across West Africa. The platform manages high-velocity retail transactions spanning consumer electronics, fashion, groceries, and household appliances. The database architecture is engineered to satisfy intense concurrent demand during regional promotional sales, supporting:
* **Shoppers/Consumers:** High-speed catalog search, multi-faceted filtering, shopping cart checkout, and digital payment execution.
* **Merchants & Warehouse Operators:** Stock tracking, automated reorder triggers, dispatch logging, and shipment tracking.
* **Finance & DBA:** Real-time payment verification, ACID transactional integrity, query plan tuning, and distributed high availability.

### 1.2 Enterprise Architectural Strategy: Polyglot Persistence
Rather than forcing all business domains into a single database engine, NovaMart implements a **Polyglot Persistence Architecture**:
1. **Relational Core (MySQL 8.0 InnoDB):** Orders, payments, customer identity, and financial ledgers requiring strict ACID guarantees and 3NF normalization.
2. **Document Store (MongoDB):** Polymorphic product catalog and customer reviews requiring flexible, schemaless JSON structures with zero DDL migration downtime.
3. **In-Memory Key-Value Store (Redis 5.0/7.0):** Ephemeral shopping cart sessions with auto-expiring TTLs and sub-millisecond stock decrement caching.

---

## 2. Activity Summaries & Empirical Technical Evidence

### Portfolio 1: Database Design & Relational Modelling (7 Marks)
* **Design Implementation:** Developed an 8-table relational schema in MySQL 8.0 (`customers`, `customer_addresses`, `categories`, `products`, `orders`, `order_items`, `payments`, `inventory_logs`) with InnoDB referential constraints (`ON DELETE CASCADE` / `RESTRICT`) and check constraints (`stock_quantity >= 0`, `unit_price > 0`).
* **Normalisation Proof (1NF to 3NF/BCNF):**
  * **1NF:** Elimination of repeating order item arrays and multi-valued customer addresses; all attributes are atomic.
  * **2NF:** Resolved partial functional dependencies in composite relation `order_items(order_id, product_id)`. Non-prime product descriptions and prices were decoupled into `products`, keeping only transaction-specific quantity and purchase price in `order_items`.
  * **3NF / BCNF:** Eliminated transitive dependencies: `order_id -> customer_id -> customer_email` and `product_id -> category_id -> category_name` by isolating categories and customer profiles into independent relations, preventing update and deletion anomalies.

### Portfolio 2: Query Processing & Performance Optimisation (7 Marks)
* **Dataset Scale:** Populated `novamart_db` with a realistic benchmark workload of **9,010 Orders**, **9,015 Order Items**, and **9,010 Payments**.
* **Business Analytics Queries:** Implemented complex queries featuring multi-table joins, grouping, aggregations, and window functions (`DENSE_RANK()`) to analyze category profit margins, customer lifetime value (LTV), and stock velocity.
* **Execution Plan Optimization (`EXPLAIN ANALYZE`):**
  * **Target Query:** High-frequency portal query filtering delivered orders by date range and status.
  * **Baseline (Unoptimized):** Used single-column index `idx_order_status`. Scanned **3,802 rows**, required an expensive in-memory **Filesort** (`Sort: o.order_date DESC`), costing **915.60** with an execution time of **25.47 ms**.
  * **Stage 1 (Composite B-Tree Index `idx_orders_status_date`):** Placing equality filter `order_status` before range/sort attribute `order_date DESC` **completely eliminated the Filesort**, reduced rows scanned to **1,280** (66.3% fewer reads), and reduced latency to **14.74 ms** (42.1% speedup).
  * **Stage 2 (Covering Index `idx_orders_covering`):** Fulfilling all select attributes (`customer_id`, `total_amount`) directly from index leaf nodes completed index scanning in just **3.07 ms** (77.9% faster scan).

### Portfolio 3: Transactions & Concurrency Control (7 Marks)
* **ACID Implementation:**
  * **Commit Path:** Successfully executed atomic checkout decrementing iPhone stock (25 to 24 units), creating order `9388`, line items, and recording payment `PAY-ACID-SUCCESS-9388`.
  * **Rollback Path:** Simulated payment gateway decline (HTTP 402). Transaction executed an immediate `ROLLBACK`, restoring MacBook stock to 10 units with **0 orphaned orders**.
  * **Savepoint Recovery:** Demonstrated nested recovery using `SAVEPOINT before_payment_attempt`. When digital wallet payment failed, the transaction rolled back to the savepoint and successfully completed via credit card without restarting checkout.
* **Multi-Threaded Concurrency Simulation:** Executed automated parallel python sessions (`simulate_concurrency.py`) competing for product 8 (stock = 6) using pessimistic locking (`SELECT ... FOR UPDATE`):
  * **Captured Result:** Session 1 acquired an exclusive row lock at `13:42:59`. When Session 2 attempted access at `13:42:59.692`, InnoDB placed Session 2 into a `LOCK WAIT` queue for **2.64 seconds** until Session 1 committed. Session 2 then read updated stock (5) and safely decremented to **4**, proving complete prevention of the lost-update race condition.

### Portfolio 4: NoSQL & Advanced Data Models (7 Marks)
* **Document Model (MongoDB):** Designed rich JSON documents ([`nosql_model.json`](../portfolio-4-nosql/nosql_model.json)) representing polymorphic catalog items. Nested `specifications` store divergent attributes (RAM/CPU for laptops, virgin wool/fit for suits, grain length/aging for basmati rice) without the relational EAV anti-pattern.
* **Atomic Updates & Aggregations:** Verified atomic review insertions using `$push` and `$inc`, and executed a 4-stage MongoDB Aggregation Pipeline calculating customer satisfaction metrics across categories (Electronics: 4.94 stars across 6 reviews).
* **Key-Value Caching (Redis):** Modeled ephemeral user cart sessions with 7-day TTL expiration (`HSET cart:session:<id>`) and in-memory inventory counters to absorb flash-sale traffic.

### Portfolio 5: Distributed & Cloud Database Exercise (6 Marks)
* **Distributed Topology:** Configured a multi-node cluster ([`docker-compose-distributed.yml`](../portfolio-5-distributed-cloud/docker-compose-distributed.yml)) featuring:
  * Primary Master node with Global Transaction Identifiers (GTID) and semi-synchronous replication.
  * Dedicated Read-Only Replicas offloading read traffic via database proxies.
  * Distributed Redis cache nodes.
* **Horizontal Sharding:** Designed an entity-based sharding strategy partitioned by `customer_id` using consistent hashing ($\text{Shard} = \text{MurmurHash3}(\text{customer_id}) \pmod N$), ensuring 98% of customer queries remain single-shard operations.
* **High Availability & CAP Trade-Offs:** Evaluated Multi-AZ automated failover with quorum consensus (RTO < 30s, RPO = 0), and framed architectural decisions through the CAP and PACELC theorems (CP for financial checkout, AP for catalog browsing).

---

## 3. Individual Technical Reflection

### 3.1 Design Choices & Rationale
A major architectural decision was adopting **Polyglot Persistence**. Early in the design, I considered storing dynamic product attributes in MySQL using JSON columns (`JSON_EXTRACT`). However, indexing deeply nested arrays and performing aggregations across polymorphic attributes in MySQL proved cumbersome compared to MongoDB's native Document Model and Aggregation Pipeline. Conversely, maintaining customer financial balances and inventory decrement in MongoDB would have complicated ACID multi-document consistency. Decoupling the systems into relational MySQL for transactional ledgers and MongoDB for catalog browsing yielded the optimal balance of consistency and developer agility.

### 3.2 Technical Challenges & Solutions Encountered
1. **Timezone Discontinuity During Bulk Seeding:** When populating 9,000 orders using randomized timestamps, MySQL threw `ERROR 1292 (22007): Incorrect datetime value` due to Daylight Saving Time (DST) spring-forward gaps in standard time zones. I resolved this by enforcing strict UTC time zone handling (`SET time_zone = '+00:00';`), ensuring deterministic timestamp operations across all platforms.
2. **Eliminating In-Memory Sorting in High-Volume Queries:** In Portfolio 2, initial query profiling revealed MySQL was executing an explicit in-memory filesort despite an index on `order_status`. By analyzing B-Tree index traversal rules, I realized equality filter columns must precede range/sorting columns in composite indexes. Constructing `idx_orders_status_date(order_status, order_date DESC)` enabled the storage engine to return pre-sorted leaf pages directly, cutting execution latency by 42.1%.
3. **Concurrency Lock Contention:** Implementing pessimistic row locking (`FOR UPDATE`) successfully prevented race conditions, but excessively long lock durations can cause connection timeouts. Through the multi-threaded simulation, I observed Session 2 waiting 2.64s. In production systems, row locks should only be held during minimal critical sections, complemented by Redis-level optimistic atomic decrements.

---

## 4. Academic Integrity & AI-Use Declaration

This practical portfolio represents independent technical work designed, coded, and verified by **Peace Ekoh (ID: 301866431)**.

In accordance with MIVA Open University academic integrity guidelines, the use of AI tools is declared below:
* **AI Tool Utilized:** Google DeepMind / Antigravity Agentic Assistant.
* **Scope of Assistance:** Brainstorming edge-case query scenarios, drafting initial SQL procedure templates, and formatting markdown tables.
* **Verification & Independent Validation:** Every database schema, stored procedure, composite index, transaction script, concurrency simulation, and NoSQL pipeline was personally executed, tested, and validated locally on **MySQL 8.0.30** and **Python 3.10**. All query execution plans (`EXPLAIN ANALYZE`) and concurrency lock wait logs presented in this portfolio represent genuine empirical outputs generated on my local machine.

---

## 5. References & Academic Bibliography
1. Elmasri, R. and Navathe, S.B., 2021. *Fundamentals of Database Systems*. 7th ed. Boston: Pearson.
2. Silberschatz, A., Korth, H.F. and Sudarshan, S., 2020. *Database System Concepts*. 7th ed. New York: McGraw-Hill.
3. MySQL AB, 2026. *MySQL 8.0 Reference Manual: Optimization and Indexes*. Oracle Corporation. Available at: <https://dev.mysql.com/doc/refman/8.0/en/optimization.html>.
4. MongoDB Inc., 2026. *MongoDB Documentation: Data Modeling & Aggregation Pipeline*. Available at: <https://www.mongodb.com/docs/>.
5. Kleppmann, M., 2017. *Designing Data-Intensive Applications: The Big Ideas Behind Reliable, Scalable, and Maintainable Systems*. Sebastopol: O'Reilly Media.
