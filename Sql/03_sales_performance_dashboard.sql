
/* ============================================================
   Project 3: Sales Performance Dashboard
   ------------------------------------------------------------
   Purpose:
   Evaluate business sales performance across different periods
   and identify long-term sales trends.

   Key Metrics:
   - Total Revenue / Orders / Customers
   - Average Order Value
   - Monthly / Quarterly / Yearly Sales
   - Running Total Sales
   - Year-over-Year Growth
   - Month-over-Month Growth

   Note: uses OrderDateKey (not DueDateKey) so figures reflect
   when the sale was actually placed.
   ============================================================ */

DROP VIEW IF EXISTS Sales_Performance_Dashboard;
GO

CREATE VIEW Sales_Performance_Dashboard AS
WITH SalesPerformance AS
(
    SELECT
        SalesAmount,
        OrderQuantity,
        SalesOrderNumber,
        CustomerKey,
        CAST(CAST(DateKey AS varchar) AS date)                                   AS Order_Date,
        YEAR(CAST(CAST(DateKey AS varchar) AS date))                             AS Year_Order_Date,
        DATETRUNC(MONTH, CAST(CAST(DateKey AS varchar) AS date))                 AS Month_Order_Date,
        DATENAME(QUARTER, CAST(CAST(DateKey AS varchar) AS date))                AS Quarter_Order_Date
    FROM FactInternetSales f
    INNER JOIN DimDate d ON f.OrderDateKey = d.DateKey
),
Sales_Performance AS
(
    SELECT DISTINCT
        Order_Date,
        Year_Order_Date,
        Month_Order_Date,
        Quarter_Order_Date,
        ROUND(SUM(SalesAmount) OVER (PARTITION BY Order_Date), 2)                          AS Total_Revenue,
        COUNT(DISTINCT SalesOrderNumber) OVER (PARTITION BY Order_Date)                    AS Total_Order,
        COUNT(DISTINCT CustomerKey) OVER (PARTITION BY Order_Date)                         AS Total_Customer,
        ROUND(
            SUM(SalesAmount) OVER (PARTITION BY Order_Date)
            / COUNT(DISTINCT SalesOrderNumber) OVER (PARTITION BY Order_Date), 2)          AS Average_Order_Value,
        ROUND(SUM(SalesAmount) OVER (PARTITION BY Month_Order_Date), 2)                    AS Monthly_Sales,
        ROUND(SUM(SalesAmount) OVER (PARTITION BY Year_Order_Date, Quarter_Order_Date), 2) AS Quarter_Sales,
        ROUND(SUM(SalesAmount) OVER (PARTITION BY Year_Order_Date), 2)                     AS Yearly_Sales,
        ROUND(SUM(SalesAmount) OVER (ORDER BY Order_Date
              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2)                        AS Running_Total_Sales,
        ROUND(SUM(SalesAmount) OVER (PARTITION BY Month_Order_Date ORDER BY Month_Order_Date
              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2)                        AS Running_Monthly_Sales,
        ROUND(SUM(SalesAmount) OVER (PARTITION BY Year_Order_Date ORDER BY Year_Order_Date
              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2)                        AS Running_Yearly_Sales,
        ROUND(
            SUM(SalesAmount) OVER (PARTITION BY Year_Order_Date, Month_Order_Date)
            / SUM(SalesAmount) OVER (PARTITION BY Year_Order_Date), 2) * 100               AS Monthly_Contribution_To_Year,
        ROUND(
            SUM(SalesAmount) OVER (PARTITION BY Year_Order_Date)
            / SUM(SalesAmount) OVER (), 2) * 100                                           AS Yearly_Contribution_To_TotalSales
    FROM SalesPerformance
)
SELECT *,
    LAG(Monthly_Sales) OVER (ORDER BY Year_Order_Date, Month_Order_Date)                   AS Previous_Month_Sales,
    (Monthly_Sales - LAG(Monthly_Sales) OVER (ORDER BY Year_Order_Date, Month_Order_Date))
        / LAG(Monthly_Sales) OVER (ORDER BY Year_Order_Date, Month_Order_Date) * 100       AS Month_Over_Month,
    LAG(Yearly_Sales) OVER (ORDER BY Year_Order_Date)                                      AS Previous_Year_Sales,
    (Yearly_Sales - LAG(Yearly_Sales) OVER (ORDER BY Year_Order_Date))
        / LAG(Yearly_Sales) OVER (ORDER BY Year_Order_Date) * 100                          AS Year_Over_Year
FROM Sales_Performance;
GO

SELECT * FROM Sales_Performance_Dashboard;
GO
