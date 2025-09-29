SELECT 
  c.ivr_id as calls_ivr_id,
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
ORDER BY calls_ivr_id;