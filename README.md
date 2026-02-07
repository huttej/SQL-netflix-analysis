# SQL-netflix-analysis
netflix movies and tv series analysis
This project focuses on cleaning, normalizing, and analyzing Netflix content data using SQL
The goal is to transform raw Netflix data into an analysis-ready relational model and answer real-world business questions using advanced SQL concepts like CTEs, window functions, string processing, and joins.

Data Cleaning & Preparation
1️. Handling Duplicates

Identified duplicate records using show_id, title, and type

Removed duplicates using ROW_NUMBER() with CTE

2️. Primary Key & Null Handling

Checked for NULL show_id

Converted show_id to NOT NULL

Added Primary Key constraint

3️. Normalization (1NF)

Created separate tables for multi-valued columns
4️.Handling Missing Values

Filled missing country values using director-country mapping

Handled missing duration values using rating where applicable

5️.Staging Table

Created a clean staging table netflix_stg:

Deduplicated records

Cleaned date formats

Standardized duration

Business Analysis Queries
1. Movies vs TV Shows by Director

Directors who created both Movies and TV Shows, with counts in separate columns.

2. Country with Highest Comedy Movies

Identified the country producing the maximum number of comedy movies.

3. Top Director per Year

For each year, found the director with the highest number of releases using ranking logic.

4. Average Movie Duration by Genre

Calculated average movie duration (in minutes) for each genre.

5. Directors Who Made Both Comedy & Horror Movies

Listed directors who directed both Comedy and Horror movies, along with counts.

