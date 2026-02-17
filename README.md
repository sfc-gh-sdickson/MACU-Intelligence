<img src="Snowflake_Logo.svg" width="200">

# Mountain America Credit Union Intelligence Agent & Feature Store Demo

## About Mountain America Credit Union

Mountain America Credit Union is one of the largest credit unions in the United States, serving over 1 million members across Utah, Idaho, Arizona, Nevada, and New Mexico. As a member-owned financial cooperative, MACU provides a full range of financial services with a focus on member value and community impact.

### Key Services

- **Share Savings**: Primary membership accounts with competitive dividends
- **Checking**: Rewards and basic checking with no hidden fees
- **Share Certificates**: Term deposits with guaranteed returns
- **Auto Loans**: Competitive rates for new and used vehicles
- **Home Loans**: Mortgages, refinancing, and home equity products
- **Personal Loans**: Signature and secured personal lending
- **Credit Cards**: Visa Rewards cards with cash back
- **Digital Banking**: Full-featured mobile and online banking

### Technology Innovation

- **Member-First Digital Experience**: Modern mobile and online banking
- **AI-Powered Assistance**: Intelligence Agent for staff support
- **ML-Driven Decisions**: Risk assessment, fraud detection, personalization
- **Feature Store**: Centralized ML feature management

## Project Overview

This Snowflake Intelligence solution showcases:

### Architecture

<img src="docs/images/architecture-diagram.svg" alt="MACU Intelligence Agent Architecture" width="100%">

### Feature Store Capabilities
- **Feature Engineering**: SQL-based feature definitions with versioning
- **Feature Registry**: Centralized catalog of all features with metadata
- **Training Datasets**: Point-in-time correct feature retrieval
- **Online Serving**: Low-latency feature serving for real-time inference
- **Feature Monitoring**: Data quality and drift detection

### Credit Union Intelligence Use Cases
- **Loan Risk Assessment**: Default probability scoring
- **Fraud Detection**: Real-time transaction risk scoring
- **Member 360**: Unified view of member behavior and value
- **Churn Prevention**: Early warning signals and retention actions
- **Compliance Support**: BSA/AML guidance and policy lookup

## Directory Structure

```
├── README.md                           # This file
├── docs/
│   ├── AGENT_SETUP.md                  # Agent configuration guide
│   ├── DEMO_PRESENTATION_GUIDE.md      # Demo walkthrough
│   ├── FEATURE_STORE_GUIDE.md          # Feature Store documentation
│   └── questions.md                    # Sample agent questions
├── notebooks/
│   └── macu_ml_models.ipynb            # ML training notebook
└── sql/
    ├── setup/
    │   ├── 01_database_and_schema.sql  # Database initialization
    │   └── 02_create_tables.sql        # Core table definitions
    ├── data/
    │   └── 04_generate_synthetic_data.sql  # Synthetic data generation
    ├── feature_store/
    │   ├── 03_create_feature_store.sql     # Feature Store infrastructure
    │   ├── 05_create_features.sql          # Feature definitions
    │   ├── 05a_populate_monitoring_data.sql # Monitoring data
    │   └── 05b_create_aggregation_views.sql # Aggregation views
    ├── views/
    │   ├── 06_create_views.sql             # Analytical views
    │   └── 07_create_semantic_views.sql    # Semantic views for Analyst
    ├── search/
    │   └── 08_create_cortex_search.sql     # Cortex Search services
    ├── ml/
    │   └── 09_create_model_functions.sql   # ML inference functions
    ├── agent/
    │   └── 10_create_intelligence_agent.sql # Agent creation
    ├── monitoring/
    │   └── 11_create_monitoring_dashboard.sql # Dashboard views
    └── validation/
        └── 12_validate_deployment.sql      # Deployment validation
```

## Database Schema

### 1. **RAW Schema**: Core Banking Tables
- MEMBERS: Credit union members and demographics
- ACCOUNTS: Share savings, checking, certificates, credit cards
- LOANS: Auto, mortgage, home equity, personal loans
- CARDS: Debit and credit card details
- TRANSACTIONS: All financial transactions
- DIRECT_DEPOSITS: Payroll and recurring deposits
- SUPPORT_INTERACTIONS: Member service contacts
- SUPPORT_TRANSCRIPTS: Interaction transcripts for search
- COMPLIANCE_DOCUMENTS: Policies and regulations
- PRODUCT_KNOWLEDGE: Product documentation
- BRANCHES: Branch locations

### 2. **FEATURE_STORE Schema**: ML Feature Management
- ENTITY_MEMBER/ACCOUNT/LOAN/TRANSACTION: Entity tables
- FEATURE_REGISTRY: Feature metadata and definitions
- FEATURE_GROUPS: Logical feature groupings
- FEATURE_COMPUTATION_LOG: Computation history
- FEATURE_STORE_HEALTH: Health monitoring

### 3. **ANALYTICS Schema**: Intelligence Views
- V_MEMBER_360: Comprehensive member profile
- V_ACCOUNT_SUMMARY: Account details and activity
- V_LOAN_PORTFOLIO: Loan analysis view
- V_TRANSACTION_ANALYTICS: Transaction patterns
- V_SUPPORT_ANALYTICS: Support metrics
- SV_* Semantic views for Cortex Analyst

## Setup Instructions

### Prerequisites
- Snowflake account with Cortex Intelligence enabled
- ACCOUNTADMIN or equivalent privileges
- Warehouse for query execution

### Quick Start
```sql
-- 1. Create database and schemas
-- Run: sql/setup/01_database_and_schema.sql

-- 2. Create core tables
-- Run: sql/setup/02_create_tables.sql

-- 3. Create Feature Store tables
-- Run: sql/feature_store/03_create_feature_store.sql

-- 4. Generate synthetic data (~5 min)
-- Run: sql/data/04_generate_synthetic_data.sql

-- 5. Create aggregation views
-- Run: sql/feature_store/05b_create_aggregation_views.sql

-- 6. Create analytical views
-- Run: sql/views/06_create_views.sql

-- 7. Create semantic views for AI
-- Run: sql/views/07_create_semantic_views.sql

-- 8. Create Cortex Search services
-- Run: sql/search/08_create_cortex_search.sql

-- 9. Create ML wrapper functions
-- Run: sql/ml/09_create_model_functions.sql

-- 10. Configure Intelligence Agent
-- Run: sql/agent/10_create_intelligence_agent.sql

-- 11. Create monitoring dashboards
-- Run: sql/monitoring/11_create_monitoring_dashboard.sql

-- 12. Validate deployment
-- Run: sql/validation/12_validate_deployment.sql
```

## Data Volumes

- **Members**: ~10,000 active members
- **Accounts**: ~25,000 (savings, checking, certificates, credit)
- **Loans**: ~7,500 (auto, mortgage, home equity, personal)
- **Transactions**: ~500,000 historical
- **Features**: 15+ engineered features
- **Branches**: 30+ locations across 5 states

## Using the Agent

### Example Queries

```sql
-- Product information
SELECT SNOWFLAKE.CORTEX.AGENT(
    'MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT',
    'What are the current auto loan rates?'
);

-- Member analytics
SELECT SNOWFLAKE.CORTEX.AGENT(
    'MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT',
    'How many PLATINUM tier members do we have in Utah?'
);

-- Loan risk assessment
SELECT SNOWFLAKE.CORTEX.AGENT(
    'MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT',
    'What is the default risk for a member with 680 credit score requesting $35,000 auto loan?'
);

-- Compliance guidance
SELECT SNOWFLAKE.CORTEX.AGENT(
    'MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT',
    'What are our SAR filing requirements?'
);
```

## Service Areas

Mountain America Credit Union serves:
- **Utah** - Primary market (Salt Lake City, Provo, Ogden, St. George)
- **Idaho** - Boise, Meridian, Idaho Falls
- **Arizona** - Mesa, Gilbert, Chandler
- **Nevada** - Las Vegas, Henderson
- **New Mexico** - Albuquerque

## Documentation

- [Agent Setup Guide](docs/AGENT_SETUP.md) - Detailed agent configuration
- [Feature Store Guide](docs/FEATURE_STORE_GUIDE.md) - Feature management documentation
- [Demo Presentation Guide](docs/DEMO_PRESENTATION_GUIDE.md) - Demo walkthrough
- [Sample Questions](docs/questions.md) - Example queries for the agent

## Version History

- **v1.0** (February 2026): Initial release
  - Complete Feature Store implementation
  - Credit union-specific semantic views
  - 500K+ transactions, 10K members
  - 15+ ML features
  - Cortex Search for support and compliance
  - Intelligence Agent with multi-tool support

---

**Created**: February 2026  
**Focus**: SQL-First Feature Store for Credit Union ML  
**Platform**: Snowflake Cortex

**ALL SQL SYNTAX VERIFIED** ✅  
**FEATURE STORE PATTERNS TESTED** ✅

---

*Built with Snowflake Cortex, Feature Store, and Intelligence Agent*
