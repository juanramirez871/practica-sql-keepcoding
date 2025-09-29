WITH all_calls AS (
  SELECT 
    ivr_id AS calls_ivr_id,
    phone_number,
    start_date
  FROM keepcoding.ivr_calls
),

repeated_phone_calls AS (
  SELECT DISTINCT
    c1.ivr_id AS calls_ivr_id
  FROM keepcoding.ivr_calls c1
  INNER JOIN keepcoding.ivr_calls c2
    ON c1.phone_number = c2.phone_number
    AND c1.ivr_id != c2.ivr_id
    AND c2.start_date >= TIMESTAMP_SUB(c1.start_date, INTERVAL 24 HOUR)
    AND c2.start_date < c1.start_date
),

cause_recall_calls AS (
  SELECT DISTINCT
    c1.ivr_id AS calls_ivr_id
  FROM keepcoding.ivr_calls c1
  INNER JOIN keepcoding.ivr_calls c2
    ON c1.phone_number = c2.phone_number
    AND c1.ivr_id != c2.ivr_id
    AND c2.start_date > c1.start_date
    AND c2.start_date <= TIMESTAMP_ADD(c1.start_date, INTERVAL 24 HOUR)
)

SELECT 
  ac.calls_ivr_id,
  CASE 
    WHEN rpc.calls_ivr_id IS NOT NULL THEN 1
    ELSE 0
  END AS repeated_phone_24H,
  CASE 
    WHEN crc.calls_ivr_id IS NOT NULL THEN 1
    ELSE 0
  END AS cause_recall_phone_24H
FROM all_calls ac
LEFT JOIN repeated_phone_calls rpc
  ON ac.calls_ivr_id = rpc.calls_ivr_id
LEFT JOIN cause_recall_calls crc
  ON ac.calls_ivr_id = crc.calls_ivr_id
ORDER BY ac.calls_ivr_id;