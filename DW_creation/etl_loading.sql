-- 0. Create the Database
CREATE DATABASE IF NOT EXISTS e_redes;
USE e_redes;

-- 1. Create Dimension Tables
CREATE TABLE dim_installation (
    installation_id INT PRIMARY KEY,
    installation_code VARCHAR(50),  -- User Key (Business Key)
    designation VARCHAR(100),
    type_of_installation VARCHAR(100),
    busbar VARCHAR(50),
    construction_type VARCHAR(100),
    usage_level_band VARCHAR(50),
    installed_power_kva FLOAT,
    contracted_power_kva FLOAT,
    number_of_clients INT,
    power_generation_kw FLOAT,
    number_of_client_producers INT,
    latitude FLOAT,
    longitude FLOAT,
    at_mt_transformation_ratio_kv VARCHAR(50),
    tip_mv FLOAT,
    max_sc_power_hv_mv FLOAT,
    max_sc_power_mv_mv FLOAT,
    min_sc_power_hv_mv FLOAT,
    min_sc_power_mv_mv FLOAT,
    sc_current_hv_ka FLOAT
);

CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    full_date DATE UNIQUE,          
    day INT NOT NULL,
    month_id INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    quarter_id INT NOT NULL,
    quarter INT NOT NULL,
    year_id INT NOT NULL,
    year INT NOT NULL,
    week_number INT NOT NULL,
    day_of_week VARCHAR(20) NOT NULL,
    is_weekend BOOLEAN NOT NULL
);

CREATE TABLE dim_location (
    municipality_id INT PRIMARY KEY,
    municipality_code VARCHAR(50),  -- User Key (Business Key)
    municipality VARCHAR(255) UNIQUE NOT NULL,
    district_id INT NOT NULL,
    district_code VARCHAR(50) NOT NULL,
    district VARCHAR(255) NOT NULL,
    nuts_iii_id INT NOT NULL,
    nuts_iii_code VARCHAR(50) NOT NULL,
    nuts_iii VARCHAR(255) NOT NULL,
    nuts_ii_id INT NOT NULL,
    nuts_ii_code VARCHAR(50) NOT NULL,
    nuts_ii VARCHAR(255) NOT NULL
);

CREATE TABLE dim_voltage_class (
    voltage_class_id INT PRIMARY KEY,
    voltage_class_code VARCHAR(10) NOT NULL, -- User Key (Business Key)
    voltage_event_type VARCHAR(50) NOT NULL,
    magnitude_basis VARCHAR(50) NOT NULL,
    class_family_code VARCHAR(10) NOT NULL,
    duration_class_code VARCHAR(10) NOT NULL,
    voltage_range_description VARCHAR(100) NOT NULL,
    duration_range_description VARCHAR(100) NOT NULL,
    voltage_min_pct FLOAT NOT NULL,
    voltage_max_pct FLOAT NOT NULL,
    duration_min_ms INT NOT NULL,
    duration_max_ms INT NOT NULL,
    severity_rank INT NOT NULL CHECK (severity_rank >= 1 AND severity_rank <= 5)
);

CREATE TABLE dim_voltage_level (
    voltage_level_id INT PRIMARY KEY,
    nominal_voltage_v FLOAT NOT NULL,
    voltage_band_code VARCHAR(20) NOT NULL,
    voltage_band_description VARCHAR(100) NOT NULL
);

CREATE TABLE dim_exceptional_event (
    exceptional_event_id INT PRIMARY KEY,
    exceptional_event_name VARCHAR(255) NOT NULL
);

-- 2. Create Fact Tables
CREATE TABLE fact_voltage_event (
    event_count INT,
    exceptional_flag INT,
    record_count INT,
    start_date_id INT NOT NULL,
    end_date_id INT NOT NULL,
    installation_id INT NOT NULL,
    voltage_level_id INT NOT NULL,
    voltage_class_id INT NOT NULL,
    exceptional_event_id INT NOT NULL,
    municipality_id INT NOT NULL,
    FOREIGN KEY (start_date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (end_date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (installation_id) REFERENCES dim_installation(installation_id),
    FOREIGN KEY (voltage_level_id) REFERENCES dim_voltage_level(voltage_level_id),
    FOREIGN KEY (voltage_class_id) REFERENCES dim_voltage_class(voltage_class_id),
    FOREIGN KEY (exceptional_event_id) REFERENCES dim_exceptional_event(exceptional_event_id),
    FOREIGN KEY (municipality_id) REFERENCES dim_location(municipality_id)
);

CREATE TABLE fact_continuous_phenomena (
    voltage_l1_pct FLOAT,
    voltage_l2_pct FLOAT,
    voltage_l3_pct FLOAT,
    flicker_l1_pct FLOAT,
    flicker_l2_pct FLOAT,
    flicker_l3_pct FLOAT,
    thd_l1_pct FLOAT,
    thd_l2_pct FLOAT,
    thd_l3_pct FLOAT,
    unbalanced_pct FLOAT,
    frequency_pct FLOAT,
    monitoring_days INT,
    norm_compliance FLOAT,
    start_date_id INT NOT NULL,
    end_date_id INT NOT NULL,
    installation_id INT NOT NULL,
    voltage_level_id INT NOT NULL,
    exceptional_event_id INT NOT NULL,
    municipality_id INT NOT NULL,
    FOREIGN KEY (start_date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (end_date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (installation_id) REFERENCES dim_installation(installation_id),
    FOREIGN KEY (voltage_level_id) REFERENCES dim_voltage_level(voltage_level_id),
    FOREIGN KEY (exceptional_event_id) REFERENCES dim_exceptional_event(exceptional_event_id),
    FOREIGN KEY (municipality_id) REFERENCES dim_location(municipality_id)
);

-- 3. Create Aggregate Fact Tables


CREATE TABLE agg_municipality_voltage_event (
    total_event_count INT,
    total_record_count INT,
    installation_count INT,
    month_id INT, 
    municipality_id INT NOT NULL,
    voltage_level_id INT NOT NULL,
    voltage_class_id INT NOT NULL,
    FOREIGN KEY (municipality_id) REFERENCES dim_location(municipality_id),
    FOREIGN KEY (voltage_level_id) REFERENCES dim_voltage_level(voltage_level_id),
    FOREIGN KEY (voltage_class_id) REFERENCES dim_voltage_class(voltage_class_id)
);

CREATE TABLE agg_municipality_continuous_phenomena (
    avg_voltage_l1_pct FLOAT,
    avg_voltage_l2_pct FLOAT,
    avg_voltage_l3_pct FLOAT,
    avg_flicker_l1_pct FLOAT,
    avg_flicker_l2_pct FLOAT,
    avg_flicker_l3_pct FLOAT,
    avg_thd_l1_pct FLOAT,
    avg_thd_l2_pct FLOAT,
    avg_thd_l3_pct FLOAT,
    avg_unbalanced_pct FLOAT,
    avg_frequency_pct FLOAT,
    total_monitoring_days INT,
    installation_count INT,
    month_id INT,
    municipality_id INT NOT NULL,
    voltage_level_id INT NOT NULL,
    FOREIGN KEY (municipality_id) REFERENCES dim_location(municipality_id),
    FOREIGN KEY (voltage_level_id) REFERENCES dim_voltage_level(voltage_level_id)
);