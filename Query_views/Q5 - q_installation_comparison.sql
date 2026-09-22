create or replace view vw_installation_comparison as

SELECT
    dl.municipality, -- Grouping by Geographic Dimension
    COUNT(DISTINCT CASE WHEN di.type_of_installation = 'Subestação' THEN fcp.installation_id END) AS substation_count,
    COUNT(DISTINCT CASE WHEN di.type_of_installation = 'PTD' THEN fcp.installation_id END) AS ptd_count,
    SUM(fcp.flicker_l1_pct * fcp.monitoring_days) / NULLIF(SUM(fcp.monitoring_days), 0) AS weighted_avg_flicker,
    SUM(fcp.unbalanced_pct * fcp.monitoring_days) / NULLIF(SUM(fcp.monitoring_days), 0) AS weighted_avg_unbalance,
    COALESCE(SUM(fve.event_count), 0) AS total_voltage_events,
    COALESCE(SUM(fve.event_count * dvc.severity_rank) / NULLIF(SUM(fve.event_count), 0), 0) AS avg_event_severity
FROM fact_continuous_phenomena fcp
JOIN dim_installation di ON fcp.installation_id = di.installation_id
JOIN dim_location dl ON fcp.municipality_id = dl.municipality_id -- Included Geographic Dimension
LEFT JOIN fact_voltage_event fve ON fcp.installation_id = fve.installation_id
                                 AND fcp.start_date_id = fve.start_date_id
LEFT JOIN dim_voltage_class dvc ON fve.voltage_class_id = dvc.voltage_class_id
GROUP BY dl.municipality
ORDER BY dl.municipality;