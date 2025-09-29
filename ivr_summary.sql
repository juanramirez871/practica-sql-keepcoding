CREATE OR REPLACE TABLE keepcoding.ivr_summary AS

WITH base_calls AS (
  SELECT DISTINCT
    ivr_id,
    phone_number,
    ivr_result,
    vdn_label,
    start_date,
    end_date,
    total_duration,
    customer_segment,
    ivr_language,
    steps_module,
    module_aggregation
  FROM keepcoding.ivr_calls
),

vdn_agg AS (
  SELECT 
    ivr_id,
    CASE 
      WHEN vdn_label LIKE 'ATC%' THEN 'FRONT'
      WHEN vdn_label LIKE 'TECH%' THEN 'TECH'
      WHEN vdn_label = 'ABSORPTION' THEN 'ABSORPTION'
      ELSE 'RESTO'
    END AS vdn_aggregation
  FROM keepcoding.ivr_calls
),

doc_identification AS (
  WITH identified_steps AS (
    SELECT 
      ivr_id,
      document_type,
      document_identification,
      step_sequence,
      ROW_NUMBER() OVER (
        PARTITION BY ivr_id 
        ORDER BY step_sequence ASC
      ) as rn
    FROM keepcoding.ivr_steps
    WHERE 
      document_type IS NOT NULL 
      AND document_type != '' 
      AND document_type != 'UNKNOWN'
      AND document_type != 'DESCONOCIDO'
      AND document_identification IS NOT NULL 
      AND document_identification != '' 
      AND document_identification != 'UNKNOWN'
  )
  SELECT 
    ivr_id,
    document_type,
    document_identification
  FROM identified_steps
  WHERE rn = 1
),

cust_phone AS (
  WITH phone_steps AS (
    SELECT 
      ivr_id,
      customer_phone,
      step_sequence,
      ROW_NUMBER() OVER (
        PARTITION BY ivr_id 
        ORDER BY step_sequence ASC
      ) as rn
    FROM keepcoding.ivr_steps
    WHERE 
      customer_phone IS NOT NULL 
      AND customer_phone != '' 
      AND customer_phone != 'UNKNOWN'
  )
  SELECT 
    ivr_id,
    customer_phone
  FROM phone_steps
  WHERE rn = 1
),

bill_account AS (
  WITH valid_billing_accounts AS (
    SELECT 
      ivr_id,
      billing_account_id,
      step_sequence,
      ROW_NUMBER() OVER (
        PARTITION BY ivr_id 
        ORDER BY step_sequence ASC
      ) as rn
    FROM keepcoding.ivr_steps
    WHERE billing_account_id IS NOT NULL 
      AND TRIM(billing_account_id) != '' 
      AND UPPER(TRIM(billing_account_id)) != 'UNKNOWN'
  )
  SELECT 
    ivr_id,
    billing_account_id
  FROM valid_billing_accounts
  WHERE rn = 1
),

masiva_flag AS (
  SELECT 
    c.ivr_id,
    CASE 
      WHEN m.ivr_id IS NOT NULL THEN 1
      ELSE 0
    END as masiva_lg
  FROM (
    SELECT DISTINCT ivr_id
    FROM keepcoding.ivr_modules
  ) c
  LEFT JOIN (
    SELECT DISTINCT ivr_id
    FROM keepcoding.ivr_modules
    WHERE module_name = 'AVERIA_MASIVA'
  ) m ON c.ivr_id = m.ivr_id
),

phone_identification AS (
  WITH all_calls AS (
    SELECT DISTINCT ivr_id
    FROM keepcoding.ivr_steps
  ),
  calls_with_phone_identification AS (
    SELECT DISTINCT ivr_id
    FROM keepcoding.ivr_steps
    WHERE step_name = 'CUSTOMERINFOBYPHONE.TX' 
      AND step_result = 'OK'
  )
  SELECT 
    ac.ivr_id,
    CASE 
      WHEN cwpi.ivr_id IS NOT NULL THEN 1
      ELSE 0
    END AS info_by_phone_lg
  FROM all_calls ac
  LEFT JOIN calls_with_phone_identification cwpi
    ON ac.ivr_id = cwpi.ivr_id
),

dni_identification AS (
  WITH all_calls AS (
    SELECT DISTINCT ivr_id
    FROM keepcoding.ivr_steps
  ),
  calls_with_dni_identification AS (
    SELECT DISTINCT ivr_id
    FROM keepcoding.ivr_steps
    WHERE step_name = 'CUSTOMERINFOBYDNI.TX' 
      AND step_result = 'OK'
  )
  SELECT 
    ac.ivr_id,
    CASE 
      WHEN cwdi.ivr_id IS NOT NULL THEN 1
      ELSE 0
    END AS info_by_dni_lg
  FROM all_calls ac
  LEFT JOIN calls_with_dni_identification cwdi
    ON ac.ivr_id = cwdi.ivr_id
),

phone_24h_flags AS (
  WITH all_calls AS (
    SELECT 
      ivr_id,
      phone_number,
      start_date
    FROM keepcoding.ivr_calls
  ),
  repeated_phone_calls AS (
    SELECT DISTINCT
      c1.ivr_id
    FROM keepcoding.ivr_calls c1
    INNER JOIN keepcoding.ivr_calls c2
      ON c1.phone_number = c2.phone_number
      AND c1.ivr_id != c2.ivr_id
      AND c2.start_date >= TIMESTAMP_SUB(c1.start_date, INTERVAL 24 HOUR)
      AND c2.start_date < c1.start_date
  ),
  cause_recall_calls AS (
    SELECT DISTINCT
      c1.ivr_id
    FROM keepcoding.ivr_calls c1
    INNER JOIN keepcoding.ivr_calls c2
      ON c1.phone_number = c2.phone_number
      AND c1.ivr_id != c2.ivr_id
      AND c2.start_date > c1.start_date
      AND c2.start_date <= TIMESTAMP_ADD(c1.start_date, INTERVAL 24 HOUR)
  )
  SELECT 
    ac.ivr_id,
    CASE 
      WHEN rpc.ivr_id IS NOT NULL THEN 1
      ELSE 0
    END AS repeated_phone_24H,
    CASE 
      WHEN crc.ivr_id IS NOT NULL THEN 1
      ELSE 0
    END AS cause_recall_phone_24H
  FROM all_calls ac
  LEFT JOIN repeated_phone_calls rpc
    ON ac.ivr_id = rpc.ivr_id
  LEFT JOIN cause_recall_calls crc
    ON ac.ivr_id = crc.ivr_id
)

SELECT 
  bc.ivr_id,
  bc.phone_number,
  bc.ivr_result,
  va.vdn_aggregation,
  bc.start_date,
  bc.end_date,
  bc.total_duration,
  bc.customer_segment,
  bc.ivr_language,
  bc.steps_module,
  bc.module_aggregation,
  di.document_type,
  di.document_identification,
  cp.customer_phone,
  ba.billing_account_id,
  mf.masiva_lg,
  pi.info_by_phone_lg,
  dni.info_by_dni_lg,
  pf.repeated_phone_24H,
  pf.cause_recall_phone_24H

FROM base_calls bc
LEFT JOIN vdn_agg va ON bc.ivr_id = va.ivr_id
LEFT JOIN doc_identification di ON bc.ivr_id = di.ivr_id
LEFT JOIN cust_phone cp ON bc.ivr_id = cp.ivr_id
LEFT JOIN bill_account ba ON bc.ivr_id = ba.ivr_id
LEFT JOIN masiva_flag mf ON bc.ivr_id = mf.ivr_id
LEFT JOIN phone_identification pi ON bc.ivr_id = pi.ivr_id
LEFT JOIN dni_identification dni ON bc.ivr_id = dni.ivr_id
LEFT JOIN phone_24h_flags pf ON bc.ivr_id = pf.ivr_id

ORDER BY bc.ivr_id;