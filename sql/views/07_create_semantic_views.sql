-- ============================================================================
-- Mountain America Credit Union - Semantic Views for Cortex Analyst
-- ============================================================================
-- Purpose: Create semantic views that define business metrics, dimensions,
--          and relationships for natural language querying via Cortex Analyst
-- ============================================================================

USE DATABASE MACU_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE MACU_WH;

-- ============================================================================
-- Semantic View 1: Member Analytics (Primary semantic model)
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_MEMBER_ANALYTICS
  COMMENT = 'Semantic view for analyzing Mountain America Credit Union member data, accounts, and financial behavior'
AS
SELECT * FROM V_MEMBER_360
WITH SEMANTICS (
    -- Entity Definition
    ENTITY MEMBERS (
        member_id SYNONYM 'member ID' UNIQUE COMMENT 'Unique identifier for each credit union member',
        full_name SYNONYM 'member name' COMMENT 'Full name of the member',
        email COMMENT 'Member email address',
        phone SYNONYM 'phone number' COMMENT 'Member phone number'
    ),
    
    -- Dimensions (Categorical attributes)
    DIMENSION city COMMENT 'City where member resides',
    DIMENSION address_state SYNONYM 'state' COMMENT 'State where member resides',
    DIMENSION zip_code SYNONYM 'ZIP' COMMENT 'Postal code',
    DIMENSION member_status SYNONYM 'status' COMMENT 'Current membership status: ACTIVE, INACTIVE, or CLOSED',
    DIMENSION membership_tier SYNONYM 'tier' COMMENT 'Member tier level: STANDARD, GOLD, or PLATINUM',
    DIMENSION kyc_status COMMENT 'Know Your Customer verification status',
    DIMENSION risk_tier SYNONYM 'risk level' COMMENT 'Member risk classification: LOW, MEDIUM, or HIGH',
    DIMENSION employment_status COMMENT 'Employment status: EMPLOYED, SELF_EMPLOYED, RETIRED, or STUDENT',
    DIMENSION employer_name SYNONYM 'employer' COMMENT 'Name of member employer',
    DIMENSION acquisition_channel SYNONYM 'channel' COMMENT 'How the member was acquired: BRANCH, ONLINE, MOBILE, REFERRAL, EMPLOYER, MARKETING',
    DIMENSION primary_branch_id SYNONYM 'home branch' COMMENT 'Primary branch location ID',
    DIMENSION digital_banking_enrolled SYNONYM 'digital member' COMMENT 'Whether member uses digital banking',
    
    -- Time Dimensions
    DIMENSION membership_date TYPE DATE SYNONYM 'join date' COMMENT 'Date when member joined MACU',
    DIMENSION date_of_birth TYPE DATE SYNONYM 'DOB' COMMENT 'Member date of birth',
    
    -- Metrics (Numeric measures)
    METRIC age TYPE NUMBER COMMENT 'Member age in years',
    METRIC tenure_days TYPE NUMBER COMMENT 'Days since member joined',
    METRIC tenure_years TYPE NUMBER SYNONYM 'years as member' COMMENT 'Years since member joined',
    METRIC credit_score TYPE NUMBER COMMENT 'Member credit score (300-850)',
    METRIC income_verified TYPE NUMBER SYNONYM 'income' COMMENT 'Verified annual income',
    METRIC total_accounts TYPE NUMBER SYNONYM 'account count' COMMENT 'Total number of accounts held by member',
    METRIC total_deposit_balance TYPE NUMBER SYNONYM 'deposits' COMMENT 'Total balance across all deposit accounts',
    METRIC total_credit_balance TYPE NUMBER SYNONYM 'credit card balance' COMMENT 'Total credit card balance',
    METRIC active_loans TYPE NUMBER SYNONYM 'loan count' COMMENT 'Number of active loans',
    METRIC total_loan_balance TYPE NUMBER SYNONYM 'loan balance' COMMENT 'Total outstanding loan balance',
    METRIC transactions_last_30_days TYPE NUMBER SYNONYM 'recent transactions' COMMENT 'Transaction count in last 30 days',
    METRIC transaction_volume_30_days TYPE NUMBER SYNONYM 'monthly spend' COMMENT 'Total transaction amount in last 30 days'
);

-- ============================================================================
-- Semantic View 2: Account Analytics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_ACCOUNT_ANALYTICS
  COMMENT = 'Semantic view for analyzing MACU account data including deposits, credit, and activity'
AS
SELECT * FROM V_ACCOUNT_SUMMARY
WITH SEMANTICS (
    ENTITY ACCOUNTS (
        account_id SYNONYM 'account number' UNIQUE COMMENT 'Unique account identifier',
        member_id COMMENT 'Member who owns this account'
    ),
    
    DIMENSION member_name SYNONYM 'account holder' COMMENT 'Name of the account holder',
    DIMENSION account_type TYPE STRING SYNONYM 'product type' 
        COMMENT 'Account type: SHARE_SAVINGS, CHECKING, SHARE_CERTIFICATE, IRA, CREDIT_CARD',
    DIMENSION account_subtype SYNONYM 'product subtype' COMMENT 'Specific product variant',
    DIMENSION account_status SYNONYM 'status' COMMENT 'Account status: ACTIVE, DORMANT, CLOSED',
    DIMENSION account_name SYNONYM 'product name' COMMENT 'Descriptive account name',
    DIMENSION overdraft_protection COMMENT 'Whether overdraft protection is enabled',
    DIMENSION joint_account COMMENT 'Whether this is a joint account',
    
    DIMENSION opened_date TYPE DATE SYNONYM 'open date' COMMENT 'Date account was opened',
    DIMENSION maturity_date TYPE DATE COMMENT 'Maturity date for certificates',
    DIMENSION last_activity_date TYPE DATE COMMENT 'Date of last account activity',
    
    METRIC current_balance TYPE NUMBER SYNONYM 'balance' COMMENT 'Current account balance',
    METRIC available_balance TYPE NUMBER COMMENT 'Available balance for withdrawals',
    METRIC credit_limit TYPE NUMBER COMMENT 'Credit limit for credit accounts',
    METRIC utilization_pct TYPE NUMBER SYNONYM 'utilization' COMMENT 'Credit utilization percentage',
    METRIC dividend_rate TYPE NUMBER SYNONYM 'rate' COMMENT 'Dividend/interest rate',
    METRIC apy_rate TYPE NUMBER SYNONYM 'APY' COMMENT 'Annual percentage yield',
    METRIC term_months TYPE NUMBER SYNONYM 'term' COMMENT 'Certificate term in months',
    METRIC account_age_days TYPE NUMBER SYNONYM 'account age' COMMENT 'Days since account opened',
    METRIC days_since_activity TYPE NUMBER COMMENT 'Days since last activity',
    METRIC monthly_transactions TYPE NUMBER COMMENT 'Transactions in last 30 days',
    METRIC monthly_volume TYPE NUMBER COMMENT 'Transaction volume in last 30 days'
);

-- ============================================================================
-- Semantic View 3: Loan Portfolio Analytics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_LOAN_ANALYTICS
  COMMENT = 'Semantic view for analyzing MACU loan portfolio including auto, mortgage, and personal loans'
AS
SELECT * FROM V_LOAN_PORTFOLIO
WITH SEMANTICS (
    ENTITY LOANS (
        loan_id SYNONYM 'loan number' UNIQUE COMMENT 'Unique loan identifier',
        member_id COMMENT 'Member who holds this loan'
    ),
    
    DIMENSION member_name SYNONYM 'borrower' COMMENT 'Name of the borrower',
    DIMENSION loan_type TYPE STRING SYNONYM 'loan category' 
        COMMENT 'Loan type: AUTO, MORTGAGE, HOME_EQUITY, PERSONAL, RV_BOAT',
    DIMENSION loan_subtype COMMENT 'Specific loan variant',
    DIMENSION loan_status SYNONYM 'status' COMMENT 'Loan status: ACTIVE, PAID_OFF, DELINQUENT',
    DIMENSION collateral_type COMMENT 'Type of collateral securing the loan',
    DIMENSION delinquency_status COMMENT 'Current delinquency status',
    DIMENSION autopay_enrolled SYNONYM 'autopay' COMMENT 'Whether automatic payments are enrolled',
    
    DIMENSION origination_date TYPE DATE SYNONYM 'funded date' COMMENT 'Date loan was originated',
    DIMENSION maturity_date TYPE DATE SYNONYM 'payoff date' COMMENT 'Loan maturity date',
    DIMENSION next_payment_date TYPE DATE COMMENT 'Next payment due date',
    
    METRIC original_amount TYPE NUMBER SYNONYM 'loan amount' COMMENT 'Original loan amount',
    METRIC current_balance TYPE NUMBER SYNONYM 'balance' COMMENT 'Current outstanding balance',
    METRIC principal_paid TYPE NUMBER COMMENT 'Principal amount paid so far',
    METRIC pct_paid TYPE NUMBER SYNONYM 'percent paid' COMMENT 'Percentage of loan paid off',
    METRIC interest_rate TYPE NUMBER SYNONYM 'rate' COMMENT 'Interest rate on the loan',
    METRIC apr TYPE NUMBER COMMENT 'Annual percentage rate',
    METRIC term_months TYPE NUMBER SYNONYM 'term' COMMENT 'Loan term in months',
    METRIC monthly_payment TYPE NUMBER SYNONYM 'payment' COMMENT 'Monthly payment amount',
    METRIC payment_due_day TYPE NUMBER COMMENT 'Day of month payment is due',
    METRIC months_since_origination TYPE NUMBER COMMENT 'Months since loan funded',
    METRIC months_remaining TYPE NUMBER COMMENT 'Months until payoff',
    METRIC collateral_value TYPE NUMBER COMMENT 'Value of collateral',
    METRIC ltv_ratio TYPE NUMBER SYNONYM 'LTV' COMMENT 'Loan to value ratio',
    METRIC days_past_due TYPE NUMBER SYNONYM 'DPD' COMMENT 'Days past due',
    METRIC times_30_days_late TYPE NUMBER COMMENT 'Count of 30-day late payments',
    METRIC times_60_days_late TYPE NUMBER COMMENT 'Count of 60-day late payments',
    METRIC times_90_days_late TYPE NUMBER COMMENT 'Count of 90+ day late payments',
    METRIC current_credit_score TYPE NUMBER SYNONYM 'credit score' COMMENT 'Borrower current credit score'
);

-- ============================================================================
-- Semantic View 4: Transaction Analytics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_TRANSACTION_ANALYTICS
  COMMENT = 'Semantic view for analyzing MACU transaction patterns and spending behavior'
AS
SELECT * FROM V_TRANSACTION_ANALYTICS
WITH SEMANTICS (
    ENTITY TRANSACTIONS (
        transaction_id SYNONYM 'transaction number' UNIQUE COMMENT 'Unique transaction identifier'
    ),
    
    DIMENSION account_id COMMENT 'Account involved in transaction',
    DIMENSION member_id COMMENT 'Member involved in transaction',
    DIMENSION member_name COMMENT 'Member name',
    DIMENSION account_type COMMENT 'Type of account',
    DIMENSION transaction_type TYPE STRING COMMENT 'Transaction type: PURCHASE, DEPOSIT, TRANSFER, etc.',
    DIMENSION transaction_category SYNONYM 'category' COMMENT 'Spending category',
    DIMENSION flow_direction COMMENT 'Whether money is CREDIT or DEBIT',
    DIMENSION merchant_name SYNONYM 'merchant' COMMENT 'Name of merchant',
    DIMENSION merchant_category SYNONYM 'MCC' COMMENT 'Merchant category code',
    DIMENSION mcc_category_name COMMENT 'MCC category description',
    DIMENSION mcc_category_group SYNONYM 'spending type' COMMENT 'MCC category group',
    DIMENSION merchant_city COMMENT 'Merchant city',
    DIMENSION merchant_state COMMENT 'Merchant state',
    DIMENSION is_recurring SYNONYM 'recurring' COMMENT 'Whether this is a recurring transaction',
    DIMENSION is_international SYNONYM 'international' COMMENT 'Whether transaction is international',
    DIMENSION status COMMENT 'Transaction status',
    DIMENSION risk_level SYNONYM 'fraud risk' COMMENT 'Fraud risk assessment',
    DIMENSION channel COMMENT 'Transaction channel',
    DIMENSION device_type SYNONYM 'device' COMMENT 'Device used for transaction',
    DIMENSION day_of_week COMMENT 'Day of week transaction occurred',
    
    DIMENSION transaction_date TYPE DATE SYNONYM 'date' COMMENT 'Date of transaction',
    DIMENSION transaction_timestamp TYPE TIMESTAMP SYNONYM 'time' COMMENT 'Timestamp of transaction',
    
    METRIC amount TYPE NUMBER COMMENT 'Transaction amount (positive for credits, negative for debits)',
    METRIC absolute_amount TYPE NUMBER SYNONYM 'amount' COMMENT 'Absolute transaction amount',
    METRIC running_balance TYPE NUMBER COMMENT 'Account balance after transaction',
    METRIC fraud_score TYPE NUMBER COMMENT 'Fraud probability score (0-1)',
    METRIC hour_of_day TYPE NUMBER COMMENT 'Hour when transaction occurred (0-23)'
);

-- ============================================================================
-- Semantic View 5: Support Analytics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_SUPPORT_ANALYTICS
  COMMENT = 'Semantic view for analyzing MACU member support interactions and satisfaction'
AS
SELECT * FROM V_SUPPORT_ANALYTICS
WITH SEMANTICS (
    ENTITY INTERACTIONS (
        interaction_id SYNONYM 'case number' UNIQUE COMMENT 'Unique support interaction identifier'
    ),
    
    DIMENSION member_id COMMENT 'Member who initiated support contact',
    DIMENSION member_name COMMENT 'Member name',
    DIMENSION membership_tier SYNONYM 'member tier' COMMENT 'Member tier at time of interaction',
    DIMENSION agent_id SYNONYM 'agent' COMMENT 'Support agent who handled the interaction',
    DIMENSION interaction_type TYPE STRING SYNONYM 'contact type' COMMENT 'Type of interaction: CALL, CHAT, EMAIL, etc.',
    DIMENSION channel COMMENT 'Contact channel',
    DIMENSION category SYNONYM 'issue category' COMMENT 'Category of the issue',
    DIMENSION subcategory SYNONYM 'issue type' COMMENT 'Specific issue type',
    DIMENSION subject SYNONYM 'issue' COMMENT 'Subject or summary of the interaction',
    DIMENSION resolution_status SYNONYM 'status' COMMENT 'Current resolution status',
    DIMENSION resolution_achieved SYNONYM 'resolved' COMMENT 'Whether issue was resolved',
    DIMENSION nps_category COMMENT 'NPS classification: PROMOTER, PASSIVE, or DETRACTOR',
    DIMENSION escalated COMMENT 'Whether interaction was escalated',
    DIMENSION first_contact_resolution SYNONYM 'FCR' COMMENT 'Whether resolved on first contact',
    DIMENSION branch_id COMMENT 'Branch associated with interaction',
    DIMENSION branch_name SYNONYM 'branch' COMMENT 'Branch name',
    DIMENSION region COMMENT 'Geographic region',
    DIMENSION day_of_week COMMENT 'Day of week of interaction',
    
    DIMENSION interaction_date TYPE DATE SYNONYM 'date' COMMENT 'Date of interaction',
    DIMENSION interaction_timestamp TYPE TIMESTAMP SYNONYM 'time' COMMENT 'Timestamp of interaction',
    
    METRIC duration_seconds TYPE NUMBER COMMENT 'Duration in seconds',
    METRIC duration_minutes TYPE NUMBER SYNONYM 'duration' COMMENT 'Duration in minutes',
    METRIC satisfaction_score TYPE NUMBER SYNONYM 'CSAT' COMMENT 'Customer satisfaction score (1-5)',
    METRIC nps_score TYPE NUMBER SYNONYM 'NPS' COMMENT 'Net Promoter Score (-100 to 100)',
    METRIC hour_of_day TYPE NUMBER COMMENT 'Hour when interaction started (0-23)'
);

-- Display confirmation
SELECT 'Semantic views created successfully' AS STATUS, 5 AS semantic_views_created;
