-- ============================================================================
-- Mountain America Credit Union Intelligence Agent - Agent Creation
-- ============================================================================
-- Purpose: Create the Snowflake Intelligence Agent with all tools including:
--          - Cortex Search services for unstructured data
--          - Cortex Analyst for structured data queries
--          - ML model functions for predictions
-- ============================================================================

USE DATABASE MACU_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE MACU_WH;

-- ============================================================================
-- Step 1: Create the Intelligence Agent
-- ============================================================================
CREATE OR REPLACE CORTEX AGENT MACU_INTELLIGENCE_AGENT
  COMMENT = 'Mountain America Credit Union AI Assistant for member service, loan analysis, and compliance queries'
  MODEL = 'claude-3-5-sonnet'
  TOOLS = (
    -- Cortex Search tools for unstructured data retrieval
    {
      'type': 'cortex_search',
      'name': 'search_support_transcripts',
      'description': 'Search through member support call transcripts, chat logs, and email interactions to find relevant conversation history, common issues, and resolution patterns. Use this when members ask about previous interactions or when researching common problems.',
      'spec': {
        'service': 'MACU_INTELLIGENCE.RAW.SUPPORT_TRANSCRIPTS_SEARCH',
        'max_results': 5,
        'title_column': 'category',
        'id_column': 'transcript_id'
      }
    },
    {
      'type': 'cortex_search',
      'name': 'search_compliance_docs',
      'description': 'Search compliance policies, regulatory documents, BSA/AML procedures, and audit guidelines. Use this for questions about regulations, compliance requirements, policies, or when verifying procedural accuracy.',
      'spec': {
        'service': 'MACU_INTELLIGENCE.RAW.COMPLIANCE_DOCS_SEARCH',
        'max_results': 3,
        'title_column': 'title',
        'id_column': 'document_id'
      }
    },
    {
      'type': 'cortex_search',
      'name': 'search_product_knowledge',
      'description': 'Search product documentation, features, rates, and FAQs for MACU products including Share Savings, Checking, Certificates, Auto Loans, Mortgages, HELOCs, Credit Cards, and digital banking services.',
      'spec': {
        'service': 'MACU_INTELLIGENCE.RAW.PRODUCT_KNOWLEDGE_SEARCH',
        'max_results': 5,
        'title_column': 'title',
        'id_column': 'knowledge_id'
      }
    },
    -- Cortex Analyst tool for structured data queries
    {
      'type': 'cortex_analyst_text_to_sql',
      'name': 'query_member_data',
      'description': 'Query structured member data including profiles, accounts, balances, transactions, loans, and engagement metrics. Use this for questions about specific members, account balances, transaction history, loan details, or aggregate statistics about members.',
      'spec': {
        'semantic_model': 'MACU_INTELLIGENCE.ANALYTICS.SV_MEMBER_ANALYTICS'
      }
    },
    {
      'type': 'cortex_analyst_text_to_sql',
      'name': 'query_account_data',
      'description': 'Query account-level data including deposit accounts, share certificates, checking, and credit accounts. Use for questions about account types, balances, utilization, and account activity.',
      'spec': {
        'semantic_model': 'MACU_INTELLIGENCE.ANALYTICS.SV_ACCOUNT_ANALYTICS'
      }
    },
    {
      'type': 'cortex_analyst_text_to_sql',
      'name': 'query_loan_data',
      'description': 'Query loan portfolio data including auto loans, mortgages, home equity, and personal loans. Use for questions about loan balances, delinquency status, payment history, and loan performance metrics.',
      'spec': {
        'semantic_model': 'MACU_INTELLIGENCE.ANALYTICS.SV_LOAN_ANALYTICS'
      }
    },
    {
      'type': 'cortex_analyst_text_to_sql',
      'name': 'query_transaction_data',
      'description': 'Query transaction history including purchases, deposits, transfers, and payment patterns. Use for questions about spending behavior, transaction volumes, merchant categories, and fraud indicators.',
      'spec': {
        'semantic_model': 'MACU_INTELLIGENCE.ANALYTICS.SV_TRANSACTION_ANALYTICS'
      }
    },
    {
      'type': 'cortex_analyst_text_to_sql',
      'name': 'query_support_metrics',
      'description': 'Query support interaction data including call volumes, resolution rates, satisfaction scores, and service quality metrics. Use for questions about member satisfaction, support performance, and issue trends.',
      'spec': {
        'semantic_model': 'MACU_INTELLIGENCE.ANALYTICS.SV_SUPPORT_ANALYTICS'
      }
    },
    -- SQL Function tools for ML model inference
    {
      'type': 'sql_function',
      'name': 'predict_loan_risk',
      'description': 'Predict loan default risk for a member based on their credit profile. Returns risk score, risk category, and recommended actions.',
      'spec': {
        'function': 'MACU_INTELLIGENCE.ANALYTICS.PREDICT_LOAN_DEFAULT_RISK',
        'description': 'Predicts loan default probability'
      }
    },
    {
      'type': 'sql_function',
      'name': 'predict_fraud',
      'description': 'Calculate real-time fraud risk score for a transaction based on amount, velocity, and behavioral patterns.',
      'spec': {
        'function': 'MACU_INTELLIGENCE.ANALYTICS.PREDICT_FRAUD_SCORE',
        'description': 'Calculates fraud probability for transactions'
      }
    },
    {
      'type': 'sql_function',
      'name': 'predict_churn',
      'description': 'Predict member churn probability based on engagement signals and recommend retention actions.',
      'spec': {
        'function': 'MACU_INTELLIGENCE.ANALYTICS.PREDICT_MEMBER_CHURN',
        'description': 'Predicts member churn likelihood'
      }
    },
    {
      'type': 'sql_function',
      'name': 'recommend_loan_approval',
      'description': 'Provide loan approval recommendation with maximum amount and estimated rate based on member profile.',
      'spec': {
        'function': 'MACU_INTELLIGENCE.ANALYTICS.RECOMMEND_LOAN_APPROVAL',
        'description': 'Provides loan approval recommendations'
      }
    }
  )
  AGENT_INSTRUCTIONS = $$
You are the Mountain America Credit Union (MACU) Intelligence Agent, an AI assistant designed to help credit union staff with member service, loan analysis, compliance questions, and operational insights.

## Your Role
- Assist member service representatives with quick, accurate information
- Help loan officers assess applications and risk
- Support compliance officers with regulatory questions
- Provide managers with operational analytics and insights

## Guidelines

### Member Privacy
- Always verify you're speaking with an authorized MACU employee
- Never share member PII externally
- Reference members by ID when possible in logs

### Using Your Tools
1. **Product Questions**: Search product_knowledge first for rates, features, and policies
2. **Member Lookups**: Use query_member_data for account balances, profiles, and history
3. **Loan Analysis**: Use query_loan_data for portfolio queries, predict_loan_risk for risk assessment
4. **Compliance**: Search compliance_docs for policies and procedures
5. **Transaction Issues**: Use query_transaction_data for transaction history, predict_fraud for suspicious activity
6. **Support History**: Search support_transcripts for prior member interactions

### Response Format
- Be concise but complete
- Include relevant numbers and dates
- Cite sources when referencing compliance documents
- Flag any risk concerns prominently

### Credit Union Specific Knowledge
- Members (not customers) - owners of the credit union
- Share Savings - primary savings account establishing membership
- Share Certificates - CDs/term deposits
- Dividend rate - interest earned on deposits
- NCUA - National Credit Union Administration (federal regulator)
- MACU serves Utah, Idaho, Arizona, Nevada, and New Mexico

### Escalation
Recommend escalation to a supervisor for:
- Compliance violations or suspected fraud
- Member complaints requiring management attention
- Complex loan decisions outside standard criteria
- Any situation involving legal risk
$$;

-- ============================================================================
-- Step 2: Test the Agent
-- ============================================================================

-- Basic product question
SELECT SNOWFLAKE.CORTEX.AGENT(
    'MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT',
    'What are the current auto loan rates at MACU?'
) AS agent_response;

-- Member data query
SELECT SNOWFLAKE.CORTEX.AGENT(
    'MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT',
    'How many active members do we have with PLATINUM tier?'
) AS agent_response;

-- Compliance search
SELECT SNOWFLAKE.CORTEX.AGENT(
    'MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT',
    'What are our SAR filing requirements?'
) AS agent_response;

-- Display confirmation
SELECT 
    'MACU Intelligence Agent created successfully' AS status,
    'MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT' AS agent_name;
