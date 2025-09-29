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
  ivr_id AS calls_ivr_id,
  document_type,
  document_identification
FROM identified_steps
WHERE rn = 1
ORDER BY calls_ivr_id;