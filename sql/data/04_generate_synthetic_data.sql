-- ============================================================================
-- Mountain America Credit Union - Synthetic Data Generation
-- ============================================================================
-- Purpose: Generate realistic synthetic data for the MACU Intelligence demo
--          including members, accounts, loans, transactions, and support data
-- ============================================================================

USE DATABASE MACU_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE MACU_WH;

-- ============================================================================
-- Section 1: Reference Data - Branches
-- ============================================================================

TRUNCATE TABLE IF EXISTS BRANCHES;

INSERT INTO BRANCHES (branch_id, branch_name, branch_type, address_line1, city, state, zip_code, phone, manager_id, region, opened_date, status, atm_count, drive_through, saturday_hours, created_at)
SELECT 
    'BR' || LPAD(seq4()::VARCHAR, 4, '0'),
    branch_name,
    'FULL_SERVICE',
    address_line1,
    city,
    state,
    zip_code,
    '801-' || LPAD((UNIFORM(200, 999, RANDOM()))::VARCHAR, 3, '0') || '-' || LPAD((UNIFORM(1000, 9999, RANDOM()))::VARCHAR, 4, '0'),
    'MGR' || LPAD(seq4()::VARCHAR, 4, '0'),
    region,
    DATEADD('day', -UNIFORM(365, 7300, RANDOM()), CURRENT_DATE()),
    'ACTIVE',
    UNIFORM(1, 4, RANDOM()),
    UNIFORM(0, 100, RANDOM()) < 70,
    TRUE,
    CURRENT_TIMESTAMP()
FROM (
    SELECT 
        seq4() as rn,
        CASE seq4() % 30
            WHEN 0 THEN 'Salt Lake City Main'
            WHEN 1 THEN 'Provo Center'
            WHEN 2 THEN 'Ogden Downtown'
            WHEN 3 THEN 'Sandy Branch'
            WHEN 4 THEN 'West Valley'
            WHEN 5 THEN 'Draper'
            WHEN 6 THEN 'Lehi Tech Corridor'
            WHEN 7 THEN 'St. George'
            WHEN 8 THEN 'Logan'
            WHEN 9 THEN 'Orem University'
            WHEN 10 THEN 'Bountiful'
            WHEN 11 THEN 'Murray'
            WHEN 12 THEN 'Taylorsville'
            WHEN 13 THEN 'South Jordan'
            WHEN 14 THEN 'American Fork'
            WHEN 15 THEN 'Boise Main'
            WHEN 16 THEN 'Meridian'
            WHEN 17 THEN 'Idaho Falls'
            WHEN 18 THEN 'Mesa'
            WHEN 19 THEN 'Gilbert'
            WHEN 20 THEN 'Chandler'
            WHEN 21 THEN 'Las Vegas Henderson'
            WHEN 22 THEN 'Las Vegas Summerlin'
            WHEN 23 THEN 'Albuquerque'
            WHEN 24 THEN 'Cedar City'
            WHEN 25 THEN 'Park City'
            WHEN 26 THEN 'Layton'
            WHEN 27 THEN 'Spanish Fork'
            WHEN 28 THEN 'Tooele'
            ELSE 'Herriman'
        END as branch_name,
        CASE seq4() % 30
            WHEN 0 THEN '123 Main Street'
            WHEN 1 THEN '456 Center Street'
            WHEN 2 THEN '789 Washington Blvd'
            WHEN 3 THEN '321 State Street'
            WHEN 4 THEN '555 West Valley Blvd'
            WHEN 5 THEN '777 Draper Parkway'
            WHEN 6 THEN '999 Innovation Way'
            WHEN 7 THEN '111 Red Cliffs Drive'
            WHEN 8 THEN '222 Main Street'
            WHEN 9 THEN '333 University Ave'
            ELSE (UNIFORM(100, 9999, RANDOM()))::VARCHAR || ' Commerce Drive'
        END as address_line1,
        CASE seq4() % 30
            WHEN 0 THEN 'Salt Lake City' WHEN 1 THEN 'Provo' WHEN 2 THEN 'Ogden'
            WHEN 3 THEN 'Sandy' WHEN 4 THEN 'West Valley City' WHEN 5 THEN 'Draper'
            WHEN 6 THEN 'Lehi' WHEN 7 THEN 'St. George' WHEN 8 THEN 'Logan'
            WHEN 9 THEN 'Orem' WHEN 10 THEN 'Bountiful' WHEN 11 THEN 'Murray'
            WHEN 12 THEN 'Taylorsville' WHEN 13 THEN 'South Jordan' WHEN 14 THEN 'American Fork'
            WHEN 15 THEN 'Boise' WHEN 16 THEN 'Meridian' WHEN 17 THEN 'Idaho Falls'
            WHEN 18 THEN 'Mesa' WHEN 19 THEN 'Gilbert' WHEN 20 THEN 'Chandler'
            WHEN 21 THEN 'Henderson' WHEN 22 THEN 'Las Vegas' WHEN 23 THEN 'Albuquerque'
            WHEN 24 THEN 'Cedar City' WHEN 25 THEN 'Park City' WHEN 26 THEN 'Layton'
            WHEN 27 THEN 'Spanish Fork' WHEN 28 THEN 'Tooele' ELSE 'Herriman'
        END as city,
        CASE 
            WHEN seq4() % 30 BETWEEN 0 AND 14 THEN 'UT'
            WHEN seq4() % 30 BETWEEN 15 AND 17 THEN 'ID'
            WHEN seq4() % 30 BETWEEN 18 AND 20 THEN 'AZ'
            WHEN seq4() % 30 BETWEEN 21 AND 22 THEN 'NV'
            WHEN seq4() % 30 = 23 THEN 'NM'
            ELSE 'UT'
        END as state,
        CASE 
            WHEN seq4() % 30 BETWEEN 0 AND 14 THEN '84' || LPAD((UNIFORM(100, 199, RANDOM()))::VARCHAR, 3, '0')
            WHEN seq4() % 30 BETWEEN 15 AND 17 THEN '83' || LPAD((UNIFORM(600, 699, RANDOM()))::VARCHAR, 3, '0')
            WHEN seq4() % 30 BETWEEN 18 AND 20 THEN '85' || LPAD((UNIFORM(200, 299, RANDOM()))::VARCHAR, 3, '0')
            WHEN seq4() % 30 BETWEEN 21 AND 22 THEN '89' || LPAD((UNIFORM(100, 199, RANDOM()))::VARCHAR, 3, '0')
            ELSE '87' || LPAD((UNIFORM(100, 199, RANDOM()))::VARCHAR, 3, '0')
        END as zip_code,
        CASE seq4() % 10
            WHEN 0 THEN 'Michael' WHEN 1 THEN 'Jennifer' WHEN 2 THEN 'David'
            WHEN 3 THEN 'Sarah' WHEN 4 THEN 'Christopher' WHEN 5 THEN 'Amanda'
            WHEN 6 THEN 'Matthew' WHEN 7 THEN 'Jessica' WHEN 8 THEN 'Daniel'
            ELSE 'Ashley'
        END as first_name,
        CASE seq4() % 10
            WHEN 0 THEN 'Johnson' WHEN 1 THEN 'Williams' WHEN 2 THEN 'Brown'
            WHEN 3 THEN 'Jones' WHEN 4 THEN 'Garcia' WHEN 5 THEN 'Miller'
            WHEN 6 THEN 'Davis' WHEN 7 THEN 'Rodriguez' WHEN 8 THEN 'Martinez'
            ELSE 'Anderson'
        END as last_name,
        CASE 
            WHEN seq4() % 30 BETWEEN 0 AND 6 THEN 'WASATCH_FRONT'
            WHEN seq4() % 30 BETWEEN 7 AND 9 THEN 'UTAH_COUNTY'
            WHEN seq4() % 30 BETWEEN 10 AND 14 THEN 'NORTHERN_UTAH'
            WHEN seq4() % 30 BETWEEN 15 AND 17 THEN 'IDAHO'
            WHEN seq4() % 30 BETWEEN 18 AND 20 THEN 'ARIZONA'
            WHEN seq4() % 30 BETWEEN 21 AND 22 THEN 'NEVADA'
            ELSE 'SOUTHWEST'
        END as region
    FROM TABLE(GENERATOR(ROWCOUNT => 30))
) src;

-- ============================================================================
-- Section 2: Reference Data - Merchant Categories
-- ============================================================================

TRUNCATE TABLE IF EXISTS MERCHANT_CATEGORIES;

-- MERCHANT_CATEGORIES will be populated in Section 13

-- ============================================================================
-- Section 3: Generate Members
-- ============================================================================

TRUNCATE TABLE IF EXISTS MEMBERS;

INSERT INTO MEMBERS (
    member_id, first_name, last_name, email, phone, date_of_birth,
    ssn_last_four, address_line1, city, address_state, zip_code,
    membership_date, member_status, membership_tier, kyc_status, risk_tier,
    credit_score, income_verified, employment_status, employer_name,
    acquisition_channel, primary_branch_id, digital_banking_enrolled,
    created_at, updated_at
)
SELECT
    'MEM' || LPAD(seq4()::VARCHAR, 7, '0') as member_id,
    first_names[UNIFORM(0, 49, RANDOM())] as first_name,
    last_names[UNIFORM(0, 49, RANDOM())] as last_name,
    LOWER(first_names[UNIFORM(0, 49, RANDOM())]) || '.' || 
        LOWER(last_names[UNIFORM(0, 49, RANDOM())]) || 
        UNIFORM(1, 999, RANDOM())::VARCHAR || '@' ||
        email_domains[UNIFORM(0, 9, RANDOM())] as email,
    '801-' || LPAD(UNIFORM(200, 999, RANDOM())::VARCHAR, 3, '0') || '-' || 
        LPAD(UNIFORM(1000, 9999, RANDOM())::VARCHAR, 4, '0') as phone,
    DATEADD('day', -UNIFORM(6570, 29200, RANDOM()), CURRENT_DATE()) as date_of_birth,
    LPAD(UNIFORM(1000, 9999, RANDOM())::VARCHAR, 4, '0') as ssn_last_four,
    UNIFORM(100, 9999, RANDOM())::VARCHAR || ' ' || 
        streets[UNIFORM(0, 19, RANDOM())] as address_line1,
    cities[UNIFORM(0, 29, RANDOM())] as city,
    states[UNIFORM(0, 4, RANDOM())] as address_state,
    CASE states[UNIFORM(0, 4, RANDOM())]
        WHEN 'UT' THEN '84' || LPAD(UNIFORM(100, 199, RANDOM())::VARCHAR, 3, '0')
        WHEN 'ID' THEN '83' || LPAD(UNIFORM(600, 699, RANDOM())::VARCHAR, 3, '0')
        WHEN 'AZ' THEN '85' || LPAD(UNIFORM(200, 299, RANDOM())::VARCHAR, 3, '0')
        WHEN 'NV' THEN '89' || LPAD(UNIFORM(100, 199, RANDOM())::VARCHAR, 3, '0')
        ELSE '87' || LPAD(UNIFORM(100, 199, RANDOM())::VARCHAR, 3, '0')
    END as zip_code,
    DATEADD('day', -UNIFORM(30, 3650, RANDOM()), CURRENT_DATE()) as membership_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 92 THEN 'ACTIVE'
         WHEN UNIFORM(0, 100, RANDOM()) < 97 THEN 'INACTIVE'
         ELSE 'CLOSED' END as member_status,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'STANDARD'
         WHEN UNIFORM(0, 100, RANDOM()) < 90 THEN 'GOLD'
         ELSE 'PLATINUM' END as membership_tier,
    'VERIFIED' as kyc_status,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN 'LOW'
         WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 'MEDIUM'
         ELSE 'HIGH' END as risk_tier,
    UNIFORM(550, 850, RANDOM()) as credit_score,
    ROUND(UNIFORM(25000, 200000, RANDOM()), -3) as income_verified,
    employment_statuses[UNIFORM(0, 4, RANDOM())] as employment_status,
    employers[UNIFORM(0, 29, RANDOM())] as employer_name,
    acquisition_channels[UNIFORM(0, 5, RANDOM())] as acquisition_channel,
    'BR' || LPAD(UNIFORM(0, 29, RANDOM())::VARCHAR, 4, '0') as primary_branch_id,
    UNIFORM(0, 100, RANDOM()) < 75 as digital_banking_enrolled,
    CURRENT_TIMESTAMP() as created_at,
    CURRENT_TIMESTAMP() as updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 10000)),
    (SELECT 
        ARRAY_CONSTRUCT('James','John','Robert','Michael','William','David','Richard','Joseph','Thomas','Christopher','Daniel','Matthew','Anthony','Mark','Donald','Steven','Paul','Andrew','Joshua','Kenneth','Kevin','Brian','George','Timothy','Ronald','Edward','Jason','Jeffrey','Ryan','Jacob','Gary','Nicholas','Eric','Jonathan','Stephen','Larry','Justin','Scott','Brandon','Benjamin','Samuel','Raymond','Gregory','Frank','Alexander','Patrick','Jack','Dennis','Jerry','Tyler','Aaron','Jose','Adam','Nathan','Henry','Douglas','Zachary','Peter','Kyle') as first_names,
        ARRAY_CONSTRUCT('Smith','Johnson','Williams','Brown','Jones','Garcia','Miller','Davis','Rodriguez','Martinez','Hernandez','Lopez','Gonzalez','Wilson','Anderson','Thomas','Taylor','Moore','Jackson','Martin','Lee','Perez','Thompson','White','Harris','Sanchez','Clark','Ramirez','Lewis','Robinson','Walker','Young','Allen','King','Wright','Scott','Torres','Nguyen','Hill','Flores','Green','Adams','Nelson','Baker','Hall','Rivera','Campbell','Mitchell','Carter','Roberts') as last_names,
        ARRAY_CONSTRUCT('gmail.com','yahoo.com','hotmail.com','outlook.com','icloud.com','aol.com','msn.com','live.com','mail.com','protonmail.com') as email_domains,
        ARRAY_CONSTRUCT('Main Street','Oak Avenue','Maple Drive','Cedar Lane','Pine Road','Elm Street','Park Avenue','Lake Drive','Mountain View','Valley Road','Center Street','State Street','University Avenue','Highland Drive','Redwood Road','Fort Union Blvd','Bangerter Highway','Legacy Parkway','Wasatch Blvd','Technology Way') as streets,
        ARRAY_CONSTRUCT('Salt Lake City','Provo','Ogden','Sandy','West Valley City','Draper','Lehi','St. George','Logan','Orem','Bountiful','Murray','Taylorsville','South Jordan','American Fork','Boise','Meridian','Idaho Falls','Mesa','Gilbert','Chandler','Henderson','Las Vegas','Albuquerque','Cedar City','Park City','Layton','Spanish Fork','Tooele','Herriman') as cities,
        ARRAY_CONSTRUCT('UT','ID','AZ','NV','NM') as states,
        ARRAY_CONSTRUCT('EMPLOYED','SELF_EMPLOYED','RETIRED','STUDENT','UNEMPLOYED') as employment_statuses,
        ARRAY_CONSTRUCT('Intermountain Healthcare','University of Utah','Brigham Young University','Utah State University','Zions Bank','Goldman Sachs','Adobe','Microsoft','Amazon','Overstock','Domo','Qualtrics','Pluralsight','Ancestry','eBay','Hill Air Force Base','Delta Airlines','SkyWest Airlines','Rio Tinto','Walmart','Costco','Home Depot','Target','UPS','FedEx','Comcast','AT&T','Verizon','State of Utah','LDS Church') as employers,
        ARRAY_CONSTRUCT('BRANCH','ONLINE','MOBILE','REFERRAL','EMPLOYER','MARKETING') as acquisition_channels
    );

-- ============================================================================
-- Section 4: Generate Accounts
-- ============================================================================

TRUNCATE TABLE IF EXISTS ACCOUNTS;

-- Share Savings (every member gets one)
INSERT INTO ACCOUNTS (
    account_id, member_id, account_type, account_subtype, account_status,
    account_name, current_balance, available_balance, pending_balance, minimum_balance, credit_limit,
    dividend_rate, apy_rate, term_months, maturity_date,
    opened_date, last_activity_date, overdraft_protection, joint_account,
    created_at, updated_at
)
SELECT
    'ACC' || LPAD(ROW_NUMBER() OVER (ORDER BY member_id)::VARCHAR, 8, '0'),
    member_id,
    'SHARE_SAVINGS',
    'PRIMARY_SAVINGS',
    member_status,
    'Primary Share Savings',
    ROUND(UNIFORM(5, 25000, RANDOM()), 2),
    ROUND(UNIFORM(5, 25000, RANDOM()), 2),
    0,
    5.00,
    NULL,
    0.10,
    0.10,
    NULL,
    NULL,
    membership_date,
    DATEADD('day', -UNIFORM(0, 30, RANDOM()), CURRENT_DATE()),
    FALSE,
    UNIFORM(0, 100, RANDOM()) < 15,
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
FROM MEMBERS;

-- Checking accounts (70% of members)
INSERT INTO ACCOUNTS (
    account_id, member_id, account_type, account_subtype, account_status,
    account_name, current_balance, available_balance, pending_balance, minimum_balance, credit_limit,
    dividend_rate, apy_rate, term_months, maturity_date,
    opened_date, last_activity_date, overdraft_protection, joint_account,
    created_at, updated_at
)
SELECT
    'ACC' || LPAD((10000 + ROW_NUMBER() OVER (ORDER BY member_id))::VARCHAR, 8, '0'),
    member_id,
    'CHECKING',
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN 'REWARDS_CHECKING' ELSE 'BASIC_CHECKING' END,
    member_status,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN 'Rewards Checking' ELSE 'Free Checking' END,
    ROUND(UNIFORM(0, 15000, RANDOM()), 2),
    ROUND(UNIFORM(0, 15000, RANDOM()), 2),
    0,
    0,
    NULL,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN 0.05 ELSE 0.00 END,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN 0.05 ELSE 0.00 END,
    NULL,
    NULL,
    DATEADD('day', UNIFORM(0, 365, RANDOM()), membership_date),
    DATEADD('day', -UNIFORM(0, 14, RANDOM()), CURRENT_DATE()),
    UNIFORM(0, 100, RANDOM()) < 60,
    UNIFORM(0, 100, RANDOM()) < 20,
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
FROM MEMBERS
WHERE UNIFORM(0, 100, RANDOM()) < 70;

-- Share Certificates (25% of members)
INSERT INTO ACCOUNTS (
    account_id, member_id, account_type, account_subtype, account_status,
    account_name, current_balance, available_balance, pending_balance, minimum_balance, credit_limit,
    dividend_rate, apy_rate, term_months, maturity_date,
    opened_date, last_activity_date, overdraft_protection, joint_account,
    created_at, updated_at
)
SELECT
    'ACC' || LPAD((20000 + ROW_NUMBER() OVER (ORDER BY member_id))::VARCHAR, 8, '0'),
    member_id,
    'SHARE_CERTIFICATE',
    CASE term_choice
        WHEN 1 THEN '6_MONTH_CD'
        WHEN 2 THEN '12_MONTH_CD'
        WHEN 3 THEN '24_MONTH_CD'
        ELSE '36_MONTH_CD'
    END,
    member_status,
    CASE term_choice
        WHEN 1 THEN '6-Month Share Certificate'
        WHEN 2 THEN '12-Month Share Certificate'
        WHEN 3 THEN '24-Month Share Certificate'
        ELSE '36-Month Share Certificate'
    END,
    ROUND(UNIFORM(1000, 75000, RANDOM()), -2),
    0,
    0,
    1000,
    NULL,
    CASE term_choice WHEN 1 THEN 4.25 WHEN 2 THEN 4.50 WHEN 3 THEN 4.75 ELSE 5.00 END,
    CASE term_choice WHEN 1 THEN 4.33 WHEN 2 THEN 4.59 WHEN 3 THEN 4.85 ELSE 5.12 END,
    CASE term_choice WHEN 1 THEN 6 WHEN 2 THEN 12 WHEN 3 THEN 24 ELSE 36 END,
    DATEADD('month', 
        CASE term_choice WHEN 1 THEN 6 WHEN 2 THEN 12 WHEN 3 THEN 24 ELSE 36 END,
        opened_dt),
    opened_dt,
    opened_dt,
    FALSE,
    FALSE,
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
FROM (
    SELECT 
        member_id, 
        member_status,
        UNIFORM(1, 4, RANDOM()) as term_choice,
        DATEADD('day', -UNIFORM(30, 730, RANDOM()), CURRENT_DATE()) as opened_dt
    FROM MEMBERS
    WHERE UNIFORM(0, 100, RANDOM()) < 25
);

-- Credit Cards (40% of members)
INSERT INTO ACCOUNTS (
    account_id, member_id, account_type, account_subtype, account_status,
    account_name, current_balance, available_balance, pending_balance, minimum_balance, credit_limit,
    dividend_rate, apy_rate, term_months, maturity_date,
    opened_date, last_activity_date, overdraft_protection, joint_account,
    created_at, updated_at
)
SELECT
    'ACC' || LPAD((30000 + ROW_NUMBER() OVER (ORDER BY m.member_id))::VARCHAR, 8, '0'),
    m.member_id,
    'CREDIT_CARD',
    CASE WHEN m.credit_score >= 740 THEN 'VISA_PLATINUM'
         WHEN m.credit_score >= 680 THEN 'VISA_REWARDS'
         ELSE 'VISA_CLASSIC' END,
    m.member_status,
    CASE WHEN m.credit_score >= 740 THEN 'Visa Platinum Rewards'
         WHEN m.credit_score >= 680 THEN 'Visa Rewards Card'
         ELSE 'Visa Classic' END,
    -ROUND(UNIFORM(100, 5000, RANDOM()), 2),
    ROUND(UNIFORM(100, 20000, RANDOM()), 2),
    0,
    25,
    credit_lim,
    NULL,
    CASE WHEN m.credit_score >= 740 THEN 12.99
         WHEN m.credit_score >= 680 THEN 15.99
         ELSE 19.99 END,
    NULL,
    NULL,
    DATEADD('day', UNIFORM(30, 1000, RANDOM()), m.membership_date),
    DATEADD('day', -UNIFORM(0, 30, RANDOM()), CURRENT_DATE()),
    FALSE,
    FALSE,
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
FROM MEMBERS m
CROSS JOIN (
    SELECT CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 30 THEN 5000
        WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 10000
        WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 15000
        ELSE 25000
    END as credit_lim
) c
WHERE UNIFORM(0, 100, RANDOM()) < 40;

-- ============================================================================
-- Section 5: Generate Loans
-- ============================================================================

TRUNCATE TABLE IF EXISTS LOANS;

-- Auto Loans
INSERT INTO LOANS (
    loan_id, member_id, account_id, loan_type, loan_subtype, loan_status,
    original_amount, current_balance, interest_rate, apr,
    term_months, monthly_payment, payment_due_day, next_payment_date,
    origination_date, maturity_date,
    collateral_type, collateral_value, ltv_ratio,
    days_past_due, times_30_days_late, times_60_days_late, times_90_days_late,
    autopay_enrolled, refinanced_from_loan_id, created_at, updated_at
)
SELECT
    'LN' || LPAD(ROW_NUMBER() OVER (ORDER BY member_id)::VARCHAR, 8, '0'),
    member_id,
    NULL,
    'AUTO',
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'NEW_AUTO' ELSE 'USED_AUTO' END,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 'ACTIVE' ELSE 'DELINQUENT' END,
    loan_amt,
    ROUND(loan_amt * (1 - (months_old / term_m) * UNIFORM(0.8, 1.0, RANDOM())), 2),
    rate,
    rate + 0.25,
    term_m,
    ROUND(loan_amt / term_m * (1 + rate/100), 2),
    UNIFORM(1, 28, RANDOM()),
    DATEADD('day', UNIFORM(1, 30, RANDOM()), CURRENT_DATE()),
    orig_date,
    DATEADD('month', term_m, orig_date),
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'NEW_VEHICLE' ELSE 'USED_VEHICLE' END,
    ROUND(loan_amt * UNIFORM(1.0, 1.3, RANDOM()), 2),
    ROUND(UNIFORM(70, 95, RANDOM()), 2),
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 90 THEN 0 ELSE UNIFORM(1, 120, RANDOM()) END,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 0 ELSE UNIFORM(0, 3, RANDOM()) END,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 0 ELSE UNIFORM(0, 2, RANDOM()) END,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 98 THEN 0 ELSE UNIFORM(0, 1, RANDOM()) END,
    UNIFORM(0, 100, RANDOM()) < 65,
    NULL,
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
FROM (
    SELECT 
        member_id,
        ROUND(UNIFORM(15000, 65000, RANDOM()), -2) as loan_amt,
        ROUND(UNIFORM(4.5, 12.0, RANDOM()), 2) as rate,
        CASE WHEN UNIFORM(0, 100, RANDOM()) < 50 THEN 60 
             WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 72 ELSE 84 END as term_m,
        DATEADD('day', -UNIFORM(30, 1500, RANDOM()), CURRENT_DATE()) as orig_date,
        UNIFORM(1, 60, RANDOM()) as months_old
    FROM MEMBERS
    WHERE member_status = 'ACTIVE' AND UNIFORM(0, 100, RANDOM()) < 30
);

-- Mortgages
INSERT INTO LOANS (
    loan_id, member_id, account_id, loan_type, loan_subtype, loan_status,
    original_amount, current_balance, interest_rate, apr,
    term_months, monthly_payment, payment_due_day, next_payment_date,
    origination_date, maturity_date,
    collateral_type, collateral_value, ltv_ratio,
    days_past_due, times_30_days_late, times_60_days_late, times_90_days_late,
    autopay_enrolled, refinanced_from_loan_id, created_at, updated_at
)
SELECT
    'LN' || LPAD((10000 + ROW_NUMBER() OVER (ORDER BY member_id))::VARCHAR, 8, '0'),
    member_id,
    NULL,
    'MORTGAGE',
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN 'CONVENTIONAL' 
         WHEN UNIFORM(0, 100, RANDOM()) < 90 THEN 'FHA' ELSE 'VA' END,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 97 THEN 'ACTIVE' ELSE 'DELINQUENT' END,
    loan_amt,
    ROUND(loan_amt * UNIFORM(0.7, 0.98, RANDOM()), 2),
    rate,
    rate + 0.125,
    term_m,
    ROUND(loan_amt / term_m * (1 + rate/100), 2),
    1,
    DATEADD('day', UNIFORM(1, 30, RANDOM()), CURRENT_DATE()),
    orig_date,
    DATEADD('month', term_m, orig_date),
    'REAL_ESTATE',
    ROUND(loan_amt * UNIFORM(1.05, 1.35, RANDOM()), 2),
    ROUND(UNIFORM(65, 95, RANDOM()), 2),
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 0 ELSE UNIFORM(1, 90, RANDOM()) END,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 92 THEN 0 ELSE UNIFORM(0, 2, RANDOM()) END,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 97 THEN 0 ELSE UNIFORM(0, 1, RANDOM()) END,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 99 THEN 0 ELSE UNIFORM(0, 1, RANDOM()) END,
    UNIFORM(0, 100, RANDOM()) < 80,
    NULL,
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
FROM (
    SELECT 
        member_id,
        ROUND(UNIFORM(200000, 750000, RANDOM()), -3) as loan_amt,
        ROUND(UNIFORM(5.5, 7.5, RANDOM()), 3) as rate,
        CASE WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 360 ELSE 180 END as term_m,
        DATEADD('day', -UNIFORM(60, 2500, RANDOM()), CURRENT_DATE()) as orig_date
    FROM MEMBERS
    WHERE member_status = 'ACTIVE' AND credit_score >= 620 AND UNIFORM(0, 100, RANDOM()) < 20
);

-- Personal Loans
INSERT INTO LOANS (
    loan_id, member_id, account_id, loan_type, loan_subtype, loan_status,
    original_amount, current_balance, interest_rate, apr,
    term_months, monthly_payment, payment_due_day, next_payment_date,
    origination_date, maturity_date,
    collateral_type, collateral_value, ltv_ratio,
    days_past_due, times_30_days_late, times_60_days_late, times_90_days_late,
    autopay_enrolled, refinanced_from_loan_id, created_at, updated_at
)
SELECT
    'LN' || LPAD((20000 + ROW_NUMBER() OVER (ORDER BY member_id))::VARCHAR, 8, '0'),
    member_id,
    NULL,
    'PERSONAL',
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 'SIGNATURE' ELSE 'SECURED' END,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 92 THEN 'ACTIVE' ELSE 'DELINQUENT' END,
    loan_amt,
    ROUND(loan_amt * UNIFORM(0.3, 0.95, RANDOM()), 2),
    rate,
    rate,
    term_m,
    ROUND(loan_amt / term_m * (1 + rate/100), 2),
    UNIFORM(1, 28, RANDOM()),
    DATEADD('day', UNIFORM(1, 30, RANDOM()), CURRENT_DATE()),
    orig_date,
    DATEADD('month', term_m, orig_date),
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 'NONE' ELSE 'SAVINGS' END,
    NULL,
    NULL,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 88 THEN 0 ELSE UNIFORM(1, 90, RANDOM()) END,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 0 ELSE UNIFORM(0, 3, RANDOM()) END,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 93 THEN 0 ELSE UNIFORM(0, 2, RANDOM()) END,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 97 THEN 0 ELSE UNIFORM(0, 1, RANDOM()) END,
    UNIFORM(0, 100, RANDOM()) < 55,
    NULL,
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
FROM (
    SELECT 
        member_id,
        ROUND(UNIFORM(2000, 35000, RANDOM()), -2) as loan_amt,
        ROUND(UNIFORM(8.0, 18.0, RANDOM()), 2) as rate,
        CASE WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN 36 
             WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 48 ELSE 60 END as term_m,
        DATEADD('day', -UNIFORM(30, 1200, RANDOM()), CURRENT_DATE()) as orig_date
    FROM MEMBERS
    WHERE member_status = 'ACTIVE' AND UNIFORM(0, 100, RANDOM()) < 15
);

-- ============================================================================
-- Section 6: Generate Cards
-- ============================================================================

TRUNCATE TABLE IF EXISTS CARDS;

INSERT INTO CARDS (
    card_id, account_id, member_id, card_type, card_product, card_status,
    card_number_last_four, expiration_date, activation_date,
    daily_limit, monthly_limit, international_enabled,
    contactless_enabled, virtual_card,
    rewards_program, rewards_points_balance, created_at, updated_at
)
SELECT
    'CRD' || LPAD(ROW_NUMBER() OVER (ORDER BY a.account_id)::VARCHAR, 8, '0'),
    a.account_id,
    a.member_id,
    CASE WHEN a.account_type = 'CREDIT_CARD' THEN 'CREDIT' ELSE 'DEBIT' END,
    CASE WHEN a.account_type = 'CREDIT_CARD' THEN 'VISA_REWARDS' ELSE 'DEBIT_STANDARD' END,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 'ACTIVE' 
         WHEN UNIFORM(0, 100, RANDOM()) < 98 THEN 'LOCKED' ELSE 'EXPIRED' END,
    LPAD(UNIFORM(1000, 9999, RANDOM())::VARCHAR, 4, '0'),
    DATEADD('month', UNIFORM(1, 48, RANDOM()), CURRENT_DATE()),
    a.opened_date,
    CASE WHEN a.account_type = 'CREDIT_CARD' THEN COALESCE(a.credit_limit, 5000) ELSE 2000 END,
    CASE WHEN a.account_type = 'CREDIT_CARD' THEN COALESCE(a.credit_limit, 5000) * 2 ELSE 10000 END,
    UNIFORM(0, 100, RANDOM()) < 70,
    UNIFORM(0, 100, RANDOM()) < 85,
    UNIFORM(0, 100, RANDOM()) < 15,
    CASE WHEN a.account_type = 'CREDIT_CARD' THEN 'CASHBACK_PLUS' ELSE NULL END,
    CASE WHEN a.account_type = 'CREDIT_CARD' THEN UNIFORM(500, 50000, RANDOM()) ELSE 0 END,
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
FROM ACCOUNTS a
WHERE a.account_type IN ('CREDIT_CARD', 'CHECKING');

-- ============================================================================
-- Section 7: Generate Transactions
-- ============================================================================

TRUNCATE TABLE IF EXISTS TRANSACTIONS;

INSERT INTO TRANSACTIONS (
    transaction_id, account_id, member_id, card_id, transaction_type, transaction_category,
    amount, running_balance, transaction_date, transaction_timestamp, posted_date,
    description, merchant_name, merchant_category, merchant_city, merchant_state, merchant_country,
    is_recurring, is_international, status, fraud_score, dispute_status, channel, device_type,
    created_at
)
WITH date_range AS (
    SELECT DATEADD('day', -seq4(), CURRENT_DATE()) as txn_date
    FROM TABLE(GENERATOR(ROWCOUNT => 180))
),
member_accounts AS (
    SELECT 
        a.account_id, 
        a.member_id, 
        a.account_type,
        a.current_balance,
        m.city,
        m.address_state
    FROM ACCOUNTS a
    JOIN MEMBERS m ON a.member_id = m.member_id
    WHERE a.account_status = 'ACTIVE'
      AND a.account_type IN ('CHECKING', 'CREDIT_CARD', 'SHARE_SAVINGS')
)
SELECT
    'TXN' || LPAD(ROW_NUMBER() OVER (ORDER BY ma.account_id, dr.txn_date)::VARCHAR, 10, '0'),
    ma.account_id,
    ma.member_id,
    NULL,
    txn_types[UNIFORM(0, 9, RANDOM())],
    txn_categories[UNIFORM(0, 14, RANDOM())],
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 20 
         THEN ROUND(UNIFORM(10, 500, RANDOM()), 2)
         ELSE -ROUND(UNIFORM(5, 300, RANDOM()), 2) END,
    ma.current_balance,
    dr.txn_date,
    DATEADD('second', UNIFORM(0, 86400, RANDOM()), dr.txn_date::TIMESTAMP),
    DATEADD('day', UNIFORM(0, 2, RANDOM()), dr.txn_date),
    descriptions[UNIFORM(0, 19, RANDOM())],
    merchants[UNIFORM(0, 29, RANDOM())],
    mccs[UNIFORM(0, 14, RANDOM())],
    ma.city,
    ma.address_state,
    'US',
    UNIFORM(0, 100, RANDOM()) < 15,
    UNIFORM(0, 100, RANDOM()) < 3,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 98 THEN 'COMPLETED' 
         WHEN UNIFORM(0, 100, RANDOM()) < 99 THEN 'PENDING' ELSE 'DECLINED' END,
    ROUND(UNIFORM(0, 0.3, RANDOM()), 3),
    NULL,
    channels[UNIFORM(0, 4, RANDOM())],
    devices[UNIFORM(0, 4, RANDOM())],
    CURRENT_TIMESTAMP()
FROM member_accounts ma
CROSS JOIN date_range dr
CROSS JOIN (
    SELECT 
        ARRAY_CONSTRUCT('PURCHASE','DEPOSIT','TRANSFER','WITHDRAWAL','PAYMENT','REFUND','FEE','INTEREST','DIVIDEND','ATM') as txn_types,
        ARRAY_CONSTRUCT('GROCERIES','DINING','GAS','UTILITIES','ENTERTAINMENT','HEALTHCARE','SHOPPING','TRAVEL','INSURANCE','EDUCATION','HOME','AUTO','PERSONAL','BUSINESS','OTHER') as txn_categories,
        ARRAY_CONSTRUCT('Grocery purchase','Restaurant','Gas station','Online shopping','Subscription','Bill payment','ATM withdrawal','Transfer','Direct deposit','Payroll','Refund','Interest payment','Fee','Dividend','Cash back','Rewards redemption','Check deposit','Mobile deposit','Wire transfer','ACH transfer') as descriptions,
        ARRAY_CONSTRUCT('Walmart','Costco','Amazon','Target','Smiths','Harmons','Chevron','Maverick','Netflix','Spotify','Comcast','Rocky Mountain Power','Starbucks','Chick-fil-A','Home Depot','Lowes','Best Buy','Apple','Google','Venmo','PayPal','Zelle','Uber','Lyft','DoorDash','Grubhub','Delta Airlines','Southwest','Marriott','Hilton') as merchants,
        ARRAY_CONSTRUCT('5411','5541','5812','5814','5912','5311','5651','5732','4900','7011','4511','5999','6011','5816','5818') as mccs,
        ARRAY_CONSTRUCT('MOBILE_APP','ONLINE','BRANCH','ATM','POS') as channels,
        ARRAY_CONSTRUCT('IOS','ANDROID','WEB','ATM','POS_TERMINAL') as devices
)
WHERE UNIFORM(0, 100, RANDOM()) < 8;

-- ============================================================================
-- Section 8: Generate Support Interactions
-- ============================================================================

TRUNCATE TABLE IF EXISTS SUPPORT_INTERACTIONS;

INSERT INTO SUPPORT_INTERACTIONS (
    interaction_id, member_id, agent_id, interaction_type, channel,
    category, subcategory, subject, interaction_date, interaction_timestamp,
    duration_seconds, resolution_status, resolution_achieved,
    satisfaction_score, nps_score, escalated, first_contact_resolution,
    branch_id, created_at
)
SELECT
    'SI' || LPAD(ROW_NUMBER() OVER (ORDER BY m.member_id)::VARCHAR, 8, '0'),
    m.member_id,
    'AGT' || LPAD(UNIFORM(1, 100, RANDOM())::VARCHAR, 4, '0'),
    interaction_types[UNIFORM(0, 4, RANDOM())],
    channels[UNIFORM(0, 4, RANDOM())],
    categories[cat_idx],
    subcategories[cat_idx],
    subjects[cat_idx],
    DATEADD('day', -UNIFORM(0, 365, RANDOM()), CURRENT_DATE()),
    DATEADD('second', UNIFORM(28800, 64800, RANDOM()), 
            DATEADD('day', -UNIFORM(0, 365, RANDOM()), CURRENT_DATE())::TIMESTAMP),
    UNIFORM(60, 1800, RANDOM()),
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 'RESOLVED' 
         WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 'PENDING' ELSE 'ESCALATED' END,
    UNIFORM(0, 100, RANDOM()) < 85,
    UNIFORM(1, 5, RANDOM()),
    UNIFORM(-100, 100, RANDOM()),
    UNIFORM(0, 100, RANDOM()) < 8,
    UNIFORM(0, 100, RANDOM()) < 75,
    m.primary_branch_id,
    CURRENT_TIMESTAMP()
FROM MEMBERS m
CROSS JOIN (
    SELECT 
        UNIFORM(0, 9, RANDOM()) as cat_idx,
        ARRAY_CONSTRUCT('CALL','CHAT','EMAIL','BRANCH_VISIT','VIDEO') as interaction_types,
        ARRAY_CONSTRUCT('PHONE','WEB_CHAT','EMAIL','BRANCH','VIDEO_CALL') as channels,
        ARRAY_CONSTRUCT('ACCOUNT_INQUIRY','CARD_SERVICES','LOAN_SERVICES','DIGITAL_BANKING','DISPUTE','FRAUD','GENERAL','ACCOUNT_CHANGES','FEES','PRODUCT_INFO') as categories,
        ARRAY_CONSTRUCT('Balance inquiry','Lost/stolen card','Payment question','Login issue','Transaction dispute','Suspicious activity','General question','Address change','Fee reversal','Rate inquiry') as subcategories,
        ARRAY_CONSTRUCT('Account balance question','Report lost card','Loan payment inquiry','Mobile app help','Dispute transaction','Report fraud','General assistance','Update contact info','Request fee waiver','Product rates') as subjects
)
WHERE UNIFORM(0, 100, RANDOM()) < 50;

-- ============================================================================
-- Section 9: Generate Support Transcripts
-- ============================================================================

TRUNCATE TABLE IF EXISTS SUPPORT_TRANSCRIPTS;

INSERT INTO SUPPORT_TRANSCRIPTS (
    transcript_id, interaction_id, member_id, agent_id, interaction_date,
    interaction_type, category, subcategory, transcript_text,
    sentiment_score, resolution_achieved, key_topics, created_at
)
SELECT
    'TR' || LPAD(ROW_NUMBER() OVER (ORDER BY interaction_id)::VARCHAR, 8, '0'),
    interaction_id,
    member_id,
    'AGT' || LPAD(UNIFORM(1, 50, RANDOM())::VARCHAR, 4, '0'),
    interaction_date,
    channel,
    category,
    CASE category
        WHEN 'ACCOUNT_INQUIRY' THEN 'Balance Check'
        WHEN 'CARD_SERVICES' THEN 'Card Replacement'
        WHEN 'LOAN_INQUIRY' THEN 'Rate Inquiry'
        WHEN 'TECHNICAL_SUPPORT' THEN 'App Issue'
        WHEN 'DISPUTE' THEN 'Unauthorized Transaction'
        WHEN 'FRAUD_REPORT' THEN 'Phishing'
        ELSE 'General'
    END,
    transcript_templates[UNIFORM(0, 9, RANDOM())],
    ROUND(UNIFORM(-1.0, 1.0, RANDOM()), 4),
    UNIFORM(0, 100, RANDOM()) < 85,
    topic_arrays[UNIFORM(0, 9, RANDOM())],
    CURRENT_TIMESTAMP()
FROM SUPPORT_INTERACTIONS
CROSS JOIN (
    SELECT
        ARRAY_CONSTRUCT(
            'Member called regarding account balance discrepancy. Agent verified recent transactions and explained pending holds. Member satisfied with explanation.',
            'Member reported lost debit card while traveling. Agent immediately blocked card and expedited replacement. Provided temporary digital card access.',
            'Member inquired about auto loan rates for used vehicle purchase. Agent explained current rates and pre-approval process. Member started application.',
            'Member experiencing mobile app login issues after phone upgrade. Agent walked through re-enrollment process and verified security settings.',
            'Member disputed unauthorized transaction at gas station. Agent initiated dispute process and issued provisional credit.',
            'Member reported suspicious text claiming to be from MACU. Agent confirmed phishing attempt and educated on fraud prevention.',
            'Member requested wire transfer to family overseas. Agent verified recipient details and explained fees and timing.',
            'Member asked about increasing credit card limit. Agent reviewed account history and submitted limit increase request.',
            'Member complained about overdraft fee. Agent reviewed account activity and waived fee as courtesy for long-standing member.',
            'Member inquired about mortgage refinance options. Agent explained current rates and connected with loan officer.'
        ) as transcript_templates,
        ARRAY_CONSTRUCT(
            ARRAY_CONSTRUCT('balance', 'pending', 'transactions'),
            ARRAY_CONSTRUCT('card', 'lost', 'replacement'),
            ARRAY_CONSTRUCT('auto loan', 'rates', 'application'),
            ARRAY_CONSTRUCT('mobile app', 'login', 'technical'),
            ARRAY_CONSTRUCT('dispute', 'unauthorized', 'fraud'),
            ARRAY_CONSTRUCT('phishing', 'scam', 'security'),
            ARRAY_CONSTRUCT('wire transfer', 'international', 'fees'),
            ARRAY_CONSTRUCT('credit limit', 'increase', 'review'),
            ARRAY_CONSTRUCT('overdraft', 'fee', 'waiver'),
            ARRAY_CONSTRUCT('mortgage', 'refinance', 'rates')
        ) as topic_arrays
);

-- ============================================================================
-- Section 10: Generate Compliance Documents
-- ============================================================================

TRUNCATE TABLE IF EXISTS COMPLIANCE_DOCUMENTS;

INSERT INTO COMPLIANCE_DOCUMENTS (document_id, document_type, title, content, version, effective_date, expiration_date, department, tags, regulatory_reference, last_reviewed_date, next_review_date, created_at, updated_at)
SELECT 'DOC001', 'POLICY', 'Bank Secrecy Act (BSA) Compliance Policy', 'This policy establishes Mountain America Credit Union''s commitment to compliance with the Bank Secrecy Act and anti-money laundering regulations. All employees must complete annual BSA training. Currency Transaction Reports (CTRs) must be filed for cash transactions exceeding $10,000. Suspicious Activity Reports (SARs) must be filed within 30 days of detecting suspicious activity. The BSA Officer is responsible for overall program compliance.', '3.0', '2024-01-01', '2025-12-31', 'COMPLIANCE', ARRAY_CONSTRUCT('BSA', 'AML', 'compliance'), 'BSA/AML', '2024-01-01', '2025-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'DOC002', 'PROCEDURE', 'Anti-Money Laundering (AML) Procedures', 'AML procedures require enhanced due diligence for high-risk members including politically exposed persons (PEPs), foreign nationals, and cash-intensive businesses. Transaction monitoring systems flag unusual patterns. Red flags include structuring, rapid movement of funds, and inconsistent transaction patterns. All alerts must be reviewed within 48 hours.', '2.5', '2024-01-01', '2025-12-31', 'COMPLIANCE', ARRAY_CONSTRUCT('AML', 'due diligence'), 'BSA/AML', '2024-01-01', '2025-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'DOC003', 'GUIDELINE', 'Suspicious Activity Report (SAR) Filing Guidelines', 'SARs must be filed for transactions of $5,000 or more involving potential money laundering, BSA violations, or other suspicious activity. The SAR must be filed within 30 calendar days of initial detection. No disclosure of SAR filing may be made to any person involved in the transaction. Retain SAR documentation for 5 years.', '2.0', '2024-01-01', '2025-12-31', 'COMPLIANCE', ARRAY_CONSTRUCT('SAR', 'reporting'), 'BSA/AML', '2024-01-01', '2025-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'DOC004', 'POLICY', 'Customer Identification Program (CIP)', 'All new members must provide valid government-issued ID, date of birth, address, and Social Security Number. Identity must be verified within reasonable time after account opening. Documentary and non-documentary verification methods are acceptable. Records must be retained for 5 years after account closure.', '2.0', '2024-01-01', '2025-12-31', 'OPERATIONS', ARRAY_CONSTRUCT('KYC', 'CIP', 'identity'), 'CIP/KYC', '2024-01-01', '2025-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'DOC005', 'PROCEDURE', 'OFAC Compliance Procedures', 'All members and transactions must be screened against OFAC SDN List. Matches require immediate escalation to Compliance. No transactions may proceed with confirmed OFAC matches. False positives must be documented and cleared. Daily OFAC list updates are automatically applied.', '1.5', '2024-01-01', '2025-12-31', 'COMPLIANCE', ARRAY_CONSTRUCT('OFAC', 'sanctions'), 'OFAC', '2024-01-01', '2025-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'DOC006', 'POLICY', 'Fair Lending Policy', 'MACU is committed to fair lending practices in compliance with ECOA and Fair Housing Act. Lending decisions are based on creditworthiness, not prohibited factors. Regular fair lending analysis is conducted. All loan denials require documented legitimate business reasons.', '2.0', '2024-01-01', '2025-12-31', 'LENDING', ARRAY_CONSTRUCT('fair lending', 'ECOA'), 'ECOA/FHA', '2024-01-01', '2025-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'DOC007', 'POLICY', 'Privacy Policy - Gramm-Leach-Bliley Act', 'Member nonpublic personal information is protected under GLBA. Privacy notices provided at account opening and annually. Members may opt-out of information sharing with non-affiliates. Employee access to member data is role-based and audited.', '3.0', '2024-01-01', '2025-12-31', 'COMPLIANCE', ARRAY_CONSTRUCT('privacy', 'GLBA'), 'GLBA', '2024-01-01', '2025-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'DOC008', 'PROCEDURE', 'Regulation E - Electronic Fund Transfers', 'Members must report unauthorized EFTs within 60 days of statement. Provisional credit provided within 10 business days for debit card disputes. Investigation completed within 45 days (90 days for new accounts or POS transactions). Written determination provided to member.', '2.0', '2024-01-01', '2025-12-31', 'OPERATIONS', ARRAY_CONSTRUCT('Reg E', 'EFT', 'disputes'), 'Reg E', '2024-01-01', '2025-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'DOC009', 'PROCEDURE', 'Truth in Lending Act (TILA) Compliance', 'All consumer credit disclosures must include APR, finance charges, amount financed, and total of payments. Disclosures provided before consummation of credit transaction. Right of rescission for home-secured loans. Advertising must not be misleading.', '2.0', '2024-01-01', '2025-12-31', 'LENDING', ARRAY_CONSTRUCT('TILA', 'disclosures'), 'TILA/Reg Z', '2024-01-01', '2025-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'DOC010', 'GUIDELINE', 'Elder Financial Exploitation Prevention', 'Staff trained to recognize signs of elder exploitation including unusual withdrawals, new authorized signers, and behavioral changes. Suspicious activity reported to APS and filed as SAR. Enhanced verification for large transactions by seniors. Trusted contact information collected.', '1.5', '2024-01-01', '2025-12-31', 'COMPLIANCE', ARRAY_CONSTRUCT('elder abuse', 'fraud prevention'), 'SAR', '2024-01-01', '2025-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'DOC011', 'GUIDELINE', 'NCUA Examination Preparation', 'Annual NCUA examination requires preparation of loan files, BSA documentation, board minutes, and financial reports. Examination response team includes CEO, CFO, CCO, and department heads. All requests fulfilled within 24 hours during exam.', '1.0', '2024-01-01', '2025-12-31', 'COMPLIANCE', ARRAY_CONSTRUCT('NCUA', 'examination'), 'NCUA', '2024-01-01', '2025-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'DOC012', 'POLICY', 'Vendor Management Policy', 'Third-party vendors undergo due diligence review. Critical vendors require annual review. Contracts must include data security provisions. Vendor access to member data is logged and monitored.', '2.0', '2024-01-01', '2025-12-31', 'OPERATIONS', ARRAY_CONSTRUCT('vendor', 'third-party'), 'TPRM', '2024-01-01', '2025-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'DOC013', 'POLICY', 'Information Security Policy', 'All systems protected by multi-factor authentication. Data encrypted at rest and in transit. Annual penetration testing required. Security incidents reported within 1 hour of detection.', '3.0', '2024-01-01', '2025-12-31', 'IT', ARRAY_CONSTRUCT('security', 'infosec'), 'GLBA', '2024-01-01', '2025-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'DOC014', 'POLICY', 'Business Continuity Plan', 'Critical systems have 4-hour RTO. Annual DR testing required. Backup site activated within 24 hours. Employee emergency contact list updated quarterly.', '2.5', '2024-01-01', '2025-12-31', 'OPERATIONS', ARRAY_CONSTRUCT('BCP', 'disaster recovery'), 'FFIEC', '2024-01-01', '2025-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'DOC015', 'PROCEDURE', 'Wire Transfer Procedures', 'Domestic wires processed same day if received by 3pm. International wires require OFAC screening. Callback verification for wires over $25,000. Member authentication required for all wire requests.', '2.0', '2024-01-01', '2025-12-31', 'OPERATIONS', ARRAY_CONSTRUCT('wire', 'transfer'), 'BSA/AML', '2024-01-01', '2025-01-01', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP();

-- ============================================================================
-- Section 11: Generate Product Knowledge
-- ============================================================================

TRUNCATE TABLE IF EXISTS PRODUCT_KNOWLEDGE;

INSERT INTO PRODUCT_KNOWLEDGE (knowledge_id, product_name, category, title, content, version, effective_date, tags, related_products, faq_questions, created_at, updated_at)
SELECT 'PKB001', 'Share Savings Account', 'SAVINGS', 'Share Savings Account Overview', 'Primary membership account establishing credit union membership. Minimum $5 balance required to maintain membership. Earns 0.10% APY on all balances. No monthly fees. Federally insured up to $250,000 by NCUA. Unlimited withdrawals. Mobile and online access included.', '1.0', CURRENT_DATE(), ARRAY_CONSTRUCT('savings', 'membership', 'primary'), ARRAY_CONSTRUCT('PKB002', 'PKB003'), ARRAY_CONSTRUCT('What is the minimum balance?', 'Is there a monthly fee?'), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'PKB002', 'High-Yield Savings Account', 'SAVINGS', 'High-Yield Savings Account Overview', 'Earn up to 4.25% APY on balances. Tiered rates: 4.25% APY on balances $100,000+, 4.00% APY on $25,000-$99,999, 3.75% APY on $1,000-$24,999. $1,000 minimum to open. No monthly fees. Transfer limits apply per Reg D.', '1.0', CURRENT_DATE(), ARRAY_CONSTRUCT('savings', 'high-yield', 'interest'), ARRAY_CONSTRUCT('PKB001', 'PKB005'), ARRAY_CONSTRUCT('What is the APY?', 'What is the minimum to open?'), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'PKB003', 'Free Checking Account', 'CHECKING', 'Free Checking Account Overview', 'No monthly maintenance fees. No minimum balance. Free debit card with rewards. Free online and mobile banking. Free bill pay. Overdraft protection available. Mobile check deposit. 30,000+ surcharge-free ATMs nationwide.', '1.0', CURRENT_DATE(), ARRAY_CONSTRUCT('checking', 'free', 'debit card'), ARRAY_CONSTRUCT('PKB004', 'PKB014'), ARRAY_CONSTRUCT('Are there any fees?', 'Is there a debit card?'), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'PKB004', 'Rewards Checking Account', 'CHECKING', 'Rewards Checking Account Overview', 'Earn 0.05% APY on all balances plus debit card rewards. 1 point per $2 spent on debit purchases. Points redeemable for cash back, travel, or merchandise. Includes all Free Checking features. Monthly e-statement required for rewards.', '1.0', CURRENT_DATE(), ARRAY_CONSTRUCT('checking', 'rewards', 'points'), ARRAY_CONSTRUCT('PKB003', 'PKB012'), ARRAY_CONSTRUCT('How do I earn points?', 'How do I redeem rewards?'), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'PKB005', 'Share Certificate (CD)', 'CERTIFICATES', 'Share Certificate Overview', 'Guaranteed returns with fixed rates. Terms: 6-month (4.25% APY), 12-month (4.50% APY), 24-month (4.75% APY), 36-month (5.00% APY). $1,000 minimum deposit. Early withdrawal penalties apply. Interest compounded daily, paid monthly. NCUA insured.', '1.0', CURRENT_DATE(), ARRAY_CONSTRUCT('certificate', 'CD', 'fixed rate'), ARRAY_CONSTRUCT('PKB001', 'PKB002'), ARRAY_CONSTRUCT('What are the rates?', 'What is the early withdrawal penalty?'), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'PKB006', 'Auto Loan - New Vehicle', 'LOANS', 'New Auto Loan Overview', 'Finance your new car with rates as low as 5.49% APR. Terms up to 84 months. No application fee. Pre-approval available. GAP insurance available. Rate based on credit score: 760+ (5.49%), 700-759 (6.49%), 640-699 (8.49%), below 640 (12.99%).', '1.0', CURRENT_DATE(), ARRAY_CONSTRUCT('auto', 'new car', 'loan'), ARRAY_CONSTRUCT('PKB007'), ARRAY_CONSTRUCT('What is the rate?', 'How long can the term be?'), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'PKB007', 'Auto Loan - Used Vehicle', 'LOANS', 'Used Auto Loan Overview', 'Finance used vehicles up to 7 years old. Rates from 5.99% APR. Terms up to 72 months. Maximum loan amount based on NADA value. Vehicles must have under 100,000 miles. Private party purchases allowed.', '1.0', CURRENT_DATE(), ARRAY_CONSTRUCT('auto', 'used car', 'loan'), ARRAY_CONSTRUCT('PKB006'), ARRAY_CONSTRUCT('What is the max vehicle age?', 'Can I buy from a private party?'), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'PKB008', 'Home Mortgage - Purchase', 'LOANS', 'Home Purchase Mortgage Overview', 'Conventional, FHA, and VA loans available. Rates from 6.25% APR. Down payments as low as 3%. First-time homebuyer programs available. Free pre-approval. Local processing and underwriting. Close in as few as 21 days.', '1.0', CURRENT_DATE(), ARRAY_CONSTRUCT('mortgage', 'home', 'purchase'), ARRAY_CONSTRUCT('PKB009', 'PKB010'), ARRAY_CONSTRUCT('What is the minimum down payment?', 'How long to close?'), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'PKB009', 'Home Mortgage - Refinance', 'LOANS', 'Home Refinance Overview', 'Lower your rate or access equity. Rate-and-term and cash-out options. No-closing-cost options available. Streamline refinance for existing MACU mortgages. Free refinance analysis. Lock rate for up to 60 days.', '1.0', CURRENT_DATE(), ARRAY_CONSTRUCT('mortgage', 'refinance', 'home equity'), ARRAY_CONSTRUCT('PKB008', 'PKB010'), ARRAY_CONSTRUCT('Can I do a cash-out refinance?', 'What are closing costs?'), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'PKB010', 'Home Equity Line of Credit (HELOC)', 'LOANS', 'HELOC Overview', 'Access your home equity with rates from Prime + 0.50%. Draw period of 10 years, repayment period of 20 years. No annual fee. Interest-only payments during draw period. Borrow up to 90% combined LTV. Tax-deductible interest (consult tax advisor).', '1.0', CURRENT_DATE(), ARRAY_CONSTRUCT('HELOC', 'home equity', 'line of credit'), ARRAY_CONSTRUCT('PKB008', 'PKB009'), ARRAY_CONSTRUCT('What is the draw period?', 'What is the max LTV?'), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'PKB011', 'Personal Loan', 'LOANS', 'Personal Loan Overview', 'Unsecured personal loans from $2,000 to $50,000. Rates from 9.99% APR. Terms up to 60 months. No collateral required. Fixed monthly payments. Use for debt consolidation, home improvement, or major purchases.', '1.0', CURRENT_DATE(), ARRAY_CONSTRUCT('personal', 'unsecured', 'loan'), ARRAY_CONSTRUCT('PKB006', 'PKB007'), ARRAY_CONSTRUCT('Is collateral required?', 'What can I use it for?'), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'PKB012', 'Visa Platinum Rewards Card', 'CREDIT_CARDS', 'Visa Platinum Card Overview', 'Premium rewards credit card. Earn 2X points on travel and dining, 1X on everything else. 0% intro APR for 15 months. No annual fee. 12.99% variable APR after intro period. Includes travel insurance, purchase protection, and extended warranty.', '1.0', CURRENT_DATE(), ARRAY_CONSTRUCT('credit card', 'rewards', 'platinum'), ARRAY_CONSTRUCT('PKB013'), ARRAY_CONSTRUCT('What is the intro APR?', 'Is there an annual fee?'), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'PKB013', 'Visa Rewards Card', 'CREDIT_CARDS', 'Visa Rewards Card Overview', 'Earn 1.5X points on all purchases. No annual fee. 15.99% variable APR. Points never expire. Redeem for cash back, travel, gift cards, or merchandise. EMV chip and contactless payment enabled.', '1.0', CURRENT_DATE(), ARRAY_CONSTRUCT('credit card', 'rewards', 'cash back'), ARRAY_CONSTRUCT('PKB012'), ARRAY_CONSTRUCT('Do points expire?', 'How do I redeem points?'), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'PKB014', 'Mobile Banking App', 'DIGITAL', 'Mobile Banking App Overview', 'Full-featured mobile banking for iOS and Android. Check balances, transfer funds, pay bills, deposit checks. Biometric login (Face ID, Touch ID). Card controls to lock/unlock cards. Real-time alerts. Zelle integration for P2P payments.', '1.0', CURRENT_DATE(), ARRAY_CONSTRUCT('mobile', 'app', 'digital'), ARRAY_CONSTRUCT('PKB015'), ARRAY_CONSTRUCT('What features are available?', 'Is Zelle supported?'), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()
UNION ALL SELECT 'PKB015', 'Online Banking', 'DIGITAL', 'Online Banking Overview', 'Secure online access 24/7. View accounts, statements, and transaction history. Transfer between accounts. Pay bills with free bill pay. Set up alerts and notifications. Download transactions to financial software. eStatements available.', '1.0', CURRENT_DATE(), ARRAY_CONSTRUCT('online', 'digital', 'banking'), ARRAY_CONSTRUCT('PKB014'), ARRAY_CONSTRUCT('Can I pay bills online?', 'How do I set up alerts?'), CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP();

-- ============================================================================
-- Section 12: Generate Direct Deposits
-- ============================================================================

TRUNCATE TABLE IF EXISTS DIRECT_DEPOSITS;

INSERT INTO DIRECT_DEPOSITS (
    deposit_id, member_id, account_id, deposit_type, source_name,
    amount, frequency, deposit_date, routing_number, is_active,
    first_deposit_date, last_deposit_date, avg_deposit_amount, created_at, updated_at
)
SELECT
    'DD' || LPAD(ROW_NUMBER() OVER (ORDER BY a.account_id)::VARCHAR, 8, '0'),
    a.member_id,
    a.account_id,
    deposit_types[UNIFORM(0, 4, RANDOM())],
    source_names[UNIFORM(0, 9, RANDOM())],
    ROUND(UNIFORM(1500, 8000, RANDOM()), 2),
    frequencies[UNIFORM(0, 2, RANDOM())],
    DATEADD('day', -UNIFORM(1, 14, RANDOM()), CURRENT_DATE()),
    '124' || LPAD(UNIFORM(100000, 999999, RANDOM())::VARCHAR, 6, '0'),
    TRUE,
    DATEADD('day', -UNIFORM(365, 1000, RANDOM()), CURRENT_DATE()),
    DATEADD('day', -UNIFORM(1, 14, RANDOM()), CURRENT_DATE()),
    ROUND(UNIFORM(1500, 8000, RANDOM()), 2),
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
FROM ACCOUNTS a
CROSS JOIN (
    SELECT
        ARRAY_CONSTRUCT('Intermountain Healthcare','University of Utah','Brigham Young University','State of Utah','Hill Air Force Base','Goldman Sachs','Adobe Systems','Social Security Administration','Department of Veterans Affairs','Retirement Benefits') as source_names,
        ARRAY_CONSTRUCT('PAYROLL','PAYROLL','PAYROLL','GOVERNMENT','PENSION') as deposit_types,
        ARRAY_CONSTRUCT('WEEKLY','BIWEEKLY','MONTHLY') as frequencies
)
WHERE a.account_type = 'CHECKING' AND UNIFORM(0, 100, RANDOM()) < 60;

-- ============================================================================
-- Section 13: Generate Merchant Categories
-- ============================================================================

TRUNCATE TABLE IF EXISTS MERCHANT_CATEGORIES;

INSERT INTO MERCHANT_CATEGORIES (mcc_code, category_name, category_group, description, cashback_eligible, rewards_multiplier, high_risk_category, spending_limit_category, created_at)
SELECT '5411', 'Grocery Stores', 'RETAIL', 'Grocery stores and supermarkets', TRUE, 2.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '5541', 'Service Stations', 'AUTOMOTIVE', 'Gas stations', TRUE, 2.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '5812', 'Restaurants', 'DINING', 'Restaurants and eating establishments', TRUE, 3.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '5814', 'Fast Food', 'DINING', 'Quick service restaurants', TRUE, 3.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '5912', 'Drug Stores', 'HEALTHCARE', 'Pharmacies and drug stores', TRUE, 1.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '5311', 'Department Stores', 'RETAIL', 'Department stores', TRUE, 1.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '5651', 'Clothing Stores', 'RETAIL', 'Clothing stores', TRUE, 1.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '5732', 'Electronics Stores', 'RETAIL', 'Electronics and computer stores', TRUE, 1.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '4900', 'Utilities', 'UTILITIES', 'Electric, gas, water services', FALSE, 1.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '7011', 'Lodging', 'TRAVEL', 'Hotels, motels, resorts', TRUE, 3.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '4511', 'Airlines', 'TRAVEL', 'Airlines and air carriers', TRUE, 3.0, FALSE, TRUE, CURRENT_TIMESTAMP()
UNION ALL SELECT '5999', 'Miscellaneous Retail', 'RETAIL', 'Miscellaneous retail stores', TRUE, 1.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '6011', 'ATM/Cash', 'FINANCIAL', 'ATM withdrawals and cash advances', FALSE, 0.0, FALSE, TRUE, CURRENT_TIMESTAMP()
UNION ALL SELECT '5816', 'Digital Goods', 'DIGITAL', 'Digital goods and media', TRUE, 1.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '5818', 'Streaming Services', 'DIGITAL', 'Streaming and digital subscriptions', TRUE, 1.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '7995', 'Gambling', 'GAMBLING', 'Casinos and gambling', FALSE, 0.0, TRUE, TRUE, CURRENT_TIMESTAMP()
UNION ALL SELECT '5962', 'Direct Marketing', 'MARKETING', 'Telemarketing and direct sales', FALSE, 1.0, TRUE, TRUE, CURRENT_TIMESTAMP()
UNION ALL SELECT '4829', 'Wire Transfers', 'FINANCIAL', 'Money transfers and wire services', FALSE, 0.0, TRUE, TRUE, CURRENT_TIMESTAMP()
UNION ALL SELECT '6051', 'Quasi Cash', 'FINANCIAL', 'Quasi-cash transactions', FALSE, 0.0, TRUE, TRUE, CURRENT_TIMESTAMP()
UNION ALL SELECT '6012', 'Financial Services', 'FINANCIAL', 'Financial institution services', FALSE, 1.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '5734', 'Software Stores', 'RETAIL', 'Computer software stores', TRUE, 1.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '5942', 'Book Stores', 'RETAIL', 'Book stores', TRUE, 1.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '5944', 'Jewelry Stores', 'RETAIL', 'Jewelry and watch stores', TRUE, 1.0, FALSE, TRUE, CURRENT_TIMESTAMP()
UNION ALL SELECT '5945', 'Hobby Stores', 'RETAIL', 'Hobby, toy, and game shops', TRUE, 1.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '5947', 'Gift Shops', 'RETAIL', 'Gift, card, novelty stores', TRUE, 1.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '7832', 'Movie Theaters', 'ENTERTAINMENT', 'Motion picture theaters', TRUE, 1.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '8011', 'Doctors', 'HEALTHCARE', 'Doctors and physicians', TRUE, 1.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '8021', 'Dentists', 'HEALTHCARE', 'Dentists and orthodontists', TRUE, 1.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '8062', 'Hospitals', 'HEALTHCARE', 'Hospitals and medical centers', TRUE, 1.0, FALSE, FALSE, CURRENT_TIMESTAMP()
UNION ALL SELECT '7512', 'Car Rental', 'TRAVEL', 'Car rental agencies', TRUE, 2.0, FALSE, FALSE, CURRENT_TIMESTAMP();

-- ============================================================================
-- Section 14: Generate Compliance Events
-- ============================================================================

TRUNCATE TABLE IF EXISTS COMPLIANCE_EVENTS;

INSERT INTO COMPLIANCE_EVENTS (
    event_id, member_id, account_id, transaction_id, event_type,
    event_date, event_timestamp, severity, description, amount_involved,
    status, assigned_to, resolution_date, resolution_notes,
    regulatory_filing_required, filing_reference, created_at, updated_at
)
SELECT
    'CE' || LPAD(ROW_NUMBER() OVER (ORDER BY m.member_id)::VARCHAR, 8, '0'),
    m.member_id,
    NULL,
    NULL,
    event_types[UNIFORM(0, 7, RANDOM())],
    event_dt,
    DATEADD('second', UNIFORM(28800, 64800, RANDOM()), event_dt::TIMESTAMP),
    severities[UNIFORM(0, 2, RANDOM())],
    descriptions[UNIFORM(0, 7, RANDOM())],
    ROUND(UNIFORM(1000, 50000, RANDOM()), 2),
    statuses[UNIFORM(0, 3, RANDOM())],
    'AGT' || LPAD(UNIFORM(1, 20, RANDOM())::VARCHAR, 4, '0'),
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN DATEADD('day', UNIFORM(1, 30, RANDOM()), event_dt) ELSE NULL END,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN 'Event reviewed and resolved per standard procedures' ELSE NULL END,
    UNIFORM(0, 100, RANDOM()) < 20,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN 'SAR-' || LPAD(UNIFORM(100000, 999999, RANDOM())::VARCHAR, 6, '0') ELSE NULL END,
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
FROM MEMBERS m
CROSS JOIN (
    SELECT
        DATEADD('day', -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) as event_dt,
        ARRAY_CONSTRUCT('CTR_FILING','SAR_REVIEW','OFAC_ALERT','HIGH_RISK_REVIEW','STRUCTURING_ALERT','UNUSUAL_ACTIVITY','KYC_UPDATE','ELDER_ABUSE_ALERT') as event_types,
        ARRAY_CONSTRUCT('LOW','MEDIUM','HIGH') as severities,
        ARRAY_CONSTRUCT('Currency transaction report filing required','Suspicious activity identified for review','OFAC screening match requires verification','High-risk member periodic review','Potential structuring pattern detected','Unusual transaction activity flagged','KYC information requires update','Potential elder financial exploitation') as descriptions,
        ARRAY_CONSTRUCT('OPEN','UNDER_REVIEW','RESOLVED','CLOSED') as statuses
)
WHERE UNIFORM(0, 100, RANDOM()) < 5;

-- ============================================================================
-- Section 15: Generate Device Sessions
-- ============================================================================

TRUNCATE TABLE IF EXISTS DEVICE_SESSIONS;

INSERT INTO DEVICE_SESSIONS (
    session_id, member_id, device_id, device_type, device_os, browser,
    ip_address, location_city, location_state, location_country,
    session_start, session_end, session_duration_seconds,
    pages_viewed, actions_taken, is_mobile_app, app_version, risk_score, created_at
)
SELECT
    'SES' || LPAD(ROW_NUMBER() OVER (ORDER BY m.member_id, session_dt)::VARCHAR, 10, '0'),
    m.member_id,
    'DEV' || LPAD(UNIFORM(1, 100000, RANDOM())::VARCHAR, 8, '0'),
    device_types[UNIFORM(0, 3, RANDOM())],
    os_types[UNIFORM(0, 4, RANDOM())],
    browsers[UNIFORM(0, 4, RANDOM())],
    UNIFORM(10, 255, RANDOM())::VARCHAR || '.' || UNIFORM(0, 255, RANDOM())::VARCHAR || '.' || UNIFORM(0, 255, RANDOM())::VARCHAR || '.' || UNIFORM(0, 255, RANDOM())::VARCHAR,
    m.city,
    m.address_state,
    'US',
    session_start_ts,
    DATEADD('second', session_dur, session_start_ts),
    session_dur,
    UNIFORM(1, 20, RANDOM()),
    UNIFORM(1, 10, RANDOM()),
    UNIFORM(0, 100, RANDOM()) < 60,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN '4.' || UNIFORM(0, 9, RANDOM())::VARCHAR || '.' || UNIFORM(0, 99, RANDOM())::VARCHAR ELSE NULL END,
    ROUND(UNIFORM(0, 0.3, RANDOM()), 3),
    CURRENT_TIMESTAMP()
FROM MEMBERS m
CROSS JOIN (
    SELECT
        DATEADD('second', UNIFORM(0, 86400, RANDOM()), DATEADD('day', -UNIFORM(0, 30, RANDOM()), CURRENT_DATE())::TIMESTAMP) as session_start_ts,
        DATEADD('day', -UNIFORM(0, 30, RANDOM()), CURRENT_DATE()) as session_dt,
        UNIFORM(60, 1800, RANDOM()) as session_dur,
        ARRAY_CONSTRUCT('MOBILE','DESKTOP','TABLET','OTHER') as device_types,
        ARRAY_CONSTRUCT('iOS','Android','Windows','macOS','Linux') as os_types,
        ARRAY_CONSTRUCT('Safari','Chrome','Firefox','Edge','App') as browsers
)
WHERE UNIFORM(0, 100, RANDOM()) < 30;

-- ============================================================================
-- Section 16: Generate External Data (Credit Bureau)
-- ============================================================================

TRUNCATE TABLE IF EXISTS EXTERNAL_DATA;

INSERT INTO EXTERNAL_DATA (
    external_data_id, member_id, data_source, data_type, request_date, response_date,
    status, credit_score, credit_score_model, report_data, verification_result,
    expiration_date, created_at
)
SELECT
    'EXT' || LPAD(ROW_NUMBER() OVER (ORDER BY m.member_id)::VARCHAR, 8, '0'),
    m.member_id,
    data_sources[UNIFORM(0, 2, RANDOM())],
    data_types[UNIFORM(0, 2, RANDOM())],
    request_dt,
    DATEADD('second', UNIFORM(1, 300, RANDOM()), request_dt),
    'COMPLETED',
    m.credit_score,
    'FICO8',
    OBJECT_CONSTRUCT('inquiries', UNIFORM(0, 5, RANDOM()), 'accounts', UNIFORM(3, 15, RANDOM()), 'utilization', UNIFORM(10, 80, RANDOM())),
    'VERIFIED',
    DATEADD('day', 30, request_dt),
    CURRENT_TIMESTAMP()
FROM MEMBERS m
CROSS JOIN (
    SELECT
        DATEADD('day', -UNIFORM(1, 90, RANDOM()), CURRENT_DATE())::TIMESTAMP as request_dt,
        ARRAY_CONSTRUCT('EXPERIAN','EQUIFAX','TRANSUNION') as data_sources,
        ARRAY_CONSTRUCT('CREDIT_REPORT','CREDIT_SCORE','IDENTITY_VERIFICATION') as data_types
)
WHERE UNIFORM(0, 100, RANDOM()) < 40;

-- ============================================================================
-- Section 17: Generate Loan Applications
-- ============================================================================

TRUNCATE TABLE IF EXISTS LOAN_APPLICATIONS;

INSERT INTO LOAN_APPLICATIONS (
    application_id, member_id, loan_type, loan_subtype, application_status,
    requested_amount, approved_amount, requested_term_months, approved_term_months,
    approved_rate, application_date, decision_date, decision_reason_codes,
    credit_score_at_application, dti_ratio, employment_verified, income_verified,
    collateral_verified, underwriter_id, channel, promo_code, created_at, updated_at
)
SELECT
    'APP' || LPAD(ROW_NUMBER() OVER (ORDER BY m.member_id)::VARCHAR, 8, '0'),
    m.member_id,
    loan_types[UNIFORM(0, 2, RANDOM())],
    loan_subtypes[UNIFORM(0, 5, RANDOM())],
    app_statuses[status_idx],
    req_amt,
    CASE WHEN status_idx < 2 THEN ROUND(req_amt * UNIFORM(0.8, 1.0, RANDOM()), -2) ELSE NULL END,
    req_term,
    CASE WHEN status_idx < 2 THEN req_term ELSE NULL END,
    CASE WHEN status_idx < 2 THEN ROUND(UNIFORM(5.0, 15.0, RANDOM()), 2) ELSE NULL END,
    app_dt,
    CASE WHEN status_idx > 0 THEN DATEADD('day', UNIFORM(1, 5, RANDOM()), app_dt) ELSE NULL END,
    CASE WHEN status_idx = 2 THEN 'LOW_CREDIT_SCORE,HIGH_DTI' ELSE NULL END,
    m.credit_score,
    ROUND(UNIFORM(15, 50, RANDOM()), 2),
    TRUE,
    TRUE,
    CASE WHEN loan_types[UNIFORM(0, 2, RANDOM())] != 'PERSONAL' THEN TRUE ELSE FALSE END,
    'UW' || LPAD(UNIFORM(1, 20, RANDOM())::VARCHAR, 4, '0'),
    channels[UNIFORM(0, 3, RANDOM())],
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN 'SPRING2024' ELSE NULL END,
    CURRENT_TIMESTAMP(),
    CURRENT_TIMESTAMP()
FROM MEMBERS m
CROSS JOIN (
    SELECT
        DATEADD('day', -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) as app_dt,
        ROUND(UNIFORM(5000, 50000, RANDOM()), -3) as req_amt,
        CASE WHEN UNIFORM(0, 100, RANDOM()) < 50 THEN 60 WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 48 ELSE 36 END as req_term,
        UNIFORM(0, 3, RANDOM()) as status_idx,
        ARRAY_CONSTRUCT('AUTO','PERSONAL','MORTGAGE') as loan_types,
        ARRAY_CONSTRUCT('NEW_AUTO','USED_AUTO','SIGNATURE','SECURED','CONVENTIONAL','FHA') as loan_subtypes,
        ARRAY_CONSTRUCT('APPROVED','FUNDED','DECLINED','PENDING') as app_statuses,
        ARRAY_CONSTRUCT('ONLINE','BRANCH','MOBILE','PHONE') as channels
)
WHERE UNIFORM(0, 100, RANDOM()) < 25;

-- ============================================================================
-- Section 18: Verification Counts
-- ============================================================================

SELECT 'Data Generation Complete' AS status;

SELECT 'MEMBERS' as table_name, COUNT(*) as row_count FROM MEMBERS
UNION ALL SELECT 'ACCOUNTS', COUNT(*) FROM ACCOUNTS
UNION ALL SELECT 'LOANS', COUNT(*) FROM LOANS
UNION ALL SELECT 'CARDS', COUNT(*) FROM CARDS
UNION ALL SELECT 'TRANSACTIONS', COUNT(*) FROM TRANSACTIONS
UNION ALL SELECT 'SUPPORT_INTERACTIONS', COUNT(*) FROM SUPPORT_INTERACTIONS
UNION ALL SELECT 'SUPPORT_TRANSCRIPTS', COUNT(*) FROM SUPPORT_TRANSCRIPTS
UNION ALL SELECT 'COMPLIANCE_DOCUMENTS', COUNT(*) FROM COMPLIANCE_DOCUMENTS
UNION ALL SELECT 'COMPLIANCE_EVENTS', COUNT(*) FROM COMPLIANCE_EVENTS
UNION ALL SELECT 'PRODUCT_KNOWLEDGE', COUNT(*) FROM PRODUCT_KNOWLEDGE
UNION ALL SELECT 'BRANCHES', COUNT(*) FROM BRANCHES
UNION ALL SELECT 'DIRECT_DEPOSITS', COUNT(*) FROM DIRECT_DEPOSITS
UNION ALL SELECT 'MERCHANT_CATEGORIES', COUNT(*) FROM MERCHANT_CATEGORIES
UNION ALL SELECT 'DEVICE_SESSIONS', COUNT(*) FROM DEVICE_SESSIONS
UNION ALL SELECT 'EXTERNAL_DATA', COUNT(*) FROM EXTERNAL_DATA
UNION ALL SELECT 'LOAN_APPLICATIONS', COUNT(*) FROM LOAN_APPLICATIONS
ORDER BY table_name;
