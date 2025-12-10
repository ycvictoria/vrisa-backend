-- ============================================================
-- MEASUREMENT FUNCTIONS (CRUD + GENERIC UPDATE)

-- INSERT
CREATE OR REPLACE FUNCTION insert_measurement(
    p_value FLOAT,
    p_timestamp TIMESTAMP,
    p_idSensor INT,
    p_idParameter INT
)
RETURNS TABLE(idMeasurement INT)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    INSERT INTO "measurement"(value, timestamp_measure, idSensor, idParameter)
    VALUES (p_value, p_timestamp, p_idSensor, p_idParameter)
    RETURNING idMeasurement;
END;
$$;

-- SELECT ALL
CREATE OR REPLACE FUNCTION get_measurements()
RETURNS SETOF "measurement"
LANGUAGE sql AS $$
    SELECT * FROM "measurement";
$$;

-- SELECT BY ID
CREATE OR REPLACE FUNCTION get_measurement_by_id(p_idMeasurement INT)
RETURNS SETOF "measurement"
LANGUAGE sql AS $$
    SELECT * FROM "measurement" WHERE idMeasurement = p_idMeasurement;
$$;

-- GENERIC UPDATE
CREATE OR REPLACE FUNCTION update_measurement_generic(
    p_idMeasurement INT,
    p_value FLOAT DEFAULT NULL,
    p_timestamp TIMESTAMP DEFAULT NULL,
    p_idSensor INT DEFAULT NULL,
    p_idParameter INT DEFAULT NULL
)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "measurement"
    SET
        value = COALESCE(p_value, value),
        timestamp_measure = COALESCE(p_timestamp, timestamp_measure),
        idSensor = COALESCE(p_idSensor, idSensor),
        idParameter = COALESCE(p_idParameter, idParameter)
    WHERE idMeasurement = p_idMeasurement;
END;
$$;

-- DELETE
CREATE OR REPLACE FUNCTION delete_measurement(p_idMeasurement INT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM "measurement" WHERE idMeasurement = p_idMeasurement;
END;
$$;


-- ============================================================

--esto es para la parte de reportes que selecciona las mediciones deacuerdo 
--a los filtros seleccionados en el frontend
CREATE OR REPLACE FUNCTION get_station_measurements_report(
  station_ids INT[],
  variable_ids INT[],
  start_date TIMESTAMP,
  end_date TIMESTAMP
)
RETURNS TABLE(
  estacion TEXT,
  sensor TEXT,
  parametro TEXT,
  fecha TIMESTAMP,
  valor FLOAT,
  unidad TEXT
) AS $$
  SELECT
    st.name AS estacion,
    se.model AS sensor,
    v.name AS parametro,
    m.timestamp_measure AS fecha,
    m.value AS valor,
    v.measurement_unit AS unidad
  FROM measurement m
  JOIN sensor se ON m.idSensor = se.idSensor
  JOIN station st ON se.idStation = st.idStation
  JOIN variable v ON m.idParameter = v.idVariable
  WHERE
    (station_ids IS NULL OR se.idStation = ANY(station_ids)) AND
    (variable_ids IS NULL OR m.idParameter = ANY(variable_ids)) AND
    m.timestamp_measure BETWEEN start_date AND end_date
  ORDER BY m.timestamp_measure ASC;
$$ LANGUAGE sql STABLE;

--para ver que variables los sensores  miden por estaciones
CREATE OR REPLACE FUNCTION get_variables_by_stations(
  station_ids INT[]
)
RETURNS TABLE(
  idVariable INT,
  name TEXT,
  measurement_unit TEXT,
  category TEXT
) AS $$
  SELECT DISTINCT
    v.idVariable,
    v.name,
    v.measurement_unit,
    v.category
  FROM variable v
  JOIN measurement m ON m.idParameter = v.idVariable
  JOIN sensor s ON s.idSensor = m.idSensor
  WHERE station_ids IS NULL 
     OR s.idStation = ANY(station_ids)
  ORDER BY v.name;
$$ LANGUAGE sql STABLE;
