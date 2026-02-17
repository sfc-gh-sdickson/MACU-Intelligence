-- ============================================================================
-- Mountain America Credit Union - Monitoring Data Population
-- ============================================================================
-- Purpose: Populate feature store health and computation log tables
--          with sample monitoring data for dashboard visualization
-- ============================================================================

USE DATABASE MACU_INTELLIGENCE;
USE SCHEMA FEATURE_STORE;
USE WAREHOUSE MACU_FEATURE_WH;

-- ============================================================================
-- Populate Feature Computation Log
-- ============================================================================

INSERT INTO FEATURE_COMPUTATION_LOG (
    computation_id, feature_group, computation_start, computation_end,
    status, rows_processed, error_message
)
SELECT
    UUID_STRING() AS computation_id,
    fg.group_name AS feature_group,
    DATEADD('hour', -seq.seq * 6, CURRENT_TIMESTAMP()) AS computation_start,
    DATEADD('minute', 5 + MOD(seq.seq, 10), DATEADD('hour', -seq.seq * 6, CURRENT_TIMESTAMP())) AS computation_end,
    CASE WHEN MOD(seq.seq, 50) = 0 THEN 'FAILED' ELSE 'SUCCESS' END AS status,
    CASE WHEN MOD(seq.seq, 50) = 0 THEN 0 ELSE 1000 + MOD(seq.seq * 127, 9000) END AS rows_processed,
    CASE WHEN MOD(seq.seq, 50) = 0 THEN 'Timeout waiting for source data refresh' ELSE NULL END AS error_message
FROM FEATURE_GROUPS fg
CROSS JOIN (SELECT seq4() as seq FROM TABLE(GENERATOR(ROWCOUNT => 100))) seq;

-- ============================================================================
-- Populate Feature Store Health Metrics
-- ============================================================================

INSERT INTO FEATURE_STORE_HEALTH (
    health_check_id, feature_group, check_timestamp, last_refresh,
    rows_count, null_percentage, staleness_minutes, is_healthy, health_score
)
SELECT
    UUID_STRING() AS health_check_id,
    fg.group_name AS feature_group,
    DATEADD('hour', -seq.seq, CURRENT_TIMESTAMP()) AS check_timestamp,
    DATEADD('minute', -MOD(seq.seq * 7, 120), DATEADD('hour', -seq.seq, CURRENT_TIMESTAMP())) AS last_refresh,
    8000 + MOD(seq.seq * 37, 4000) AS rows_count,
    MOD(seq.seq * 3, 500) / 100.0 AS null_percentage,
    MOD(seq.seq * 7, 120) AS staleness_minutes,
    CASE WHEN MOD(seq.seq * 7, 120) < 60 AND MOD(seq.seq * 3, 500) / 100.0 < 5.0 THEN TRUE ELSE FALSE END AS is_healthy,
    GREATEST(0, 100 - (MOD(seq.seq * 7, 120) / 2.0) - MOD(seq.seq * 3, 500) / 50.0) AS health_score
FROM FEATURE_GROUPS fg
CROSS JOIN (SELECT seq4() as seq FROM TABLE(GENERATOR(ROWCOUNT => 168))) seq;

-- Display confirmation
SELECT 'Monitoring data populated successfully' AS STATUS,
    (SELECT COUNT(*) FROM FEATURE_COMPUTATION_LOG) AS computation_log_rows,
    (SELECT COUNT(*) FROM FEATURE_STORE_HEALTH) AS health_check_rows;
