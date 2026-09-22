create or replace view vw_annual_trends as
SELECT
    dd.year,
    AVG(amcp.avg_flicker_l1_pct) AS avg_flicker_l1,
    AVG(amcp.avg_flicker_l2_pct) AS avg_flicker_l2,
    AVG(amcp.avg_flicker_l3_pct) AS avg_flicker_l3,
    LEAST(
        AVG(amcp.avg_flicker_l1_pct),
        AVG(amcp.avg_flicker_l2_pct),
        AVG(amcp.avg_flicker_l3_pct)
    ) AS worst_phase_flicker,

    AVG(amcp.avg_thd_l1_pct) AS avg_thd_l1,
    AVG(amcp.avg_thd_l2_pct) AS avg_thd_l2,
    AVG(amcp.avg_thd_l3_pct) AS avg_thd_l3,
    LEAST(
        AVG(amcp.avg_thd_l1_pct),
        AVG(amcp.avg_thd_l2_pct),
        AVG(amcp.avg_thd_l3_pct)
    ) AS worst_phase_thd,

    -- Voltage Averages
    AVG(amcp.avg_voltage_l1_pct) AS avg_voltage_l1,
    AVG(amcp.avg_voltage_l2_pct) AS avg_voltage_l2,
    AVG(amcp.avg_voltage_l3_pct) AS avg_voltage_l3,
    LEAST(
        AVG(amcp.avg_voltage_l1_pct),
        AVG(amcp.avg_voltage_l2_pct),
        AVG(amcp.avg_voltage_l3_pct)
    ) AS worst_phase_voltage,

    -- Aggregated Totals
    SUM(amcp.total_monitoring_days) AS total_monitoring_days,
    SUM(amcp.installation_count) AS total_installation_months

FROM agg_municipality_continuous_phenomena amcp
JOIN dim_date dd ON amcp.month_id = dd.month_id
GROUP BY dd.year
ORDER BY dd.year ASC;