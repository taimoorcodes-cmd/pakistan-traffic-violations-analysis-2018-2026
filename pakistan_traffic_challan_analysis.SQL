
-- ================================
-- Pakistan Traffic Challan Analysis
-- Author: Taimoor Ghalib
-- Dataset: 827,700 rows | 2018-2026
-- Tool: MySQL
-- ================================


-- ================================
-- Query 1: National Financial Summary
-- ================================

SELECT
    SUM(Fine_Amount_PKR) AS Total_Imposed_Revenue_PKR,
    SUM(Amount_Collected_PKR) AS Total_Collected_PKR,
    SUM(Fine_Amount_PKR) - SUM(Amount_Collected_PKR) AS Total_Leakage_PKR,
    CONCAT(ROUND((SUM(Amount_Collected_PKR) / 
    SUM(Fine_Amount_PKR)) * 100, 2), '%') AS National_Recovery_Rate
FROM traffic_challan_data;


-- ================================
-- Query 2: Revenue Leakage by Violation Type
-- ================================

SELECT
    Violation_Type,
    COUNT(Challan_ID) AS Total_Challans,
    CONCAT(ROUND((SUM(CASE WHEN Payment_Status = 'Paid' 
    THEN 1 ELSE 0 END) / COUNT(Challan_ID)) * 100, 2), '%') 
    AS Compliance_Rate,
    SUM(Fine_Amount_PKR) AS Total_Fines_PKR,
    SUM(Amount_Collected_PKR) AS Collected_PKR,
    SUM(Fine_Amount_PKR) - SUM(Amount_Collected_PKR) 
    AS Leakage_PKR
FROM traffic_challan_data
GROUP BY Violation_Type
ORDER BY Leakage_PKR DESC;


-- ================================
-- Query 3: Provincial Revenue Performance
-- ================================

SELECT
    Province,
    COUNT(Challan_ID) AS Total_Challans,
    SUM(Fine_Amount_PKR) AS Target_Revenue_PKR,
    SUM(Amount_Collected_PKR) AS Actual_Revenue_PKR,
    CONCAT(ROUND((SUM(Amount_Collected_PKR) / 
    SUM(Fine_Amount_PKR)) * 100, 2), '%') AS Recovery_Rate,
    SUM(Fine_Amount_PKR) - SUM(Amount_Collected_PKR) 
    AS Unrecovered_PKR
FROM traffic_challan_data
GROUP BY Province
ORDER BY Actual_Revenue_PKR DESC;


-- ================================
-- Query 4: Vehicle Type Risk Analysis
-- ================================

SELECT
    Vehicle_Type,
    COUNT(Challan_ID) AS Total_Challans,
    ROUND(AVG(Fine_Amount_PKR), 2) AS Avg_Fine_PKR,
    CONCAT(ROUND((SUM(CASE WHEN Payment_Status = 'Paid' 
    THEN 1 ELSE 0 END) / COUNT(Challan_ID)) * 100, 2), '%') 
    AS Paid_Rate,
    SUM(Fine_Amount_PKR) - SUM(Amount_Collected_PKR) 
    AS Leakage_PKR
FROM traffic_challan_data
GROUP BY Vehicle_Type
ORDER BY Leakage_PKR DESC;


-- ================================
-- Query 5: Yearly Growth Trend
-- ================================

SELECT
    Year,
    COUNT(Challan_ID) AS Annual_Challans,
    ROUND(AVG(Fine_Amount_PKR), 2) AS Avg_Ticket_Cost_PKR,
    SUM(Amount_Collected_PKR) AS Annual_Collection_PKR,
    CONCAT(ROUND((SUM(CASE WHEN Payment_Status = 'Paid' 
    THEN 1 ELSE 0 END) / COUNT(Challan_ID)) * 100, 2), '%') 
    AS Annual_Compliance_Rate
FROM traffic_challan_data
GROUP BY Year
ORDER BY Year ASC;


-- ================================
-- Query 6: Top 10 Cities by Cash Leakage
-- ================================

SELECT
    City,
    Province,
    COUNT(Challan_ID) AS Total_Challans,
    SUM(Fine_Amount_PKR) - SUM(Amount_Collected_PKR) 
    AS Leakage_PKR,
    CONCAT(ROUND((SUM(Amount_Collected_PKR) / 
    SUM(Fine_Amount_PKR)) * 100, 2), '%') AS Recovery_Rate
FROM traffic_challan_data
GROUP BY City, Province
ORDER BY Leakage_PKR DESC
LIMIT 10;


-- ================================
-- Query 7: Dangerous Vehicle + Violation Combo
-- ================================

SELECT
    Vehicle_Type,
    Violation_Type,
    COUNT(Challan_ID) AS Total_Challans,
    SUM(Fine_Amount_PKR) - SUM(Amount_Collected_PKR) 
    AS Combo_Leakage_PKR
FROM traffic_challan_data
WHERE Violation_Type IN ('Speeding',
'Reckless Driving', 'Overloading')
GROUP BY Vehicle_Type, Violation_Type
ORDER BY Combo_Leakage_PKR DESC
LIMIT 10;


-- ================================
-- Query 8: Quarterly Seasonal Leakage
-- ================================

SELECT
    CASE
        WHEN Month IN ('January', 'February', 'March') 
        THEN 'Q1'
        WHEN Month IN ('April', 'May', 'June') 
        THEN 'Q2'
        WHEN Month IN ('July', 'August', 'September') 
        THEN 'Q3'
        ELSE 'Q4'
    END AS Quarter,
    SUM(Fine_Amount_PKR) AS Target_Fines_PKR,
    SUM(Fine_Amount_PKR) - SUM(Amount_Collected_PKR) 
    AS Quarter_Leakage_PKR
FROM traffic_challan_data
GROUP BY Quarter
ORDER BY Quarter_Leakage_PKR DESC;


-- ================================
-- Query 9: Enforcement Method Efficiency
-- ================================

SELECT
    Enforcement_Method,
    COUNT(Challan_ID) AS Total_Challans,
    CONCAT(ROUND((SUM(CASE WHEN Payment_Status = 'Paid' 
    THEN 1 ELSE 0 END) / COUNT(Challan_ID)) * 100, 2), '%') 
    AS Compliance_Rate,
    SUM(Fine_Amount_PKR) AS Total_Fines_PKR,
    SUM(Fine_Amount_PKR) - SUM(Amount_Collected_PKR) 
    AS Leakage_PKR
FROM traffic_challan_data
GROUP BY Enforcement_Method
ORDER BY Leakage_PKR DESC;


-- ================================
-- Query 10: Critical Leakage Hotspots
-- ================================

SELECT
    City,
    Violation_Type,
    COUNT(Challan_ID) AS Total_Challans,
    SUM(Fine_Amount_PKR) - SUM(Amount_Collected_PKR) 
    AS Unrecovered_PKR
FROM traffic_challan_data
GROUP BY City, Violation_Type
ORDER BY Unrecovered_PKR DESC
LIMIT 5;