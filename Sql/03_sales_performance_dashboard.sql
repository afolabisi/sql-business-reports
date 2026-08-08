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
WITH SalesBase AS
(
    -- Raw fact rows with date parts pre-extracted
    SELECT
        SalesAmount,
        SalesOrderNumber,
        CustomerKey,
        CAST(CAST(DateKey AS varchar) AS date)                    AS Order_Date,
        YEAR(CAST(CAST(DateKey AS varchar) AS date))              AS Year_Order_Date,
        DATETRUNC(MONTH, CAST(CAST(DateKey AS varchar) AS date))  AS Month_Order_Date,
        DATENAME(QUARTER, CAST(CAST(DateKey AS varchar) AS date)) AS Quarter_Order_Date
    FROM FactInternetSales f
    INNER JOIN DimDate d ON f.OrderDateKey = d.DateKey
),
Daily_Totals AS
(
    -- One row per calendar day
    SELECT
        Order_Date,
        Year_Order_Date,
        Month_Order_Date,
        Quarter_Order_Date,
        SUM(SalesAmount)                                              AS Total_Revenue,
        COUNT(DISTINCT SalesOrderNumber)                              AS Total_Order,
        COUNT(DISTINCT CustomerKey)                                   AS Total_Customer,
        ROUND(SUM(SalesAmount) / COUNT(DISTINCT SalesOrderNumber), 2) AS Average_Order_Value
    FROM SalesBase
    GROUP BY Order_Date, Year_Order_Date, Month_Order_Date, Quarter_Order_Date
),
Running_Totals AS
(
    -- Cumulative revenue, built directly on the daily grain
    SELECT
        Order_Date,
        SUM(Total_Revenue) OVER (
            ORDER BY Order_Date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS Running_Total_Sales
    FROM Daily_Totals
),
Monthly_Totals AS
(
    -- One row per month, with prior month attached for MoM growth
    SELECT
        Month_Order_Date,
        SUM(Total_Revenue)                                      AS Monthly_Sales,
        LAG(SUM(Total_Revenue)) OVER (ORDER BY Month_Order_Date) AS Previous_Month_Sales
    FROM Daily_Totals
    GROUP BY Month_Order_Date
),
Quarterly_Totals AS
(
    -- One row per year + quarter
    SELECT
        Year_Order_Date,
        Quarter_Order_Date,
        SUM(Total_Revenue) AS Quarter_Sales
    FROM Daily_Totals
    GROUP BY Year_Order_Date, Quarter_Order_Date
),
Yearly_Totals AS
(
    -- One row per year, with prior year attached for YoY growth
    SELECT
        Year_Order_Date,
        SUM(Total_Revenue)                                     AS Yearly_Sales,
        LAG(SUM(Total_Revenue)) OVER (ORDER BY Year_Order_Date) AS Previous_Year_Sales
    FROM Daily_Totals
    GROUP BY Year_Order_Date
),
Grand_Total AS
(
    -- Single company-wide total, used for the yearly contribution %
    SELECT SUM(Yearly_Sales) AS Total_All_Sales
    FROM Yearly_Totals
)
SELECT
    dt.Order_Date,
    dt.Year_Order_Date,
    dt.Month_Order_Date,
    dt.Quarter_Order_Date,
    dt.Total_Revenue,
    dt.Total_Order,
    dt.Total_Customer,
    dt.Average_Order_Value,
    rt.Running_Total_Sales,
    mt.Monthly_Sales,
    mt.Previous_Month_Sales,
    ROUND((mt.Monthly_Sales - mt.Previous_Month_Sales) / mt.Previous_Month_Sales * 100, 2) AS Month_Over_Month,
    qt.Quarter_Sales,
    yt.Yearly_Sales,
    yt.Previous_Year_Sales,
    ROUND((yt.Yearly_Sales - yt.Previous_Year_Sales) / yt.Previous_Year_Sales * 100, 2)     AS Year_Over_Year,
    ROUND(mt.Monthly_Sales / yt.Yearly_Sales, 4) * 100                                      AS Monthly_Contribution_To_Year,
    ROUND(yt.Yearly_Sales / gt.Total_All_Sales, 4) * 100                                    AS Yearly_Contribution_To_TotalSales
FROM Daily_Totals dt
INNER JOIN Running_Totals   rt ON dt.Order_Date = rt.Order_Date
INNER JOIN Monthly_Totals   mt ON dt.Month_Order_Date = mt.Month_Order_Date
INNER JOIN Quarterly_Totals qt ON dt.Year_Order_Date = qt.Year_Order_Date AND dt.Quarter_Order_Date = qt.Quarter_Order_Date
INNER JOIN Yearly_Totals    yt ON dt.Year_Order_Date = yt.Year_Order_Date
CROSS JOIN Grand_Total gt;
GO

SELECT * FROM Sales_Performance_Dashboard;
GO

/*
   Business Insights to pull from this view:
   - Best / Worst Sales Month  -> ORDER BY Monthly_Sales DESC / ASC
   - Best / Worst Quarter      -> ORDER BY Quarter_Sales DESC / ASC
   - Highest Sales Year        -> ORDER BY Yearly_Sales DESC
   - Sales Trend Analysis      -> plot Running_Total_Sales over Order_Date
*/
