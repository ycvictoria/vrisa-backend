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
