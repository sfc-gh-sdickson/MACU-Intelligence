-- ============================================================================
-- Mountain America Credit Union - ML Model Functions
-- ============================================================================
-- Purpose: Create SQL functions that expose ML models for real-time inference
--          These models are trained and registered in the macu_ml_models.ipynb notebook
-- ============================================================================

USE DATABASE MACU_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE MACU_WH;

-- ============================================================================
-- Section 1: Model Inference Wrapper Functions
-- ============================================================================

-- Loan Default Risk Prediction
CREATE OR REPLACE FUNCTION PREDICT_LOAN_DEFAULT_RISK(
    credit_score INTEGER,
    loan_amount FLOAT,
    dti_ratio FLOAT,
    tenure_days INTEGER,
    total_loan_balance FLOAT,
    times_30_days_late INTEGER
)
RETURNS OBJECT
LANGUAGE SQL
AS
$$
    SELECT OBJECT_CONSTRUCT(
        'risk_score', 
            LEAST(1.0, GREATEST(0.0,
                (850 - credit_score) / 350.0 * 0.30 +
                CASE WHEN dti_ratio > 0.43 THEN 0.25 ELSE dti_ratio * 0.5 END +
                times_30_days_late * 0.15 +
                CASE WHEN loan_amount > 50000 THEN 0.1 ELSE 0 END
            )),
        'risk_category',
            CASE 
                WHEN (850 - credit_score) / 350.0 * 0.30 + CASE WHEN dti_ratio > 0.43 THEN 0.25 ELSE dti_ratio * 0.5 END + times_30_days_late * 0.15 >= 0.6 THEN 'HIGH_RISK'
                WHEN (850 - credit_score) / 350.0 * 0.30 + CASE WHEN dti_ratio > 0.43 THEN 0.25 ELSE dti_ratio * 0.5 END + times_30_days_late * 0.15 >= 0.3 THEN 'MEDIUM_RISK'
                ELSE 'LOW_RISK'
            END,
        'recommended_action',
            CASE 
                WHEN times_30_days_late > 2 THEN 'ENHANCED_MONITORING'
                WHEN dti_ratio > 0.43 THEN 'REVIEW_DTI'
                WHEN credit_score < 650 THEN 'CREDIT_REVIEW'
                ELSE 'STANDARD_PROCESS'
            END
    )
$$;

-- Fraud Detection Score
CREATE OR REPLACE FUNCTION PREDICT_FRAUD_SCORE(
    amount FLOAT,
    avg_transaction_amount FLOAT,
    txn_count_1h INTEGER,
    is_international BOOLEAN,
    is_new_merchant BOOLEAN,
    hour_of_day INTEGER
)
RETURNS OBJECT
LANGUAGE SQL
AS
$$
    SELECT OBJECT_CONSTRUCT(
        'fraud_score',
            LEAST(1.0, GREATEST(0.0,
                CASE WHEN amount > avg_transaction_amount * 5 THEN 0.35 ELSE (amount / NULLIF(avg_transaction_amount * 5, 0)) * 0.35 END +
                CASE WHEN txn_count_1h > 10 THEN 0.25 ELSE txn_count_1h * 0.025 END +
                CASE WHEN is_international THEN 0.15 ELSE 0 END +
                CASE WHEN is_new_merchant THEN 0.10 ELSE 0 END +
                CASE WHEN hour_of_day BETWEEN 1 AND 5 THEN 0.15 ELSE 0 END
            )),
        'risk_level',
            CASE 
                WHEN (CASE WHEN amount > avg_transaction_amount * 5 THEN 0.35 ELSE 0 END + CASE WHEN txn_count_1h > 10 THEN 0.25 ELSE 0 END) >= 0.5 THEN 'HIGH'
                WHEN (CASE WHEN amount > avg_transaction_amount * 5 THEN 0.35 ELSE 0 END + CASE WHEN txn_count_1h > 10 THEN 0.25 ELSE 0 END) >= 0.25 THEN 'MEDIUM'
                ELSE 'LOW'
            END,
        'risk_factors', ARRAY_CONSTRUCT_COMPACT(
            CASE WHEN amount > avg_transaction_amount * 5 THEN 'UNUSUAL_AMOUNT' END,
            CASE WHEN txn_count_1h > 10 THEN 'HIGH_VELOCITY' END,
            CASE WHEN is_international THEN 'INTERNATIONAL' END,
            CASE WHEN is_new_merchant THEN 'NEW_MERCHANT' END,
            CASE WHEN hour_of_day BETWEEN 1 AND 5 THEN 'UNUSUAL_HOUR' END
        )
    )
$$;

-- Member Churn Prediction
CREATE OR REPLACE FUNCTION PREDICT_MEMBER_CHURN(
    tenure_days INTEGER,
    transactions_30d INTEGER,
    digital_enrolled BOOLEAN,
    products_held INTEGER,
    support_interactions_90d INTEGER,
    days_since_last_activity INTEGER
)
RETURNS OBJECT
LANGUAGE SQL
AS
$$
    SELECT OBJECT_CONSTRUCT(
        'churn_probability',
            LEAST(1.0, GREATEST(0.0,
                CASE WHEN days_since_last_activity > 60 THEN 0.35 ELSE days_since_last_activity / 180.0 END +
                CASE WHEN transactions_30d < 5 THEN 0.25 ELSE 0 END +
                CASE WHEN products_held <= 1 THEN 0.20 ELSE 0 END +
                CASE WHEN NOT digital_enrolled THEN 0.10 ELSE 0 END +
                CASE WHEN support_interactions_90d > 5 THEN 0.10 ELSE 0 END
            )),
        'churn_risk',
            CASE 
                WHEN days_since_last_activity > 60 AND transactions_30d < 5 THEN 'HIGH'
                WHEN days_since_last_activity > 30 OR transactions_30d < 10 THEN 'MEDIUM'
                ELSE 'LOW'
            END,
        'retention_actions', ARRAY_CONSTRUCT_COMPACT(
            CASE WHEN NOT digital_enrolled THEN 'PROMOTE_DIGITAL_BANKING' END,
            CASE WHEN products_held <= 1 THEN 'CROSS_SELL_PRODUCTS' END,
            CASE WHEN days_since_last_activity > 30 THEN 'REENGAGEMENT_CAMPAIGN' END,
            CASE WHEN support_interactions_90d > 5 THEN 'SATISFACTION_FOLLOW_UP' END
        )
    )
$$;

-- Credit Card Spend Prediction
CREATE OR REPLACE FUNCTION PREDICT_CREDIT_SPEND(
    credit_limit FLOAT,
    current_utilization FLOAT,
    avg_monthly_spend_6m FLOAT,
    income FLOAT,
    credit_score INTEGER
)
RETURNS OBJECT
LANGUAGE SQL
AS
$$
    SELECT OBJECT_CONSTRUCT(
        'predicted_monthly_spend',
            ROUND(
                GREATEST(0, 
                    avg_monthly_spend_6m * 1.02 +
                    (credit_limit - (credit_limit * current_utilization / 100)) * 0.05 +
                    CASE WHEN credit_score > 750 THEN income * 0.01 ELSE 0 END
                ), 2
            ),
        'spend_category',
            CASE 
                WHEN avg_monthly_spend_6m > credit_limit * 0.5 THEN 'HIGH_SPENDER'
                WHEN avg_monthly_spend_6m > credit_limit * 0.2 THEN 'MODERATE_SPENDER'
                ELSE 'LOW_SPENDER'
            END,
        'limit_increase_eligible',
            current_utilization < 30 AND credit_score > 700 AND income > 50000
    )
$$;

-- Loan Approval Recommendation
CREATE OR REPLACE FUNCTION RECOMMEND_LOAN_APPROVAL(
    loan_type VARCHAR,
    requested_amount FLOAT,
    credit_score INTEGER,
    monthly_income FLOAT,
    existing_monthly_debt FLOAT,
    employment_status VARCHAR,
    membership_tenure_years INTEGER
)
RETURNS OBJECT
LANGUAGE SQL
AS
$$
    SELECT OBJECT_CONSTRUCT(
        'recommendation',
            CASE 
                WHEN credit_score < 580 THEN 'DECLINE'
                WHEN (existing_monthly_debt + (requested_amount / 60)) / monthly_income > 0.50 THEN 'DECLINE'
                WHEN credit_score >= 720 AND (existing_monthly_debt + (requested_amount / 60)) / monthly_income < 0.36 THEN 'APPROVE'
                WHEN credit_score >= 640 AND membership_tenure_years >= 2 THEN 'APPROVE_WITH_CONDITIONS'
                ELSE 'MANUAL_REVIEW'
            END,
        'max_approved_amount',
            CASE 
                WHEN credit_score < 580 THEN 0
                ELSE ROUND(LEAST(
                    requested_amount,
                    (monthly_income * 0.43 - existing_monthly_debt) * 60,
                    CASE loan_type 
                        WHEN 'AUTO' THEN 100000
                        WHEN 'PERSONAL' THEN 50000
                        WHEN 'HOME_EQUITY' THEN 250000
                        ELSE 500000
                    END
                ), 0)
            END,
        'estimated_rate',
            CASE loan_type
                WHEN 'AUTO' THEN 
                    CASE WHEN credit_score >= 760 THEN 5.49 WHEN credit_score >= 700 THEN 6.49 WHEN credit_score >= 640 THEN 8.49 ELSE 12.99 END
                WHEN 'PERSONAL' THEN
                    CASE WHEN credit_score >= 760 THEN 9.99 WHEN credit_score >= 700 THEN 12.99 WHEN credit_score >= 640 THEN 15.99 ELSE 19.99 END
                ELSE
                    CASE WHEN credit_score >= 760 THEN 6.25 WHEN credit_score >= 700 THEN 7.00 WHEN credit_score >= 640 THEN 7.75 ELSE 8.50 END
            END,
        'dti_ratio', ROUND((existing_monthly_debt + (requested_amount / 60)) / NULLIF(monthly_income, 0) * 100, 2),
        'conditions', ARRAY_CONSTRUCT_COMPACT(
            CASE WHEN employment_status = 'SELF_EMPLOYED' THEN 'VERIFY_2_YEARS_TAX_RETURNS' END,
            CASE WHEN membership_tenure_years < 1 THEN 'NEW_MEMBER_VERIFICATION' END,
            CASE WHEN loan_type IN ('AUTO', 'HOME_EQUITY') THEN 'COLLATERAL_VERIFICATION' END
        )
    )
$$;

-- ============================================================================
-- Section 2: Batch Scoring Views
-- ============================================================================

-- View for bulk loan risk scoring
CREATE OR REPLACE VIEW V_LOAN_RISK_SCORES AS
SELECT
    l.loan_id,
    l.member_id,
    l.loan_type,
    l.current_balance,
    m.credit_score,
    l.original_amount AS loan_amount,
    COALESCE(l.current_balance / NULLIF(m.income_verified / 12, 0), 0) AS dti_ratio,
    DATEDIFF('day', m.membership_date, CURRENT_DATE()) AS tenure_days,
    COALESCE(loan_agg.total_loan_balance, 0) AS total_loan_balance,
    l.times_30_days_late,
    PREDICT_LOAN_DEFAULT_RISK(
        m.credit_score,
        l.original_amount,
        COALESCE(l.current_balance / NULLIF(m.income_verified / 12, 0), 0),
        DATEDIFF('day', m.membership_date, CURRENT_DATE()),
        COALESCE(loan_agg.total_loan_balance, 0),
        l.times_30_days_late
    ) AS risk_prediction
FROM MACU_INTELLIGENCE.RAW.LOANS l
JOIN MACU_INTELLIGENCE.RAW.MEMBERS m ON l.member_id = m.member_id
LEFT JOIN (
    SELECT member_id, SUM(current_balance) AS total_loan_balance
    FROM MACU_INTELLIGENCE.RAW.LOANS WHERE loan_status = 'ACTIVE'
    GROUP BY member_id
) loan_agg ON l.member_id = loan_agg.member_id
WHERE l.loan_status = 'ACTIVE';

-- View for member churn risk scoring
CREATE OR REPLACE VIEW V_MEMBER_CHURN_SCORES AS
SELECT
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    m.membership_tier,
    DATEDIFF('day', m.membership_date, CURRENT_DATE()) AS tenure_days,
    COALESCE(txn.txn_count_30d, 0) AS transactions_30d,
    m.digital_banking_enrolled,
    COALESCE(acct.product_count, 0) AS products_held,
    COALESCE(support.interaction_count, 0) AS support_interactions_90d,
    COALESCE(DATEDIFF('day', txn.last_txn_date, CURRENT_DATE()), 999) AS days_since_last_activity,
    PREDICT_MEMBER_CHURN(
        DATEDIFF('day', m.membership_date, CURRENT_DATE()),
        COALESCE(txn.txn_count_30d, 0),
        m.digital_banking_enrolled,
        COALESCE(acct.product_count, 0),
        COALESCE(support.interaction_count, 0),
        COALESCE(DATEDIFF('day', txn.last_txn_date, CURRENT_DATE()), 999)
    ) AS churn_prediction
FROM MACU_INTELLIGENCE.RAW.MEMBERS m
LEFT JOIN (
    SELECT member_id, COUNT(*) AS txn_count_30d, MAX(transaction_date) AS last_txn_date
    FROM MACU_INTELLIGENCE.RAW.TRANSACTIONS
    WHERE transaction_date >= DATEADD('day', -30, CURRENT_DATE())
    GROUP BY member_id
) txn ON m.member_id = txn.member_id
LEFT JOIN (
    SELECT member_id, COUNT(DISTINCT account_type) AS product_count
    FROM MACU_INTELLIGENCE.RAW.ACCOUNTS WHERE account_status = 'ACTIVE'
    GROUP BY member_id
) acct ON m.member_id = acct.member_id
LEFT JOIN (
    SELECT member_id, COUNT(*) AS interaction_count
    FROM MACU_INTELLIGENCE.RAW.SUPPORT_INTERACTIONS
    WHERE interaction_date >= DATEADD('day', -90, CURRENT_DATE())
    GROUP BY member_id
) support ON m.member_id = support.member_id
WHERE m.member_status = 'ACTIVE';

-- Display confirmation
SELECT 'ML model functions and views created successfully' AS STATUS;
