# Power Quality Data Mart: Integrating and Analysing E-REDES Operational Data

A dimensional data warehouse for analysing power quality in Portugal's electricity distribution network, built from open data published by [E-REDES](https://e-redes.opendatasoft.com/). Voltage dips, overvoltages and continuous indicators such as flicker and harmonic distortion are combined into a star-schema data mart, queried with SQL and explored in a Power BI dashboard.

---

## Why this project

Power quality data is published as wide, operational tables that are hard to compare across places, voltage levels and years. The goal was to show what a data warehouse makes possible that the raw files do not:

- Compare **event-based** data (dips, overvoltages) with **continuous monitoring** data (voltage, flicker, THD, frequency) in one model.
- Check compliance with the **NP EN 50160** standard across regions, voltage levels and time.
- Separate normal grid behaviour from **exceptional events** such as storms, so comparisons are fair.

## Data

| Source | Content |
|---|---|
| E-REDES Open Data Portal | Network features, voltage dips, overvoltages, continuous phenomena, secondary substations (PTD) |
| Eurostat LAU registry | Municipality names and codes |
| European Commission GISCO | NUTS III region definitions (GeoJSON) |

The E-REDES data is described by the provider as an approximation of network conditions at collection time and may contain minor inconsistencies.

## Dimensional model

Four stars share conformed dimensions (Date and Location in all four).

- **Fact tables (transaction):** `Fact_Voltage_Event`, `Fact_Continuous_Phenomena`
- **Aggregate tables (periodic snapshot, municipality × month):** `Agg_Municipality_Voltage_Event`, `Agg_Municipality_Continuous_Quality`
- **Dimensions:** `Dim_Date`, `Dim_Location`, `Dim_Installation`, `Dim_Voltage_Class`, `Dim_Voltage_Level`, `Dim_Exceptional_Event`

Design notes:

- `Fact_Voltage_Event` has one row per installation, monitoring period and voltage event class. The source stores counts as wide matrices (cells A1 to X5 for dips, S1 to T3 for overvoltages), which are **unpivoted** so each cell can be filtered and grouped directly.
- Event counts are **fully additive**. Compliance percentages are **semi-additive**: they are averaged, never summed, and weighted by monitoring days or installation count.
- `Dim_Date` plays two roles (start and end date) in the transaction facts.
- `Dim_Location` supports two roll-up paths: Municipality → District, and Municipality → NUTS III → NUTS II.

## ETL

- **Extract:** CSV exports from the portal, plus LAU and GeoJSON files, kept as a stable staging snapshot.
- **Transform:** Python and Pandas. Cleaning, surrogate keys, unpivoting the event matrices, deriving monitoring days and a compliance score, and default records so no fact row is lost to a missing key.
- **Load:** MySQL through SQLAlchemy and PyMySQL, dimensions first and then facts, with foreign key constraints enforced.

## Analytical queries

Seven SQL views answer specific business questions:

| View | Question |
|---|---|
| `vw_exceptional` | How much do storms and depressions inflate event counts? |
| `vw_non_compliance` | Which municipalities have the worst flicker compliance? |
| `vw_severity_index` | Which NUTS II regions have the most severe voltage events? |
| `vw_annual_trends` | How have flicker, THD and voltage compliance evolved by year? |
| `vw_installation_comparison` | Do PTDs underperform relative to substations? |
| `vw_phase_asymmetry` | How balanced is performance across phases L1, L2 and L3? |
| `vw_load_size_comparison` | Does installed capacity relate to power quality? |

## Dashboard

A Power BI dashboard built on top of these views, with drill-down from NUTS II to NUTS III to municipality.

Some of what it shows:

- Around 197 thousand voltage events in total, of which about 2.7 thousand fall in exceptional-event periods.
- A visible degradation in power quality around 2016, followed by stabilisation close to full compliance.
- Cyclone Kirk is the exceptional event with the largest impact.
- Alentejo and Norte have the highest severity-weighted event index. Centro, Norte and Oeste e Vale do Tejo show comparatively lower compliance.

## Tech stack

Python (Pandas), MySQL, SQLAlchemy, PyMySQL, SQL, Power BI and Modeling Tool.

## Repository structure

```
├── DW_creation/
│   ├── All_Data_DW.xlsx                     # consolidated project dataset
│   ├──etl_extraction_transformation.ipynb
│   └── etl_loading.sql
│       etl_table_population.py
├── Query_views/
│   ├── Q1 - q_exceptional.sql
│   ├── Q2 - q_non_compliance.sql
│   ├── Q3 - q_severity_index.sql
│   ├── Q4 - q_yearly_trends.sql
│   ├── Q5 - q_installation_comparison.sql
│   ├── Q6 - q_phase_asymmetry.sql
│   └── Q7 - q_load_size_comparison.sql
├── Visualization/
├── README.md
├── Report.pdf
└── .gitignore
```

## Team

* [Carolina Dias](https://github.com/CarolDias18) 
* [Leonor Couto] (https://github.com/Leonor2004)
* [Mariana Pereira](https://github.com/mfaria-p) 
* [Simão Bernardo](https://github.com/simaozuzarte) 
* [Sofia Fernandes]() 

Carolina Dias, Leonor Couto, Mariana Pereira, Simão Bernardo, Sofia Fernandes.

**My contribution (Simão):** planning of the dimensional bus matrix, contributing to the dimensional model (which went through several iterations with the all team), writing the data dictionary, writing 2 of the analytical queries and contributing on dashboard visuals. The ETL code was mainly developed by other team members.

## Possible future work

Applying machine learning to the warehouse data to anticipate voltage dips, outages or equipment failures. This is not implemented in this project.
