/*
  This script performs various quality checks for data consistency, accuracy
  and standardization across the silver schemas. It includes cecks for:
  - Null or duplicate primary keys
  - Unwanted spaces in string fields
  - Data standardizatin and consistency
  - Invalid date ranges and orders
  - Data consistency between related fields

  Usage Notes:
    - Run these checks after data loading silver layer
    - Investigate and resolve any discrepancies found during the checks.
*/

-- Check for Nulls or Duplicated in the PK
SELECT 
	'Total Column Count' AS title,
	COUNT(*) AS count
FROM silver.crm_cust_info

UNION ALL

SELECT 
	'Total Unique cst_id Count',
	COUNT(DISTINCT cst_id)
FROM silver.crm_cust_info;

-- See PK's that aren't unique

SELECT *
FROM silver.crm_cust_info
WHERE cst_id IN (
	SELECT 
		cst_id
	FROM silver.crm_cust_info
	GROUP BY cst_id
	HAVING COUNT(*) > 1
)

UNION ALL

SELECT *
FROM silver.crm_cust_info
WHERE cst_id IS NULL;

-- Check for unwanted spaces

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE DATALENGTH(TRIM(cst_lastname)) != DATALENGTH(cst_lastname);

-- Data Standardizaton and Consistency

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

-- ==================================================================
-- crm_prd_info
-- ==================================================================

SELECT TOP 100 *
FROM silver.crm_prd_info;

-- Check for duplicate keys: - prd_id

SELECT COUNT(DISTINCT prd_id)
FROM silver.crm_prd_info;

SELECT COUNT(*)
FROM silver.crm_prd_info;

-- Check for NULL PK's

SELECT prd_id
FROM silver.crm_prd_info
WHERE prd_id IS NULL

-- Check for uneccessary spaces

SELECT prd_nm
FROM silver.crm_prd_info
WHERE DATALENGTH(TRIM(prd_nm)) != DATALENGTH(prd_nm);

-- Data Starndardization & Consistency

SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- Invalid Date Orders

SELECT 
	*,
	DATEADD(day, -1, LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)) AS new_end_dt
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt;

-- ======================================================
-- erp_cust_az12
-- ======================================================

-- Check for Primary key existence as foreign key

SELECT *
FROM silver.erp_cust_az12
WHERE cid NOT IN (
	SELECT DISTINCT cst_key
	FROM silver.crm_cust_info
);

SELECT *
FROM (
	SELECT 
		CASE 
			WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
			ELSE cid
		END AS cid
	FROM silver.erp_cust_az12
) AS t
WHERE cid NOT IN (
	SELECT DISTINCT cst_key
	FROM silver.crm_cust_info
);

-- Data Starndardization & Consistency

SELECT DISTINCT gen
FROM silver.erp_cust_az12;

-- ======================================================
-- erp_loc_a101
-- ======================================================

SELECT TOP 100 *
FROM silver.erp_loc_a101;

-- Check for joins

SELECT cid
FROM silver.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (
	SELECT DISTINCT cst_key
	FROM silver.crm_cust_info
);

-- Data Standardization & Consistency

SELECT DISTINCT cntry 
FROM silver.erp_loc_a101
