# BI_Operational_Solution
implementation of a robust solution using PostgreSQL with a star schema architecture, automating data integration through stored procedures and optimizing queries with CTEs.  Dynamic reports in Jaspersoft Studio and interactive dashboards in Power BI, delivering a clear, consistent, and scalable reporting solution

# CRM & ERP Data Integration, Reporting, and Dashboarding Project

### Author: Juan Manuel González

## 📌 Overview

This project focuses on integrating CRM and ERP data into a structured PostgreSQL database, building dynamic reports using Jaspersoft Studio, and creating an interactive Power BI dashboard to analyze key business metrics such as customer acquisition, order performance, and revenue trends.

---

## ⚙️ Tech Stack

- **Database:** PostgreSQL (with pgAdmin)
- **Reporting Tool:** Jaspersoft Studio
- **Dashboard Tool:** Power BI Desktop
- **SQL Features:** Stored Procedures, CTEs, Views, Schema Separation
- **Design Patterns:** Star Schema, Parameterized Queries, Data Cleaning

---

## 📐 Project Structure

### 1. **Database Design**
- Used PostgreSQL with two separate schemas:
  - `crm_schema` for customer data and acquisition channels.
  - `erp_schema` for products, orders, and shipping details.
- Enforced data integrity using primary and foreign keys.
- Optimized performance with:
  - Use of `VARCHAR(n)` over `TEXT`
  - Cleaning incomplete or low-value records
  - Efficient join strategies using CTEs and `DISTINCT`

### 2. **Stored Procedures**
- A stored procedure was created to generate a unified dataset.
- Designed for automation and easy maintenance.
- Handled edge cases such as case sensitivity and boolean filtering.

### 3. **Data Model**
- Implemented a **Star Schema** with:
  - Fact tables: `Orders`, `OrderDetails`
  - Dimension tables: `Customers`, `Products`, `Suppliers`, `Dates`, `AcquisitionChannels`

---

## 📊 Jaspersoft Report

- Built a modular, dynamic report with grouping by Product and Category.
- Implemented user-defined parameters (Date, Category) for filtering at SQL level.
- Included:
  - **Crosstab**: For quick visual breakdowns.
  - **Subreport**: For Top Clients, synced via parameters.
  - **Conditional Formatting**: Highlighted Top 5 clients with dynamic coloring.

---

## 📈 Power BI Dashboard

- Interactive dashboard created using Power BI Desktop.
- Features:
  - KPI Cards: Total Revenue, Profit, Customer Count
  - Bar/Line Charts: Customer acquisition performance, time-based trends
  - Tables: Customer segments, top clients/products
  - Filters: Global slicers for Date, Category, Region, Acquisition Channel
  - DAX Measures: Custom calculations for Profit, Quantity, Sales

---

## 🚧 Challenges & Solutions

- **Challenge:** Learning and configuring Jaspersoft Studio components and datasets.
- **Solution:** Resolved through documentation, forums, and hands-on tutorials. Focused on proper parameter passing between main report, crosstab, and subreport for consistency.

---

## Key Outcomes

- Built a scalable, normalized data architecture.
- Delivered dynamic, user-friendly reporting across tools.
- Gained deep insight into BI toolchains and dataset orchestration.
- Provided end-users with intuitive, interactive access to key business metrics.

---

## Files Included

- SQL Scripts for schema and stored procedures
- Jaspersoft `.jrxml` report files
- Power BI `.pbix` dashboard
- Sample dataset files

---

## Contact

**Juan Manuel González**  
📧 juanmanuel@example.com  
🌐 [LinkedIn](https://linkedin.com/in/juanmanuelgonzalez) *(optional)*
