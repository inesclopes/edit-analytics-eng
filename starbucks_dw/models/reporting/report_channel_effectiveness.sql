{{
  config(
    materialized = 'table',
    )
}}

WITH prep_offer_response AS (

SELECT
offer_channel,
offer_type,
{{ dbt_utils.pivot(
      'transaction_status',
      dbt_utils.get_column_values(table=ref('fct_offer_transactions'), column='transaction_status')
) }}
FROM {{ ref('fct_offer_transactions') }} fct
WHERE offer_type!='informational'
GROUP BY offer_channel, offer_type
),
all_aggs AS (

SELECT
offer_channel,
'all' as offer_type,
{{ dbt_utils.pivot(
      'transaction_status',
      dbt_utils.get_column_values(ref('fct_offer_transactions'), 'transaction_status')
) }}
FROM {{ ref('fct_offer_transactions') }} fct
WHERE offer_type!='informational'
GROUP BY offer_channel
)


SELECT * ,
round((cast( completed as decimal) / received)*100,0) as completion_percent
FROM prep_offer_response
UNION ALL
SELECT *,
round((cast( completed as decimal) / received)*100,0) as completion_percent
FROM all_aggs
ORDER BY offer_channel, offer_type
