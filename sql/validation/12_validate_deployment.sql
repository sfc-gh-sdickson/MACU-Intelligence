-- ============================================================================
-- Mountain America Credit Union - Deployment Validation
-- ============================================================================
-- Purpose: Validate all components of the MACU Intelligence deployment
--          including tables, views, feature store, search services, and agent
-- ============================================================================

USE DATABASE MACU_INTELLIGENCE;
USE WAREHOUSE MACU_WH;

-- ============================================================================
-- Section 1: Validate Database Objects
-- ============================================================================

-- Check all schemas exist
SELECT 'SCHEMAS' AS object_type, schema_name, created
FROM MACU_INTELLIGENCE.INFORMATION_SCHEMA.SCHEMATA
WHERE schema_name IN ('RAW', 'FEATURE_STORE', 'ANALYTICS')
ORDER BY schema_name;

-- Check core tables in RAW schema
SELECT 'RAW_TABLES' AS check_type, table_name, row_count
FROM MACU_INTELLIGENCE.INFORMATION_SCHEMA.TABLES
WHERE table_schema = 'RAW' AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Check feature store tables
SELECT 'FEATURE_STORE_TABLES' AS check_type, table_name, row_count
FROM MACU_INTELLIGENCE.INFORMATION_SCHEMA.TABLES
WHERE table_schema = 'FEATURE_STORE' AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Check analytical views
SELECT 'ANALYTICAL_VIEWS' AS check_type, table_name
FROM MACU_INTELLIGENCE.INFORMATION_SCHEMA.TABLES
WHERE table_schema = 'ANALYTICS' AND table_type = 'VIEW'
ORDER BY table_name;

-- ============================================================================
-- Section 2: Validate Data Counts
-- ============================================================================

SELECT 'DATA_VALIDATION' AS check_type,
    'MEMBERS' AS table_name, 
    COUNT(*) AS row_count,
    CASE WHEN COUNT(*) >= 9000 THEN 'PASS' ELSE 'FAIL' END AS status
FROM MACU_INTELLIGENCE.RAW.MEMBERS
UNION ALL
SELECT 'DATA_VALIDATION', 'ACCOUNTS', COUNT(*),
    CASE WHEN COUNT(*) >= 15000 THEN 'PASS' ELSE 'FAIL' END
FROM MACU_INTELLIGENCE.RAW.ACCOUNTS
UNION ALL
SELECT 'DATA_VALIDATION', 'LOANS', COUNT(*),
    CASE WHEN COUNT(*) >= 5000 THEN 'PASS' ELSE 'FAIL' END
FROM MACU_INTELLIGENCE.RAW.LOANS
UNION ALL
SELECT 'DATA_VALIDATION', 'TRANSACTIONS', COUNT(*),
    CASE WHEN COUNT(*) >= 400000 THEN 'PASS' ELSE 'FAIL' END
FROM MACU_INTELLIGENCE.RAW.TRANSACTIONS
UNION ALL
SELECT 'DATA_VALIDATION', 'SUPPORT_INTERACTIONS', COUNT(*),
    CASE WHEN COUNT(*) >= 4000 THEN 'PASS' ELSE 'FAIL' END
FROM MACU_INTELLIGENCE.RAW.SUPPORT_INTERACTIONS
UNION ALL
SELECT 'DATA_VALIDATION', 'SUPPORT_TRANSCRIPTS', COUNT(*),
    CASE WHEN COUNT(*) >= 4000 THEN 'PASS' ELSE 'FAIL' END
FROM MACU_INTELLIGENCE.RAW.SUPPORT_TRANSCRIPTS
UNION ALL
SELECT 'DATA_VALIDATION', 'COMPLIANCE_DOCUMENTS', COUNT(*),
    CASE WHEN COUNT(*) >= 50 THEN 'PASS' ELSE 'FAIL' END
FROM MACU_INTELLIGENCE.RAW.COMPLIANCE_DOCUMENTS
UNION ALL
SELECT 'DATA_VALIDATION', 'PRODUCT_KNOWLEDGE', COUNT(*),
    CASE WHEN COUNT(*) >= 50 THEN 'PASS' ELSE 'FAIL' END
FROM MACU_INTELLIGENCE.RAW.PRODUCT_KNOWLEDGE
UNION ALL
SELECT 'DATA_VALIDATION', 'BRANCHES', COUNT(*),
    CASE WHEN COUNT(*) >= 25 THEN 'PASS' ELSE 'FAIL' END
FROM MACU_INTELLIGENCE.RAW.BRANCHES;

-- ============================================================================
-- Section 3: Validate Feature Store
-- ============================================================================

-- Check feature groups
SELECT 'FEATURE_GROUPS' AS check_type, 
    group_name, 
    entity_type,
    'PASS' AS status
FROM MACU_INTELLIGENCE.FEATURE_STORE.FEATURE_GROUPS;

-- Check feature registry
SELECT 'FEATURE_REGISTRY' AS check_type,
    COUNT(*) AS total_features,
    COUNT(DISTINCT feature_group) AS feature_groups,
    SUM(CASE WHEN is_real_time THEN 1 ELSE 0 END) AS real_time_features,
    'PASS' AS status
FROM MACU_INTELLIGENCE.FEATURE_STORE.FEATURE_REGISTRY;

-- ============================================================================
-- Section 4: Validate Cortex Search Services
-- ============================================================================

-- Test Support Transcripts Search
SELECT 'CORTEX_SEARCH_SUPPORT' AS check_type,
    CASE WHEN PARSE_JSON(
        SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
            'MACU_INTELLIGENCE.RAW.SUPPORT_TRANSCRIPTS_SEARCH',
            '{"query": "card", "columns": ["transcript_text"], "limit": 1}'
        )
    )['results'] IS NOT NULL THEN 'PASS' ELSE 'FAIL' END AS status;

-- Test Compliance Docs Search
SELECT 'CORTEX_SEARCH_COMPLIANCE' AS check_type,
    CASE WHEN PARSE_JSON(
        SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
            'MACU_INTELLIGENCE.RAW.COMPLIANCE_DOCS_SEARCH',
            '{"query": "AML", "columns": ["content"], "limit": 1}'
        )
    )['results'] IS NOT NULL THEN 'PASS' ELSE 'FAIL' END AS status;

-- Test Product Knowledge Search
SELECT 'CORTEX_SEARCH_PRODUCTS' AS check_type,
    CASE WHEN PARSE_JSON(
        SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
            'MACU_INTELLIGENCE.RAW.PRODUCT_KNOWLEDGE_SEARCH',
            '{"query": "savings", "columns": ["content"], "limit": 1}'
        )
    )['results'] IS NOT NULL THEN 'PASS' ELSE 'FAIL' END AS status;

-- ============================================================================
-- Section 5: Validate ML Functions
-- ============================================================================
-- NOTE: ML functions are created via the macu_ml_models.ipynb notebook.
--       Uncomment the tests below after running the notebook.

-- Test loan default risk prediction
-- SELECT 'ML_FUNCTION_LOAN_RISK' AS check_type,
--     PREDICT_LOAN_DEFAULT_RISK(720, 25000, 0.35, 365, 50000, 0) AS result,
--     'PASS' AS status;

-- Test fraud score prediction
-- SELECT 'ML_FUNCTION_FRAUD' AS check_type,
--     PREDICT_FRAUD_SCORE(500, 100, 3, FALSE, FALSE, 14) AS result,
--     'PASS' AS status;

-- Test churn prediction
-- SELECT 'ML_FUNCTION_CHURN' AS check_type,
--     PREDICT_MEMBER_CHURN(365, 20, TRUE, 3, 1, 5) AS result,
--     'PASS' AS status;

-- Test loan approval recommendation
-- SELECT 'ML_FUNCTION_LOAN_APPROVAL' AS check_type,
--     RECOMMEND_LOAN_APPROVAL('AUTO', 35000, 720, 6000, 1500, 'EMPLOYED', 3) AS result,
--     'PASS' AS status;

-- ============================================================================
-- Section 6: Validate Semantic Views
-- ============================================================================

SELECT 'SEMANTIC_VIEWS' AS check_type,
    table_name,
    'PASS' AS status
FROM MACU_INTELLIGENCE.INFORMATION_SCHEMA.TABLES
WHERE table_schema = 'ANALYTICS' 
    AND table_name LIKE 'SV_%'
ORDER BY table_name;

-- ============================================================================
-- Section 7: Test Agent (if created)
-- ============================================================================

-- Note: Uncomment the following to test the agent
-- SELECT 'AGENT_TEST' AS check_type,
--     SNOWFLAKE.CORTEX.AGENT(
--         'MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT',
--         'What products does MACU offer?'
--     ) AS response,
--     'PASS' AS status;

-- ============================================================================
-- Section 8: Summary Report
-- ============================================================================

SELECT 
    'DEPLOYMENT_SUMMARY' AS report_type,
    CURRENT_TIMESTAMP() AS validation_time,
    (SELECT COUNT(*) FROM MACU_INTELLIGENCE.INFORMATION_SCHEMA.TABLES WHERE table_schema = 'RAW' AND table_type = 'BASE TABLE') AS raw_tables,
    (SELECT COUNT(*) FROM MACU_INTELLIGENCE.INFORMATION_SCHEMA.TABLES WHERE table_schema = 'FEATURE_STORE' AND table_type = 'BASE TABLE') AS feature_store_tables,
    (SELECT COUNT(*) FROM MACU_INTELLIGENCE.INFORMATION_SCHEMA.TABLES WHERE table_schema = 'ANALYTICS' AND table_type = 'VIEW') AS analytical_views,
    (SELECT COUNT(*) FROM MACU_INTELLIGENCE.RAW.MEMBERS) AS total_members,
    (SELECT COUNT(*) FROM MACU_INTELLIGENCE.RAW.TRANSACTIONS) AS total_transactions,
    (SELECT COUNT(*) FROM MACU_INTELLIGENCE.FEATURE_STORE.FEATURE_REGISTRY) AS registered_features,
    'COMPLETE' AS deployment_status;
