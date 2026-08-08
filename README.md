# SQL Business Reports

8 SQL business intelligence reports built on **AdventureWorksDW2022** — customer analytics, product performance, sales trends, regional analysis, and executive KPIs, using SQL Server (T-SQL), CTEs, window functions, and views.

---

## Overview

This repository is a portfolio of SQL views built to simulate real business reporting — the kind of analysis a BI analyst or data analyst would deliver to different stakeholders (marketing, product, sales, and executive leadership). Each report answers a specific business question and is built as a reusable SQL Server view on top of the AdventureWorksDW2022 sample data warehouse.

**Tools used:** SQL Server / T-SQL, SQL Server Management Studio (SSMS)
**Database:** [AdventureWorksDW2022](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure) (Microsoft's sample data warehouse)

---

## Repository Structure

```
sql-business-reports/
├── README.md
├── LICENSE
├── sql/
│   ├── 01_customer_analytics.sql
│   ├── 02_product_performance.sql
│   ├── 03_sales_performance_dashboard.sql
│   ├── 04_regional_sales_analysis.sql
│   └── 05_executive_kpi_dashboard.sql
└── screenshots/
    ├── 01_customer_analytics_result.png
    ├── 02_product_performance_result.png
    ├── 03_sales_performance_dashboard_result.png
    ├── 04_regional_sales_analysis_result.png
    └── 05_executive_kpi_dashboard_result.png
```

---

## Projects

### 01. Customer Analytics Report
Segments customers by purchasing behavior and long-term value — total revenue, average order value, customer lifespan, recency, and age group — then classifies each customer as **VIP / Loyal / Regular / New / At-Risk**.

**Key metrics:** Total Orders, Total Revenue, Average Order Value, Average Monthly Spend, Customer Lifespan (Months), Recency, Age Segmentation, Customer Segmentation

![Customer Analytics Result](screenshots/01_customer_analytics_result.png)

---

### 02. Product Performance Report
Ranks every product by revenue and units sold to surface top performers, slow movers, and each product's contribution to total revenue.

**Key metrics:** Total Revenue, Total Orders, Total Quantity Sold, Average Selling Price, Revenue Rank, Sales Rank, Revenue Contribution %, Revenue Category (Low/Medium/High/Top Performer)

![Product Performance Result](screenshots/02_product_performance_result.png)

---

### 03. Sales Performance Dashboard
Tracks sales trends over time — daily, monthly, quarterly, and yearly — with running totals and period-over-period growth.

**Key metrics:** Total Revenue, Monthly/Quarterly/Yearly Sales, Running Total Sales, Month-over-Month Growth, Year-over-Year Growth, Contribution to Year/Total Sales

![Sales Performance Dashboard Result](screenshots/03_sales_performance_dashboard_result.png)

---

### 04. Regional Sales Analysis
Breaks down revenue, orders, and customer counts across the geographic hierarchy — region, country, state, and city — to identify top and underperforming markets.

**Key metrics:** Total Revenue / Orders / Customers by Region, Country, State, and City

![Regional Sales Analysis Result](screenshots/04_regional_sales_analysis_result.png)

---

### 05. Executive KPI Dashboard
A single-row, high-level summary built for leadership — the headline numbers plus the single best-performing product, country, sales territory, and category.

**Key metrics:** Total Sales, Total Customers, Total Orders, Average Sales per Order, Average Revenue per Customer, Best-Selling Product, Best Country, Best Sales Territory, Best Category

![Executive KPI Dashboard Result](screenshots/05_executive_kpi_dashboard_result.png)

---

## Techniques Demonstrated

- Common Table Expressions (CTEs), including multi-stage/chained CTEs
- Window functions: `SUM() OVER()`, `RANK()`, `LAG()`, running totals
- Aggregate functions with `GROUP BY` across multiple grains (daily → monthly → yearly)
- `CROSS JOIN` for attaching single-row summary values to a result set
- `CASE` statements for business segmentation logic
- Views (`CREATE VIEW`) as reusable reporting objects
- Query modularization — breaking dense window-function logic into single-purpose, named CTEs for readability

---

## How to Run

1. Restore the [AdventureWorksDW2022](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure) sample database in SQL Server.
2. Open any file from `/sql` in SSMS or Azure Data Studio, connected to the AdventureWorksDW2022 database.
3. Execute the script — each one drops/creates its view and then selects from it, so you'll see results immediately.

---

## Roadmap

A few more reports are planned for this repo:
- Promotion Effectiveness Report
- Product Category Analysis
- Customer Retention Analysis

---

## Related Project

Check out my [DataWarehouse project](#) — a full Bronze/Silver/Gold medallion architecture data warehouse built from scratch in SQL Server, which these reports build on the same underlying SQL skill set.

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
