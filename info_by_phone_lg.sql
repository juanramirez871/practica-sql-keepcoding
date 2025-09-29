WITH all_calls AS (
  SELECT DISTINCT ivr_id AS calls_ivr_id
  FROM keepcoding.ivr_steps
),

calls_with_phone_identification AS (
  SELECT DISTINCT ivr_id AS calls_ivr_id
  FROM keepcoding.ivr_steps
  WHERE step_name = 'CUSTOMERINFOBYPHONE.TX' 
    AND step_result = 'OK'
)

SELECT 
  ac.calls_ivr_id,
  CASE 
    WHEN cwpi.calls_ivr_id IS NOT NULL THEN 1
    ELSE 0
  END AS info_by_phone_lg
FROM all_calls ac
LEFT JOIN calls_with_phone_identification cwpi
  ON ac.calls_ivr_id = cwpi.calls_ivr_id
ORDER BY ac.calls_ivr_id;