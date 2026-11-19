/*
Read-only issue queries. Run only after a reviewed test load has created Silver.
No data is changed. Returned rows need review, not automatic correction.
SQL Server execution has not been validated for this repository refresh.
*/
USE [DataWarehouse];
GO

-- Duplicate or missing customer IDs.
SELECT cst_id, COUNT_BIG(*) AS row_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING cst_id IS NULL OR COUNT_BIG(*) > 1;
GO

-- Missing required product keys or invalid product intervals.
SELECT prd_id, prd_key, prd_start_dt, prd_end_dt
FROM silver.crm_prd_info
WHERE prd_key IS NULL OR LTRIM(RTRIM(prd_key)) = N''
   OR (prd_end_dt IS NOT NULL AND prd_start_dt > prd_end_dt);
GO

-- Sales rows whose customer key does not resolve.
SELECT s.sls_ord_num, s.sls_cust_id
FROM silver.crm_sales_details AS s
WHERE NOT EXISTS (
    SELECT 1 FROM silver.crm_cust_info AS c WHERE c.cst_id = s.sls_cust_id
);
GO

-- Sales rows whose product key does not resolve to any product record.
-- This is not a time-valid historical dimension join.
SELECT s.sls_ord_num, s.sls_prd_key
FROM silver.crm_sales_details AS s
WHERE NOT EXISTS (
    SELECT 1 FROM silver.crm_prd_info AS p WHERE p.prd_key = s.sls_prd_key
);
GO

-- Candidate quantity/date issues. Confirm the business rule before rejecting.
SELECT sls_ord_num, sls_quantity, sls_order_dt, sls_ship_dt, sls_due_dt
FROM silver.crm_sales_details
WHERE sls_quantity IS NULL OR sls_quantity <= 0
   OR sls_order_dt IS NULL
   OR sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;
GO

-- Arithmetic disagreement without integer multiplication overflow.
SELECT sls_ord_num, sls_sales, sls_quantity, sls_price
FROM silver.crm_sales_details
WHERE sls_sales IS NULL OR sls_price IS NULL
   OR CAST(sls_sales AS decimal(28, 4)) <>
      CAST(sls_quantity AS decimal(18, 4)) * CAST(sls_price AS decimal(18, 4));
GO
