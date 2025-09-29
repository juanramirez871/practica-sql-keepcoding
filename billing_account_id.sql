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
  ivr_id as calls_ivr_id,
  billing_account_id
FROM valid_billing_accounts
WHERE rn = 1
ORDER BY calls_ivr_id;