create view vw_phase_asymmetry as

SELECT
    di.type_of_installation,
    dvl.voltage_band_description,
    SUM(fcp.flicker_l1_pct * fcp.monitoring_days) / NULLIF(SUM(fcp.monitoring_days), 0) AS weighted_flicker_l1,
    SUM(fcp.flicker_l2_pct * fcp.monitoring_days) / NULLIF(SUM(fcp.monitoring_days), 0) AS weighted_flicker_l2,
    SUM(fcp.flicker_l3_pct * fcp.monitoring_days) / NULLIF(SUM(fcp.monitoring_days), 0) AS weighted_flicker_l3,
    SUM(fcp.voltage_l1_pct * fcp.monitoring_days) / NULLIF(SUM(fcp.monitoring_days), 0) AS weighted_voltage_l1,
    SUM(fcp.voltage_l2_pct * fcp.monitoring_days) / NULLIF(SUM(fcp.monitoring_days), 0) AS weighted_voltage_l2,
    SUM(fcp.voltage_l3_pct * fcp.monitoring_days) / NULLIF(SUM(fcp.monitoring_days), 0) AS weighted_voltage_l3,
    COUNT(*) AS records
FROM fact_continuous_phenomena fcp
JOIN dim_installation di ON fcp.installation_id = di.installation_id
JOIN dim_voltage_level dvl ON fcp.voltage_level_id = dvl.voltage_level_id
WHERE fcp.flicker_l1_pct < 100
  AND fcp.flicker_l2_pct < 100
  AND fcp.flicker_l3_pct < 100
GROUP BY di.type_of_installation, dvl.voltage_band_description
HAVING COUNT(*) >= 20
ORDER BY di.type_of_installation, dvl.voltage_band_description;