================================================================================
MIVA OPEN UNIVERSITY - SCHOOL OF POSTGRADUATE STUDIES
MASTER OF INFORMATION TECHNOLOGY (MIT) | 2026/2027 ACADEMIC SESSION
COURSE: MIT 8103 ADVANCED DATABASE SYSTEMS (CONTINUOUS ASSESSMENT)
================================================================================
Student Name: Peace Ekoh
Student ID: 301866431
Submission Identifier: Ekoh_Peace_301866431
Selected Case Study: NovaMart Retail Logistics & Storefront (E-Commerce Platform)
GitHub Repository URL: https://github.com/peace-ekoh/advanced-database-portfolio
================================================================================

SUBMISSION CONTENTS:
-------------------
1. Ekoh_Peace_301866431_Portfolio_Report.pdf (.html / .md):
   The official 2-3 page Continuous Assessment summary report covering all five 
   portfolio activities, empirical execution evidence, technical reflection, and 
   the mandatory Academic Integrity / AI-Use declaration.

2. Full Practical Source Code & Verification Scripts (on GitHub repository):
   - portfolio-1-database-design/
     * schema.sql: 3NF relational schema DDL with InnoDB referential integrity.
     * seed_data.sql: Realistic seed data for customers, products, and categories.
     * README.md: Entity-Relationship diagram and step-by-step normalisation proof.
   
   - portfolio-2-query-optimisation/
     * queries.sql: Analytical business queries and indexing target queries.
     * generate_bulk_orders.sql: Stored procedure generating 9,000+ benchmark orders.
     * query_results.txt: Complete query outputs and business performance metrics.
     * README.md: EXPLAIN ANALYZE execution plan analysis and 42.1% speedup benchmarks.

   - portfolio-3-transactions-concurrency/
     * transactions.sql: ACID commit, rollback, and nested savepoint scripts.
     * transaction_results.txt: Verified execution output of transaction scenarios.
     * simulate_concurrency.py: Multi-threaded Python script testing row-level locking.
     * concurrency_output.txt: Real-time terminal log proving 2.64s lock wait prevention.
     * README.md: Isolation levels and lost-update race condition analysis.

   - portfolio-4-nosql/
     * nosql_model.json: Polymorphic JSON document models for product catalog and reviews.
     * mongodb_queries.js: MongoDB queries, $push/$inc atomic updates, and aggregation pipeline.
     * run_nosql_demo.py: Python execution harness verifying document store queries.
     * nosql_execution_output.txt: Verified aggregation and polymorphic search outputs.
     * README.md: Relational vs. NoSQL suitability and Redis caching architecture.

   - portfolio-5-distributed-cloud/
     * docker-compose-distributed.yml: Multi-container primary-replica cluster topology.
     * replication_setup.sql: GTID semi-synchronous replication and heartbeat scripts.
     * README.md: Sharding design, multi-AZ high availability, and CAP/PACELC analysis.

HOW TO VERIFY CODE LOCALLY:
---------------------------
- Relational Database: MySQL 8.0.30
  Command: mysql -u root < portfolio-1-database-design/schema.sql
- Concurrency Simulation: Python 3.10
  Command: python portfolio-3-transactions-concurrency/simulate_concurrency.py
- NoSQL Demonstration: Python 3.10 / Node.js 18
  Command: python portfolio-4-nosql/run_nosql_demo.py
- Distributed Cluster: Docker & Docker Compose
  Command: docker-compose -f portfolio-5-distributed-cloud/docker-compose-distributed.yml up -d
================================================================================
