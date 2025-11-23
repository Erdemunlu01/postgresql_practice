#!/bin/bash
# PostgreSQL Practice Applications
# Purpose: Create database, create table, download dataset, load data, verify

########################################
# Module 00 – Switch to postgres user
########################################
# Purpose: Access PostgreSQL system user

echo "Switching to postgres user..."
sudo -i -u postgres

########################################
# Module 01 – Create Database
########################################
# Purpose: Create a new PostgreSQL database for practice

echo "Creating database..."
psql -c "CREATE DATABASE psql_practice;"

# Expected output:
# CREATE DATABASE


########################################
# Module 02 – Create Table
########################################
# Purpose: Create target table before loading CSV

psql -d psql_practice -c "
CREATE TABLE practice_data(
    sale_id INT,
    sale_date TEXT,
    check_in_date TEXT,
    price NUMERIC,
    concept_name TEXT,
    city_name TEXT,
    day_name TEXT,
    eb_score TEXT
);
"

# Expected output:
# CREATE TABLE


########################################
# Module 03 – Download Dataset
########################################
echo "Downloading dataset..."
wget https://raw.githubusercontent.com/.../psql_practice_data.csv

# Expected output:
# psql_practice_data.csv saved


########################################
# Module 04 – Preview Dataset
########################################
echo "Previewing dataset..."
head -10 psql_practice_data.csv


########################################
# Module 05 – Load Dataset into PostgreSQL
########################################
echo "Loading data into PostgreSQL..."
psql -d psql_practice -c "\copy practice_data FROM 'psql_practice_data.csv' CSV HEADER;"

# Expected output:
# COPY 415122


########################################
# Module 06 – Verify Data Load
########################################
echo "Verifying data..."
psql -d psql_practice -c "SELECT * FROM practice_data LIMIT 5;"


echo "Process Completed."