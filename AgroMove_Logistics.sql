SELECT 
    COUNT(Log_Row_ID) AS Total_Raw_Rows,
    COUNT(DISTINCT Trip_ID) AS Actual_Unique_Trips,
    (COUNT(Log_Row_ID) - COUNT(DISTINCT Trip_ID)) AS Duplicate_Rows_Found,
    SUM(CASE WHEN Maintenance_Cost_Naira IS NULL THEN 1 ELSE 0 END) AS Missing_Null_Maintenance_Rows
FROM Raw_Fleet_Logs;

DROP TABLE IF EXISTS Clean_Fleet_Trips;

CREATE TABLE Clean_Fleet_Trips AS
SELECT DISTINCT
    Trip_ID,
    Trip_Date,
    Driver_Name,
    Truck_Plate,
    UPPER(TRIM(Origin_City)) AS Clean_Origin_City,
    UPPER(TRIM(Destination_City)) AS Clean_Destination_City,
    Distance_KM,
    Fuel_Liters_Used,
    Fuel_Cost_Naira,
    COALESCE(Maintenance_Cost_Naira, 0) AS Clean_Maintenance_Naira,
    Trip_Revenue_Naira,
    (Trip_Revenue_Naira - Fuel_Cost_Naira - COALESCE(Maintenance_Cost_Naira, 0)) AS Net_Trip_Profit_Naira,
    Delivery_Status
FROM Raw_Fleet_Logs;

SELECT 
    Driver_Name,
    Truck_Plate,
    COUNT(Trip_ID) AS Total_Clean_Trips,
    SUM(Distance_KM) AS Total_Distance_KM,
    SUM(Fuel_Liters_Used) AS Total_Fuel_Liters,
    ROUND(SUM(Distance_KM) / SUM(Fuel_Liters_Used), 2) AS KM_Per_Liter_Efficiency,
    SUM(Net_Trip_Profit_Naira) AS Total_Net_Profit_Naira
FROM Clean_Fleet_Trips
GROUP BY Driver_Name, Truck_Plate
ORDER BY KM_Per_Liter_Efficiency ASC;

