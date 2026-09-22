create or replace view vw_exceptional as

SELECT
    ee.exceptional_event_name,
    COUNT(*) AS records,
    SUM(fve.event_count) AS total_events,
    AVG(fve.event_count) AS avg_events_per_record,
    SUM(d_end.full_date - d_start.full_date) AS total_duration_days,
    SUM(fve.event_count) / NULLIF(SUM(d_end.full_date - d_start.full_date), 0) AS events_per_day,
    AVG(fve.event_count / NULLIF((d_end.full_date - d_start.full_date), 0)) AS avg_events_per_day_per_record
FROM fact_voltage_event fve
JOIN dim_exceptional_event ee ON fve.exceptional_event_id = ee.exceptional_event_id
JOIN dim_date d_start ON fve.start_date_id = d_start.date_id
JOIN dim_date d_end ON fve.end_date_id = d_end.date_id
WHERE d_end.full_date > d_start.full_date
GROUP BY ee.exceptional_event_name
ORDER BY events_per_day DESC;