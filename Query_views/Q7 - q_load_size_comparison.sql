create or replace view vw_load_size_comparison as

SELECT
    CASE
        WHEN di.installed_power_kva < 400   THEN '1 - Small (<400 kVA)'
        WHEN di.installed_power_kva < 1260  THEN '2 - Medium (400–1260 kVA)'
        WHEN di.installed_power_kva < 5000  THEN '3 - Large (1260–5000 kVA)'
        ELSE                                     '4 - Very Large (>5000 kVA)'
    END AS power_band,
    COUNT(DISTINCT fcp.installation_id) AS installations,
    SUM(fcp.flicker_l1_pct * fcp.monitoring_days) / NULLIF(SUM(fcp.monitoring_days), 0) AS weighted_avg_flicker,
    SUM(fcp.unbalanced_pct * fcp.monitoring_days) / NULLIF(SUM(fcp.monitoring_days), 0) AS weighted_avg_unbalance,
    AVG(di.number_of_clients) AS avg_clients_served,
    SUM(fcp.monitoring_days) AS total_monitoring_days
FROM fact_continuous_phenomena fcp
JOIN dim_installation di ON fcp.installation_id = di.installation_id
WHERE di.installed_power_kva IS NOT NULL
  AND fcp.flicker_l1_pct < 100
GROUP BY 
    CASE
        WHEN di.installed_power_kva < 400   THEN '1 - Small (<400 kVA)'
        WHEN di.installed_power_kva < 1260  THEN '2 - Medium (400–1260 kVA)'
        WHEN di.installed_power_kva < 5000  THEN '3 - Large (1260–5000 kVA)'
        ELSE                                     '4 - Very Large (>5000 kVA)'
    END
ORDER BY power_band;