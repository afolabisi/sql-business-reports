/* 
============================================================
   Project 2: Product Performance Report
   ------------------------------------------------------------
   Purpose:
   Analyze product performance to identify high-performing
   products, slow-moving products, and overall product
   profitability.

   Key Metrics:
   - Total Revenue
   - Total Orders
   - Total Quantity Sold
   - Average Selling Price
   - Average Revenue per Order
   - Number of Customers Purchasing
   - Revenue Rank
   - Sales Rank

   Product Insights:
   - Top 10 / Bottom 10 Products
   - Highest Revenue Product
   - Highest Quantity Sold
   - Most Popular Product Color
   - Best Product Line / Category
   ============================================================
*/

DROP VIEW IF EXISTS Product_Performance_Result;
GO

CREATE VIEW Product_Performance_Result AS
WITH ProductPerformance AS
(
    SELECT
        p.ProductKey                                AS Product_Key,
        p.EnglishProductName                        AS Product_Name,
        p.Color                                      AS Product_Color,
        f.SalesOrderNumber                          AS OrderNumber,
        f.SalesAmount                                AS SalesAmount,
        f.UnitPrice                                  AS UnitPrice,
        f.OrderQuantity,
        f.CustomerKey                                AS CustomerKey,
        c.EnglishProductCategoryName                AS Product_Category,
        s.EnglishProductSubcategoryName              AS Product_Subcategory
    FROM DimProduct p
    LEFT JOIN FactInternetSales f ON p.ProductKey = f.ProductKey
    LEFT JOIN DimProductSubcategory s ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
    LEFT JOIN DimProductCategory c ON s.ProductCategoryKey = c.ProductCategoryKey
),
ProductAnalytics AS
(
    SELECT
        Product_Key,
        Product_Name,
        Product_Category,
        Product_Subcategory,
        Product_Color,
        SUM(SalesAmount)                                            AS Total_Revenue,
        COUNT(DISTINCT OrderNumber)                                 AS Total_Orders,
        AVG(UnitPrice)                                              AS Average_Selling_Price,
        SUM(OrderQuantity)                                          AS Total_Quantity_Sold,
        ROUND(SUM(SalesAmount) / COUNT(DISTINCT OrderNumber), 2)    AS Average_Revenue_per_Order,
        COUNT(DISTINCT CustomerKey)                                 AS Number_of_Customers_Purchasing,
        RANK() OVER (ORDER BY SUM(SalesAmount) DESC)                AS Revenue_Rank,
        RANK() OVER (ORDER BY SUM(OrderQuantity) DESC)              AS Sales_Rank,
        ROUND(SUM(SalesAmount) / SUM(SUM(SalesAmount)) OVER (), 8) * 100 AS Revenue_Contributor
    FROM ProductPerformance
    GROUP BY Product_Key, Product_Name, Product_Category, Product_Subcategory, Product_Color
)
SELECT *,
    CASE
        WHEN Total_Revenue BETWEEN 0 AND 1000 THEN 'Low Performer'
        WHEN Total_Revenue BETWEEN 1000 AND 5000 THEN 'Medium Performer'
        WHEN Total_Revenue BETWEEN 5000 AND 10000 THEN 'High Performer'
        ELSE 'Top Performer'
    END AS Revenue_Category
FROM ProductAnalytics;
GO

SELECT * FROM Product_Performance_Result;
GO
