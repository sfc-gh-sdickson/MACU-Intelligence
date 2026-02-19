-- ============================================================================
-- Mountain America Credit Union Intelligence Agent - Agent Creation
-- ============================================================================
-- Purpose: Create the Snowflake Intelligence Agent with all tools including:
--          - Cortex Search services for unstructured data
--          - Cortex Analyst for structured data queries
--          - ML Model functions for predictions
-- 
-- PREREQUISITE: Run 09_create_model_functions.sql first to create the UDFs
-- ============================================================================

USE DATABASE MACU_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE MACU_WH;

-- ============================================================================
-- Step 1: Create the Intelligence Agent
-- ============================================================================
CREATE OR REPLACE AGENT MACU_INTELLIGENCE_AGENT
  COMMENT = 'Mountain America Credit Union AI Assistant for member service, loan analysis, compliance queries, and ML predictions'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  orchestration:
    budget:
      seconds: 90
      tokens: 32000

  instructions:
    response: |
      Be concise but complete. Include relevant numbers and dates. 
      Cite sources when referencing compliance documents.
      Flag any risk concerns prominently.
      When providing predictions, always explain the key factors.
    orchestration: |
      For product questions use search_product_knowledge.
      For member lookups use query_member_data.
      For loan analysis use query_loan_data.
      For compliance questions use search_compliance_docs.
      For transaction issues use query_transaction_data.
      For support history use search_support_transcripts.
      For loan risk assessment or high-risk loans use query_loan_risk_predictions.
      For churn prediction or at-risk members use query_churn_predictions.
      For NEW loan approval decisions (not existing loans) use recommend_loan.
      For fraud scoring on specific transactions use predict_fraud.
    system: |
      You are the Mountain America Credit Union (MACU) Intelligence Agent, an AI assistant designed to help credit union staff with member service, loan analysis, compliance questions, ML-powered predictions, and operational insights.
      
      ## Your Role
      - Assist member service representatives with quick, accurate information
      - Help loan officers assess applications and risk using ML models
      - Support compliance officers with regulatory questions
      - Provide managers with operational analytics and insights
      - Deliver fraud risk scores for suspicious transactions
      - Predict member churn to enable proactive retention
      
      ## ML Capabilities
      You have access to trained ML models for:
      - Loan Default Risk Prediction: Scores loan risk based on credit score, DTI, payment history
      - Fraud Detection: Scores transactions based on amount, velocity, location patterns
      - Member Churn Prediction: Identifies at-risk members based on engagement patterns
      - Loan Approval Recommendation: Provides approval decisions with rate estimates
      
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
      - question: "What is the default risk for a member with 680 credit score applying for a $25,000 loan?"
        answer: "I'll use our loan risk prediction model to assess the default probability and risk category."
      - question: "Is this $5,000 international transaction at 3am suspicious?"
        answer: "I'll run our fraud detection model to score this transaction for fraud risk."
      - question: "Which members are at high risk of churning?"
        answer: "I'll query our churn prediction scores to identify at-risk members."
      - question: "Should we approve this auto loan application?"
        answer: "I'll use our loan approval model to provide a recommendation with estimated rate."
      - question: "What are our BSA/AML reporting requirements?"
        answer: "I'll search our compliance documents for BSA/AML procedures."
      - question: "Show me the loan portfolio delinquency breakdown by loan type"
        answer: "I'll query our loan analytics to get the delinquency breakdown."
      - question: "What issues have members been calling about most frequently?"
        answer: "I'll search support transcripts to identify common issues."
      - question: "How many auto loans originated this month?"
        answer: "I'll query the loan data to get this month's auto loan origination count."

  tools:
    # Cortex Search Tools
    - tool_spec:
        type: "cortex_search"
        name: "search_support_transcripts"
        description: "Search through member support call transcripts, chat logs, and email interactions to find relevant conversation history, common issues, and resolution patterns."
    - tool_spec:
        type: "cortex_search"
        name: "search_compliance_docs"
        description: "Search compliance policies, regulatory documents, BSA/AML procedures, NCUA guidelines, and audit requirements."
    - tool_spec:
        type: "cortex_search"
        name: "search_product_knowledge"
        description: "Search product documentation, features, rates, eligibility, and FAQs for MACU products including Share Savings, Checking, Certificates, Auto Loans, Mortgages, HELOCs, Credit Cards."
    
    # Cortex Analyst Tools
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "query_member_data"
        description: "Query structured member data including profiles, accounts, balances, demographics, tenure, credit scores, and engagement metrics."
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "query_loan_data"
        description: "Query loan portfolio data including auto loans, mortgages, home equity, personal loans, delinquency status, payment history, and risk metrics."
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "query_transaction_data"
        description: "Query transaction history including purchases, deposits, transfers, merchant categories, fraud scores, and payment patterns."
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "query_support_metrics"
        description: "Query support interaction data including call volumes, resolution rates, satisfaction scores, NPS, and agent performance."
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "query_account_data"
        description: "Query account data including balances, account types, utilization, activity, and product holdings."
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "query_loan_risk_predictions"
        description: "Query ML-generated loan default risk predictions. Find high-risk loans, get risk scores by loan type, identify loans needing attention. Returns risk_category (HIGH_RISK/MEDIUM_RISK/LOW_RISK), risk_score, and recommended_action."
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "query_churn_predictions"
        description: "Query ML-generated member churn predictions. Find at-risk members, get churn probability scores, identify members for retention campaigns. Returns churn_risk (HIGH/MEDIUM/LOW), churn_probability, and retention_actions."

    # ML Prediction Tools
    - tool_spec:
        type: "generic"
        name: "predict_loan_risk"
        description: "Predict loan default risk using ML model. Returns risk score (0-1), risk category (LOW/MEDIUM/HIGH), and recommended action. Use for assessing existing loans or evaluating new applications."
        input_schema:
          type: "object"
          properties:
            credit_score:
              type: "integer"
              description: "Member's credit score (300-850)"
            loan_amount:
              type: "number"
              description: "Loan amount in dollars"
            dti_ratio:
              type: "number"
              description: "Debt-to-income ratio (0-1, e.g., 0.35 for 35%)"
            tenure_days:
              type: "integer"
              description: "Member tenure in days"
            total_loan_balance:
              type: "number"
              description: "Total outstanding loan balance"
            times_30_days_late:
              type: "integer"
              description: "Number of times 30+ days late on payments"
          required: ["credit_score", "loan_amount", "dti_ratio"]

    - tool_spec:
        type: "generic"
        name: "predict_fraud"
        description: "Score a transaction for fraud risk using ML model. Returns fraud score (0-1), risk level, and risk factors. Use for real-time fraud detection on suspicious transactions."
        input_schema:
          type: "object"
          properties:
            amount:
              type: "number"
              description: "Transaction amount in dollars"
            avg_transaction_amount:
              type: "number"
              description: "Member's average transaction amount"
            txn_count_1h:
              type: "integer"
              description: "Number of transactions in past hour"
            is_international:
              type: "boolean"
              description: "Whether transaction is international"
            is_new_merchant:
              type: "boolean"
              description: "Whether merchant is new to this member"
            hour_of_day:
              type: "integer"
              description: "Hour of day (0-23)"
          required: ["amount", "avg_transaction_amount"]

    - tool_spec:
        type: "generic"
        name: "predict_churn"
        description: "Predict member churn probability using ML model. Returns churn probability, risk level, and recommended retention actions. Use for identifying at-risk members."
        input_schema:
          type: "object"
          properties:
            tenure_days:
              type: "integer"
              description: "Member tenure in days"
            transactions_30d:
              type: "integer"
              description: "Number of transactions in past 30 days"
            digital_enrolled:
              type: "boolean"
              description: "Whether member uses digital banking"
            products_held:
              type: "integer"
              description: "Number of products/accounts held"
            support_interactions_90d:
              type: "integer"
              description: "Support interactions in past 90 days"
            days_since_last_activity:
              type: "integer"
              description: "Days since last account activity"
          required: ["tenure_days", "transactions_30d", "products_held"]

    - tool_spec:
        type: "generic"
        name: "recommend_loan"
        description: "Get loan approval recommendation using ML model. Returns approval decision (APPROVE/DECLINE/MANUAL_REVIEW), max approved amount, estimated rate, and conditions. Use for loan application decisions."
        input_schema:
          type: "object"
          properties:
            loan_type:
              type: "string"
              description: "Type of loan: AUTO, PERSONAL, HOME_EQUITY, MORTGAGE"
            requested_amount:
              type: "number"
              description: "Requested loan amount in dollars"
            credit_score:
              type: "integer"
              description: "Applicant's credit score (300-850)"
            monthly_income:
              type: "number"
              description: "Monthly income in dollars"
            existing_monthly_debt:
              type: "number"
              description: "Existing monthly debt payments"
            employment_status:
              type: "string"
              description: "Employment status: EMPLOYED, SELF_EMPLOYED, RETIRED, STUDENT"
            membership_tenure_years:
              type: "integer"
              description: "Years as MACU member"
          required: ["loan_type", "requested_amount", "credit_score", "monthly_income", "existing_monthly_debt"]

  tool_resources:
    # Cortex Search Resources
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
    
    # Cortex Analyst Resources
    query_member_data:
      semantic_view: "MACU_INTELLIGENCE.ANALYTICS.SV_MEMBER_ANALYTICS"
    query_loan_data:
      semantic_view: "MACU_INTELLIGENCE.ANALYTICS.SV_LOAN_ANALYTICS"
    query_transaction_data:
      semantic_view: "MACU_INTELLIGENCE.ANALYTICS.SV_TRANSACTION_ANALYTICS"
    query_support_metrics:
      semantic_view: "MACU_INTELLIGENCE.ANALYTICS.SV_SUPPORT_ANALYTICS"
    query_account_data:
      semantic_view: "MACU_INTELLIGENCE.ANALYTICS.SV_ACCOUNT_ANALYTICS"
    query_loan_risk_predictions:
      semantic_view: "MACU_INTELLIGENCE.ANALYTICS.SV_LOAN_RISK_PREDICTIONS"
    query_churn_predictions:
      semantic_view: "MACU_INTELLIGENCE.ANALYTICS.SV_CHURN_PREDICTIONS"
    
    # ML Model Function Resources
    predict_loan_risk:
      type: "function"
      execution_environment:
        type: "warehouse"
        warehouse: "MACU_WH"
      identifier: "MACU_INTELLIGENCE.ANALYTICS.PREDICT_LOAN_DEFAULT_RISK"
    predict_fraud:
      type: "function"
      execution_environment:
        type: "warehouse"
        warehouse: "MACU_WH"
      identifier: "MACU_INTELLIGENCE.ANALYTICS.PREDICT_FRAUD_SCORE"
    predict_churn:
      type: "function"
      execution_environment:
        type: "warehouse"
        warehouse: "MACU_WH"
      identifier: "MACU_INTELLIGENCE.ANALYTICS.PREDICT_MEMBER_CHURN"
    recommend_loan:
      type: "function"
      execution_environment:
        type: "warehouse"
        warehouse: "MACU_WH"
      identifier: "MACU_INTELLIGENCE.ANALYTICS.RECOMMEND_LOAN_APPROVAL"
  $$;

-- ============================================================================
-- Step 2: Verify the Agent
-- ============================================================================
DESCRIBE AGENT MACU_INTELLIGENCE_AGENT;

-- ============================================================================
-- Step 3: Test the Agent
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
    'MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT' AS agent_name,
    14 AS total_tools,
    '3 Search + 7 Analyst (including ML predictions) + 4 ML Functions' AS tool_breakdown;
