/* ============================================================
   Project 5: Executive KPI Dashboard
   ------------------------------------------------------------
   Purpose:
   Provide business executives with high-level KPIs for
   monitoring company performance.

   Executive KPIs:
   - Total Revenue / Customers / Orders
   - Average Order Value
   - Average Revenue per Customer
   - Best Product / Category / Country / Sales Territory
   ============================================================ */

DROP VIEW IF EXISTS Executive_KPI_Dashboard;
GO

CREATE VIEW Executive_KPI_Dashboard AS
WITH Business_Details AS
(
    SELECT
        SalesAmount,
        CustomerKey,
        p.ProductKey                       AS ProductKey,
        p.EnglishProductName               AS ProductName,
        SalesOrderNumber,
        OrderQuantity,
        SalesTerritoryCountry,
        EnglishProductSubcategoryName,
        EnglishProductCategoryName         AS Category_Name,
        EnglishCountryRegionName           AS Country_Name,
        SalesTerritoryRegion               AS Region,
        SUM(SalesAmount) OVER (PARTITION BY CustomerKey)          AS SalesPerCustomer,
        SUM(SalesAmount) OVER (PARTITION BY EnglishProductName)   AS SalesPerProduct
    FROM FactInternetSales f
    INNER JOIN DimGeography g ON f.SalesTerritoryKey = g.SalesTerritoryKey
    INNER JOIN DimSalesTerritory t ON t.SalesTerritoryKey = g.SalesTerritoryKey
    INNER JOIN DimProduct p ON p.ProductKey = f.ProductKey
    INNER JOIN DimProductSubcategory s ON s.ProductSubcategoryKey = p.ProductSubcategoryKey
    INNER JOIN DimProductCategory c ON c.ProductCategoryKey = s.ProductCategoryKey
),
Best_Product AS
(
    SELECT TOP 1 ProductName, SalesPerProduct
    FROM Business_Details
    GROUP BY ProductName, SalesPerProduct
    ORDER BY SalesPerProduct DESC
),
Best_Country AS
(
    SELECT TOP 1 Country_Name, SUM(SalesAmount) AS Total_Sales
    FROM Business_Details
    GROUP BY Country_Name
    ORDER BY Total_Sales DESC
),
Best_Sales_Territory AS
(
    SELECT TOP 1 Region, SUM(SalesAmount) AS Total_Sales
    FROM Business_Details
    GROUP BY Region
    ORDER BY Total_Sales DESC
),
Best_Category AS
(
    SELECT TOP 1 Category_Name, SUM(SalesAmount) AS Total_Sales
    FROM Business_Details
    GROUP BY Category_Name
    ORDER BY Total_Sales DESC
)
SELECT
    SUM(bd.SalesAmount)                                            AS Total_Sales,
    COUNT(DISTINCT bd.CustomerKey)                                 AS Total_Customer,
    COUNT(DISTINCT bd.SalesOrderNumber)                            AS Total_Order,
    SUM(bd.SalesAmount) / COUNT(DISTINCT bd.SalesOrderNumber)      AS Average_Sales_Per_Order,
    AVG(bd.SalesPerCustomer)                                       AS Average_Revenue_per_Customer,
    bp.ProductName                                                 AS Best_Selling_Product,
    bc.Country_Name                                                AS Best_Country,
    bst.Region                                                     AS Best_Sales_Territory,
    bcat.Category_Name                                             AS Best_Category
FROM Business_Details bd
CROSS JOIN Best_Product bp
CROSS JOIN Best_Country bc
CROSS JOIN Best_Sales_Territory bst
CROSS JOIN Best_Category bcat
GROUP BY bp.ProductName, bc.Country_Name, bst.Region, bcat.Category_Name;
GO

SELECT * FROM Executive_KPI_Dashboard;
GO
