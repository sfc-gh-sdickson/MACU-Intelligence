# MACU Intelligence Feature Store Guide

## Overview

The MACU Intelligence Feature Store provides centralized feature management for machine learning models, enabling:

- **Feature Reuse**: Share features across ML projects
- **Point-in-Time Correctness**: Retrieve features as of any historical timestamp
- **Online Serving**: Low-latency feature retrieval for real-time inference
- **Feature Governance**: Track lineage, versioning, and ownership

## Architecture

<img src="./images/feature-store-diagram.svg" alt="Feature Store Architecture" width="100%">

## Core Components

### 1. Entities

Entities represent the business objects for which features are computed:

| Entity | Join Key | Description |
|--------|----------|-------------|
| MEMBER | member_id | Credit union members |
| ACCOUNT | account_id | Deposit and credit accounts |
| LOAN | loan_id | Loan products |
| TRANSACTION | transaction_id | Financial transactions |

### 2. Feature Groups

Logical groupings of related features:

| Group | Entity | Features | Refresh |
|-------|--------|----------|---------|
| MEMBER_PROFILE | MEMBER | Demographics, tenure, account count | Daily |
| TRANSACTION_PATTERNS | MEMBER | Spending behavior, velocity | Hourly |
| LOAN_RISK | MEMBER | Debt ratios, payment history | Daily |
| FRAUD_DETECTION | TRANSACTION | Anomaly scores, velocity | Real-time |
| MEMBER_ENGAGEMENT | MEMBER | Login frequency, channel usage | Daily |
| CREDIT_UTILIZATION | MEMBER | Credit usage patterns | Daily |

### 3. Feature Registry

The FEATURE_REGISTRY table tracks all features:

```sql
SELECT feature_id, feature_name, feature_group, 
       refresh_frequency, is_real_time
FROM MACU_INTELLIGENCE.FEATURE_STORE.FEATURE_REGISTRY
WHERE is_active = TRUE;
```

## Feature Definitions

### Member Profile Features

| Feature | Type | Description |
|---------|------|-------------|
| mem_tenure_days | INTEGER | Days since membership |
| mem_num_accounts | INTEGER | Total account count |
| mem_total_balance | DECIMAL | Sum of all balances |

### Transaction Pattern Features

| Feature | Type | Window | Description |
|---------|------|--------|-------------|
| txn_count_7d | INTEGER | 7 days | Transaction count |
| txn_volume_7d | DECIMAL | 7 days | Transaction volume |
| txn_avg_amount | DECIMAL | 30 days | Average amount |

### Loan Risk Features

| Feature | Type | Description |
|---------|------|-------------|
| loan_total_balance | DECIMAL | Outstanding loan balance |
| loan_num_active | INTEGER | Active loan count |
| loan_dti_ratio | DECIMAL | Debt-to-income ratio |

### Fraud Detection Features

| Feature | Type | Real-time | Description |
|---------|------|-----------|-------------|
| fraud_txn_velocity_1h | INTEGER | Yes | Transactions per hour |
| fraud_amount_deviation | DECIMAL | Yes | Unusual amount flag |
| fraud_new_merchant_flag | BOOLEAN | Yes | New merchant indicator |

## Using the Feature Store

### Creating Feature Views (via Python API)

```python
from snowflake.ml.feature_store import FeatureStore, FeatureView, Entity

# Initialize Feature Store
fs = FeatureStore(
    session=session,
    database="MACU_INTELLIGENCE",
    name="FEATURE_STORE",
    default_warehouse="MACU_FEATURE_WH"
)

# Define entity
member_entity = Entity(
    name="MEMBER",
    join_keys=["MEMBER_ID"],
    desc="Credit union member entity"
)

# Register entity
fs.register_entity(member_entity)

# Create FeatureView
member_profile_fv = FeatureView(
    name="MEMBER_PROFILE_FEATURES",
    entities=[member_entity],
    feature_df=session.sql(member_profile_query),
    timestamp_col="FEATURE_TIMESTAMP",
    refresh_freq="1 day",
    desc="Member profile features"
)

# Register FeatureView
fs.register_feature_view(feature_view=member_profile_fv, version="v1")
```

### Retrieving Features for Training

```python
# Create spine dataframe with member IDs and timestamps
spine_df = session.create_dataframe(training_data)

# Get feature views
member_fv = fs.get_feature_view("MEMBER_PROFILE_FEATURES", "v1")
txn_fv = fs.get_feature_view("TRANSACTION_PATTERN_FEATURES", "v1")

# Generate training dataset
training_features = fs.generate_dataset(
    spine_df=spine_df,
    features=[member_fv, txn_fv],
    spine_timestamp_col="event_timestamp",
    include_feature_view_timestamp_col=False
)
```

### Online Feature Retrieval

```python
# Get features for real-time inference
online_features = fs.retrieve_feature_values(
    spine_df=inference_requests,
    features=[member_fv, txn_fv]
)
```

## Aggregation Views

Pre-aggregation views support Feature Store Dynamic Tables:

```sql
-- View existing aggregation views
SELECT table_name 
FROM MACU_INTELLIGENCE.INFORMATION_SCHEMA.VIEWS
WHERE table_schema = 'FEATURE_STORE' 
  AND table_name LIKE 'V_%_AGGS';
```

Available aggregation views:
- `V_MEMBER_PROFILE_AGGS` - Member account counts
- `V_TRANSACTION_PATTERN_AGGS` - Transaction metrics
- `V_LOAN_RISK_AGGS` - Loan portfolio stats
- `V_FRAUD_DETECTION_AGGS` - Fraud indicators

## Monitoring

### Feature Store Health

```sql
-- Check feature freshness
SELECT feature_group, 
       MAX(last_refresh) AS last_refresh,
       AVG(staleness_minutes) AS avg_staleness,
       AVG(health_score) AS avg_health
FROM MACU_INTELLIGENCE.FEATURE_STORE.FEATURE_STORE_HEALTH
WHERE check_timestamp >= DATEADD('day', -1, CURRENT_TIMESTAMP())
GROUP BY feature_group;
```

### Computation History

```sql
-- View recent computation jobs
SELECT feature_group, status, computation_start, 
       DATEDIFF('second', computation_start, computation_end) AS duration_sec,
       rows_processed
FROM MACU_INTELLIGENCE.FEATURE_STORE.FEATURE_COMPUTATION_LOG
WHERE computation_start >= DATEADD('day', -1, CURRENT_TIMESTAMP())
ORDER BY computation_start DESC;
```

## Best Practices

### 1. Feature Naming

- Use descriptive prefixes: `mem_`, `txn_`, `loan_`, `fraud_`
- Include time window: `_7d`, `_30d`, `_1h`
- Be consistent across features

### 2. Refresh Frequencies

| Feature Type | Recommended Refresh |
|--------------|---------------------|
| Profile/demographic | Daily |
| Transaction patterns | Hourly |
| Real-time fraud | Streaming/Real-time |
| Aggregated metrics | Daily |

### 3. Data Quality

- Monitor null percentages
- Set alerting thresholds for staleness
- Validate feature distributions periodically

### 4. Performance

- Use appropriate warehouse sizes for computation
- Partition large feature tables
- Materialize frequently-used features

## Troubleshooting

### Features Not Refreshing

1. Check Dynamic Table status: `SHOW DYNAMIC TABLES;`
2. Verify warehouse is running
3. Check for source data issues

### High Latency

1. Review query plans for feature views
2. Consider pre-aggregation for complex features
3. Optimize warehouse sizing

### Data Quality Issues

1. Check null percentages in health table
2. Validate source data completeness
3. Review feature computation logs for errors
