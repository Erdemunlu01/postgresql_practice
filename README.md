# PostgreSQL Practice Applications

This repository includes practical PostgreSQL exercises aimed at improving SQL skills within a **Data Engineering / Data Analytics** context.

The main goals of this repository are:

- Practicing PostgreSQL with real examples
- Strengthening analytical thinking
- Building reusable SQL patterns
- Creating a reference document for future projects
- Sharing learning progress

---

## Repository Files

```
psql_practice_notes.sql
psql_practice_terminal.sh
psql_practice_data.csv
README.md
```

---

## How to Use

### 1. Run Shell Script

```bash
chmod +x psql_practice_terminal.sh
./psql_practice_terminal.sh
```

This script will:

- Create database
- Create table
- Download dataset (if included)
- Load data into PostgreSQL
- Verify import

---

### 2. Execute SQL Script

Open PostgreSQL:

```bash
psql -d psql_practice
```

Run:

```sql
\i psql_practice_notes.sql
```

---

## Topics Covered

- Data preview
- Concept analysis
- Revenue by city and concept
- Seasonality impact
- EB score segmentation
- Persona (sales_level_based) creation
- Customer segmentation
- Expected revenue calculation

---

## Example Output

```
segments | avg_price | weighted_expected_revenue
High     | 120.5     | 0.42
Middle   | 78.2      | 0.33
...
```

---

## Real-World Usage

These SQL queries are commonly used in:

- Hotel & tourism analytics
- Pricing strategy
- Revenue optimization
- Customer segmentation
- Demand forecasting

---

## Why PostgreSQL?

PostgreSQL is widely used in:

- Data Warehousing
- ETL pipelines
- Analytical data platforms
- Cloud databases (AWS RDS, GCP Cloud SQL, Azure PostgreSQL)

---

## License

This repository is created for educational purposes.
