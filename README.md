# 🏗️ Modern SQL Data Warehouse & Analytics Project

![Database](https://img.shields.io/badge/Database-SQL%20Server-CC292B?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![Language](https://img.shields.io/badge/Language-T--SQL-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-Medallion%20(Bronze%2FSilver%2FGold)-FFD700?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)

An end-to-end data warehousing project built with **Microsoft SQL Server Management Studio (SSMS)** and **T-SQL**. This project consolidates disparate enterprise source data (CRM and ERP systems) through automated ETL pipelines into an analytics-ready Star Schema using the **Medallion Architecture** pattern.

---

## 📑 Table of Contents
* Project Overview
* Data Architecture
* Repository Structure

---

## 🎯 Project Overview

In real-world organizations, transactional data is often fragmented across multiple sources (CRM, ERP, legacy flat files) with inconsistent formatting, missing data, and duplicated records.

This project delivers:
* **Centralized Storage:** Ingesting raw ERP and CRM CSV datasets into a structured database.
* **Robust Data Cleaning:** Handling data inconsistencies, missing fields, whitespace padding, and invalid values in the Silver layer.
* **Dimensional Modeling:** Producing an optimized Star Schema (Fact and Dimension tables) in the Gold layer for fast analytical queries and BI dashboards.
* **Single Source of Truth:** Unifying duplicate entities across CRM and ERP systems (e.g., resolving gender conflicts with master source priority).


---

## 🏗️ Data Architecture

The pipeline implements the **Medallion Architecture**, progressing raw files into high-trust business views:
<img width="851" height="754" alt="image" src="https://github.com/user-attachments/assets/5a3ae2e3-fc5e-4d77-83f1-dc0739f3f84e" />
**Bronze Layer (Ingetion)**
* Bulk loads CSV data from raw ERP and CRM files.
* Scripts ensure repeatable execution by truncating tables before re-loading.

**Silver Layer (Transformations)**
* **Customer Normalization:** Cleans marital status codes, eliminates leading/trailing whitespace, and reconciles conflicting records (CRM serves as the master source for gender).
* **Product Normalization:** Filters out retired/historical records (`WHERE prd_end_dt IS NULL`) to maintain current product snapshots.
* **Sales Normalization:** Standardizes dates and ensures numerical integrity on prices and quantities.

**Gold Layer (Dimensional Views)**
* Generates surrogate keys dynamically using `ROW_NUMBER() OVER (...)`.
* Links dimension views to `fact_sales` via foreign key surrogate relationships for high-performance reporting.

---

## 📁 Repository Structure

```text
sql-data-warehouse-project-baraa/
│
├── datasets/                 # Raw source CSV datasets (CRM and ERP data)
├── docs/                     # Data architecture diagrams and requirements
│
├── scripts/
│   ├── init_database.sql     # Database and schema initialization (Bronze, Silver, Gold)
│   ├── bronze/               # DDL and load procedures for the Bronze layer
│   ├── silver/               # Cleansing scripts and DDL for the Silver layer
│   └── gold/                 # Star schema views (dim_customers, dim_products, fact_sales)
│
├── tests/                    # Data validation and data quality audit scripts
└── README.md
