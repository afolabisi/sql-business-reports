/* ============================================================
   Project 4: Regional Sales Analysis
   ------------------------------------------------------------
   Purpose:
   Analyze sales performance across different countries and
   sales territories.

   Key Metrics:
   - Revenue by Country / Territory / State / City
   - Orders by Region
   - Customers by Region

   Business Insights:
   - Best / Lowest Performing Country
   - Best Sales Territory
   - Regional Contribution Percentage
   - Customer Distribution by Region
   ============================================================ */

DROP VIEW IF EXISTS Regional_Sales_Analysis;
GO

CREATE VIEW Regional_Sales_Analysis AS
WITH Country_Details AS
(
    SELECT DISTINCT
        CustomerKey,
        ProductKey,
        SalesOrderNumber,
        SalesAmount,
        OrderQuantity,
        CountryRegionCode,
        StateProvinceName             AS State_Name,
        EnglishCountryRegionName      AS Country_Name,
        City,
        SalesTerritoryRegion          AS Region
    FROM FactInternetSales f
    INNER JOIN DimGeography g ON f.SalesTerritoryKey = g.SalesTerritoryKey
    INNER JOIN DimSalesTerritory s ON g.SalesTerritoryKey = s.SalesTerritoryKey
)
SELECT
    Region,
    Country_Name,
    State_Name,
    City,
    SUM(SalesAmount) OVER (PARTITION BY Region)                       AS Total_Revenue_By_Region,
    SUM(SalesAmount) OVER (PARTITION BY Country_Name)                 AS Total_Revenue_By_Country,
    SUM(SalesAmount) OVER (PARTITION BY State_Name)                   AS Total_Revenue_By_State,
    SUM(SalesAmount) OVER (PARTITION BY City)                         AS Total_Revenue_By_City,
    COUNT(DISTINCT SalesOrderNumber) OVER (PARTITION BY Region)       AS Total_Order_By_Region,
    COUNT(DISTINCT SalesOrderNumber) OVER (PARTITION BY Country_Name) AS Total_Order_By_Country,
    COUNT(DISTINCT SalesOrderNumber) OVER (PARTITION BY State_Name)   AS Total_Order_By_State,
    COUNT(DISTINCT SalesOrderNumber) OVER (PARTITION BY City)         AS Total_Order_By_City,
    COUNT(DISTINCT CustomerKey) OVER (PARTITION BY Region)            AS Total_Customer_By_Region,
    COUNT(DISTINCT CustomerKey) OVER (PARTITION BY Country_Name)      AS Total_Customer_By_Country,
    COUNT(DISTINCT CustomerKey) OVER (PARTITION BY State_Name)        AS Total_Customer_By_State,
    COUNT(DISTINCT CustomerKey) OVER (PARTITION BY City)              AS Total_Customer_By_City
FROM Country_Details;
GO

SELECT * FROM Regional_Sales_Analysis;
GO
