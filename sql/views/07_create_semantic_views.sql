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
  TABLES (
    members AS V_MEMBER_360
      PRIMARY KEY (member_id)
      COMMENT = 'Comprehensive member profile with accounts and activity'
  )
  DIMENSIONS (
    members.member_id AS member_id COMMENT = 'Unique identifier for each credit union member',
    members.full_name AS full_name WITH SYNONYMS = ('member name') COMMENT = 'Full name of the member',
    members.email AS email COMMENT = 'Member email address',
    members.phone AS phone WITH SYNONYMS = ('phone number') COMMENT = 'Member phone number',
    members.city AS city COMMENT = 'City where member resides',
    members.address_state AS address_state WITH SYNONYMS = ('state') COMMENT = 'State where member resides',
    members.zip_code AS zip_code WITH SYNONYMS = ('ZIP') COMMENT = 'Postal code',
    members.member_status AS member_status WITH SYNONYMS = ('status') COMMENT = 'Current membership status: ACTIVE, INACTIVE, or CLOSED',
    members.membership_tier AS membership_tier WITH SYNONYMS = ('tier') COMMENT = 'Member tier level: STANDARD, GOLD, or PLATINUM',
    members.kyc_status AS kyc_status COMMENT = 'Know Your Customer verification status',
    members.risk_tier AS risk_tier WITH SYNONYMS = ('risk level') COMMENT = 'Member risk classification: LOW, MEDIUM, or HIGH',
    members.employment_status AS employment_status COMMENT = 'Employment status',
    members.employer_name AS employer_name WITH SYNONYMS = ('employer') COMMENT = 'Name of member employer',
    members.acquisition_channel AS acquisition_channel WITH SYNONYMS = ('channel') COMMENT = 'How the member was acquired',
    members.primary_branch_id AS primary_branch_id WITH SYNONYMS = ('home branch') COMMENT = 'Primary branch location ID',
    members.digital_banking_enrolled AS digital_banking_enrolled WITH SYNONYMS = ('digital member') COMMENT = 'Whether member uses digital banking',
    members.membership_date AS membership_date WITH SYNONYMS = ('join date') COMMENT = 'Date when member joined MACU',
    members.date_of_birth AS date_of_birth WITH SYNONYMS = ('DOB') COMMENT = 'Member date of birth'
  )
  METRICS (
    members.member_count AS COUNT(member_id) COMMENT = 'Count of members',
    members.avg_age AS AVG(age) COMMENT = 'Average member age in years',
    members.avg_tenure_days AS AVG(tenure_days) COMMENT = 'Average days since member joined',
    members.avg_tenure_years AS AVG(tenure_years) WITH SYNONYMS = ('avg years as member') COMMENT = 'Average years since member joined',
    members.avg_credit_score AS AVG(credit_score) COMMENT = 'Average member credit score',
    members.total_income AS SUM(income_verified) WITH SYNONYMS = ('income') COMMENT = 'Total verified income',
    members.total_accounts AS SUM(total_accounts) WITH SYNONYMS = ('account count') COMMENT = 'Total number of accounts held by members',
    members.total_deposit_balance AS SUM(total_deposit_balance) WITH SYNONYMS = ('deposits') COMMENT = 'Total balance across all deposit accounts',
    members.total_credit_balance AS SUM(total_credit_balance) WITH SYNONYMS = ('credit card balance') COMMENT = 'Total credit card balance',
    members.total_active_loans AS SUM(active_loans) WITH SYNONYMS = ('loan count') COMMENT = 'Number of active loans',
    members.total_loan_balance AS SUM(total_loan_balance) WITH SYNONYMS = ('loan balance') COMMENT = 'Total outstanding loan balance',
    members.total_transactions_30d AS SUM(transactions_last_30_days) WITH SYNONYMS = ('recent transactions') COMMENT = 'Transaction count in last 30 days',
    members.total_transaction_volume_30d AS SUM(transaction_volume_30_days) WITH SYNONYMS = ('monthly spend') COMMENT = 'Total transaction amount in last 30 days'
  )
  COMMENT = 'Semantic view for analyzing Mountain America Credit Union member data, accounts, and financial behavior';

-- ============================================================================
-- Semantic View 2: Account Analytics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_ACCOUNT_ANALYTICS
  TABLES (
    accounts AS V_ACCOUNT_SUMMARY
      PRIMARY KEY (account_id)
      COMMENT = 'Account summary with balances and activity'
  )
  DIMENSIONS (
    accounts.account_id AS account_id WITH SYNONYMS = ('account number') COMMENT = 'Unique account identifier',
    accounts.member_id AS member_id COMMENT = 'Member who owns this account',
    accounts.member_name AS member_name WITH SYNONYMS = ('account holder') COMMENT = 'Name of the account holder',
    accounts.account_type AS account_type WITH SYNONYMS = ('product type') COMMENT = 'Account type: SHARE_SAVINGS, CHECKING, SHARE_CERTIFICATE, IRA, CREDIT_CARD',
    accounts.account_subtype AS account_subtype WITH SYNONYMS = ('product subtype') COMMENT = 'Specific product variant',
    accounts.account_status AS account_status WITH SYNONYMS = ('status') COMMENT = 'Account status: ACTIVE, DORMANT, CLOSED',
    accounts.account_name AS account_name WITH SYNONYMS = ('product name') COMMENT = 'Descriptive account name',
    accounts.overdraft_protection AS overdraft_protection COMMENT = 'Whether overdraft protection is enabled',
    accounts.joint_account AS joint_account COMMENT = 'Whether this is a joint account',
    accounts.opened_date AS opened_date WITH SYNONYMS = ('open date') COMMENT = 'Date account was opened',
    accounts.maturity_date AS maturity_date COMMENT = 'Maturity date for certificates',
    accounts.last_activity_date AS last_activity_date COMMENT = 'Date of last account activity'
  )
  METRICS (
    accounts.account_count AS COUNT(account_id) COMMENT = 'Count of accounts',
    accounts.total_current_balance AS SUM(current_balance) WITH SYNONYMS = ('total balance') COMMENT = 'Total current account balance',
    accounts.avg_current_balance AS AVG(current_balance) WITH SYNONYMS = ('average balance') COMMENT = 'Average current balance',
    accounts.total_available_balance AS SUM(available_balance) COMMENT = 'Total available balance',
    accounts.total_credit_limit AS SUM(credit_limit) COMMENT = 'Total credit limit',
    accounts.avg_utilization_pct AS AVG(utilization_pct) WITH SYNONYMS = ('avg utilization') COMMENT = 'Average credit utilization percentage',
    accounts.avg_dividend_rate AS AVG(dividend_rate) WITH SYNONYMS = ('avg rate') COMMENT = 'Average dividend/interest rate',
    accounts.avg_apy_rate AS AVG(apy_rate) WITH SYNONYMS = ('avg APY') COMMENT = 'Average annual percentage yield',
    accounts.avg_account_age_days AS AVG(account_age_days) WITH SYNONYMS = ('avg account age') COMMENT = 'Average days since account opened',
    accounts.total_monthly_transactions AS SUM(monthly_transactions) COMMENT = 'Total monthly transactions',
    accounts.total_monthly_volume AS SUM(monthly_volume) COMMENT = 'Total monthly transaction volume'
  )
  COMMENT = 'Semantic view for analyzing MACU account data including deposits, credit, and activity';

-- ============================================================================
-- Semantic View 3: Loan Portfolio Analytics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_LOAN_ANALYTICS
  TABLES (
    loans AS V_LOAN_PORTFOLIO
      PRIMARY KEY (loan_id)
      COMMENT = 'Loan portfolio with balances and delinquency status'
  )
  DIMENSIONS (
    loans.loan_id AS loan_id WITH SYNONYMS = ('loan number') COMMENT = 'Unique loan identifier',
    loans.member_id AS member_id COMMENT = 'Member who holds this loan',
    loans.member_name AS member_name WITH SYNONYMS = ('borrower') COMMENT = 'Name of the borrower',
    loans.loan_type AS loan_type WITH SYNONYMS = ('loan category') COMMENT = 'Loan type: AUTO, MORTGAGE, HOME_EQUITY, PERSONAL, RV_BOAT',
    loans.loan_subtype AS loan_subtype COMMENT = 'Specific loan variant',
    loans.loan_status AS loan_status WITH SYNONYMS = ('status') COMMENT = 'Loan status: ACTIVE, PAID_OFF, DELINQUENT',
    loans.collateral_type AS collateral_type COMMENT = 'Type of collateral securing the loan',
    loans.delinquency_status AS delinquency_status COMMENT = 'Current delinquency status',
    loans.autopay_enrolled AS autopay_enrolled WITH SYNONYMS = ('autopay') COMMENT = 'Whether automatic payments are enrolled',
    loans.origination_date AS origination_date WITH SYNONYMS = ('funded date') COMMENT = 'Date loan was originated',
    loans.maturity_date AS maturity_date WITH SYNONYMS = ('payoff date') COMMENT = 'Loan maturity date',
    loans.next_payment_date AS next_payment_date COMMENT = 'Next payment due date'
  )
  METRICS (
    loans.loan_count AS COUNT(loan_id) COMMENT = 'Count of loans',
    loans.total_original_amount AS SUM(original_amount) WITH SYNONYMS = ('total funded') COMMENT = 'Total original loan amount',
    loans.avg_original_amount AS AVG(original_amount) WITH SYNONYMS = ('avg loan amount') COMMENT = 'Average original loan amount',
    loans.total_current_balance AS SUM(current_balance) WITH SYNONYMS = ('total balance') COMMENT = 'Total current outstanding balance',
    loans.avg_current_balance AS AVG(current_balance) WITH SYNONYMS = ('avg balance') COMMENT = 'Average current balance',
    loans.total_principal_paid AS SUM(principal_paid) COMMENT = 'Total principal paid',
    loans.avg_pct_paid AS AVG(pct_paid) WITH SYNONYMS = ('avg percent paid') COMMENT = 'Average percentage of loan paid off',
    loans.avg_interest_rate AS AVG(interest_rate) WITH SYNONYMS = ('avg rate') COMMENT = 'Average interest rate on loans',
    loans.avg_apr AS AVG(apr) COMMENT = 'Average annual percentage rate',
    loans.avg_term_months AS AVG(term_months) WITH SYNONYMS = ('avg term') COMMENT = 'Average loan term in months',
    loans.total_monthly_payment AS SUM(monthly_payment) WITH SYNONYMS = ('total payments') COMMENT = 'Total monthly payment amount',
    loans.avg_monthly_payment AS AVG(monthly_payment) WITH SYNONYMS = ('avg payment') COMMENT = 'Average monthly payment',
    loans.total_collateral_value AS SUM(collateral_value) COMMENT = 'Total value of collateral',
    loans.avg_ltv_ratio AS AVG(ltv_ratio) WITH SYNONYMS = ('avg LTV') COMMENT = 'Average loan to value ratio',
    loans.avg_days_past_due AS AVG(days_past_due) WITH SYNONYMS = ('avg DPD') COMMENT = 'Average days past due',
    loans.total_30_day_lates AS SUM(times_30_days_late) COMMENT = 'Total count of 30-day late payments',
    loans.total_60_day_lates AS SUM(times_60_days_late) COMMENT = 'Total count of 60-day late payments',
    loans.total_90_day_lates AS SUM(times_90_days_late) COMMENT = 'Total count of 90+ day late payments',
    loans.avg_credit_score AS AVG(current_credit_score) WITH SYNONYMS = ('avg credit score') COMMENT = 'Average borrower credit score'
  )
  COMMENT = 'Semantic view for analyzing MACU loan portfolio including auto, mortgage, and personal loans';

-- ============================================================================
-- Semantic View 4: Transaction Analytics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_TRANSACTION_ANALYTICS
  TABLES (
    transactions AS V_TRANSACTION_ANALYTICS
      PRIMARY KEY (transaction_id)
      COMMENT = 'Transaction details with merchant and fraud information'
  )
  DIMENSIONS (
    transactions.transaction_id AS transaction_id WITH SYNONYMS = ('transaction number') COMMENT = 'Unique transaction identifier',
    transactions.account_id AS account_id COMMENT = 'Account involved in transaction',
    transactions.member_id AS member_id COMMENT = 'Member involved in transaction',
    transactions.member_name AS member_name COMMENT = 'Member name',
    transactions.account_type AS account_type COMMENT = 'Type of account',
    transactions.transaction_type AS transaction_type COMMENT = 'Transaction type: PURCHASE, DEPOSIT, TRANSFER, etc.',
    transactions.transaction_category AS transaction_category WITH SYNONYMS = ('category') COMMENT = 'Spending category',
    transactions.flow_direction AS flow_direction COMMENT = 'Whether money is CREDIT or DEBIT',
    transactions.merchant_name AS merchant_name WITH SYNONYMS = ('merchant') COMMENT = 'Name of merchant',
    transactions.merchant_category AS merchant_category WITH SYNONYMS = ('MCC') COMMENT = 'Merchant category code',
    transactions.mcc_category_name AS mcc_category_name COMMENT = 'MCC category description',
    transactions.mcc_category_group AS mcc_category_group WITH SYNONYMS = ('spending type') COMMENT = 'MCC category group',
    transactions.merchant_city AS merchant_city COMMENT = 'Merchant city',
    transactions.merchant_state AS merchant_state COMMENT = 'Merchant state',
    transactions.is_recurring AS is_recurring WITH SYNONYMS = ('recurring') COMMENT = 'Whether this is a recurring transaction',
    transactions.is_international AS is_international WITH SYNONYMS = ('international') COMMENT = 'Whether transaction is international',
    transactions.status AS status COMMENT = 'Transaction status',
    transactions.risk_level AS risk_level WITH SYNONYMS = ('fraud risk') COMMENT = 'Fraud risk assessment',
    transactions.channel AS channel COMMENT = 'Transaction channel',
    transactions.device_type AS device_type WITH SYNONYMS = ('device') COMMENT = 'Device used for transaction',
    transactions.day_of_week AS day_of_week COMMENT = 'Day of week transaction occurred',
    transactions.transaction_date AS transaction_date WITH SYNONYMS = ('date') COMMENT = 'Date of transaction',
    transactions.transaction_timestamp AS transaction_timestamp WITH SYNONYMS = ('time') COMMENT = 'Timestamp of transaction'
  )
  METRICS (
    transactions.transaction_count AS COUNT(transaction_id) COMMENT = 'Count of transactions',
    transactions.total_amount AS SUM(amount) COMMENT = 'Sum of transaction amounts (net of credits and debits)',
    transactions.total_absolute_amount AS SUM(absolute_amount) WITH SYNONYMS = ('total volume') COMMENT = 'Sum of absolute transaction amounts',
    transactions.avg_amount AS AVG(absolute_amount) WITH SYNONYMS = ('average amount') COMMENT = 'Average transaction amount',
    transactions.avg_fraud_score AS AVG(fraud_score) COMMENT = 'Average fraud probability score'
  )
  COMMENT = 'Semantic view for analyzing MACU transaction patterns and spending behavior';

-- ============================================================================
-- Semantic View 5: Support Analytics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_SUPPORT_ANALYTICS
  TABLES (
    interactions AS V_SUPPORT_ANALYTICS
      PRIMARY KEY (interaction_id)
      COMMENT = 'Support interaction details with satisfaction metrics'
  )
  DIMENSIONS (
    interactions.interaction_id AS interaction_id WITH SYNONYMS = ('case number') COMMENT = 'Unique support interaction identifier',
    interactions.member_id AS member_id COMMENT = 'Member who initiated support contact',
    interactions.member_name AS member_name COMMENT = 'Member name',
    interactions.membership_tier AS membership_tier WITH SYNONYMS = ('member tier') COMMENT = 'Member tier at time of interaction',
    interactions.agent_id AS agent_id WITH SYNONYMS = ('agent') COMMENT = 'Support agent who handled the interaction',
    interactions.interaction_type AS interaction_type WITH SYNONYMS = ('contact type') COMMENT = 'Type of interaction: CALL, CHAT, EMAIL, etc.',
    interactions.channel AS channel COMMENT = 'Contact channel',
    interactions.category AS category WITH SYNONYMS = ('issue category') COMMENT = 'Category of the issue',
    interactions.subcategory AS subcategory WITH SYNONYMS = ('issue type') COMMENT = 'Specific issue type',
    interactions.subject AS subject WITH SYNONYMS = ('issue') COMMENT = 'Subject or summary of the interaction',
    interactions.resolution_status AS resolution_status WITH SYNONYMS = ('status') COMMENT = 'Current resolution status',
    interactions.resolution_achieved AS resolution_achieved WITH SYNONYMS = ('resolved') COMMENT = 'Whether issue was resolved',
    interactions.nps_category AS nps_category COMMENT = 'NPS classification: PROMOTER, PASSIVE, or DETRACTOR',
    interactions.escalated AS escalated COMMENT = 'Whether interaction was escalated',
    interactions.first_contact_resolution AS first_contact_resolution WITH SYNONYMS = ('FCR') COMMENT = 'Whether resolved on first contact',
    interactions.branch_id AS branch_id COMMENT = 'Branch associated with interaction',
    interactions.branch_name AS branch_name WITH SYNONYMS = ('branch') COMMENT = 'Branch name',
    interactions.region AS region COMMENT = 'Geographic region',
    interactions.day_of_week AS day_of_week COMMENT = 'Day of week of interaction',
    interactions.interaction_date AS interaction_date WITH SYNONYMS = ('date') COMMENT = 'Date of interaction',
    interactions.interaction_timestamp AS interaction_timestamp WITH SYNONYMS = ('time') COMMENT = 'Timestamp of interaction'
  )
  METRICS (
    interactions.interaction_count AS COUNT(interaction_id) COMMENT = 'Count of interactions',
    interactions.total_duration_seconds AS SUM(duration_seconds) COMMENT = 'Total duration in seconds',
    interactions.avg_duration_minutes AS AVG(duration_minutes) WITH SYNONYMS = ('avg duration') COMMENT = 'Average duration in minutes',
    interactions.avg_satisfaction_score AS AVG(satisfaction_score) WITH SYNONYMS = ('avg CSAT') COMMENT = 'Average customer satisfaction score',
    interactions.avg_nps_score AS AVG(nps_score) WITH SYNONYMS = ('avg NPS') COMMENT = 'Average Net Promoter Score'
  )
  COMMENT = 'Semantic view for analyzing MACU member support interactions and satisfaction';

-- Display confirmation
SELECT 'Semantic views created successfully' AS STATUS, 5 AS semantic_views_created;
