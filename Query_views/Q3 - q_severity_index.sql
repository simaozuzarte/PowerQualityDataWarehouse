create or replace view vw_severity_index as

SELECT
    dl.nuts_ii,
    SUM(amve.total_event_count) AS total_events,
    SUM(amve.total_event_count * dvc.severity_rank) AS weighted_severity_index,
    SUM(amve.total_event_count * dvc.severity_rank) / NULLIF(SUM(amve.total_event_count), 0) AS avg_severity_per_event,
    COUNT(DISTINCT amve.municipality_id) AS municipalities_covered,
    SUM(amve.total_record_count) AS total_records
FROM agg_municipality_voltage_event amve
JOIN dim_location dl ON amve.municipality_id = dl.municipality_id
JOIN dim_voltage_class dvc ON amve.voltage_class_id = dvc.voltage_class_id
GROUP BY dl.nuts_ii
ORDER BY weighted_severity_index DESC;
