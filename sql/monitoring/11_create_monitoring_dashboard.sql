-- ============================================================================
-- Mountain America Credit Union - Monitoring Dashboard Views
-- ============================================================================
-- Purpose: Create views for operational monitoring including feature store
--          health, model performance, and system metrics
-- ============================================================================

USE DATABASE MACU_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE MACU_WH;

-- ============================================================================
-- View 1: Feature Store Health Dashboard
-- ============================================================================
CREATE OR REPLACE VIEW V_FEATURE_STORE_DASHBOARD AS
SELECT
    feature_group,
    MAX(check_timestamp) AS last_check,
    MAX(last_refresh) AS last_refresh,
    AVG(rows_count) AS avg_row_count,
    AVG(null_percentage) AS avg_null_pct,
    AVG(staleness_minutes) AS avg_staleness_min,
    SUM(CASE WHEN is_healthy THEN 1 ELSE 0 END) / COUNT(*) * 100 AS health_pct,
    AVG(health_score) AS avg_health_score
FROM MACU_INTELLIGENCE.FEATURE_STORE.FEATURE_STORE_HEALTH
WHERE check_timestamp >= DATEADD('day', -7, CURRENT_TIMESTAMP())
GROUP BY feature_group;

-- ============================================================================
-- View 2: Feature Computation History
-- ============================================================================
CREATE OR REPLACE VIEW V_FEATURE_COMPUTATION_HISTORY AS
SELECT
    DATE_TRUNC('hour', computation_start) AS computation_hour,
    feature_group,
    COUNT(*) AS total_runs,
    SUM(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END) AS successful_runs,
    SUM(CASE WHEN status = 'FAILED' THEN 1 ELSE 0 END) AS failed_runs,
    AVG(DATEDIFF('second', computation_start, computation_end)) AS avg_duration_sec,
    SUM(rows_processed) AS total_rows_processed
FROM MACU_INTELLIGENCE.FEATURE_STORE.FEATURE_COMPUTATION_LOG
WHERE computation_start >= DATEADD('day', -7, CURRENT_TIMESTAMP())
GROUP BY DATE_TRUNC('hour', computation_start), feature_group
ORDER BY computation_hour DESC;

-- ============================================================================
-- View 3: Loan Portfolio Risk Dashboard
-- ============================================================================
CREATE OR REPLACE VIEW V_LOAN_RISK_DASHBOARD AS
SELECT
    loan_type,
    COUNT(*) AS total_loans,
    SUM(current_balance) AS total_balance,
    AVG(interest_rate) AS avg_rate,
    SUM(CASE WHEN days_past_due = 0 THEN 1 ELSE 0 END) AS current_loans,
    SUM(CASE WHEN days_past_due > 0 AND days_past_due < 30 THEN 1 ELSE 0 END) AS late_loans,
    SUM(CASE WHEN days_past_due >= 30 AND days_past_due < 60 THEN 1 ELSE 0 END) AS dpd_30_loans,
    SUM(CASE WHEN days_past_due >= 60 AND days_past_due < 90 THEN 1 ELSE 0 END) AS dpd_60_loans,
    SUM(CASE WHEN days_past_due >= 90 THEN 1 ELSE 0 END) AS dpd_90_plus_loans,
    SUM(CASE WHEN days_past_due >= 30 THEN current_balance ELSE 0 END) AS delinquent_balance,
    ROUND(SUM(CASE WHEN days_past_due >= 30 THEN current_balance ELSE 0 END) / NULLIF(SUM(current_balance), 0) * 100, 2) AS delinquency_rate_pct
FROM MACU_INTELLIGENCE.RAW.LOANS
WHERE loan_status = 'ACTIVE'
GROUP BY loan_type
ORDER BY total_balance DESC;

-- ============================================================================
-- View 4: Daily Transaction Metrics
-- ============================================================================
CREATE OR REPLACE VIEW V_DAILY_TRANSACTION_METRICS AS
SELECT
    transaction_date,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT member_id) AS unique_members,
    SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END) AS total_credits,
    SUM(CASE WHEN amount < 0 THEN ABS(amount) ELSE 0 END) AS total_debits,
    SUM(ABS(amount)) AS total_volume,
    AVG(ABS(amount)) AS avg_transaction_amount,
    SUM(CASE WHEN status = 'DECLINED' THEN 1 ELSE 0 END) AS declined_transactions,
    SUM(CASE WHEN fraud_score > 0.5 THEN 1 ELSE 0 END) AS high_fraud_score_txns,
    SUM(CASE WHEN is_international THEN 1 ELSE 0 END) AS international_transactions
FROM MACU_INTELLIGENCE.RAW.TRANSACTIONS
WHERE transaction_date >= DATEADD('day', -30, CURRENT_DATE())
GROUP BY transaction_date
ORDER BY transaction_date DESC;

-- ============================================================================
-- View 5: Support Metrics Dashboard
-- ============================================================================
CREATE OR REPLACE VIEW V_SUPPORT_METRICS_DASHBOARD AS
SELECT
    DATE_TRUNC('day', interaction_date) AS interaction_day,
    interaction_type,
    COUNT(*) AS total_interactions,
    AVG(duration_seconds) / 60.0 AS avg_duration_min,
    SUM(CASE WHEN resolution_achieved THEN 1 ELSE 0 END) / COUNT(*) * 100 AS resolution_rate_pct,
    SUM(CASE WHEN first_contact_resolution THEN 1 ELSE 0 END) / COUNT(*) * 100 AS fcr_rate_pct,
    AVG(satisfaction_score) AS avg_csat,
    AVG(nps_score) AS avg_nps,
    SUM(CASE WHEN escalated THEN 1 ELSE 0 END) AS escalated_count
FROM MACU_INTELLIGENCE.RAW.SUPPORT_INTERACTIONS
WHERE interaction_date >= DATEADD('day', -30, CURRENT_DATE())
GROUP BY DATE_TRUNC('day', interaction_date), interaction_type
ORDER BY interaction_day DESC, interaction_type;

-- ============================================================================
-- View 6: Member Growth Dashboard
-- ============================================================================
CREATE OR REPLACE VIEW V_MEMBER_GROWTH_DASHBOARD AS
SELECT
    DATE_TRUNC('month', membership_date) AS membership_month,
    COUNT(*) AS new_members,
    SUM(CASE WHEN acquisition_channel = 'BRANCH' THEN 1 ELSE 0 END) AS branch_acquired,
    SUM(CASE WHEN acquisition_channel = 'ONLINE' THEN 1 ELSE 0 END) AS online_acquired,
    SUM(CASE WHEN acquisition_channel = 'MOBILE' THEN 1 ELSE 0 END) AS mobile_acquired,
    SUM(CASE WHEN acquisition_channel = 'REFERRAL' THEN 1 ELSE 0 END) AS referral_acquired,
    SUM(CASE WHEN acquisition_channel = 'EMPLOYER' THEN 1 ELSE 0 END) AS employer_acquired,
    SUM(CASE WHEN digital_banking_enrolled THEN 1 ELSE 0 END) AS digital_enrolled,
    AVG(credit_score) AS avg_credit_score
FROM MACU_INTELLIGENCE.RAW.MEMBERS
WHERE membership_date >= DATEADD('year', -2, CURRENT_DATE())
GROUP BY DATE_TRUNC('month', membership_date)
ORDER BY membership_month DESC;

-- ============================================================================
-- View 7: Branch Performance Dashboard
-- ============================================================================
CREATE OR REPLACE VIEW V_BRANCH_PERFORMANCE AS
SELECT
    b.branch_id,
    b.branch_name,
    b.region,
    COUNT(DISTINCT m.member_id) AS total_members,
    SUM(a.current_balance) AS total_deposits,
    COUNT(DISTINCT l.loan_id) AS active_loans,
    SUM(l.current_balance) AS loan_portfolio_balance,
    AVG(si.satisfaction_score) AS avg_satisfaction,
    COUNT(si.interaction_id) AS support_volume_90d
FROM MACU_INTELLIGENCE.RAW.BRANCHES b
LEFT JOIN MACU_INTELLIGENCE.RAW.MEMBERS m ON b.branch_id = m.primary_branch_id AND m.member_status = 'ACTIVE'
LEFT JOIN MACU_INTELLIGENCE.RAW.ACCOUNTS a ON m.member_id = a.member_id AND a.account_status = 'ACTIVE' AND a.account_type NOT IN ('CREDIT_CARD')
LEFT JOIN MACU_INTELLIGENCE.RAW.LOANS l ON m.member_id = l.member_id AND l.loan_status = 'ACTIVE'
LEFT JOIN MACU_INTELLIGENCE.RAW.SUPPORT_INTERACTIONS si ON b.branch_id = si.branch_id AND si.interaction_date >= DATEADD('day', -90, CURRENT_DATE())
WHERE b.status = 'ACTIVE'
GROUP BY b.branch_id, b.branch_name, b.region
ORDER BY total_deposits DESC;

-- ============================================================================
-- View 8: Credit Card Portfolio Dashboard
-- ============================================================================
CREATE OR REPLACE VIEW V_CREDIT_CARD_DASHBOARD AS
SELECT
    a.account_subtype AS card_type,
    COUNT(DISTINCT a.account_id) AS total_cards,
    SUM(ABS(a.current_balance)) AS total_balance,
    SUM(a.credit_limit) AS total_credit_limit,
    ROUND(SUM(ABS(a.current_balance)) / NULLIF(SUM(a.credit_limit), 0) * 100, 2) AS portfolio_utilization_pct,
    AVG(ABS(a.current_balance)) AS avg_balance,
    AVG(a.credit_limit) AS avg_credit_limit,
    COUNT(CASE WHEN ABS(a.current_balance) / NULLIF(a.credit_limit, 0) > 0.9 THEN 1 END) AS high_utilization_count,
    SUM(c.rewards_points_balance) AS total_rewards_points
FROM MACU_INTELLIGENCE.RAW.ACCOUNTS a
JOIN MACU_INTELLIGENCE.RAW.CARDS c ON a.account_id = c.account_id
WHERE a.account_type = 'CREDIT_CARD' AND a.account_status = 'ACTIVE'
GROUP BY a.account_subtype;

-- Display confirmation
SELECT 'Monitoring dashboard views created successfully' AS STATUS, 8 AS views_created;
