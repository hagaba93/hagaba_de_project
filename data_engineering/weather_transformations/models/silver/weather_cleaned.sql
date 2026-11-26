{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['station_id', 'observation_date'],
        file_format='delta',
        on_schema_change='append_new_columns'
    )
}}

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

cleaned_data AS (

    SELECT

        TRIM(CAST(STATION AS STRING)) AS station_id,

        TRY_CAST(DATE AS DATE) AS observation_date,

        station_name,

        state,

        country,

        TRY_CAST(LATITUDE AS DOUBLE) AS latitude,

        TRY_CAST(LONGITUDE AS DOUBLE) AS longitude,

        TRY_CAST(ELEVATION AS DOUBLE) AS elevation_m,

        NULLIF(
            TRY_CAST(TEMP AS DOUBLE), 9999.9
        ) AS temperature_f,

        NULLIF(
            TRY_CAST(DEWP AS DOUBLE), 9999.9
        ) AS dew_point_f,

        NULLIF(
            TRY_CAST(MAX AS DOUBLE), 9999.9
        ) AS max_temperature_f,

        NULLIF(
            TRY_CAST(MIN AS DOUBLE), 9999.9
        ) AS min_temperature_f,

        NULLIF(
            TRY_CAST(WDSP AS DOUBLE), 999.9
        ) AS wind_speed_knots,

        NULLIF(
            TRY_CAST(PRCP AS DOUBLE), 99.99
        ) AS precipitation_inches,

        TRY_CAST(source_year AS INT) AS source_year,

        _source_file,

        TRY_CAST(_ingested_at AS TIMESTAMP) AS _ingested_at

    FROM transformed

),

deduplicated AS (

    SELECT *,

        ROW_NUMBER() OVER (
            PARTITION BY station_id, observation_date
            ORDER BY _ingested_at DESC, _source_file DESC
        ) AS row_num

    FROM cleaned_data

    WHERE station_id IS NOT NULL
      AND station_id <> ''
      AND observation_date IS NOT NULL

)

SELECT

    * EXCEPT (row_num),

    CURRENT_TIMESTAMP() AS _silver_processed_at

FROM deduplicated

WHERE row_num = 1