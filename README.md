# E-commerce Analytics Dashboard

An interactive **Power BI** dashboard analyzing e-commerce sales performance — built on a public sample dataset (Kaggle) — covering revenue trends, order status, top-selling categories, customer behavior, delivery performance, and regional sales distribution.

## 📊 Overview

This project visualizes key business metrics across **8 dashboard pages**:

| Page | Focus |
|---|---|
| Executive Dashboard | High-level KPIs — revenue, orders, customers, AOV, on-time %, avg rating, YoY growth |
| Sales Trends | Revenue and order trends over time |
| Category & Product | Performance by product category |
| Customer | Customer segmentation and behavior |
| Delivery & Logistics | Shipping and fulfillment performance |
| Reviews | Customer ratings and feedback analysis |
| Payments | Payment method and transaction insights |
| Seller | Seller-level performance metrics |

## 🚀 Key KPIs (Executive Dashboard)

- **Total Revenue:** 14.21M
- **Total Orders:** 98.67K
- **Total Customers:** 95.42K
- **Average Order Value (AOV):** 144.01
- **On-Time Delivery:** 93.23%
- **Average Rating:** 4.03
- **YoY Growth:** 253.0%

## 🖼️ Screenshots

### Executive Dashboard
![Executive Dashboard](https://github.com/nikhilsangwan1628/Ecommerce-Analytics-Dashboard/blob/main/Overview.png)

### Sales Trends
![Sales Trends](https://github.com/nikhilsangwan1628/Ecommerce-Analytics-Dashboard/blob/main/Sales%20Trends.png)

### Category & Product
![Category & Product](https://github.com/nikhilsangwan1628/Ecommerce-Analytics-Dashboard/blob/main/Category%20%26%20Product.png)

### Customer
![Customer](https://github.com/nikhilsangwan1628/Ecommerce-Analytics-Dashboard/blob/main/Customer.png)

### Delivery & Logistics
![Delivery & Logistics](https://github.com/nikhilsangwan1628/Ecommerce-Analytics-Dashboard/blob/main/Delivery%20%26%20Logistics.png)

### Reviews
![Reviews](https://github.com/nikhilsangwan1628/Ecommerce-Analytics-Dashboard/blob/main/Review.png)

### Payments
![Payments](https://github.com/nikhilsangwan1628/Ecommerce-Analytics-Dashboard/blob/main/Payment.png)

### Seller
![Seller](https://github.com/nikhilsangwan1628/Ecommerce-Analytics-Dashboard/blob/main/Seller.png)

## 🔍 Key Insights

- Revenue shows a consistent upward trend across the analyzed period, with growth accelerating in later months.
- The top 10 categories contribute the majority of total revenue, with the leading category generating ~1.30M.
- Orders peak early and decline steadily over the year — worth investigating seasonality or demand drop-off.
- Over 97% of orders complete without status issues, indicating a healthy order fulfillment pipeline.
- On-time delivery rate (93.23%) and average rating (4.03) suggest generally strong customer satisfaction.

## 🛠️ Tech Stack

- **PostgreSQL** — database used to store, clean, and query the raw dataset (via SQL scripts)
- **Power BI Desktop** — connects to PostgreSQL, models data, builds DAX measures and visualizations
- **Dataset:** [Olist Brazilian E-Commerce Dataset]
- Data cleaning/transformation done partly in SQL (PostgreSQL) and partly in Power Query

## 🏗️ Architecture

```
Kaggle Dataset (CSV)
        │
        ▼
   PostgreSQL DB   ← data loaded, cleaned, and queried via SQL
        │
        ▼
   Power BI Desktop ← live connection to PostgreSQL
        │
        ▼
  Interactive Dashboard (8 pages)
```

## 📁 Repository Structure

```
ecommerce-executive-dashboard/
├── README.md
├── screenshots/
├── dataset/             # sample CSV data or link to source
├── sql/
│   ├── schema.sql        # table definitions
│   ├── load_data.sql     # import/load scripts
│   └── queries.sql       # cleaning & transformation queries
├── dashboard.pbix         # Power BI file
└── docs/
    └── data-dictionary.md
```



## 📌 Data Source

Public sample dataset from Kaggle. [Olist Brazilian E-Commerce Dataset]


