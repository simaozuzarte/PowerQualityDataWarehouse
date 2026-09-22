create view vw_non_compliance as

SELECT
    dl.municipality,
    dl.nuts_ii,
    dvl.voltage_band_description,
    AVG(amcp.avg_flicker_l1_pct) AS flicker_l1,
    AVG(amcp.avg_flicker_l2_pct) AS flicker_l2,
    AVG(amcp.avg_flicker_l3_pct) AS flicker_l3,
    LEAST(
        AVG(amcp.avg_flicker_l1_pct),
        AVG(amcp.avg_flicker_l2_pct),
        AVG(amcp.avg_flicker_l3_pct)
    ) AS worst_phase_flicker,
    SUM(amcp.total_monitoring_days) AS total_monitoring_days,
    SUM(amcp.installation_count) AS total_installation_months
FROM agg_municipality_continuous_phenomena amcp
JOIN dim_location dl ON amcp.municipality_id = dl.municipality_id
JOIN dim_voltage_level dvl ON amcp.voltage_level_id = dvl.voltage_level_id
GROUP BY dl.municipality, dl.nuts_ii, dvl.voltage_band_description
HAVING SUM(amcp.total_monitoring_days) >= 365
ORDER BY worst_phase_flicker ASC;

