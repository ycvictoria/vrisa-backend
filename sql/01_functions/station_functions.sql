-- ============================================================
-- STATION FUNCTIONS (CRUD + GENERIC UPDATE + SPECIAL UPDATES)

-- INSERT
CREATE OR REPLACE FUNCTION insert_station(
    p_name TEXT,
    p_status TEXT,
    p_opening_date DATE,
    p_closing_date DATE,
    p_idTechnician INT
)
RETURNS TABLE(idStation INT)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    INSERT INTO "station"(name, status, opening_date, closing_date, idTechnician)
    VALUES (p_name, p_status, p_opening_date, p_closing_date, p_idTechnician)
    RETURNING idStation;
END;
$$;

-- SELECT ALL
CREATE OR REPLACE FUNCTION get_stations()
RETURNS SETOF "station"
LANGUAGE sql AS $$
    SELECT * FROM "station";
$$;

-- SELECT BY ID
CREATE OR REPLACE FUNCTION get_station_by_id(p_idStation INT)
RETURNS SETOF "station"
LANGUAGE sql AS $$
    SELECT * FROM "station" WHERE idStation = p_idStation;
$$;

CREATE OR REPLACE FUNCTION get_station_by_id(_id INT)
RETURNS TABLE (
    idstation INT,
    name TEXT,
    status TEXT,
    opening_date DATE,
    closing_date DATE,
    idtechnician INT
)
LANGUAGE sql AS $$
    SELECT 
        idstation,
        name,
        status,
        opening_date,
        closing_date,
        idtechnician
    FROM station
    WHERE idstation = _id;
$$;

CREATE OR REPLACE FUNCTION get_station_ubication(_id INT)
RETURNS TABLE (
    idstation INT,
    latitude FLOAT,
    longitude FLOAT,
    address TEXT
)
LANGUAGE sql AS $$
    SELECT 
        idstation,
        latitude,
        longitude,
        address
    FROM ubication
    WHERE idstation = _id;
$$;


CREATE OR REPLACE FUNCTION get_all_stations()
RETURNS TABLE (
  idStation INT,
  name TEXT,
  status TEXT,
  opening_date DATE,
  closing_date DATE,
  idTechnician INT
)
LANGUAGE sql
AS $$
  SELECT 
    s.idStation,
    s.name,
    s.status,
    s.opening_date,
    s.closing_date,
    s.idTechnician
  FROM station s
  ORDER BY s.name;
$$;

-- GENERIC UPDATE
CREATE OR REPLACE FUNCTION update_station_generic(
    p_idStation INT,
    p_name TEXT DEFAULT NULL,
    p_status TEXT DEFAULT NULL,
    p_opening_date DATE DEFAULT NULL,
    p_closing_date DATE DEFAULT NULL,
    p_idTechnician INT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "station"
    SET
        name = COALESCE(p_name, name),
        status = COALESCE(p_status, status),
        opening_date = COALESCE(p_opening_date, opening_date),
        closing_date = COALESCE(p_closing_date, closing_date),
        idTechnician = COALESCE(p_idTechnician, idTechnician)
    WHERE idStation = p_idStation;
END;
$$;

--select variables agrupadas por estacion para seccion reportes
CREATE OR REPLACE FUNCTION get_variables_grouped_by_station(
  station_ids INT[]
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
  result JSONB := '[]'::jsonb;
  station_row RECORD;
BEGIN
  FOR station_row IN
    SELECT s.idstation, s.name
    FROM station s
    WHERE s.idstation = ANY(station_ids)
  LOOP

    result := result || jsonb_build_object(
      'idStation', station_row.idstation,
      'station', station_row.name,
      'variables',
      (
        SELECT COALESCE(jsonb_agg(
          jsonb_build_object(
            'idVariable', v.idvariable,
            'name', v.name,
            'unit', v.measurement_unit
          )
        ), '[]'::jsonb)
        FROM variable v
        JOIN measurement m ON m.idparameter = v.idvariable
        JOIN sensor se ON se.idsensor = m.idsensor
        WHERE se.idstation = station_row.idstation
      )
    );

  END LOOP;

  RETURN result;
END;
$$;

--para generar la informacion de las tablas del reporte
CREATE OR REPLACE FUNCTION get_data_station_report(
  stations INT[],
  variables INT[],
  since_timestamp TIMESTAMP,
  until_timestamp TIMESTAMP
)
RETURNS TABLE (
  estacion TEXT,
  fecha TIMESTAMP,
  parametro TEXT,
  valor FLOAT,
  unidad TEXT
)
LANGUAGE sql AS $$
  SELECT 
    s.name AS estacion,
    m.timestamp_measure AS fecha,
    v.name AS parametro,
    m.value AS valor,
    v.measurement_unit AS unidad
  FROM measurement m
  JOIN sensor se ON se.idsensor = m.idsensor
  JOIN station s ON s.idstation = se.idstation
  JOIN variable v ON v.idvariable = m.idparameter
  WHERE se.idstation = ANY(stations)
    AND m.idparameter = ANY(variables)
    AND m.timestamp_measure BETWEEN since_timestamp AND until_timestamp
  ORDER BY s.name, m.timestamp_measure ASC;
$$;

-- SPECIAL UPDATES
CREATE OR REPLACE FUNCTION activate_station(p_idStation INT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "station" SET status = 'active'
    WHERE idStation = p_idStation;
END;
$$;

CREATE OR REPLACE FUNCTION deactivate_station(p_idStation INT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "station" SET status = 'inactive'
    WHERE idStation = p_idStation;
END;
$$;

CREATE OR REPLACE FUNCTION close_station(p_idStation INT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "station"
    SET status = 'closed',
        closing_date = NOW()
    WHERE idStation = p_idStation;
END;
$$;

-- DELETE
CREATE OR REPLACE FUNCTION delete_station(p_idStation INT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM "station" WHERE idStation = p_idStation;
END;
$$;

--sensores por estacion
CREATE OR REPLACE FUNCTION get_sensors_by_station(_id INT)
RETURNS TABLE (
    idsensor INT,
    brand TEXT,
    model TEXT,
    type TEXT,
    status TEXT,
    installation_date DATE
)
LANGUAGE sql AS $$
    SELECT 
        idsensor,
        brand,
        model,
        type,
        status,
        installation_date
    FROM sensor
    WHERE idstation = _id;
$$;

--variables que mide  la estacion 
CREATE OR REPLACE FUNCTION get_variables_by_station(_id INT)
RETURNS TABLE (
    idvariable INT,
    name TEXT,
    category TEXT,
    description TEXT,
    measurement_unit TEXT
)
LANGUAGE sql AS $$
SELECT DISTINCT
    v.idvariable,
    v.name,
    v.category,
    v.description,
    v.measurement_unit
FROM variable v
JOIN measurement m ON m.idparameter = v.idvariable
JOIN sensor s ON s.idsensor = m.idsensor
WHERE s.idstation = _id;
$$;

--buscar variables por fecha
CREATE OR REPLACE FUNCTION get_station_variable_history(
  _station_id INT,
  _variable_id INT,
  _since TIMESTAMPTZ,
  _until TIMESTAMPTZ
)
RETURNS TABLE (
  timestamp_measure TIMESTAMPTZ,
  value FLOAT
)
LANGUAGE sql AS $$
  SELECT 
    m.timestamp_measure,
    m.value
  FROM measurement m
  JOIN sensor s ON s.idSensor = m.idSensor
  WHERE s.idStation = _station_id
    AND m.idParameter = _variable_id
    AND m.timestamp_measure BETWEEN _since AND _until
  ORDER BY m.timestamp_measure;
$$;


--retorna la ultima medicion de esa variable en esa estación
CREATE OR REPLACE FUNCTION get_last_measurements_by_station(p_station INT)
RETURNS TABLE (
    idvariable INT,
    variable_name TEXT,
    unit TEXT,
    category TEXT,
    last_value FLOAT,
    last_timestamp TIMESTAMPTZ
)
LANGUAGE sql AS
$$
    SELECT
        v.idvariable,
        v.name AS variable_name,
        v.measurement_unit AS unit,
        v.category,
        m.value AS last_value,
        m.timestamp_measure AS last_timestamp
    FROM variable v
    JOIN measurement m ON m.idparameter = v.idvariable
    JOIN sensor s ON s.idsensor = m.idsensor
    WHERE s.idstation = p_station
    AND m.timestamp_measure = (
        SELECT MAX(m2.timestamp_measure)
        FROM measurement m2
        JOIN sensor s2 ON s2.idsensor = m2.idsensor
        WHERE m2.idparameter = v.idvariable
        AND s2.idstation = p_station
    )
    ORDER BY v.name;
$$;

-- ============================================================
