# Portfolio 4: NoSQL and Advanced Data Models
**Course:** MIT 8103 – Advanced Database Systems  
**Student Name:** Peace Ekoh  
**Student ID:** 301866431  
**Case Study:** NovaMart Retail Logistics & Storefront (E-Commerce Platform)  
**Database Models:** Document Store (MongoDB) & Key-Value In-Memory Store (Redis)  

---

## 1. Overview & Architectural Motivation
While relational database management systems (RDBMS) such as MySQL excel at enforcing ACID compliance across financial payments, customer orders, and ledger reconciliation, relational databases face severe limitations when handling:
1. **Polymorphic / Dynamic Product Attributes:** Across different product categories (e.g., Laptops, Smartphones, Clothing, Groceries), attributes vary completely.
2. **Customer Reviews & Rating Aggregations:** Reading product detail pages requires costly multi-table joins to compute average ratings and display user comments.
3. **High-Frequency Ephemeral Sessions:** Active shopping carts and flash-sale inventory checks place unnecessary write loads on disk-based relational storage engines.

To resolve these architectural bottlenecks, NovaMart adopts a **Polyglot Persistence Architecture**:
* **Relational (MySQL):** Orders, Payments, Financial Balances, Shipping Addresses.
* **Document Store (MongoDB):** Polymorphic Product Catalog, Dynamic Specifications, Embedded Reviews.
* **Key-Value Store (Redis):** High-speed Shopping Cart Sessions and Hot Product Inventory Caching.

---

## 2. Relational vs. NoSQL: Why the Relational Model Struggles

### 2.1 The Entity-Attribute-Value (EAV) Relational Dilemma
In a strict relational model, handling divergent product specifications forces engineers into one of two anti-patterns:
* **The "Sparse Table" Anti-Pattern:** Adding dozens of nullable columns to `products` (`screen_size`, `ram_gb`, `fabric_blend`, `grain_length`, `expiry_date`). As the catalog expands to 5,000 product types, 95% of row cells contain wasted `NULL` values.
* **The EAV Anti-Pattern:** Creating three tables (`entities`, `attributes`, `values`). Querying a single product with 6 specifications requires joining the EAV table 6 times, degrading query throughput by orders of magnitude.

### 2.2 The Document Model Solution (MongoDB)
In MongoDB, each product is modeled as a rich, self-describing **BSON/JSON Document**:
* Specific attributes are stored inside a flexible nested subdocument: `specifications: { "ram_gb": 36, "processor": "M3 Max" }`.
* Adding a new category (e.g., Automobile Tires with `aspect_ratio` and `rim_diameter`) requires **zero schema migrations or DDL downtime**.
* Product details pages are retrieved in a single $O(1)$ key-value seek without joins.

### 2.3 Embedded Reviews vs. Separate Relational Tables
In NovaMart's document model, reviews are embedded directly within the product document:
```json
"review_summary": { "average_rating": 4.88, "total_reviews": 4 },
"reviews": [
  { "review_id": "REV-101", "rating": 5, "comment": "Impeccable build quality..." }
]
```
* **Performance Benefit:** When 100,000 customers view the iPhone 15 Pro product page, the application executes a single document read. No foreign key joins or real-time `AVG(rating)` calculations are performed, slashing database latency.

---

## 3. MongoDB Data Model Specification

The complete document structure is implemented in [`nosql_model.json`](./nosql_model.json).

### Key Subdocument Breakdown:
* `pricing`: Stores base price, active discount percentages, and computed final prices in local currency (NGN).
* `inventory`: Warehouse location mapping (`warehouse_id`), available units, and reserved checkout quantities.
* `specifications`: Flexible polymorphic dictionary differing by category.
* `tags`: Array of string descriptors indexed with a Multikey Index for fast faceted filtering.
* `reviews`: Array of embedded customer feedback objects.

---

## 4. Query & Aggregation Pipeline Implementation

All operations are defined in [`mongodb_queries.js`](./mongodb_queries.js) and verified via [`run_nosql_demo.py`](./run_nosql_demo.py).

### 4.1 Polymorphic Attribute Filtering (Dot Notation)
```javascript
db.products.find(
  {
    "category.sub_category": "Laptops & Computers",
    "specifications.ram_gb": { $gte: 16 },
    "pricing.final_price": { $lte: 3000000 }
  },
  { "product_name": 1, "brand": 1, "pricing.final_price": 1, "specifications": 1 }
);
```

### 4.2 Atomic Embedded Review Insertion (`$push` and `$inc`)
When a customer submits a new review, MongoDB atomically appends the review and increments the review count in a single operation:
```javascript
db.products.updateOne(
  { "_id": "PROD-TECH-001" },
  {
    $push: { "reviews": newReviewObject },
    $inc: { "review_summary.total_reviews": 1 },
    $set: { "review_summary.average_rating": 4.88 }
  }
);
```

### 4.3 Aggregation Pipeline (Category Customer Satisfaction)
```javascript
db.products.aggregate([
  {
    $project: {
      "category": "$category.primary",
      "rating": "$review_summary.average_rating",
      "review_count": "$review_summary.total_reviews",
      "stock": "$inventory.available_stock"
    }
  },
  {
    $group: {
      "_id": "$category",
      "total_catalog_products": { $sum: 1 },
      "category_avg_rating": { $avg: "$rating" },
      "total_customer_reviews": { $sum: "$review_count" },
      "total_warehouse_stock": { $sum: "$stock" }
    }
  },
  { $sort: { "category_avg_rating": -1 } }
]);
```

---

## 5. Verified Execution Evidence

The simulation script executed against the catalog dataset produced the following verified output:

```text
===========================================================================
NOVAMART NOSQL DOCUMENT STORE ENGINE VERIFICATION (MongoDB Simulation)
Dataset: Polymorphic E-Commerce Catalog & Embedded Customer Reviews
===========================================================================

DEMO 1: POLYMORPHIC ATTRIBUTE FILTERING (Laptops with RAM >= 16GB)
Product: Apple MacBook Pro 14 M3 Max (Apple)
  Price: NGN 2,850,000.00
  Specs: RAM=36GB | CPU=Apple M3 Max (14-core CPU, 30-core GPU) | Storage=1000GB
  Stock: 10 units available

DEMO 2: FACETED TAG & RATING SEARCH (Electronics with 'titanium' or 'm3-max')
Product: Apple iPhone 15 Pro | Rating: 4.8 Stars | Tags: ['flagship', 'ios', 'titanium', 'usb-c', 'pro-camera']
Product: Apple MacBook Pro 14 M3 Max | Rating: 5.0 Stars | Tags: ['laptop', 'm3-max', 'apple-silicon', 'workstation', 'creative-pro']

DEMO 3: ATOMIC EMBEDDED REVIEW UPDATE ($push and $inc simulation)
Before Update: Reviews Count = 3, Avg Rating = 4.8
After  Update: Reviews Count = 4, Avg Rating = 4.88
Newly Appended Review: "Camera in low light is mind blowing" by Zainab Dahiru (Rating: 5.0 Stars)

DEMO 4: MONGODB AGGREGATION PIPELINE (Category Satisfaction & Stock Metrics)
Category                  | Items  | Avg Rating  | Total Reviews | Stock Units
---------------------------------------------------------------------------
Electronics               | 2      | 4.94        | 6             | 34
Groceries & Provisions    | 1      | 4.9         | 2             | 100
Fashion & Apparel         | 1      | 4.7         | 1             | 40
```

---

## 6. Key-Value Caching Model (Redis Architecture)
In addition to MongoDB, NovaMart utilizes **Redis 5.0** for memory-speed operations:
1. **User Shopping Carts:** Stored as Redis Hashes (`HSET cart:session:<cust_id> <prod_id> <qty>`) with an automatic 7-day Time-To-Live (`EXPIRE 604800`). Abandoned carts expire automatically without cluttering disk tables.
2. **Flash Sale Inventory Guard:** Atomic Redis commands (`DECRBY stock:cache:<prod_id> 1`) reject oversold orders in RAM at sub-millisecond speeds before requests touch the primary database.

---

## 7. Consistency Models & CAP Theorem Trade-Offs
* **Relational MySQL:** Prioritizes **Consistency and Partition Tolerance (CP)** for financial transactions. If a network split occurs, money transfers are blocked rather than recorded incorrectly.
* **Catalog MongoDB / Redis:** Configured for **Availability and Partition Tolerance (AP)** with **Eventual Consistency**. If a product review or rating takes 200ms to propagate to read replicas, shoppers still view product details without disruption.
