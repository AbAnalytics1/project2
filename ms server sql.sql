
-- Create a new database to house all the entities needed for the data analysis.

CREATE DATABASE Analytic;


USE Analytic;

-- In this project we are going to create 7 tables in the database for our analysis

--Create the customer table

CREATE TABLE customers(

	customer_id					INT PRIMARY KEY,	
	customer_acct_num			CHAR(11),
	first_name					VARCHAR(50),
	last_name					VARCHAR(50),
	customer_address			VARCHAR(300),
	customer_city				VARCHAR(50),
	customer_state_province		VARCHAR(50),
	customer_postal_code		CHAR(6),
	customer_country			VARCHAR(20),
	birthdate					DATE,
	marital_status				VARCHAR(10),
	yearly_income				VARCHAR(20),
	gender						VARCHAR(10),
	total_children				INT,
	num_children_at_home		INT,
	education					VARCHAR(30),
	acct_open_date				DATE,
	member_card					VARCHAR(10),
	occupation					VARCHAR(25),
	homeowner					CHAR(4)

);

--Create the product brand table.

 CREATE TABLE productBrand(
 
	productBrand_id		INT PRIMARY KEY,
	brand_name			VARCHAR(60)

 );

--Create the products table.

CREATE TABLE products(

	product_id				INT PRIMARY KEY,
	product_brandID			INT REFERENCES productBrand (productBrand_id),
	product_name			VARCHAR(200),
	product_sku				VARCHAR(20),
	product_retail_price	DECIMAL(2,2),
	product_cost			DECIMAL(2,2),
	product_weight			INT,
	recyclable				INT,
	low_fat					INT

);

-- Create the regions table.

CREATE TABLE regions(

	region_id			INT PRIMARY KEY,
	sales_district		VARCHAR(50),
	sales_region		VARCHAR(50)

);

--Create the stores table

CREATE TABLE stores(

	store_id				INT PRIMARY KEY,
	region_id				INT REFERENCES regions(region_id),
	store_type				VARCHAR(50),
	store_name				VARCHAR(20),
	store_street_address	VARCHAR(50),
	store_city				VARCHAR(50),
	store_state				VARCHAR(60),
	store_country			VARCHAR(50),
	store_phone				VARCHAR(20),
	first_opened_date		DATE,
	last_remodel_date		DATE,
	total_sqft				INT,
	grocery_sqft			INT

);

--Create the calendar table

CREATE TABLE calendar(

	cal_date DATE PRIMARY KEY

);

-- Create  transactions table

CREATE TABLE transactions(

	calendar	DATE REFERENCES calendar(cal_date),
	stock_date	DATE,	
	product_id	INT REFERENCES products(product_id),
	customer_id	INT REFERENCES customers(customer_id),
	store_id	INT REFERENCES stores(store_id),	
	quantity	INT

);

--Create the returns table

CREATE TABLE returns (

	calendar	DATE REFERENCES calendar(cal_date),
	product_id	INT REFERENCES products(product_id),	
	store_id	INT REFERENCES stores(store_id),	
	quantity	INT

);

-- Clean the customer data

--SELECT * FROM customers

UPDATE customers
SET gender = CASE 
				WHEN gender = 'F' THEN 'Female'
				WHEN gender = 'M' THEN 'Male' 
				ELSE 'undefined'
			 END;


UPDATE customers
SET marital_status = CASE 
				WHEN marital_status= 'S' THEN 'Single'
				WHEN marital_status = 'M' THEN 'Married' 
				ELSE 'undefined'
			 END;

UPDATE customers
SET homeowner = 
    CASE 
        WHEN homeowner = 'Y' THEN 'Yes'
        WHEN homeowner = 'N' THEN 'No'
        ELSE 'Undefined'
    END;

--Check for duplicates

SELECT customer_id, COUNT(customer_id) AS Duplicate
FROM customers
GROUP BY customer_id
HAVING COUNT(customer_id) > 1;

-- Remove unwanted characters

UPDATE customers
SET yearly_income = REPLACE(yearly_income,'$','')
UPDATE customers
SET yearly_income = REPLACE(yearly_income,'K','')

  
-- Check for data consistency

SELECT COUNT(LEN(customer_state_province))
FROM customers
WHERE LEN(customer_state_province) IN (3,4,5,6,7,8,9) -- 856

SELECT COUNT(LEN(customer_state_province))
FROM customers
WHERE LEN(customer_state_province) = 2 -- 9423

-- list of provinces with more than 2 characters

SELECT DISTINCT(customer_state_province)
FROM customers
WHERE LEN(customer_state_province) IN (3,4,5,6,7,8,9)

-- Change all provinces into an two letter abbreviaion for consistency

UPDATE customers
SET customer_state_province = UPPER(LEFT(customer_state_province,2))
WHERE LEN(customer_state_province) IN (3,4,5,6,7,8,9);

UPDATE customers
SET yearly_income = '150 - 170'
WHERE yearly_income = '150 +'

ALTER TABLE customers
DROP COLUMN  average_yearly_income


-- Capitalize  the province abbreviation

UPDATE customers
SET customer_state_province = UPPER(customer_state_province)

-- Create a new column
ALTER TABLE  customers
ADD average_income INT;

UPDATE customers
SET average_income = (
								CAST(SUBSTRING(yearly_income,1,CHARINDEX('-', yearly_income)-2) AS INT)
								+
								CAST(SUBSTRING(yearly_income,CHARINDEX('-', yearly_income)+2,len(yearly_income))AS INT)
					)/2

-- Alter the column and change the datatype

ALTER TABLE customers
ALTER COLUMN average_income VARCHAR(20); 

UPDATE customers
SET average_income =  CASE
    WHEN average_income >= 150 AND average_income <= 160 THEN 'High'
    WHEN average_income >= 50 AND average_income < 150 THEN 'Mid'
    WHEN average_income >= 20 AND average_income < 50 THEN 'Low'
    ELSE 'Unknown'
END;

-- What is the maximum income

SELECT MAX(average_yearly_income) FROM customers

-- what is the minimum income

SELECT MIN(average_yearly_income) FROM customers

-- Remove or disable foreign key constraints
ALTER TABLE transactions DROP CONSTRAINT FK__transacti__custo__5812160E;

-- Truncate the 'customers' table
TRUNCATE TABLE customers;

-- Add or enable back foreign key constraints
ALTER TABLE transactions ADD CONSTRAINT FK__transacti__custo__5812160E FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

-- solve the import error

ALTER TABLE products
ALTER COLUMN product_cost DECIMAL (3,2) 

ALTER TABLE products
ALTER COLUMN product_retail_price DECIMAL (3,2) 

-- Change the precision and scale of the column to address the issue

-- Remove or disable foreign key constraints
ALTER TABLE returns DROP CONSTRAINT FK__returns__product__5BE2A6F2;

-- Truncate the 'customers' table
TRUNCATE TABLE products;

-- Add or enable back foreign key constraints
ALTER TABLE returns ADD CONSTRAINT FK__returns__product__5BE2A6F2 FOREIGN KEY (product_id) REFERENCES products(product_id);

sp_help returns

--FK__transacti__produ__571DF1D5, FK__returns__product__5BE2A6F2

-- Check for duplicates

SELECT  product_id,COUNT(product_id) AS Duplicates
FROM products
GROUP BY product_id
HAVING  COUNT(product_id ) > 1

SELECT * FROM customers

-- Exploratory data Analysis on customers

-- How many customers do we have in our records

 SELECT COUNT(customer_id)
 FROM customers

-- Customers demographics
-- Find where most of our customers are located
SELECT DISTINCT(customer_country)
FROM customers

SELECT 
	COUNT(CASE WHEN customer_country ='Mexico' THEN 1 END) AS count_mexico,
	COUNT(CASE WHEN customer_country ='Canada' THEN 1 END) AS count_Canada,
	COUNT(CASE WHEN customer_country='USA' THEN 1 END) AS count_USA
	
FROM customers;

-- How many of our customers are high, mid and low income earners
SELECT 
	COUNT(CASE WHEN average_income ='High' THEN 1 END) AS count_High,
	COUNT(CASE WHEN average_income  ='Low' THEN 1 END) AS count_Low,
	COUNT(CASE WHEN average_income ='Mid' THEN 1 END) AS count_Mid
	
FROM customers;

--how many are home owners 

SELECT 
	COUNT(CASE WHEN homeowner ='No' THEN 1 END) AS count_homeowner,
	COUNT(CASE WHEN homeowner  ='Yes' THEN 1 END) AS count_not_homeowner
	
FROM customers;

--How many are married or single
SELECT 
	COUNT(CASE  WHEN marital_status ='Married' THEN 1 END) AS count_Males,
	COUNT(CASE WHEN marital_status ='Single' THEN 1 END) AS count_Females
	
FROM customers;

-- How many are males or females

SELECT 
	COUNT(CASE  WHEN gender ='Males' THEN 1 END) AS count_Males,
	COUNT(CASE WHEN gender ='Females' THEN 1 END) AS count_Females
	
FROM customers;

-- Which product had the highest cost

SELECT product_name, product_cost
FROM products
WHERE product_cost = ( SELECT MAX(product_cost) FROM products);

-- Which product had the lowest cost

SELECT product_name, product_retail_price
FROM products
WHERE product_retail_price = ( SELECT MIN(product_retail_price) FROM products);

-- How many transactions where made

SELECT COUNT(*) 
FROM transactions


-- How many customers hold 

SELECT DISTINCT(member_card) FROM customers

SELECT
		SUM(CASE WHEN member_card ='Normal'THEN 1 ELSE 0 END) AS count_normal_holder,
		SUM(CASE WHEN member_card ='Bronze'THEN 1 ELSE 0 END) AS count_bronze_holder,
		SUM(CASE WHEN member_card ='Golden'THEN 1 ELSE 0 END) AS count_golden_holder,
		SUM(CASE WHEN member_card ='Silver'THEN 1 ELSE 0 END) AS count_silver_holder
FROM customers


-- Revenue generated from customers

 SELECT CONCAT(customers.first_name, ' ' , customers.last_name) AS full_name, ROUND(SUM(transactions.quantity * products.product_retail_price),2) AS Revenue
 FROM transactions
 LEFT JOIN customers
 ON transactions.customer_id = customers.customer_id
 INNER JOIN products 
 ON transactions.product_id = products.product_id
 GROUP BY CONCAT(customers.first_name, ' ' , customers.last_name)
 ORDER BY ROUND(SUM(transactions.quantity * products.product_retail_price),2) DESC;

 -- Who are the 10 top customers

 SELECT TOP (10) CONCAT(customers.first_name, ' ' , customers.last_name) AS full_name, ROUND(SUM(transactions.quantity * products.product_retail_price),2) AS Revenue
 FROM transactions
 LEFT JOIN customers
 ON transactions.customer_id = customers.customer_id
 INNER JOIN products 
 ON transactions.product_id = products.product_id
 GROUP BY CONCAT(customers.first_name, ' ' , customers.last_name)
 ORDER BY ROUND(SUM(transactions.quantity * products.product_retail_price),2) DESC;

-- Quantities ordered by customers

SELECT TOP (10) CONCAT(customers.first_name, ' ' , customers.last_name) AS Full_name, SUM(transactions.quantity) AS TotalQuantity
FROM transactions
 LEFT JOIN customers
 ON transactions.customer_id = customers.customer_id
LEFT JOIN products
ON transactions.product_id = products.product_id
GROUP BY CONCAT(customers.first_name, ' ' , customers.last_name)
ORDER BY SUM(transactions.quantity) DESC;

-- store sales analysis

-- Stores with the highest sales and its region

SELECT stores.store_name,regions.sales_region,SUM(products.product_retail_price * transactions.quantity) AS Revenue
FROM transactions
LEFT JOIN stores
ON transactions.store_id = stores.store_id
LEFT JOIN products
ON transactions.product_id = products.product_id
LEFT JOIN regions
ON stores.region_id = regions.region_id
GROUP BY stores.store_name,regions.sales_region
ORDER BY SUM(products.product_retail_price * transactions.quantity) DESC;

-- Quantity sold in each store

SELECT stores.store_name,regions.sales_region,SUM(transactions.quantity) AS Total_Quantity
FROM transactions
LEFT JOIN stores
ON transactions.store_id = stores.store_id
LEFT JOIN products
ON transactions.product_id = products.product_id
LEFT JOIN regions
ON stores.region_id = regions.region_id
GROUP BY stores.store_name,regions.sales_region
ORDER BY SUM(transactions.quantity) DESC;

-- Product Brand analysis
-- Which top 5 brands that had the highest quantity ordered

SELECT TOP(5) productBrand.brand_name, SUM(transactions.quantity) AS Total_Quantity
FROM transactions
LEFT JOIN products
ON transactions.product_id = products.product_id
LEFT JOIN productBrand
ON products.product_brandID = productBrand.productBrand_id
GROUP BY productBrand.brand_name
ORDER BY  SUM(transactions.quantity) DESC;

-- TOP 5 Brand name that fecthed the copany the highest sales Revenues generated 
SELECT TOP(5) productBrand.brand_name, SUM(transactions.quantity * products.product_retail_price) AS Total_Revenue
FROM transactions
LEFT JOIN products
ON transactions.product_id = products.product_id
LEFT JOIN productBrand
ON products.product_brandID = productBrand.productBrand_id
GROUP BY productBrand.brand_name
ORDER BY SUM(transactions.quantity * products.product_retail_price) DESC;

-- Find the key performance indicators
-- Find the total revenue

 SELECT SUM(transactions.quantity * products.product_retail_price) AS Total_Revenue
 FROM transactions
 LEFT JOIN products
 ON transactions.product_id = products.product_id
 
-- Find the profit

 SELECT SUM((transactions.quantity * products.product_retail_price) - (products.product_cost)) AS Profit
 FROM transactions
 LEFT JOIN products
 ON transactions.product_id = products.product_id

 -- Total Transactions

 SELECT SUM(quantity) AS total_qautity
 FROM transactions

-- Total number of items returned

SELECT SUM(quantity)
FROM returns

-- Find the profits over the years
SELECT 
	SUM(CASE WHEN YEAR(transactions.calendar) = 1997 THEN transactions.quantity * products.product_retail_price - products.product_cost ELSE 0 END) AS "1997_Profit",
	SUM(CASE WHEN YEAR(transactions.calendar) = 1998 THEN transactions.quantity * products.product_retail_price - products.product_cost ELSE 0 END) AS "1998_Profit"
FROM transactions
LEFT JOIN products 
ON transactions.product_id = products.product_id
WHERE YEAR(transactions.calendar) IN (1997, 1998)

-- Find the revenue over the years

SELECT 
	SUM(CASE WHEN YEAR(transactions.calendar) = 1997 THEN transactions.quantity * products.product_retail_price  ELSE 0 END) AS "1997_Revenue",
	SUM(CASE WHEN YEAR(transactions.calendar) = 1998 THEN transactions.quantity * products.product_retail_price  ELSE 0 END) AS "1998_Revenue"
FROM transactions
LEFT JOIN products 
ON transactions.product_id = products.product_id
WHERE YEAR(transactions.calendar) IN (1997, 1998)

-- find the top 10 products whih their revenue and their revenue increase

SELECT TOP (10) products.product_name,

	SUM(CASE WHEN YEAR(transactions.calendar) = 1997 THEN transactions.quantity * products.product_retail_price  ELSE 0 END) AS "1997_Revenue",
	SUM(CASE WHEN YEAR(transactions.calendar) = 1998 THEN transactions.quantity * products.product_retail_price  ELSE 0 END) AS "1998_Revenue",
	SUM(CASE WHEN YEAR(transactions.calendar) = 1998 THEN transactions.quantity * products.product_retail_price  ELSE 0 END) -
	SUM(CASE WHEN YEAR(transactions.calendar) = 1997 THEN transactions.quantity * products.product_retail_price  ELSE 0 END) AS Revenue_Increase
FROM transactions
LEFT JOIN products 
ON transactions.product_id = products.product_id
WHERE YEAR(transactions.calendar) IN (1997, 1998)
GROUP BY products.product_name
ORDER BY SUM(CASE WHEN YEAR(transactions.calendar) = 1997 THEN transactions.quantity * products.product_retail_price  ELSE 0 END) DESC;

-- Find the top 10 products with their revenue over the years and the quantity increase

SELECT TOP (10) products.product_name,

	SUM(CASE WHEN YEAR(transactions.calendar) = 1997 THEN transactions.quantity ELSE 0 END) AS "1997_Quantity",
	SUM(CASE WHEN YEAR(transactions.calendar) = 1998 THEN transactions.quantity   ELSE 0 END) AS "1998_Quantity",
	SUM(CASE WHEN YEAR(transactions.calendar) = 1998 THEN transactions.quantity  ELSE 0 END) -
	SUM(CASE WHEN YEAR(transactions.calendar) = 1997 THEN transactions.quantity  ELSE 0 END) AS Total_quantity_Increase
FROM transactions
LEFT JOIN products 
ON transactions.product_id = products.product_id
WHERE YEAR(transactions.calendar) IN (1997, 1998)
GROUP BY products.product_name
ORDER BY SUM(CASE WHEN YEAR(transactions.calendar) = 1997 THEN transactions.quantity  ELSE 0 END) DESC;

-- Find the profits, revenue and profit margin for the top 10 products sold

SELECT TOP (10) products.product_name, SUM(transactions.quantity * products.product_retail_price) AS total_revenue,
	   SUM(transactions.quantity * products.product_retail_price - products.product_cost) AS profit,
	   ROUND(SUM((transactions.quantity * products.product_retail_price - products.product_cost)/(transactions.quantity * products.product_retail_price)),2) AS profit_margin
FROM transactions
LEFT JOIN products
ON transactions.product_id = products.product_id
WHERE YEAR(transactions.calendar) = 1997
GROUP BY products.product_name
ORDER BY SUM(transactions.quantity * products.product_retail_price - products.product_cost) DESC

-- How many transactions where made used the different member cards

SELECT
		SUM(CASE WHEN customers.member_card ='Normal'THEN 1 ELSE 0 END) AS count_normal_holder,
		SUM(CASE WHEN customers.member_card ='Bronze'THEN 1 ELSE 0 END) AS count_bronze_holder,
		SUM(CASE WHEN customers.member_card ='Golden'THEN 1 ELSE 0 END) AS count_golden_holder,
		SUM(CASE WHEN customers.member_card ='Silver'THEN 1 ELSE 0 END) AS count_silver_holder
FROM transactions 
LEFT JOIN customers
ON transactions.customer_id = customers.customer_id;

-- EXEC yearly @calendar = 1997;
-- sp_help
-- sp_rename()

-- Find the Year on Year

-- Return rate

SELECT SUM(quantity) AS total_returns FROM returns;

SELECT SUM(quantity) AS total_transactions FROM transactions;

SELECT (p.product_name),  COALESCE(SUM(r.quantity) / NULLIF(SUM(t.quantity), 0), 0) * 100 AS returns_rate
FROM transactions t
LEFT JOIN products p
ON t.product_id = p.product_id
LEFT JOIN returns r
ON p.product_id = r.product_id
GROUP BY p.product_name

-- Returns Analysis

-- find the total quatity of goods returns

SELECT SUM(quantity) 
FROM returns

-- what are the top 5 product returned

SELECT TOP (5) products.product_name, SUM(returns.quantity) AS quantity_returned
FROM returns
LEFT JOIN products
ON returns.product_id = products.product_id
GROUP BY products.product_name
ORDER BY SUM(returns.quantity) DESC;

-- what are the top 3 brands which recorded the highest quantity returned

SELECT TOP (5) productBrand.brand_name, SUM(returns.quantity) AS quantity_returned
FROM returns
LEFT JOIN products
ON returns.product_id = products.product_id
LEFT JOIN productBrand
ON products.product_brandID = productBrand.productBrand_id
GROUP BY productBrand.brand_name
ORDER BY SUM(returns.quantity) DESC;

-- which store recorded the highest number of quatity returned

SELECT TOP (1)store_name,SUM(returns.quantity) AS quantity_returned
FROM returns
LEFT JOIN stores
ON returns.store_id = stores.store_id
GROUP BY store_name
ORDER BY SUM(returns.quantity) DESC;

-- total quantity returned within the two years.

SELECT SUM(quantity) AS quantity_returned
FROM returns
WHERE YEAR(calendar) IN (1997,1998);

--what is the total quantity in 1997 and 1998 respectively by product name

SELECT  products.product_name,

		SUM(CASE WHEN YEAR(returns.calendar) = 1997 THEN returns.quantity ELSE 0 END ) AS Total_returns_1997,
		SUM(CASE WHEN YEAR(returns.calendar) = 1998 THEN returns.quantity ELSE 0 END ) AS Total_returns_1998

FROM returns
LEFT JOIN products
ON returns.product_id = products.product_id
GROUP BY products.product_name


-- find the top 10 products and compare the quantity returned. Find the difference in returns between the two years.

SELECT TOP(15) products.product_name,

		SUM(CASE WHEN YEAR(returns.calendar) = 1997 THEN returns.quantity ELSE 0 END ) AS Total_returns_1997,
		SUM(CASE WHEN YEAR(returns.calendar) = 1998 THEN returns.quantity ELSE 0 END ) AS Total_returns_1998,
		SUM( (CASE WHEN YEAR(returns.calendar) = 1998 THEN returns.quantity ELSE 0 END )- (CASE WHEN YEAR(returns.calendar) = 1997 THEN returns.quantity ELSE 0 END )) AS returns_difference

FROM returns
LEFT JOIN products
ON returns.product_id = products.product_id
GROUP BY products.product_name
ORDER BY SUM( (CASE WHEN YEAR(returns.calendar) = 1998 THEN returns.quantity ELSE 0 END )- (CASE WHEN YEAR(returns.calendar) = 1997 THEN returns.quantity ELSE 0 END ))DESC;
-- the above sql was connected to power bi for visualisation

-- done









