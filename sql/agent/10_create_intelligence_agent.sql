-- ============================================================================
-- Mountain America Credit Union Intelligence Agent - Agent Creation
-- ============================================================================
-- Purpose: Create the Snowflake Intelligence Agent with all tools including:
--          - Cortex Search services for unstructured data
--          - Cortex Analyst for structured data queries
-- ============================================================================

USE DATABASE MACU_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE MACU_WH;

-- ============================================================================
-- Step 1: Create the Intelligence Agent
-- ============================================================================
CREATE OR REPLACE AGENT MACU_INTELLIGENCE_AGENT
  COMMENT = 'Mountain America Credit Union AI Assistant for member service, loan analysis, and compliance queries'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  orchestration:
    budget:
      seconds: 60
      tokens: 32000

  instructions:
    response: |
      Be concise but complete. Include relevant numbers and dates. 
      Cite sources when referencing compliance documents.
      Flag any risk concerns prominently.
    orchestration: |
      For product questions use search_product_knowledge.
      For member lookups use query_member_data.
      For loan analysis use query_loan_data.
      For compliance questions use search_compliance_docs.
      For transaction issues use query_transaction_data.
      For support history use search_support_transcripts.
    system: |
      You are the Mountain America Credit Union (MACU) Intelligence Agent, an AI assistant designed to help credit union staff with member service, loan analysis, compliance questions, and operational insights.
      
      ## Your Role
      - Assist member service representatives with quick, accurate information
      - Help loan officers assess applications and risk
      - Support compliance officers with regulatory questions
      - Provide managers with operational analytics and insights
      
      ## Member Privacy
      - Always verify you're speaking with an authorized MACU employee
      - Never share member PII externally
      - Reference members by ID when possible in logs
      
      ## Credit Union Specific Knowledge
      - Members (not customers) - owners of the credit union
      - Share Savings - primary savings account establishing membership
      - Share Certificates - CDs/term deposits
      - Dividend rate - interest earned on deposits
      - NCUA - National Credit Union Administration (federal regulator)
      - MACU serves Utah, Idaho, Arizona, Nevada, and New Mexico
      
      ## Escalation
      Recommend escalation to a supervisor for:
      - Compliance violations or suspected fraud
      - Member complaints requiring management attention
      - Complex loan decisions outside standard criteria
      - Any situation involving legal risk
    sample_questions:
      - question: "What are the current auto loan rates at MACU?"
        answer: "I'll search our product knowledge base for the current auto loan rates."
      - question: "How many active members do we have with PLATINUM tier?"
        answer: "I'll query our member analytics to get the count of PLATINUM tier members."

  tools:
    - tool_spec:
        type: "cortex_search"
        name: "search_support_transcripts"
        description: "Search through member support call transcripts, chat logs, and email interactions to find relevant conversation history, common issues, and resolution patterns."
    - tool_spec:
        type: "cortex_search"
        name: "search_compliance_docs"
        description: "Search compliance policies, regulatory documents, BSA/AML procedures, and audit guidelines."
    - tool_spec:
        type: "cortex_search"
        name: "search_product_knowledge"
        description: "Search product documentation, features, rates, and FAQs for MACU products including Share Savings, Checking, Certificates, Auto Loans, Mortgages, HELOCs, Credit Cards."
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "query_member_data"
        description: "Query structured member data including profiles, accounts, balances, transactions, loans, and engagement metrics."
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "query_loan_data"
        description: "Query loan portfolio data including auto loans, mortgages, home equity, and personal loans, delinquency status, and payment history."
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "query_transaction_data"
        description: "Query transaction history including purchases, deposits, transfers, and payment patterns."
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "query_support_metrics"
        description: "Query support interaction data including call volumes, resolution rates, satisfaction scores."

  tool_resources:
    search_support_transcripts:
      name: "MACU_INTELLIGENCE.RAW.SUPPORT_TRANSCRIPTS_SEARCH"
      max_results: "5"
      title_column: "category"
      id_column: "transcript_id"
    search_compliance_docs:
      name: "MACU_INTELLIGENCE.RAW.COMPLIANCE_DOCS_SEARCH"
      max_results: "3"
      title_column: "title"
      id_column: "document_id"
    search_product_knowledge:
      name: "MACU_INTELLIGENCE.RAW.PRODUCT_KNOWLEDGE_SEARCH"
      max_results: "5"
      title_column: "title"
      id_column: "knowledge_id"
    query_member_data:
      semantic_view: "MACU_INTELLIGENCE.ANALYTICS.SV_MEMBER_ANALYTICS"
    query_loan_data:
      semantic_view: "MACU_INTELLIGENCE.ANALYTICS.SV_LOAN_ANALYTICS"
    query_transaction_data:
      semantic_view: "MACU_INTELLIGENCE.ANALYTICS.SV_TRANSACTION_ANALYTICS"
    query_support_metrics:
      semantic_view: "MACU_INTELLIGENCE.ANALYTICS.SV_SUPPORT_ANALYTICS"
  $$;

-- ============================================================================
-- Step 2: Test the Agent
-- ============================================================================

-- Basic product question
SELECT TRY_PARSE_JSON(
    SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
        'MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT',
        $${
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": "What are the current auto loan rates at MACU?"}
                    ]
                }
            ],
            "stream": false
        }$$
    )
) AS agent_response;

-- Display confirmation
SELECT 
    'MACU Intelligence Agent created successfully' AS status,
    'MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT' AS agent_name;
