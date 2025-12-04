

-- ============================================================
-- 3) ALERTAS POR ESTACIÓN
-- ============================================================

CREATE OR REPLACE VIEW alert_by_station AS
SELECT 
    a.idAlert,
    a.alert_type,
    a.level,
    a.description,
    a.issued_date,
    st.idStation,
    st.name AS station_name,
    m.idMeasurement,
    m.value AS measurement_value,
    m.timestamp_measure
FROM alert a
JOIN measurement m ON a.idMeasurement = m.idMeasurement
JOIN sensor s ON m.idSensor = s.idSensor
JOIN station st ON s.idStation = st.idStation;


-- ============================================================
-- 4) ALERTAS POR SENSOR
-- ============================================================

CREATE OR REPLACE VIEW alert_by_sensor AS
SELECT 
    a.idAlert,
    a.alert_type,
    a.level,
    a.description,
    a.issued_date,
    s.idSensor,
    m.value AS measurement_value,
    m.timestamp_measure
FROM alert a
JOIN measurement m ON a.idMeasurement = m.idMeasurement
JOIN sensor s ON m.idSensor = s.idSensor;


-- ============================================================
-- 5) SENSOR POR ESTACIÓN (LISTA DE SENSORES DE UNA ESTACIÓN)
-- ============================================================

CREATE OR REPLACE VIEW sensors_by_station AS
SELECT 
    s.idSensor,
    s.brand,
    s.model,
    s.type,
    s.status,
    s.installation_date,
    st.idStation,
    st.name AS station_name
FROM sensor s
JOIN station st ON s.idStation = st.idStation;


-- ============================================================
-- 6) MAINTENANCE POR ESTACIÓN
-- ============================================================

CREATE OR REPLACE VIEW maintenance_by_station AS
SELECT 
    mt.idMaintenance,
    mt.maintenance_date,
    mt.type_maintenance,
    mt.description,
    mt.certificated_documents_url,
    mt.technician_in_charge,
    u.first_name AS technician_firstname,
    u.last_name AS technician_lastname,
    s.idSensor,
    st.idStation,
    st.name AS station_name
FROM maintenance mt
JOIN sensor s ON mt.idSensor = s.idSensor
JOIN station st ON s.idStation = st.idStation
JOIN "user" u ON mt.technician_in_charge = u.idUser;
