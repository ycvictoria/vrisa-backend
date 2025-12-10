

-- ============================================================
--  VIEWS  FOR MEASUREMENTS
-- ============================================================
CREATE OR REPLACE VIEW measurement_full AS
SELECT 
    m.idMeasurement,
    m.value,
    m.timestamp_measure,
    m.idSensor,
    s.brand AS sensor_brand,
    s.model AS sensor_model,
    s.type AS sensor_type,
    s.status AS sensor_status,
    s.idStation,
    st.name AS station_name,
    st.status AS station_status,
    st.opening_date,
    st.closing_date,
    u.latitude,
    u.longitude,
    u.address AS station_address,
    m.idParameter,
    v.name AS variable_name,
    v.category AS variable_category,
    v.measurement_unit AS variable_unit
FROM measurement m
JOIN sensor s ON m.idSensor = s.idSensor
JOIN station st ON s.idStation = st.idStation
JOIN ubication u ON st.idStation = u.idStation
JOIN variable v ON m.idParameter = v.idVariable;

CREATE OR REPLACE VIEW measurements_by_sensor AS
SELECT *
FROM measurement_full
ORDER BY idSensor, timestamp_measure;

CREATE OR REPLACE VIEW measurements_by_variable AS
SELECT *
FROM measurement_full
ORDER BY variable_name, timestamp_measure;

CREATE OR REPLACE VIEW measurements_by_date AS
SELECT *
FROM measurement_full
ORDER BY timestamp_measure;

CREATE OR REPLACE VIEW measurements_by_date_range AS
SELECT *
FROM measurement_full
WHERE timestamp_measure BETWEEN '2000-01-01' AND NOW()
ORDER BY timestamp_measure;

CREATE OR REPLACE VIEW measurements_variable_by_date AS
SELECT *
FROM measurement_full
WHERE timestamp_measure BETWEEN '2000-01-01' AND NOW()
ORDER BY variable_name, timestamp_measure;

CREATE OR REPLACE VIEW measurements_sensor_by_date AS
SELECT *
FROM measurement_full
WHERE timestamp_measure BETWEEN '2000-01-01' AND NOW()
ORDER BY idSensor, timestamp_measure;

CREATE OR REPLACE VIEW alert_full AS
SELECT 
    a.idAlert,
    a.alert_type,
    a.level,
    a.description,
    a.issued_date,
    m.value AS measurement_value,
    m.timestamp_measure,
    v.name AS variable_name,
    s.idSensor,
    st.idStation
FROM alert a
JOIN measurement m ON a.idMeasurement = m.idMeasurement
JOIN variable v ON m.idParameter = v.idVariable
JOIN sensor s ON m.idSensor = s.idSensor
JOIN station st ON s.idStation = st.idStation;


CREATE OR REPLACE VIEW active_sensors AS
SELECT *
FROM sensor
WHERE status = 'active';

CREATE OR REPLACE VIEW active_stations AS
SELECT *
FROM station
WHERE status = 'active';

CREATE OR REPLACE VIEW measurement_daily AS
SELECT 
    DATE(timestamp_measure) AS day,
    idSensor,
    idParameter,
    AVG(value) AS avg_value,
    MIN(value) AS min_value,
    MAX(value) AS max_value
FROM measurement
GROUP BY day, idSensor, idParameter;

CREATE OR REPLACE VIEW measurement_weekly AS
SELECT 
    DATE_TRUNC('week', timestamp_measure) AS week,
    idSensor,
    idParameter,
    AVG(value) AS avg_value,
    MIN(value) AS min_value,
    MAX(value) AS max_value
FROM measurement
GROUP BY week, idSensor, idParameter;

CREATE OR REPLACE VIEW measurement_monthly AS
SELECT 
    DATE_TRUNC('month', timestamp_measure) AS month,
    idSensor,
    idParameter,
    AVG(value) AS avg_value,
    MIN(value) AS min_value,
    MAX(value) AS max_value
FROM measurement
GROUP BY month, idSensor, idParameter;
