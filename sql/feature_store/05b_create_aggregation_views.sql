-- ============================================================================
-- Mountain America Credit Union - Intermediate Aggregation Views
-- ============================================================================
-- Purpose: Create views to pre-aggregate data for Feature Store.
-- This is required because Dynamic Tables have limitations with GROUP BY.
-- ============================================================================

USE DATABASE MACU_INTELLIGENCE;
USE SCHEMA FEATURE_STORE;
USE WAREHOUSE MACU_FEATURE_WH;

-- Member Profile Aggregations
CREATE OR REPLACE VIEW V_MEMBER_PROFILE_AGGS AS
SELECT
    m.member_id,
    COUNT(DISTINCT a.account_id) as num_accounts
FROM MACU_INTELLIGENCE.RAW.MEMBERS m
LEFT JOIN MACU_INTELLIGENCE.RAW.ACCOUNTS a ON m.member_id = a.member_id
GROUP BY m.member_id;

-- Transaction Pattern Aggregations
CREATE OR REPLACE VIEW V_TRANSACTION_PATTERN_AGGS AS
SELECT
    member_id,
    COUNT(CASE WHEN transaction_date >= DATEADD('day', -7, CURRENT_DATE()) THEN 1 END) as txn_count_7d,
    SUM(CASE WHEN transaction_date >= DATEADD('day', -7, CURRENT_DATE()) THEN ABS(amount) END) as txn_volume_7d,
    COUNT(CASE WHEN transaction_timestamp >= DATEADD('hour', -1, CURRENT_TIMESTAMP()) THEN 1 END) as txn_count_1h
FROM MACU_INTELLIGENCE.RAW.TRANSACTIONS
WHERE status = 'COMPLETED'
GROUP BY member_id;

-- Loan Risk Aggregations
CREATE OR REPLACE VIEW V_LOAN_RISK_AGGS AS
SELECT
    m.member_id,
    COUNT(l.loan_id) as total_loans_taken,
    AVG(l.original_amount) as avg_loan_amount,
    COUNT(CASE WHEN l.loan_status = 'DELINQUENT' THEN 1 END) as num_delinquent,
    SUM(l.current_balance) as total_loan_balance
FROM MACU_INTELLIGENCE.RAW.MEMBERS m
LEFT JOIN MACU_INTELLIGENCE.RAW.LOANS l ON m.member_id = l.member_id
GROUP BY m.member_id;

-- Fraud Detection Aggregations
CREATE OR REPLACE VIEW V_FRAUD_DETECTION_AGGS AS
WITH recent_transactions AS (
    SELECT 
        t.*,
        LAG(transaction_timestamp) OVER (PARTITION BY member_id ORDER BY transaction_timestamp) as prev_txn_time,
        LAG(merchant_city) OVER (PARTITION BY member_id ORDER BY transaction_timestamp) as prev_merchant_city
    FROM MACU_INTELLIGENCE.RAW.TRANSACTIONS t
    WHERE transaction_timestamp >= DATEADD('day', -7, CURRENT_TIMESTAMP()) AND status = 'COMPLETED'
)
SELECT
    t.member_id,
    MAX(CASE WHEN ABS(t.amount) > avg_txn.avg_amount * 3 AND ABS(t.amount) > 100 THEN 1 ELSE 0 END) as has_unusual_amount,
    MAX(CASE WHEN DATEDIFF('minute', t.prev_txn_time, t.transaction_timestamp) < 5 AND t.merchant_city != t.prev_merchant_city THEN 1 ELSE 0 END) as impossible_travel_flag
FROM recent_transactions t
LEFT JOIN (
    SELECT member_id, AVG(ABS(amount)) as avg_amount
    FROM MACU_INTELLIGENCE.RAW.TRANSACTIONS
    WHERE transaction_date >= DATEADD('day', -30, CURRENT_DATE())
    GROUP BY member_id
) avg_txn ON t.member_id = avg_txn.member_id
GROUP BY t.member_id;
