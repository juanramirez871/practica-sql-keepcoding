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
  ivr_id AS calls_ivr_id,
  customer_phone
FROM phone_steps
WHERE rn = 1
ORDER BY calls_ivr_id;