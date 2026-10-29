# Inventory & Supplier Management System

A database-driven inventory management application built using **Python, Streamlit, and MySQL**. This project demonstrates practical relational database management through product and supplier management, stock transactions, and inventory reporting.

## Overview

The Inventory & Supplier Management System provides a simple interface for managing inventory records, suppliers, stock movements, and reports. It combines a Python-based application with a MySQL relational database to demonstrate database design, data integrity, and SQL programming concepts.

## Features

- **Dashboard:** View inventory summaries and key information.
- **Product Management:** Create and manage product records.
- **Supplier Management:** Maintain supplier information.
- **Stock Management:** Record stock receipts and stock issues.
- **Stock Validation:** Prevent stock issues when available inventory is insufficient.
- **SQL Views:** Organize and retrieve information from related tables.
- **Database Triggers:** Automate database operations and enforce business rules.
- **Stored Procedures:** Encapsulate reusable database operations.
- **Reports:** Generate inventory-related reports.
- **CSV Export:** Export report data for further analysis.
- **Persistent Storage:** Store application data in MySQL.

## Technology Stack

| Component | Technology |
|---|---|
| Frontend | Streamlit |
| Backend | Python |
| Database | MySQL |
| Database Programming | SQL |
| Data Export | CSV |

## Project Structure

```text
inventory-management-system/
├── app/
│   ├── main.py
│   └── database.py
├── database_design/
│   ├── phase1_design.md
│   └── schema_plan.md
├── sql/
│   ├── 01_schema.sql
│   ├── 02_sample_data.sql
│   ├── 03_views.sql
│   ├── 04_triggers.sql
│   ├── 05_procedures.sql
│   ├── 06_verification.sql
│   └── 07_practice_queries.sql
├── .env.example
├── .gitignore
├── README.md
└── requirements.txt
```

## Database Concepts Implemented

- Relational database design
- Primary keys and foreign keys
- Data integrity constraints
- SQL views
- Database triggers
- Stored procedures
- Transaction management
- Stock validation and verification queries

## Installation and Setup

### Prerequisites

- Python 3.x
- MySQL Server
- pip

### 1. Clone the repository

```bash
git clone https://github.com/rachelp07/inventory-management-system.git
cd inventory-management-system
```

### 2. Create a virtual environment

```bash
python -m venv .venv
```

Activate it on Windows:

```powershell
.venv\Scripts\Activate.ps1
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure MySQL

- Ensure MySQL Server is running.
- Create and configure the database using the provided SQL scripts.
- Execute the scripts in the appropriate order, starting with `01_schema.sql`, followed by the sample data, views, triggers, and stored procedures.
- Configure the database connection using the environment variables expected by the application.

Use `.env.example` as a reference for the required configuration. Create your own local `.env` file with the appropriate values. **Never commit real passwords or credentials.**

### 5. Run the application

```bash
streamlit run app/main.py
```

Open the local URL displayed in the terminal to access the application.

> **Note:** The database configuration and setup instructions may need adjustment to match your local MySQL credentials and application configuration.

## Testing and Verification

The project includes SQL verification scripts and has been tested for key workflows, including:

- Product and supplier creation
- Stock receipt and stock history verification
- Insufficient-stock protection
- Inventory reports
- CSV export
- Data persistence after application restart

## Future Enhancements

- Automated low-stock and expiry alerts
- Role-based access control
- Automated testing
- Improved application security
- Machine learning integration for inventory insights

## Learning Outcomes

This project provided practical experience in relational database design, SQL programming, Python–MySQL connectivity, database automation, transaction handling, and application development.

## Author

**Rachel Panhalkar**

Developed as a DBMS mini-project to demonstrate the practical application of database management concepts.
