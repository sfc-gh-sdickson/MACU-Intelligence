-- ============================================================================
-- Mountain America Credit Union - Feature Store Infrastructure
-- ============================================================================
-- Purpose: Create the infrastructure for online feature store including
--          entity tables, feature registry, and spine tables
-- ============================================================================

USE DATABASE MACU_INTELLIGENCE;
USE SCHEMA FEATURE_STORE;
USE WAREHOUSE MACU_FEATURE_WH;

-- ============================================================================
-- Section 1: Entity Tables - Define the core business entities
-- ============================================================================

-- Member Entity: Core entity for member-level features
CREATE OR REPLACE TABLE ENTITY_MEMBER (
    member_id VARCHAR(20) PRIMARY KEY,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'Member entity table for feature store';

-- Account Entity: For account-level features
CREATE OR REPLACE TABLE ENTITY_ACCOUNT (
    account_id VARCHAR(20) PRIMARY KEY,
    member_id VARCHAR(20) NOT NULL,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'Account entity table for feature store';

-- Loan Entity: For loan-level features
CREATE OR REPLACE TABLE ENTITY_LOAN (
    loan_id VARCHAR(20) PRIMARY KEY,
    member_id VARCHAR(20) NOT NULL,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'Loan entity table for feature store';

-- Transaction Entity: For transaction-level features
CREATE OR REPLACE TABLE ENTITY_TRANSACTION (
    transaction_id VARCHAR(30) PRIMARY KEY,
    member_id VARCHAR(20) NOT NULL,
    account_id VARCHAR(20) NOT NULL,
    transaction_timestamp TIMESTAMP_NTZ NOT NULL,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'Transaction entity table for feature store';

-- ============================================================================
-- Section 2: Feature Registry - Track all features and their metadata
-- ============================================================================

CREATE OR REPLACE TABLE FEATURE_REGISTRY (
    feature_id VARCHAR(50) PRIMARY KEY,
    feature_name VARCHAR(100) NOT NULL,
    feature_group VARCHAR(50) NOT NULL,
    entity_type VARCHAR(30) NOT NULL,
    description VARCHAR(1000),
    data_type VARCHAR(30),
    computation_type VARCHAR(30),
    window_size VARCHAR(30),
    aggregation_function VARCHAR(30),
    source_tables ARRAY,
    is_real_time BOOLEAN DEFAULT FALSE,
    refresh_frequency VARCHAR(30),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    created_by VARCHAR(100),
    version INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    tags ARRAY
) COMMENT = 'Registry of all features in the feature store';

-- ============================================================================
-- Section 3: Feature Groups - Logical grouping of related features
-- ============================================================================

CREATE OR REPLACE TABLE FEATURE_GROUPS (
    group_id VARCHAR(50) PRIMARY KEY,
    group_name VARCHAR(100) NOT NULL,
    description VARCHAR(1000),
    entity_type VARCHAR(30) NOT NULL,
    owner VARCHAR(100),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    tags ARRAY
) COMMENT = 'Logical grouping of related features';

-- ============================================================================
-- Section 4: Feature Store Metadata Tables
-- ============================================================================

-- Feature Computation Log: Track feature computation history
CREATE OR REPLACE TABLE FEATURE_COMPUTATION_LOG (
    computation_id VARCHAR(36) PRIMARY KEY,
    feature_group VARCHAR(50),
    computation_start TIMESTAMP_NTZ,
    computation_end TIMESTAMP_NTZ,
    status VARCHAR(20),
    rows_processed INTEGER,
    error_message VARCHAR(2000),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'Log of feature computation jobs';

-- Feature Store Health: Monitor feature freshness and quality
CREATE OR REPLACE TABLE FEATURE_STORE_HEALTH (
    health_check_id VARCHAR(36) PRIMARY KEY,
    feature_group VARCHAR(50),
    check_timestamp TIMESTAMP_NTZ,
    last_refresh TIMESTAMP_NTZ,
    rows_count INTEGER,
    null_percentage DECIMAL(5, 2),
    staleness_minutes INTEGER,
    is_healthy BOOLEAN,
    health_score DECIMAL(5, 2),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'Feature store health monitoring';

-- ============================================================================
-- Section 5: Insert Initial Feature Group Definitions
-- ============================================================================

INSERT INTO FEATURE_GROUPS (group_id, group_name, description, entity_type, owner, tags)
SELECT 'MEMBER_PROFILE', 'Member Profile Features', 'Demographic and account ownership features', 'MEMBER', 'Data Science Team', ARRAY_CONSTRUCT('profile', 'demographic')
UNION ALL SELECT 'TRANSACTION_PATTERNS', 'Transaction Pattern Features', 'Features derived from transaction behavior', 'MEMBER', 'Data Science Team', ARRAY_CONSTRUCT('transactions', 'behavior')
UNION ALL SELECT 'LOAN_RISK', 'Loan Risk Features', 'Features for loan risk assessment', 'MEMBER', 'Risk Team', ARRAY_CONSTRUCT('risk', 'loans', 'credit')
UNION ALL SELECT 'FRAUD_DETECTION', 'Fraud Detection Features', 'Features for fraud and anomaly detection', 'TRANSACTION', 'Fraud Team', ARRAY_CONSTRUCT('fraud', 'security')
UNION ALL SELECT 'MEMBER_ENGAGEMENT', 'Member Engagement Features', 'Features measuring member engagement and activity', 'MEMBER', 'Marketing Team', ARRAY_CONSTRUCT('engagement', 'activity')
UNION ALL SELECT 'CREDIT_UTILIZATION', 'Credit Utilization Features', 'Features related to credit product usage', 'MEMBER', 'Risk Team', ARRAY_CONSTRUCT('credit', 'utilization');

-- ============================================================================
-- Section 6: Insert Feature Registry Entries
-- ============================================================================

INSERT INTO FEATURE_REGISTRY (feature_id, feature_name, feature_group, entity_type, description, data_type, computation_type, window_size, aggregation_function, source_tables, is_real_time, refresh_frequency, tags)
SELECT 'mem_tenure_days', 'Member Tenure Days', 'MEMBER_PROFILE', 'MEMBER', 'Days since member joined', 'INTEGER', 'DERIVED', NULL, NULL, ARRAY_CONSTRUCT('MEMBERS'), FALSE, 'DAILY', ARRAY_CONSTRUCT('profile')
UNION ALL SELECT 'mem_num_accounts', 'Number of Accounts', 'MEMBER_PROFILE', 'MEMBER', 'Total number of accounts held', 'INTEGER', 'AGGREGATE', NULL, 'COUNT', ARRAY_CONSTRUCT('ACCOUNTS'), FALSE, 'DAILY', ARRAY_CONSTRUCT('profile')
UNION ALL SELECT 'mem_total_balance', 'Total Balance', 'MEMBER_PROFILE', 'MEMBER', 'Sum of all account balances', 'DECIMAL', 'AGGREGATE', NULL, 'SUM', ARRAY_CONSTRUCT('ACCOUNTS'), FALSE, 'HOURLY', ARRAY_CONSTRUCT('balance')
UNION ALL SELECT 'txn_count_7d', 'Transaction Count 7 Days', 'TRANSACTION_PATTERNS', 'MEMBER', 'Number of transactions in last 7 days', 'INTEGER', 'AGGREGATE', '7_DAYS', 'COUNT', ARRAY_CONSTRUCT('TRANSACTIONS'), FALSE, 'HOURLY', ARRAY_CONSTRUCT('transactions')
UNION ALL SELECT 'txn_volume_7d', 'Transaction Volume 7 Days', 'TRANSACTION_PATTERNS', 'MEMBER', 'Total transaction amount in last 7 days', 'DECIMAL', 'AGGREGATE', '7_DAYS', 'SUM', ARRAY_CONSTRUCT('TRANSACTIONS'), FALSE, 'HOURLY', ARRAY_CONSTRUCT('transactions')
UNION ALL SELECT 'txn_avg_amount', 'Average Transaction Amount', 'TRANSACTION_PATTERNS', 'MEMBER', 'Average transaction amount', 'DECIMAL', 'AGGREGATE', '30_DAYS', 'AVG', ARRAY_CONSTRUCT('TRANSACTIONS'), FALSE, 'DAILY', ARRAY_CONSTRUCT('transactions')
UNION ALL SELECT 'loan_total_balance', 'Total Loan Balance', 'LOAN_RISK', 'MEMBER', 'Sum of all outstanding loan balances', 'DECIMAL', 'AGGREGATE', NULL, 'SUM', ARRAY_CONSTRUCT('LOANS'), FALSE, 'DAILY', ARRAY_CONSTRUCT('loans', 'risk')
UNION ALL SELECT 'loan_num_active', 'Number of Active Loans', 'LOAN_RISK', 'MEMBER', 'Count of active loans', 'INTEGER', 'AGGREGATE', NULL, 'COUNT', ARRAY_CONSTRUCT('LOANS'), FALSE, 'DAILY', ARRAY_CONSTRUCT('loans')
UNION ALL SELECT 'loan_dti_ratio', 'Debt to Income Ratio', 'LOAN_RISK', 'MEMBER', 'Monthly debt payments vs income', 'DECIMAL', 'DERIVED', NULL, NULL, ARRAY_CONSTRUCT('LOANS', 'MEMBERS'), FALSE, 'DAILY', ARRAY_CONSTRUCT('risk', 'credit')
UNION ALL SELECT 'fraud_txn_velocity_1h', 'Transaction Velocity 1 Hour', 'FRAUD_DETECTION', 'MEMBER', 'Number of transactions in last hour', 'INTEGER', 'AGGREGATE', '1_HOUR', 'COUNT', ARRAY_CONSTRUCT('TRANSACTIONS'), TRUE, 'REAL_TIME', ARRAY_CONSTRUCT('fraud', 'velocity')
UNION ALL SELECT 'fraud_amount_deviation', 'Amount Deviation Score', 'FRAUD_DETECTION', 'TRANSACTION', 'Standard deviations from typical amount', 'DECIMAL', 'DERIVED', '30_DAYS', NULL, ARRAY_CONSTRUCT('TRANSACTIONS'), TRUE, 'REAL_TIME', ARRAY_CONSTRUCT('fraud', 'anomaly')
UNION ALL SELECT 'fraud_new_merchant_flag', 'New Merchant Flag', 'FRAUD_DETECTION', 'TRANSACTION', 'Transaction at never-before-seen merchant', 'BOOLEAN', 'DERIVED', NULL, NULL, ARRAY_CONSTRUCT('TRANSACTIONS'), TRUE, 'REAL_TIME', ARRAY_CONSTRUCT('fraud')
UNION ALL SELECT 'engage_login_count_30d', 'Login Count 30 Days', 'MEMBER_ENGAGEMENT', 'MEMBER', 'Number of digital banking logins', 'INTEGER', 'AGGREGATE', '30_DAYS', 'COUNT', ARRAY_CONSTRUCT('DEVICE_SESSIONS'), FALSE, 'DAILY', ARRAY_CONSTRUCT('engagement')
UNION ALL SELECT 'engage_mobile_pct', 'Mobile Usage Percentage', 'MEMBER_ENGAGEMENT', 'MEMBER', 'Percentage of logins via mobile app', 'DECIMAL', 'DERIVED', '30_DAYS', NULL, ARRAY_CONSTRUCT('DEVICE_SESSIONS'), FALSE, 'DAILY', ARRAY_CONSTRUCT('engagement', 'mobile')
UNION ALL SELECT 'engage_support_contacts', 'Support Contact Count', 'MEMBER_ENGAGEMENT', 'MEMBER', 'Number of support interactions', 'INTEGER', 'AGGREGATE', '90_DAYS', 'COUNT', ARRAY_CONSTRUCT('SUPPORT_INTERACTIONS'), FALSE, 'DAILY', ARRAY_CONSTRUCT('engagement', 'support');

-- Display confirmation
SELECT 'Feature Store infrastructure created successfully' AS STATUS;
