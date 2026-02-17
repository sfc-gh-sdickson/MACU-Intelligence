# MACU Intelligence Demo Presentation Guide

## Demo Overview

This guide provides a structured approach for demonstrating the MACU Intelligence Agent and Feature Store capabilities to stakeholders.

**Duration**: 30-45 minutes  
**Audience**: Technical and business stakeholders  
**Prerequisites**: Demo environment deployed with synthetic data

---

## Demo Agenda

1. **Introduction** (5 min) - Solution overview and business value
2. **Data Foundation** (5 min) - Data model and synthetic data
3. **Feature Store** (10 min) - Feature management and ML features
4. **Cortex Search** (5 min) - Semantic search capabilities
5. **Intelligence Agent** (15 min) - Live agent demonstrations
6. **Q&A** (5 min)

---

## Section 1: Introduction

### Key Talking Points

- Mountain America Credit Union serves 1M+ members across 5 states
- Challenge: Staff need quick access to member data, product info, and compliance guidance
- Solution: AI-powered Intelligence Agent with real-time feature serving

### Architecture Slide

```
┌─────────────────────────────────────────────────────────────────┐
│                    MACU Intelligence Agent                       │
│         "How can I help you serve our members today?"           │
└─────────────────────────────────────────────────────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
   ┌────▼────┐            ┌────▼────┐            ┌────▼────┐
   │ Cortex  │            │ Cortex  │            │   ML    │
   │ Search  │            │ Analyst │            │ Models  │
   └─────────┘            └─────────┘            └─────────┘
        │                       │                       │
   Unstructured            Structured               Predictions
   - Transcripts           - Members                - Risk Scores
   - Compliance            - Accounts               - Fraud Detection
   - Products              - Loans                  - Churn Prediction
```

---

## Section 2: Data Foundation

### Show Data Volumes

```sql
-- Quick stats query
SELECT 
    (SELECT COUNT(*) FROM MACU_INTELLIGENCE.RAW.MEMBERS) AS members,
    (SELECT COUNT(*) FROM MACU_INTELLIGENCE.RAW.ACCOUNTS) AS accounts,
    (SELECT COUNT(*) FROM MACU_INTELLIGENCE.RAW.LOANS) AS loans,
    (SELECT COUNT(*) FROM MACU_INTELLIGENCE.RAW.TRANSACTIONS) AS transactions;
```

### Highlight Credit Union Specifics

- **Members vs Customers**: Credit union terminology
- **Share Savings**: Establishes membership
- **Utah Focus**: Salt Lake City, Provo, Ogden + regional expansion
- **Local Employers**: Intermountain Healthcare, BYU, University of Utah

---

## Section 3: Feature Store Demo

### Show Feature Registry

```sql
-- Display registered features
SELECT feature_name, feature_group, refresh_frequency, is_real_time
FROM MACU_INTELLIGENCE.FEATURE_STORE.FEATURE_REGISTRY
WHERE is_active = TRUE
ORDER BY feature_group, feature_name;
```

### Show Feature Health Dashboard

```sql
-- Feature store health
SELECT feature_group, 
       ROUND(AVG(health_score), 1) AS health_score,
       ROUND(AVG(staleness_minutes), 0) AS avg_staleness_min
FROM MACU_INTELLIGENCE.FEATURE_STORE.FEATURE_STORE_HEALTH
WHERE check_timestamp >= DATEADD('hour', -24, CURRENT_TIMESTAMP())
GROUP BY feature_group
ORDER BY health_score DESC;
```

### Key Messages

- Features refresh automatically (hourly/daily)
- Real-time features for fraud detection
- Single source of truth for ML features

---

## Section 4: Cortex Search Demo

### Search Support Transcripts

```sql
-- Find card-related issues
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'MACU_INTELLIGENCE.RAW.SUPPORT_TRANSCRIPTS_SEARCH',
      '{
          "query": "lost card while traveling",
          "columns": ["transcript_text", "category"],
          "limit": 3
      }'
  )
)['results'] AS results;
```

### Search Compliance Documents

```sql
-- Find AML procedures
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'MACU_INTELLIGENCE.RAW.COMPLIANCE_DOCS_SEARCH',
      '{
          "query": "suspicious activity report filing deadline",
          "columns": ["title", "content"],
          "limit": 2
      }'
  )
)['results'] AS results;
```

### Key Messages

- Semantic understanding, not just keyword matching
- Automatic index refresh as data changes
- Sub-second response times

---

## Section 5: Intelligence Agent Demo

### Demo Script

#### Scenario 1: Product Information

> "A member calls asking about auto loan rates. Let's ask the agent."

```sql
SELECT SNOWFLAKE.CORTEX.AGENT(
    'MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT',
    'What are our current auto loan rates for new vehicles?'
);
```

#### Scenario 2: Member Lookup

> "Now let's look up some member statistics."

```sql
SELECT SNOWFLAKE.CORTEX.AGENT(
    'MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT',
    'How many PLATINUM tier members do we have in Utah, and what is their average deposit balance?'
);
```

#### Scenario 3: Loan Risk Assessment

> "A loan officer wants to assess risk for an application."

```sql
SELECT SNOWFLAKE.CORTEX.AGENT(
    'MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT',
    'What is the default risk for a member with 680 credit score, $60,000 income, requesting a $35,000 auto loan with existing monthly debt of $1,200?'
);
```

#### Scenario 4: Compliance Query

> "A compliance officer needs policy guidance."

```sql
SELECT SNOWFLAKE.CORTEX.AGENT(
    'MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT',
    'What is our policy for filing SARs and what is the deadline after detection?'
);
```

#### Scenario 5: Support History

> "Let's see if we've handled similar issues before."

```sql
SELECT SNOWFLAKE.CORTEX.AGENT(
    'MACU_INTELLIGENCE.ANALYTICS.MACU_INTELLIGENCE_AGENT',
    'Show me examples of how we resolved card disputes for members traveling internationally'
);
```

### Key Messages

- Agent uses multiple tools seamlessly
- Natural language to SQL via semantic models
- ML predictions integrated directly
- Context-aware responses (credit union terminology)

---

## Handling Questions

### "How accurate are the ML predictions?"

> "The models are trained on historical data and validated with standard ML metrics. For example, our loan default model achieves X% AUC. However, all predictions should be used as decision support, not final decisions."

### "What about data privacy?"

> "All data stays within Snowflake. The agent doesn't store conversation history, and access is controlled via Snowflake's standard RBAC. We recommend implementing logging for audit purposes."

### "Can we customize the agent?"

> "Yes, the agent instructions can be modified to reflect your specific policies, products, and terminology. Tool configurations can be updated as your data model evolves."

### "What's the cost?"

> "Costs depend on warehouse usage for queries and Cortex AI credits for the agent and search services. We recommend starting with small warehouses and right-sizing based on usage patterns."

---

## Demo Environment Reset

If needed, reset the demo data:

```sql
-- Regenerate synthetic data (takes ~5 minutes)
-- Run: sql/data/04_generate_synthetic_data.sql

-- Repopulate monitoring data
-- Run: sql/feature_store/05a_populate_monitoring_data.sql
```

---

## Follow-Up Materials

- **Technical Documentation**: docs/AGENT_SETUP.md
- **Feature Store Guide**: docs/FEATURE_STORE_GUIDE.md
- **SQL Scripts**: sql/ directory
- **ML Notebook**: notebooks/macu_ml_models.ipynb
