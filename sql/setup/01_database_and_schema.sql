-- ============================================================================
-- Mountain America Credit Union Intelligence Agent & Feature Store
-- Database and Schema Setup
-- ============================================================================
-- Purpose: Initialize the database, schemas, and warehouse for the MACU
--          Intelligence Agent solution with Feature Store capabilities
-- ============================================================================

-- Create the database
CREATE DATABASE IF NOT EXISTS MACU_INTELLIGENCE;

-- Use the database
USE DATABASE MACU_INTELLIGENCE;

-- Create schemas
CREATE SCHEMA IF NOT EXISTS RAW COMMENT = 'Raw credit union data tables';
CREATE SCHEMA IF NOT EXISTS FEATURE_STORE COMMENT = 'Feature engineering and ML features';
CREATE SCHEMA IF NOT EXISTS ANALYTICS COMMENT = 'Analytical views and semantic models';

-- Create a virtual warehouse for query processing
CREATE OR REPLACE WAREHOUSE MACU_WH WITH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for MACU Intelligence Agent queries';

-- Create a larger warehouse for feature engineering and ML workloads
CREATE OR REPLACE WAREHOUSE MACU_FEATURE_WH WITH
    WAREHOUSE_SIZE = 'SMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for feature engineering and ML workloads';

-- Set the warehouse as active
USE WAREHOUSE MACU_WH;

-- Display confirmation
SELECT 'Database, schemas, and warehouses setup completed successfully' AS STATUS;
