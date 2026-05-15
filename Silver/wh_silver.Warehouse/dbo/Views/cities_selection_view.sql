-- Auto Generated (Do not modify) 109B11B88C90EC34DCB364A89D6A748C2E55F2FE7AB219A340FADBC1E451B973
CREATE   VIEW dbo.cities_selection_view AS



WITH active_overrides AS (

    SELECT DISTINCT city_id

    FROM dbo.city_selection_overrides

    WHERE is_active = 1

),



manual_additions AS (

    SELECT

        dc.city_id,

        dc.city_name,

        dc.country_code,

        dc.latitude,

        dc.longitude,

        dc.city_pop,

        dc.is_capital,

        dc.city_score,

        'manual_override' AS selection_source

    FROM dbo.dim_city dc

    INNER JOIN active_overrides o

        ON dc.city_id = o.city_id

    WHERE dc.city_pop IS NOT NULL

      AND dc.city_pop > 0

      AND dc.latitude IS NOT NULL

      AND dc.longitude IS NOT NULL

      AND dc.city_score IS NOT NULL

),



scored AS (

    SELECT

        dc.city_id,

        dc.city_name,

        dc.country_code,

        dc.latitude,

        dc.longitude,

        dc.city_pop,

        dc.is_capital,

        dc.city_score

    FROM dbo.dim_city dc

    WHERE dc.city_pop IS NOT NULL

      AND dc.city_pop > 0

      AND dc.latitude IS NOT NULL

      AND dc.longitude IS NOT NULL

      AND dc.city_score IS NOT NULL

),



ranked AS (

    SELECT

        *,

        ROW_NUMBER() OVER (

            PARTITION BY country_code

            ORDER BY city_score DESC

        ) AS rank_in_country

    FROM scored

    WHERE city_pop > 200000

       OR is_capital = 1

),



rule_based AS (

    SELECT

        city_id,

        city_name,

        country_code,

        latitude,

        longitude,

        city_pop,

        is_capital,

        city_score,

        'rule_based' AS selection_source

    FROM ranked

    WHERE is_capital = 1

       OR rank_in_country <= 3

),



top_200 AS (

    SELECT TOP 200 *

    FROM rule_based

    ORDER BY city_score DESC

),



manual_only AS (

    SELECT m.*

    FROM manual_additions m

    WHERE NOT EXISTS (

        SELECT 1

        FROM top_200 t

        WHERE t.city_id = m.city_id

    )

),



final_selection AS (

    SELECT * FROM top_200

    UNION ALL

    SELECT * FROM manual_only

)



SELECT

    city_id,

    city_name,

    country_code,

    latitude,

    longitude,

    city_pop,

    is_capital,

    city_score,

    selection_source,

    NTILE(3) OVER (ORDER BY city_score DESC) AS difficulty_level

FROM final_selection;