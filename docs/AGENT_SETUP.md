# MACU Intelligence Agent Setup Guide

## Overview

The MACU Intelligence Agent is an AI-powered assistant built on Snowflake Cortex that helps credit union staff with member service, loan analysis, compliance queries, and operational insights.

## Prerequisites

Before deploying the Intelligence Agent, ensure you have:

1. **Snowflake Account** with Cortex features enabled
2. **Required Privileges**:
   - ACCOUNTADMIN or equivalent role
   - CREATE DATABASE, CREATE WAREHOUSE privileges
   - CORTEX_USER database role (for Cortex features)
3. **Completed Prior Setup Steps**:
   - Database and schemas created (01_database_and_schema.sql)
   - Core tables created and populated (02-04 scripts)
   - Views and semantic views created (06-07 scripts)
   - Cortex Search services created (08 script)
   - ML functions created (09 script)

## Agent Architecture

<img src="images/agent-tools-diagram.svg" alt="Agent Tool Architecture" width="100%">

## Agent Tools

### 1. Cortex Search Services

| Tool Name | Service | Use Case |
|-----------|---------|----------|
| `search_support_transcripts` | SUPPORT_TRANSCRIPTS_SEARCH | Find member interaction history |
| `search_compliance_docs` | COMPLIANCE_DOCS_SEARCH | Look up policies and regulations |
| `search_product_knowledge` | PRODUCT_KNOWLEDGE_SEARCH | Answer product questions |

### 2. Cortex Analyst (Text-to-SQL)

| Tool Name | Semantic View | Use Case |
|-----------|---------------|----------|
| `query_member_data` | SV_MEMBER_ANALYTICS | Member profiles and balances |
| `query_account_data` | SV_ACCOUNT_ANALYTICS | Account details and activity |
| `query_loan_data` | SV_LOAN_ANALYTICS | Loan portfolio analysis |
| `query_transaction_data` | SV_TRANSACTION_ANALYTICS | Transaction patterns |
| `query_support_metrics` | SV_SUPPORT_ANALYTICS | Support performance |

### 3. ML Model Functions

| Tool Name | Function | Use Case |
|-----------|----------|----------|
| `predict_loan_risk` | PREDICT_LOAN_DEFAULT_RISK | Assess loan default probability |
| `predict_fraud` | PREDICT_FRAUD_SCORE | Score transaction fraud risk |
| `predict_churn` | PREDICT_MEMBER_CHURN | Identify at-risk members |
| `recommend_loan_approval` | RECOMMEND_LOAN_APPROVAL | Loan decisioning support |

## Deployment Steps

### Step 1: Verify Prerequisites

```sql
-- Ensure all required objects exist
USE DATABASE MACU_INTELLIGENCE;

-- Check Cortex Search services
SHOW CORTEX SEARCH SERVICES IN SCHEMA RAW;

-- Check semantic views
SELECT table_name FROM INFORMATION_SCHEMA.TABLES 
WHERE table_schema = 'ANALYTICS' AND table_name LIKE 'SV_%';

-- Check ML functions
SHOW USER FUNCTIONS IN SCHEMA ANALYTICS;
```

### Step 2: Create the Agent

Run the script `sql/agent/10_create_intelligence_agent.sql`:

```sql
CREATE OR REPLACE CORTEX AGENT MACU_INTELLIGENCE_AGENT
  COMMENT = 'Mountain America Credit Union AI Assistant'
  MODEL = 'claude-3-5-sonnet'
  TOOLS = (
    -- Cortex Search tools
    { 'type': 'cortex_search', 'name': 'search_support_transcripts', ... },
    { 'type': 'cortex_search', 'name': 'search_compliance_docs', ... },
    { 'type': 'cortex_search', 'name': 'search_product_knowledge', ... },
    
    -- Cortex Analyst tools
    { 'type': 'cortex_analyst_text_to_sql', 'name': 'query_member_data', ... },
    ...
    
    -- ML Function tools
    { 'type': 'sql_function', 'name': 'predict_loan_risk', ... },
    ...
  )
  AGENT_INSTRUCTIONS = $$ ... $$;
```

### Step 3: Test the Agent

```sql
-- Test product knowledge
SELECT SNOWFLAKE.CORTEX.AGENT(
    'MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT',
    'What are the current auto loan rates?'
);

-- Test member query
SELECT SNOWFLAKE.CORTEX.AGENT(
    'MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT',
    'How many PLATINUM tier members do we have?'
);

-- Test compliance search
SELECT SNOWFLAKE.CORTEX.AGENT(
    'MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT',
    'What are our SAR filing requirements?'
);

-- Test ML prediction
SELECT SNOWFLAKE.CORTEX.AGENT(
    'MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT',
    'What is the default risk for a member with 680 credit score requesting $35,000 auto loan?'
);
```

## Agent Instructions

The agent is configured with credit union-specific instructions including:

1. **Terminology**: Uses "members" instead of "customers"
2. **Products**: Understands Share Savings, Share Certificates, HELOCs, etc.
3. **Compliance**: Knows NCUA regulations and BSA/AML requirements
4. **Geography**: Aware of MACU's service areas (UT, ID, AZ, NV, NM)
5. **Escalation**: Knows when to recommend supervisor involvement

## Granting Access

To allow other users to use the agent:

```sql
-- Grant usage on the agent
GRANT USAGE ON CORTEX AGENT MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT
TO ROLE member_service_role;

-- Grant required privileges on underlying objects
GRANT USAGE ON DATABASE MACU_INTELLIGENCE TO ROLE member_service_role;
GRANT USAGE ON ALL SCHEMAS IN DATABASE MACU_INTELLIGENCE TO ROLE member_service_role;
GRANT SELECT ON ALL TABLES IN SCHEMA MACU_INTELLIGENCE.RAW TO ROLE member_service_role;
GRANT SELECT ON ALL VIEWS IN SCHEMA MACU_INTELLIGENCE.ANALYTICS TO ROLE member_service_role;
```

## Monitoring

Monitor agent usage through Snowflake's query history:

```sql
-- View recent agent queries
SELECT query_text, user_name, start_time, total_elapsed_time
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_text LIKE '%SNOWFLAKE.CORTEX.AGENT%'
ORDER BY start_time DESC
LIMIT 50;
```

## Troubleshooting

### Agent Not Responding

1. Check warehouse is running: `SELECT CURRENT_WAREHOUSE();`
2. Verify Cortex access: `SELECT SNOWFLAKE.CORTEX.COMPLETE('claude-3-5-sonnet', 'test');`
3. Check Search services: `SHOW CORTEX SEARCH SERVICES;`

### Incorrect Answers

1. Review semantic view definitions for accuracy
2. Check data freshness in source tables
3. Verify feature store health metrics

### Permission Errors

1. Ensure user has CORTEX_USER role
2. Grant SELECT on required tables/views
3. Grant USAGE on Cortex Search services

## Best Practices

1. **Rate Limiting**: Implement application-level rate limiting for production use
2. **Logging**: Log all agent interactions for audit and improvement
3. **Feedback Loop**: Collect user feedback to improve agent instructions
4. **Regular Updates**: Refresh product knowledge and compliance docs regularly
5. **Testing**: Test agent responses after any schema or data changes
