/* ============================================================
   Project 1: Customer Analytics Report
   ------------------------------------------------------------
   Purpose:
   Develop a comprehensive customer performance report to
   understand customer purchasing behavior, customer value,
   and long-term engagement.

   Key Metrics:
   - Total Orders
   - Total Revenue
   - Average Order Value
   - Average Monthly Spend
   - Total Quantity Purchased
   - Total Products Purchased
   - Customer Lifespan (Months)
   - First Purchase Date
   - Last Purchase Date
   - Recency (Months Since Last Purchase)

   Customer Segmentation:
   - VIP Customers
   - Loyal Customers
   - Regular Customers
   - New Customers
   - At-Risk Customers

   Age Segmentation:
   - Under 25 / 25-34 / 35-44 / 45-54 / 55+
   ============================================================ */

DROP VIEW IF EXISTS Customer_Analytics_Report;
GO

CREATE VIEW Customer_Analytics_Report AS
WITH CustomerAnalytics AS
(
    SELECT
        c.CustomerKey                              AS Customer_Key,
        FirstName + ' ' + LastName                 AS Customer_Name,
        Gender,
        MaritalStatus                               AS Marital_Status,
        CAST(s.OrderDate AS date)                   AS Order_Date,
        s.SalesOrderNumber                          AS SalesOrderNumber,
        SalesAmount,
        OrderQuantity,
        s.ProductKey                                AS ProductKey,
        c.BirthDate                                 AS BirthDate,
        EnglishCountryRegionName                    AS Country_Name
    FROM DimCustomer c
    INNER JOIN FactInternetSales s ON c.CustomerKey = s.CustomerKey
    INNER JOIN DimGeography g ON g.GeographyKey = c.GeographyKey
),
Customer_Details AS
(
    SELECT
        Customer_Key,
        Customer_Name,
        Gender,
        Marital_Status,
        Country_Name,
        COUNT(SalesOrderNumber)                                            AS Total_Orders,
        SUM(SalesAmount)                                                   AS Total_Revenue,
        SUM(SalesAmount) / COUNT(SalesOrderNumber)                         AS Average_Order_Value,
        SUM(SalesAmount) / COUNT(DISTINCT DATETRUNC(MONTH, Order_Date))    AS Average_Monthly_Spend,
        SUM(OrderQuantity)                                                 AS Total_Quantity_Purchased,
        COUNT(DISTINCT ProductKey)                                         AS Total_Products_Purchased,
        MIN(Order_Date)                                                    AS First_Purchase_Date,
        MAX(Order_Date)                                                    AS Last_Purchase_Date,
        DATEDIFF(MONTH, MIN(Order_Date), MAX(Order_Date))                  AS Customer_Lifespan_Months,
        DATEDIFF(MONTH, MAX(Order_Date), GETDATE())                        AS Recency_Months_Since_Last_Purchase,
        DATEDIFF(YEAR, BirthDate, GETDATE())                                AS Customer_Age
    FROM CustomerAnalytics
    GROUP BY Customer_Key, Customer_Name, BirthDate, Gender, Marital_Status, Country_Name
)
SELECT *,
    CASE
        WHEN Customer_Age < 25 THEN 'Under 25'
        WHEN Customer_Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Customer_Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Customer_Age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS Age_Segmentation,
    CASE
        WHEN Total_Revenue > 10000 AND Customer_Lifespan_Months > 24 THEN 'VIP Customer'
        WHEN Total_Revenue BETWEEN 5000 AND 10000 AND Customer_Lifespan_Months BETWEEN 12 AND 24 THEN 'Loyal Customer'
        WHEN Total_Revenue BETWEEN 1000 AND 5000 AND Customer_Lifespan_Months BETWEEN 6 AND 12 THEN 'Regular Customer'
        WHEN Total_Revenue < 1000 AND Customer_Lifespan_Months < 6 THEN 'New Customer'
        ELSE 'At-Risk Customer'
    END AS Customer_Segmentation
FROM Customer_Details;
GO

SELECT * FROM Customer_Analytics_Report;
GO
