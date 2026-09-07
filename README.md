# 🏗️ Modern SQL Data Warehouse & Analytics Project

[![SQL Server](https://img.shields.io/badge/Database-SQL%20Server-CC292B?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)](https://www.microsoft.com/sql-server)
[![T-SQL](https://img.shields.io/badge/Language-T--SQL-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)](https://learn.microsoft.com/sql/t-sql/)
[![Architecture](https://img.shields.io/badge/Architecture-Medallion%20(Bronze%2FSilver%2FGold)-FFD700?style=for-the-badge)](#-data-architecture)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

An end-to-end data warehousing project built with **Microsoft SQL Server Management Studio (SSMS)** and **T-SQL**. This project consolidates disparate enterprise source data (CRM and ERP systems) through automated ETL pipelines into an analytics-ready Star Schema using the **Medallion Architecture** pattern.

---

## 📑 Table of Contents
- [Project Overview](#-project-overview)
- [Data Architecture](#-data-architecture)
- [Data Model (Gold Layer)](#-data-model-gold-layer)
- [ETL Workflow & Transformations](#-etl-workflow--transformations)
- [Repository Structure](#-repository-structure)
- [Getting Started](#-getting-started)
- [Sample Analytical Queries](#-sample-analytical-queries)
- [Acknowledgments](#-acknowledgments)

---

## 🎯 Project Overview

In real-world organizations, transactional data is often fragmented across multiple sources (CRM, ERP, legacy flat files) with inconsistent formatting, missing data, and duplicated records.

This project delivers:
- **Centralized Storage:** Ingesting raw ERP and CRM CSV datasets into a structured database.
- **Robust Data Cleaning:** Handling data inconsistencies, missing fields, whitespace padding, and invalid values in the Silver layer.
- **Dimensional Modeling:** Producing an optimized Star Schema (Fact and Dimension tables) in the Gold layer for fast analytical queries and BI dashboards.
- **Single Source of Truth:** Unifying duplicate entities across CRM and ERP systems (e.g., resolving gender conflicts with master source priority).

---

## 🏗️ Data Architecture

The pipeline implements the **Medallion Architecture**, progressing raw files into high-trust business views:
