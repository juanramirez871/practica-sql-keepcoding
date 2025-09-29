CREATE OR REPLACE TABLE keepcoding.ivr_calls AS
SELECT
  CAST(ivr_id AS STRING) AS ivr_id,
  SAFE_CAST(phone_number AS INT64) AS phone_number,
  CAST(ivr_result AS STRING) AS ivr_result,
  CAST(vdn_label AS STRING) AS vdn_label,
  CAST(start_date AS TIMESTAMP) AS start_date,
  CAST(end_date AS TIMESTAMP) AS end_date,
  SAFE_CAST(total_duration AS INT64) AS total_duration,
  CAST(customer_segment AS STRING) AS customer_segment,
  CAST(ivr_language AS STRING) AS ivr_language,
  SAFE_CAST(steps_module AS INT64) AS steps_module,
  CAST(module_aggregation AS STRING) AS module_aggregation
FROM `keepcoding.ivr_calls_raw`;

CREATE OR REPLACE TABLE keepcoding.ivr_modules AS
SELECT
  CAST(ivr_id AS STRING) AS ivr_id,
  SAFE_CAST(module_sequece AS INT64) AS module_sequece,
  CAST(module_name AS STRING) AS module_name,
  SAFE_CAST(module_duration AS INT64) AS module_duration,
  CAST(module_result AS STRING) AS module_result
FROM `keepcoding.ivr_modules_raw`;

CREATE OR REPLACE TABLE keepcoding.ivr_steps AS
SELECT
  CAST(ivr_id AS STRING) AS ivr_id,
  SAFE_CAST(module_sequece AS INT64) AS module_sequece,
  SAFE_CAST(step_sequence AS INT64) AS step_sequence,
  CAST(step_name AS STRING) AS step_name,
  CAST(step_result AS STRING) AS step_result,
  CAST(step_description_error AS STRING) AS step_description_error,
  CAST(document_type AS STRING) AS document_type,
  CAST(document_identification AS STRING) AS document_identification,
  CAST(customer_phone AS STRING) AS customer_phone,
  CAST(billing_account_id AS STRING) AS billing_account_id
FROM `keepcoding.ivr_steps_raw`;

CREATE OR REPLACE TABLE keepcoding.ivr_detail AS
SELECT
  c.ivr_id AS calls_ivr_id,
  c.phone_number AS calls_phone_number,
  c.ivr_result AS calls_ivr_result,
  c.vdn_label AS calls_vdn_label,
  c.start_date AS calls_start_date,
  CAST(FORMAT_TIMESTAMP('%Y%m%d', c.start_date) AS INT64) AS calls_start_date_id,
  c.end_date AS calls_end_date,
  CAST(FORMAT_TIMESTAMP('%Y%m%d', c.end_date) AS INT64) AS calls_end_date_id,
  c.total_duration AS calls_total_duration,
  c.customer_segment AS calls_customer_segment,
  c.ivr_language AS calls_ivr_language,
  c.steps_module AS calls_steps_module,
  c.module_aggregation AS calls_module_aggregation,
  
  m.module_sequece,
  m.module_name,
  m.module_duration,
  m.module_result,
  
  s.step_sequence,
  s.step_name,
  s.step_result,
  s.step_description_error,
  s.document_type,
  s.document_identification,
  s.customer_phone,
  s.billing_account_id

FROM keepcoding.ivr_calls c
LEFT JOIN keepcoding.ivr_modules m
  ON c.ivr_id = m.ivr_id
LEFT JOIN keepcoding.ivr_steps s
  ON m.ivr_id = s.ivr_id 
  AND m.module_sequece = s.module_sequece
ORDER BY 
  c.ivr_id, 
  m.module_sequece, 
  s.step_sequence;