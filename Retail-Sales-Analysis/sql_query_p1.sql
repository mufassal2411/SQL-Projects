-- SQL Retail Sales Analysis - P1
CREATE DATABASE sql_project_p1;


-- Create TABLE
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
            (
                transaction_id INT PRIMARY KEY,	
                sale_date DATE,	 
                sale_time TIME,	
                customer_id	INT,
                gender	VARCHAR(15),
                age	INT,
                category VARCHAR(15),	
                quantity	INT,
                price_per_unit FLOAT,	
                cogs	FLOAT,
                total_sale FLOAT
            );

SELECT * FROM retail_sales


--OR CAN IMPORT DATA FROM DB->TASKS->IMPORT FLAT FILE->SELECT REQUIRED FILE AND IMPORT
    

SELECT 
    COUNT(*) 
FROM retail_sales

-- Data Cleaning
SELECT * FROM retail_sales
WHERE transactions_id IS NULL

SELECT * FROM retail_sales
WHERE sale_date IS NULL

SELECT * FROM retail_sales
WHERE sale_time IS NULL

SELECT * FROM retail_sales
WHERE 
    transactions_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantiy IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL
    OR
    age IS NULL;
    
-- 
DELETE FROM retail_sales
WHERE 
    transactions_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantiy IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL
    OR
    age IS NULL;
    
-- Data Exploration

-- How many sales we have?
SELECT COUNT(*) as total_sale FROM retail_sales

-- How many uniuque customers we have ?

SELECT COUNT(DISTINCT customer_id) as unique_customers FROM retail_sales



SELECT DISTINCT category FROM retail_sales


-- Data Analysis & Business Key Problems & Answers

-- My Analysis & Findings

 --  to retrieve all columns for sales made on '2022-11-05

SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';


-- to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022

SELECT 
  *
FROM retail_sales
WHERE 
    category = 'Clothing'
    AND sale_date >= '2022-11-01'
    AND sale_date < '2022-12-01'
    AND quantiy >= 4;


--  to calculate the total sales (total_sale) for each category.

SELECT 
    category,
    SUM(total_sale) as net_sale,
    COUNT(*) as total_orders
FROM retail_sales
GROUP BY category;

--  to find the average age of customers who purchased items from the 'Beauty' category.

SELECT
    ROUND(AVG(age), 2) as avg_age
FROM retail_sales
WHERE category = 'Beauty'


--  to find all transactions where the total_sale is greater than 1000.

SELECT * FROM retail_sales
WHERE total_sale > 1000


--  to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT 
    category,
    gender,
    COUNT(*) as total_trans
FROM retail_sales
GROUP 
    BY 
    category,
    gender
ORDER BY category;


--  to calculate the average sale for each month. Find out best selling month in each year

WITH monthlysale AS (
    SELECT 
        YEAR(sale_date)  AS sales_year,
        MONTH(sale_date) AS sales_month,
        AVG(total_sale)  AS avg_sales
    FROM Retail_Sales
    GROUP BY
        YEAR(sale_date),
        MONTH(sale_date)
)
SELECT 
    sales_year,
    sales_month,
    avg_sales
FROM (
    SELECT  
        sales_year,
        sales_month,
        avg_sales,
        RANK() OVER (
            PARTITION BY sales_year
            ORDER BY avg_sales DESC
        ) AS monthrank
    FROM monthlysale
) t
WHERE monthrank = 1
ORDER BY sales_year;

-- ORDER BY 1, 3 DESC

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 

SELECT TOP 5
    customer_id,
    SUM(total_sale) as total_sales 
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales desc


-- to find the number of unique customers who purchased items from each category.


SELECT 
    category,    
    COUNT(DISTINCT customer_id) as cnt_unique_cs
FROM retail_sales
GROUP BY category;



--  to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)

WITH shifts
AS
(
SELECT *,
    CASE
        WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning'
        WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) as total_orders    
FROM shifts
GROUP BY shift;


-- End of project

