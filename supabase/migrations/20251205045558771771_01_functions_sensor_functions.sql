-- ============================================================
-- SENSOR FUNCTIONS (CRUD + GENERIC UPDATE + SPECIAL)
-- INSERT
CREATE OR REPLACE FUNCTION insert_sensor(
    p_brand TEXT,
    p_model TEXT,
    p_type TEXT,
    p_status TEXT,
    p_installation_date DATE,
    p_idStation INT
)
RETURNS TABLE(idSensor INT)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    INSERT INTO "sensor"(brand, model, type, status, installation_date, idStation)
    VALUES (p_brand, p_model, p_type, p_status, p_installation_date, p_idStation)
    RETURNING idSensor;
END;
$$;

-- SELECT ALL
CREATE OR REPLACE FUNCTION get_sensors()
RETURNS SETOF "sensor"
LANGUAGE sql AS $$
    SELECT * FROM "sensor";
$$;

-- SELECT BY ID SENSOR
CREATE OR REPLACE FUNCTION get_sensor_by_id(p_idSensor INT)
RETURNS SETOF "sensor"
LANGUAGE sql AS $$
    SELECT * FROM "sensor" WHERE idSensor = p_idSensor;
$$;

-- SELECT BY STATION
CREATE OR REPLACE FUNCTION get_sensor_by_station(p_idStation INT)
RETURNS SETOF "sensor"
LANGUAGE sql AS $$
    SELECT * FROM "sensor" WHERE idStation = p_idStation;
$$;

-- GENERIC UPDATE
CREATE OR REPLACE FUNCTION update_sensor_generic(
    p_idSensor INT,
    p_brand TEXT DEFAULT NULL,
    p_model TEXT DEFAULT NULL,
    p_type TEXT DEFAULT NULL,
    p_status TEXT DEFAULT NULL,
    p_installation_date DATE DEFAULT NULL,
    p_idStation INT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "sensor"
    SET
        brand = COALESCE(p_brand, brand),
        model = COALESCE(p_model, model),
        type = COALESCE(p_type, type),
        status = COALESCE(p_status, status),
        installation_date = COALESCE(p_installation_date, installation_date),
        idStation = COALESCE(p_idStation, idStation)
    WHERE idSensor = p_idSensor;
END;
$$;

-- SPECIAL UPDATES
CREATE OR REPLACE FUNCTION activate_sensor(p_idSensor INT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "sensor" SET status = 'active' WHERE idSensor = p_idSensor;
END;
$$;

CREATE OR REPLACE FUNCTION deactivate_sensor(p_idSensor INT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "sensor" SET status = 'inactive' WHERE idSensor = p_idSensor;
END;
$$;

-- DELETE
CREATE OR REPLACE FUNCTION delete_sensor(p_idSensor INT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM "sensor" WHERE idSensor = p_idSensor;
END;
$$;

-- ============================================================
