-- ============================================================================
-- Mountain America Credit Union Intelligence Agent - Analytical Views
-- ============================================================================
-- Purpose: Create analytical views for business intelligence and agent queries
-- ============================================================================

USE DATABASE MACU_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE MACU_WH;

-- ============================================================================
-- View 1: Member 360 View - Comprehensive member profile
-- ============================================================================
CREATE OR REPLACE VIEW V_MEMBER_360 AS
SELECT
    m.member_id,
    m.first_name,
    m.last_name,
    m.first_name || ' ' || m.last_name AS full_name,
    m.email,
    m.phone,
    m.date_of_birth,
    DATEDIFF('year', m.date_of_birth, CURRENT_DATE()) AS age,
    m.city,
    m.address_state,
    m.zip_code,
    m.membership_date,
    DATEDIFF('day', m.membership_date, CURRENT_DATE()) AS tenure_days,
    DATEDIFF('year', m.membership_date, CURRENT_DATE()) AS tenure_years,
    m.member_status,
    m.membership_tier,
    m.kyc_status,
    m.risk_tier,
    m.credit_score,
    m.income_verified,
    m.employment_status,
    m.employer_name,
    m.acquisition_channel,
    m.primary_branch_id,
    m.digital_banking_enrolled,
    COALESCE(acct.total_accounts, 0) AS total_accounts,
    COALESCE(acct.total_deposit_balance, 0) AS total_deposit_balance,
    COALESCE(acct.total_credit_balance, 0) AS total_credit_balance,
    COALESCE(loan.active_loans, 0) AS active_loans,
    COALESCE(loan.total_loan_balance, 0) AS total_loan_balance,
    COALESCE(txn.txn_count_30d, 0) AS transactions_last_30_days,
    COALESCE(txn.txn_volume_30d, 0) AS transaction_volume_30_days
FROM MACU_INTELLIGENCE.RAW.MEMBERS m
LEFT JOIN (
    SELECT 
        member_id,
        COUNT(*) AS total_accounts,
        SUM(CASE WHEN account_type NOT IN ('CREDIT_CARD') THEN current_balance ELSE 0 END) AS total_deposit_balance,
        SUM(CASE WHEN account_type = 'CREDIT_CARD' THEN ABS(current_balance) ELSE 0 END) AS total_credit_balance
    FROM MACU_INTELLIGENCE.RAW.ACCOUNTS
    WHERE account_status = 'ACTIVE'
    GROUP BY member_id
) acct ON m.member_id = acct.member_id
LEFT JOIN (
    SELECT 
        member_id,
        COUNT(*) AS active_loans,
        SUM(current_balance) AS total_loan_balance
    FROM MACU_INTELLIGENCE.RAW.LOANS
    WHERE loan_status = 'ACTIVE'
    GROUP BY member_id
) loan ON m.member_id = loan.member_id
LEFT JOIN (
    SELECT 
        member_id,
        COUNT(*) AS txn_count_30d,
        SUM(ABS(amount)) AS txn_volume_30d
    FROM MACU_INTELLIGENCE.RAW.TRANSACTIONS
    WHERE transaction_date >= DATEADD('day', -30, CURRENT_DATE()) AND status = 'COMPLETED'
    GROUP BY member_id
) txn ON m.member_id = txn.member_id;

-- ============================================================================
-- View 2: Account Summary View
-- ============================================================================
CREATE OR REPLACE VIEW V_ACCOUNT_SUMMARY AS
SELECT
    a.account_id,
    a.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    a.account_type,
    a.account_subtype,
    a.account_status,
    a.account_name,
    a.current_balance,
    a.available_balance,
    a.credit_limit,
    CASE WHEN a.credit_limit > 0 
        THEN ROUND((ABS(a.current_balance) / a.credit_limit) * 100, 2) 
        ELSE NULL END AS utilization_pct,
    a.dividend_rate,
    a.apy_rate,
    a.term_months,
    a.maturity_date,
    a.opened_date,
    DATEDIFF('day', a.opened_date, CURRENT_DATE()) AS account_age_days,
    a.last_activity_date,
    DATEDIFF('day', a.last_activity_date, CURRENT_DATE()) AS days_since_activity,
    a.overdraft_protection,
    a.joint_account,
    COALESCE(txn.txn_count, 0) AS monthly_transactions,
    COALESCE(txn.txn_volume, 0) AS monthly_volume
FROM MACU_INTELLIGENCE.RAW.ACCOUNTS a
JOIN MACU_INTELLIGENCE.RAW.MEMBERS m ON a.member_id = m.member_id
LEFT JOIN (
    SELECT 
        account_id,
        COUNT(*) AS txn_count,
        SUM(ABS(amount)) AS txn_volume
    FROM MACU_INTELLIGENCE.RAW.TRANSACTIONS
    WHERE transaction_date >= DATEADD('day', -30, CURRENT_DATE())
    GROUP BY account_id
) txn ON a.account_id = txn.account_id;

-- ============================================================================
-- View 3: Loan Portfolio View
-- ============================================================================
CREATE OR REPLACE VIEW V_LOAN_PORTFOLIO AS
SELECT
    l.loan_id,
    l.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    m.credit_score AS current_credit_score,
    l.loan_type,
    l.loan_subtype,
    l.loan_status,
    l.original_amount,
    l.current_balance,
    l.original_amount - l.current_balance AS principal_paid,
    ROUND((l.original_amount - l.current_balance) / NULLIF(l.original_amount, 0) * 100, 2) AS pct_paid,
    l.interest_rate,
    l.apr,
    l.term_months,
    l.monthly_payment,
    l.payment_due_day,
    l.next_payment_date,
    l.origination_date,
    DATEDIFF('month', l.origination_date, CURRENT_DATE()) AS months_since_origination,
    l.maturity_date,
    DATEDIFF('month', CURRENT_DATE(), l.maturity_date) AS months_remaining,
    l.collateral_type,
    l.collateral_value,
    l.ltv_ratio,
    l.days_past_due,
    l.times_30_days_late,
    l.times_60_days_late,
    l.times_90_days_late,
    CASE 
        WHEN l.days_past_due = 0 THEN 'CURRENT'
        WHEN l.days_past_due < 30 THEN 'LATE'
        WHEN l.days_past_due < 60 THEN '30_DPD'
        WHEN l.days_past_due < 90 THEN '60_DPD'
        ELSE '90_PLUS_DPD'
    END AS delinquency_status,
    l.autopay_enrolled
FROM MACU_INTELLIGENCE.RAW.LOANS l
JOIN MACU_INTELLIGENCE.RAW.MEMBERS m ON l.member_id = m.member_id;

-- ============================================================================
-- View 4: Transaction Analytics View
-- ============================================================================
CREATE OR REPLACE VIEW V_TRANSACTION_ANALYTICS AS
SELECT
    t.transaction_id,
    t.account_id,
    t.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    a.account_type,
    t.transaction_type,
    t.transaction_category,
    t.amount,
    ABS(t.amount) AS absolute_amount,
    CASE WHEN t.amount > 0 THEN 'CREDIT' ELSE 'DEBIT' END AS flow_direction,
    t.running_balance,
    t.transaction_date,
    t.transaction_timestamp,
    DAYNAME(t.transaction_date) AS day_of_week,
    HOUR(t.transaction_timestamp) AS hour_of_day,
    t.description,
    t.merchant_name,
    t.merchant_category,
    mc.category_name AS mcc_category_name,
    mc.category_group AS mcc_category_group,
    t.merchant_city,
    t.merchant_state,
    t.is_recurring,
    t.is_international,
    t.status,
    t.fraud_score,
    CASE 
        WHEN t.fraud_score >= 0.8 THEN 'HIGH_RISK'
        WHEN t.fraud_score >= 0.5 THEN 'MEDIUM_RISK'
        ELSE 'LOW_RISK'
    END AS risk_level,
    t.channel,
    t.device_type
FROM MACU_INTELLIGENCE.RAW.TRANSACTIONS t
JOIN MACU_INTELLIGENCE.RAW.MEMBERS m ON t.member_id = m.member_id
JOIN MACU_INTELLIGENCE.RAW.ACCOUNTS a ON t.account_id = a.account_id
LEFT JOIN MACU_INTELLIGENCE.RAW.MERCHANT_CATEGORIES mc ON t.merchant_category = mc.mcc_code;

-- ============================================================================
-- View 5: Support Analytics View
-- ============================================================================
CREATE OR REPLACE VIEW V_SUPPORT_ANALYTICS AS
SELECT
    si.interaction_id,
    si.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    m.membership_tier,
    si.agent_id,
    si.interaction_type,
    si.channel,
    si.category,
    si.subcategory,
    si.subject,
    si.interaction_date,
    si.interaction_timestamp,
    DAYNAME(si.interaction_date) AS day_of_week,
    HOUR(si.interaction_timestamp) AS hour_of_day,
    si.duration_seconds,
    ROUND(si.duration_seconds / 60.0, 2) AS duration_minutes,
    si.resolution_status,
    si.resolution_achieved,
    si.satisfaction_score,
    si.nps_score,
    CASE 
        WHEN si.nps_score >= 9 THEN 'PROMOTER'
        WHEN si.nps_score >= 7 THEN 'PASSIVE'
        ELSE 'DETRACTOR'
    END AS nps_category,
    si.escalated,
    si.first_contact_resolution,
    si.branch_id,
    b.branch_name,
    b.region
FROM MACU_INTELLIGENCE.RAW.SUPPORT_INTERACTIONS si
JOIN MACU_INTELLIGENCE.RAW.MEMBERS m ON si.member_id = m.member_id
LEFT JOIN MACU_INTELLIGENCE.RAW.BRANCHES b ON si.branch_id = b.branch_id;

-- ============================================================================
-- View 6: Daily Metrics Dashboard View
-- ============================================================================
CREATE OR REPLACE VIEW V_DAILY_METRICS AS
SELECT
    CURRENT_DATE() AS report_date,
    (SELECT COUNT(*) FROM MACU_INTELLIGENCE.RAW.MEMBERS WHERE member_status = 'ACTIVE') AS active_members,
    (SELECT COUNT(*) FROM MACU_INTELLIGENCE.RAW.MEMBERS WHERE membership_date = CURRENT_DATE()) AS new_members_today,
    (SELECT SUM(current_balance) FROM MACU_INTELLIGENCE.RAW.ACCOUNTS WHERE account_type NOT IN ('CREDIT_CARD') AND account_status = 'ACTIVE') AS total_deposits,
    (SELECT SUM(current_balance) FROM MACU_INTELLIGENCE.RAW.LOANS WHERE loan_status = 'ACTIVE') AS total_loans,
    (SELECT COUNT(*) FROM MACU_INTELLIGENCE.RAW.TRANSACTIONS WHERE transaction_date = CURRENT_DATE()) AS transactions_today,
    (SELECT SUM(ABS(amount)) FROM MACU_INTELLIGENCE.RAW.TRANSACTIONS WHERE transaction_date = CURRENT_DATE() AND status = 'COMPLETED') AS transaction_volume_today,
    (SELECT COUNT(*) FROM MACU_INTELLIGENCE.RAW.SUPPORT_INTERACTIONS WHERE interaction_date = CURRENT_DATE()) AS support_interactions_today,
    (SELECT AVG(satisfaction_score) FROM MACU_INTELLIGENCE.RAW.SUPPORT_INTERACTIONS WHERE interaction_date = CURRENT_DATE()) AS avg_satisfaction_today,
    (SELECT COUNT(*) FROM MACU_INTELLIGENCE.RAW.LOANS WHERE days_past_due > 30) AS delinquent_loans,
    (SELECT SUM(current_balance) FROM MACU_INTELLIGENCE.RAW.LOANS WHERE days_past_due > 30) AS delinquent_loan_balance;

-- ============================================================================
-- View 7: Member Engagement Score View
-- ============================================================================
CREATE OR REPLACE VIEW V_MEMBER_ENGAGEMENT AS
SELECT
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    m.membership_tier,
    m.digital_banking_enrolled,
    COALESCE(txn.txn_count_30d, 0) AS transactions_30d,
    COALESCE(txn.digital_txn_count, 0) AS digital_transactions_30d,
    COALESCE(support.interactions_90d, 0) AS support_interactions_90d,
    COALESCE(acct.product_count, 0) AS products_held,
    LEAST(100, 
        (COALESCE(txn.txn_count_30d, 0) * 0.5) +
        (CASE WHEN m.digital_banking_enrolled THEN 20 ELSE 0 END) +
        (COALESCE(acct.product_count, 0) * 10) +
        (CASE WHEN COALESCE(txn.digital_txn_count, 0) > 10 THEN 20 ELSE COALESCE(txn.digital_txn_count, 0) * 2 END)
    ) AS engagement_score,
    CASE 
        WHEN LEAST(100, (COALESCE(txn.txn_count_30d, 0) * 0.5) + (CASE WHEN m.digital_banking_enrolled THEN 20 ELSE 0 END) + (COALESCE(acct.product_count, 0) * 10)) >= 70 THEN 'HIGHLY_ENGAGED'
        WHEN LEAST(100, (COALESCE(txn.txn_count_30d, 0) * 0.5) + (CASE WHEN m.digital_banking_enrolled THEN 20 ELSE 0 END) + (COALESCE(acct.product_count, 0) * 10)) >= 40 THEN 'ENGAGED'
        WHEN LEAST(100, (COALESCE(txn.txn_count_30d, 0) * 0.5) + (CASE WHEN m.digital_banking_enrolled THEN 20 ELSE 0 END) + (COALESCE(acct.product_count, 0) * 10)) >= 20 THEN 'MODERATE'
        ELSE 'AT_RISK'
    END AS engagement_level
FROM MACU_INTELLIGENCE.RAW.MEMBERS m
LEFT JOIN (
    SELECT 
        member_id,
        COUNT(*) AS txn_count_30d,
        SUM(CASE WHEN channel IN ('MOBILE_APP', 'ONLINE') THEN 1 ELSE 0 END) AS digital_txn_count
    FROM MACU_INTELLIGENCE.RAW.TRANSACTIONS
    WHERE transaction_date >= DATEADD('day', -30, CURRENT_DATE())
    GROUP BY member_id
) txn ON m.member_id = txn.member_id
LEFT JOIN (
    SELECT member_id, COUNT(*) AS interactions_90d
    FROM MACU_INTELLIGENCE.RAW.SUPPORT_INTERACTIONS
    WHERE interaction_date >= DATEADD('day', -90, CURRENT_DATE())
    GROUP BY member_id
) support ON m.member_id = support.member_id
LEFT JOIN (
    SELECT member_id, COUNT(DISTINCT account_type) AS product_count
    FROM MACU_INTELLIGENCE.RAW.ACCOUNTS
    WHERE account_status = 'ACTIVE'
    GROUP BY member_id
) acct ON m.member_id = acct.member_id
WHERE m.member_status = 'ACTIVE';

-- Display confirmation
SELECT 'Analytical views created successfully' AS STATUS, 7 AS views_created;
