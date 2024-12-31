{{
  config(
    materialized = 'table',
    )
}}

WITH prep_customer_response AS (

SELECT
{{ age_buckets('age') }},
{{ income_buckets('income') }},
gender,
offer_type,
{{ dbt_utils.pivot(
      'transaction_status',
      dbt_utils.get_column_values(table=ref('fct_customer_transactions'), column='transaction_status')
) }}
FROM {{ ref('fct_customer_transactions') }} fct
JOIN marts.dim_offer dof on fct.offer_id=dof.offer_id
WHERE fct.offer_id IS NOT NULL
AND offer_type!='informational'
GROUP BY age_buckets, income_buckets, gender, offer_type
)
SELECT *

FROM prep_customer_response
