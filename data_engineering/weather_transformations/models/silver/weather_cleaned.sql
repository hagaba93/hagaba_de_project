{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['STATION', 'DATE'],
        file_format='delta',
        on_schema_change='append_new_columns'
    )
}}
-- trust me

WITH source_data AS (

    SELECT *
    FROM {{ source('bronze', 'noaa_weather_raw') }}

    {% if is_incremental() %}

    WHERE _ingested_at >= (
        SELECT COALESCE(
            MAX(_ingested_at),
            TIMESTAMP '1900-01-01 00:00:00'
        )
        FROM {{ this }}
    )

    {% endif %}

),

transformed AS (

    SELECT *,
        TRIM(SPLIT(NAME, ',')[0]) AS station_name,
        SPLIT(
            TRIM(ELEMENT_AT(SPLIT(NAME, ','), -1)),
            ' +'
        )[0] AS state,
        'US' AS country

    FROM source_data

    WHERE TRIM(ELEMENT_AT(SPLIT(NAME, ','), -1))
          RLIKE '^[A-Z]{2} +US$'

),

deduplicated AS (

    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY STATION, DATE
            ORDER BY _ingested_at DESC
        ) AS row_num

    FROM transformed

)

SELECT
    * EXCEPT (row_num),
    CURRENT_TIMESTAMP() AS _silver_processed_at
FROM deduplicated
WHERE row_num = 1