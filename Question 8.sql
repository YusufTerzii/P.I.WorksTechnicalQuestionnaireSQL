
DROP TEMPORARY TABLE IF EXISTS MedianDailyVaccinations;

CREATE TEMPORARY TABLE MedianDailyVaccinations AS
SELECT
    country,
    AVG(daily_vaccinations) AS median_daily_vaccinations
FROM
    (
        SELECT
            country,
            daily_vaccinations,
            @rownum:=@rownum+1 AS `row_number`,
            @total_rows:=CASE WHEN daily_vaccinations IS NOT NULL THEN @total_rows+1 ELSE @total_rows END AS `total_rows`
        FROM
            country_vaccination_stats
            JOIN (SELECT @rownum:=0, @total_rows:=0) AS vars
        ORDER BY
            country, daily_vaccinations
    ) AS ordered
WHERE
    ordered.row_number IN ( FLOOR((@total_rows+1)/2), FLOOR((@total_rows+2)/2) )
GROUP BY
    country;


UPDATE country_vaccination_stats t
JOIN MedianDailyVaccinations m ON t.country = m.country
SET t.daily_vaccinations = COALESCE(t.daily_vaccinations, m.median_daily_vaccinations);


UPDATE country_vaccination_stats
SET daily_vaccinations = 0
WHERE
    daily_vaccinations IS NULL;