-- ============================================================================
-- Mountain America Credit Union Intelligence Agent - Core Tables
-- ============================================================================
-- Purpose: Create core data tables for MACU banking operations
-- Credit Union specific products: Share accounts, Share certificates,
-- Auto loans, Home equity, Personal loans, Credit cards
-- ============================================================================

USE DATABASE MACU_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE MACU_WH;

-- ============================================================================
-- Table 1: MEMBERS (Credit Union term for customers)
-- ============================================================================
CREATE OR REPLACE TABLE MEMBERS (
    member_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(20),
    date_of_birth DATE,
    ssn_last_four VARCHAR(4),
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    address_state VARCHAR(2),
    zip_code VARCHAR(10),
    membership_date DATE,
    member_status VARCHAR(20) DEFAULT 'ACTIVE',
    membership_tier VARCHAR(20) DEFAULT 'STANDARD',
    kyc_status VARCHAR(20) DEFAULT 'PENDING',
    risk_tier VARCHAR(10) DEFAULT 'MEDIUM',
    credit_score INTEGER,
    income_verified DECIMAL(12, 2),
    employment_status VARCHAR(30),
    employer_name VARCHAR(255),
    acquisition_channel VARCHAR(50),
    referral_member_id VARCHAR(20),
    primary_branch_id VARCHAR(10),
    digital_banking_enrolled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'Credit union member information and demographics';

-- ============================================================================
-- Table 2: ACCOUNTS (Share accounts, checking, certificates)
-- ============================================================================
CREATE OR REPLACE TABLE ACCOUNTS (
    account_id VARCHAR(20) PRIMARY KEY,
    member_id VARCHAR(20) NOT NULL,
    account_type VARCHAR(30) NOT NULL,
    account_subtype VARCHAR(30),
    account_status VARCHAR(20) DEFAULT 'ACTIVE',
    account_name VARCHAR(100),
    current_balance DECIMAL(15, 2) DEFAULT 0,
    available_balance DECIMAL(15, 2) DEFAULT 0,
    pending_balance DECIMAL(15, 2) DEFAULT 0,
    minimum_balance DECIMAL(15, 2) DEFAULT 0,
    credit_limit DECIMAL(15, 2) DEFAULT 0,
    dividend_rate DECIMAL(6, 4) DEFAULT 0,
    apy_rate DECIMAL(6, 4) DEFAULT 0,
    term_months INTEGER,
    maturity_date DATE,
    opened_date DATE,
    last_activity_date DATE,
    overdraft_protection BOOLEAN DEFAULT FALSE,
    joint_account BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT fk_member FOREIGN KEY (member_id) REFERENCES MEMBERS(member_id)
) COMMENT = 'Member deposit and credit accounts';

-- ============================================================================
-- Table 3: LOANS (Auto, mortgage, personal, home equity)
-- ============================================================================
CREATE OR REPLACE TABLE LOANS (
    loan_id VARCHAR(20) PRIMARY KEY,
    member_id VARCHAR(20) NOT NULL,
    account_id VARCHAR(20),
    loan_type VARCHAR(30) NOT NULL,
    loan_subtype VARCHAR(30),
    loan_status VARCHAR(20) DEFAULT 'ACTIVE',
    original_amount DECIMAL(15, 2),
    current_balance DECIMAL(15, 2),
    interest_rate DECIMAL(6, 4),
    apr DECIMAL(6, 4),
    term_months INTEGER,
    monthly_payment DECIMAL(10, 2),
    payment_due_day INTEGER,
    next_payment_date DATE,
    origination_date DATE,
    maturity_date DATE,
    collateral_type VARCHAR(50),
    collateral_value DECIMAL(15, 2),
    ltv_ratio DECIMAL(5, 2),
    days_past_due INTEGER DEFAULT 0,
    times_30_days_late INTEGER DEFAULT 0,
    times_60_days_late INTEGER DEFAULT 0,
    times_90_days_late INTEGER DEFAULT 0,
    autopay_enrolled BOOLEAN DEFAULT FALSE,
    refinanced_from_loan_id VARCHAR(20),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT fk_loan_member FOREIGN KEY (member_id) REFERENCES MEMBERS(member_id)
) COMMENT = 'Member loan products including auto, mortgage, personal';

-- ============================================================================
-- Table 4: CARDS (Debit and credit cards)
-- ============================================================================
CREATE OR REPLACE TABLE CARDS (
    card_id VARCHAR(20) PRIMARY KEY,
    member_id VARCHAR(20) NOT NULL,
    account_id VARCHAR(20) NOT NULL,
    card_type VARCHAR(20) NOT NULL,
    card_product VARCHAR(50),
    card_status VARCHAR(20) DEFAULT 'ACTIVE',
    card_number_last_four VARCHAR(4),
    expiration_date DATE,
    activation_date DATE,
    daily_limit DECIMAL(10, 2),
    monthly_limit DECIMAL(12, 2),
    international_enabled BOOLEAN DEFAULT FALSE,
    contactless_enabled BOOLEAN DEFAULT TRUE,
    virtual_card BOOLEAN DEFAULT FALSE,
    rewards_program VARCHAR(50),
    rewards_points_balance INTEGER DEFAULT 0,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT fk_card_member FOREIGN KEY (member_id) REFERENCES MEMBERS(member_id),
    CONSTRAINT fk_card_account FOREIGN KEY (account_id) REFERENCES ACCOUNTS(account_id)
) COMMENT = 'Member debit and credit cards';

-- ============================================================================
-- Table 5: TRANSACTIONS
-- ============================================================================
CREATE OR REPLACE TABLE TRANSACTIONS (
    transaction_id VARCHAR(30) PRIMARY KEY,
    account_id VARCHAR(20) NOT NULL,
    member_id VARCHAR(20) NOT NULL,
    card_id VARCHAR(20),
    transaction_type VARCHAR(20) NOT NULL,
    transaction_category VARCHAR(30),
    amount DECIMAL(15, 2) NOT NULL,
    running_balance DECIMAL(15, 2),
    transaction_date DATE NOT NULL,
    transaction_timestamp TIMESTAMP_NTZ NOT NULL,
    posted_date DATE,
    description VARCHAR(500),
    merchant_name VARCHAR(255),
    merchant_category VARCHAR(10),
    merchant_city VARCHAR(100),
    merchant_state VARCHAR(2),
    merchant_country VARCHAR(3) DEFAULT 'USA',
    is_recurring BOOLEAN DEFAULT FALSE,
    is_international BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'COMPLETED',
    fraud_score DECIMAL(5, 4),
    dispute_status VARCHAR(20),
    channel VARCHAR(30),
    device_type VARCHAR(30),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT fk_txn_account FOREIGN KEY (account_id) REFERENCES ACCOUNTS(account_id),
    CONSTRAINT fk_txn_member FOREIGN KEY (member_id) REFERENCES MEMBERS(member_id)
) COMMENT = 'All financial transactions across accounts';

-- ============================================================================
-- Table 6: DIRECT_DEPOSITS
-- ============================================================================
CREATE OR REPLACE TABLE DIRECT_DEPOSITS (
    deposit_id VARCHAR(20) PRIMARY KEY,
    member_id VARCHAR(20) NOT NULL,
    account_id VARCHAR(20) NOT NULL,
    deposit_type VARCHAR(30),
    source_name VARCHAR(255),
    amount DECIMAL(12, 2),
    frequency VARCHAR(20),
    deposit_date DATE,
    routing_number VARCHAR(9),
    is_active BOOLEAN DEFAULT TRUE,
    first_deposit_date DATE,
    last_deposit_date DATE,
    avg_deposit_amount DECIMAL(12, 2),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT fk_dd_member FOREIGN KEY (member_id) REFERENCES MEMBERS(member_id),
    CONSTRAINT fk_dd_account FOREIGN KEY (account_id) REFERENCES ACCOUNTS(account_id)
) COMMENT = 'Direct deposit information and history';

-- ============================================================================
-- Table 7: LOAN_APPLICATIONS
-- ============================================================================
CREATE OR REPLACE TABLE LOAN_APPLICATIONS (
    application_id VARCHAR(20) PRIMARY KEY,
    member_id VARCHAR(20) NOT NULL,
    loan_type VARCHAR(30) NOT NULL,
    loan_subtype VARCHAR(30),
    application_status VARCHAR(20) DEFAULT 'PENDING',
    requested_amount DECIMAL(15, 2),
    approved_amount DECIMAL(15, 2),
    requested_term_months INTEGER,
    approved_term_months INTEGER,
    approved_rate DECIMAL(6, 4),
    application_date DATE,
    decision_date DATE,
    decision_reason_codes VARCHAR(500),
    credit_score_at_application INTEGER,
    dti_ratio DECIMAL(5, 2),
    employment_verified BOOLEAN,
    income_verified BOOLEAN,
    collateral_verified BOOLEAN,
    underwriter_id VARCHAR(20),
    channel VARCHAR(30),
    promo_code VARCHAR(20),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT fk_app_member FOREIGN KEY (member_id) REFERENCES MEMBERS(member_id)
) COMMENT = 'Loan application history and decisions';

-- ============================================================================
-- Table 8: SUPPORT_INTERACTIONS
-- ============================================================================
CREATE OR REPLACE TABLE SUPPORT_INTERACTIONS (
    interaction_id VARCHAR(20) PRIMARY KEY,
    member_id VARCHAR(20),
    agent_id VARCHAR(20),
    interaction_type VARCHAR(30),
    channel VARCHAR(30),
    category VARCHAR(50),
    subcategory VARCHAR(50),
    subject VARCHAR(255),
    interaction_date DATE,
    interaction_timestamp TIMESTAMP_NTZ,
    duration_seconds INTEGER,
    resolution_status VARCHAR(20),
    resolution_achieved BOOLEAN,
    satisfaction_score INTEGER,
    nps_score INTEGER,
    escalated BOOLEAN DEFAULT FALSE,
    first_contact_resolution BOOLEAN,
    branch_id VARCHAR(10),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT fk_support_member FOREIGN KEY (member_id) REFERENCES MEMBERS(member_id)
) COMMENT = 'Member support and service interactions';

-- ============================================================================
-- Table 9: SUPPORT_TRANSCRIPTS
-- ============================================================================
CREATE OR REPLACE TABLE SUPPORT_TRANSCRIPTS (
    transcript_id VARCHAR(20) PRIMARY KEY,
    interaction_id VARCHAR(20) NOT NULL,
    member_id VARCHAR(20),
    agent_id VARCHAR(20),
    interaction_date DATE,
    interaction_type VARCHAR(30),
    category VARCHAR(50),
    subcategory VARCHAR(50),
    transcript_text TEXT,
    sentiment_score DECIMAL(5, 4),
    resolution_achieved BOOLEAN,
    key_topics ARRAY,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT fk_transcript_interaction FOREIGN KEY (interaction_id) REFERENCES SUPPORT_INTERACTIONS(interaction_id)
) COMMENT = 'Support interaction transcripts for search';

-- ============================================================================
-- Table 10: COMPLIANCE_DOCUMENTS
-- ============================================================================
CREATE OR REPLACE TABLE COMPLIANCE_DOCUMENTS (
    document_id VARCHAR(20) PRIMARY KEY,
    document_type VARCHAR(50),
    title VARCHAR(255),
    content TEXT,
    version VARCHAR(20),
    effective_date DATE,
    expiration_date DATE,
    department VARCHAR(50),
    tags ARRAY,
    regulatory_reference VARCHAR(255),
    last_reviewed_date DATE,
    next_review_date DATE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'Compliance policies and regulatory documents';

-- ============================================================================
-- Table 11: PRODUCT_KNOWLEDGE
-- ============================================================================
CREATE OR REPLACE TABLE PRODUCT_KNOWLEDGE (
    knowledge_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    title VARCHAR(255),
    content TEXT,
    version VARCHAR(20),
    effective_date DATE,
    tags ARRAY,
    related_products ARRAY,
    faq_questions ARRAY,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'Product documentation and knowledge base';

-- ============================================================================
-- Table 12: MERCHANT_CATEGORIES
-- ============================================================================
CREATE OR REPLACE TABLE MERCHANT_CATEGORIES (
    mcc_code VARCHAR(10) PRIMARY KEY,
    category_name VARCHAR(100),
    category_group VARCHAR(50),
    description VARCHAR(500),
    cashback_eligible BOOLEAN DEFAULT TRUE,
    rewards_multiplier DECIMAL(3, 1) DEFAULT 1.0,
    high_risk_category BOOLEAN DEFAULT FALSE,
    spending_limit_category BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'Merchant category code definitions';

-- ============================================================================
-- Table 13: COMPLIANCE_EVENTS
-- ============================================================================
CREATE OR REPLACE TABLE COMPLIANCE_EVENTS (
    event_id VARCHAR(20) PRIMARY KEY,
    member_id VARCHAR(20),
    account_id VARCHAR(20),
    transaction_id VARCHAR(30),
    event_type VARCHAR(50),
    event_date DATE,
    event_timestamp TIMESTAMP_NTZ,
    severity VARCHAR(20),
    description TEXT,
    amount_involved DECIMAL(15, 2),
    status VARCHAR(20) DEFAULT 'OPEN',
    assigned_to VARCHAR(50),
    resolution_date DATE,
    resolution_notes TEXT,
    regulatory_filing_required BOOLEAN DEFAULT FALSE,
    filing_reference VARCHAR(50),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT fk_compliance_member FOREIGN KEY (member_id) REFERENCES MEMBERS(member_id)
) COMMENT = 'BSA/AML compliance events and investigations';

-- ============================================================================
-- Table 14: EXTERNAL_DATA
-- ============================================================================
CREATE OR REPLACE TABLE EXTERNAL_DATA (
    external_data_id VARCHAR(20) PRIMARY KEY,
    member_id VARCHAR(20) NOT NULL,
    data_source VARCHAR(50),
    data_type VARCHAR(50),
    request_date DATE,
    response_date DATE,
    status VARCHAR(20),
    credit_score INTEGER,
    credit_score_model VARCHAR(50),
    report_data VARIANT,
    verification_result VARCHAR(20),
    expiration_date DATE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT fk_external_member FOREIGN KEY (member_id) REFERENCES MEMBERS(member_id)
) COMMENT = 'External credit bureau and verification data';

-- ============================================================================
-- Table 15: DEVICE_SESSIONS
-- ============================================================================
CREATE OR REPLACE TABLE DEVICE_SESSIONS (
    session_id VARCHAR(30) PRIMARY KEY,
    member_id VARCHAR(20) NOT NULL,
    device_id VARCHAR(100),
    device_type VARCHAR(30),
    device_os VARCHAR(50),
    browser VARCHAR(50),
    ip_address VARCHAR(45),
    location_city VARCHAR(100),
    location_state VARCHAR(2),
    location_country VARCHAR(3),
    session_start TIMESTAMP_NTZ,
    session_end TIMESTAMP_NTZ,
    session_duration_seconds INTEGER,
    pages_viewed INTEGER,
    actions_taken INTEGER,
    is_mobile_app BOOLEAN DEFAULT FALSE,
    app_version VARCHAR(20),
    risk_score DECIMAL(5, 4),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT fk_session_member FOREIGN KEY (member_id) REFERENCES MEMBERS(member_id)
) COMMENT = 'Digital banking session tracking';

-- ============================================================================
-- Table 16: BRANCHES
-- ============================================================================
CREATE OR REPLACE TABLE BRANCHES (
    branch_id VARCHAR(10) PRIMARY KEY,
    branch_name VARCHAR(100),
    branch_type VARCHAR(30),
    address_line1 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    phone VARCHAR(20),
    manager_id VARCHAR(20),
    region VARCHAR(50),
    opened_date DATE,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    atm_count INTEGER DEFAULT 0,
    drive_through BOOLEAN DEFAULT FALSE,
    saturday_hours BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'Credit union branch locations';

-- Display confirmation
SELECT 'All core tables created successfully for MACU Intelligence' AS STATUS;
