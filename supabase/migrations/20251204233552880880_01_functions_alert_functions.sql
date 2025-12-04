-- ============================================================
-- ALERT FUNCTIONS (CRUD + GENERIC UPDATE + SPECIAL)
-- INSERT
CREATE OR REPLACE FUNCTION insert_alert(
    p_type TEXT,
    p_level TEXT,
    p_description TEXT,
    p_date TIMESTAMP,
    p_idMeasurement INT
)
RETURNS TABLE(idAlert INT)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    INSERT INTO "alert"(alert_type, level, description, issued_date, idMeasurement)
    VALUES (p_type, p_level, p_description, p_date, p_idMeasurement)
    RETURNING idAlert;
END;
$$;

-- SELECT ALL
CREATE OR REPLACE FUNCTION get_alerts()
RETURNS SETOF "alert"
LANGUAGE sql AS $$
    SELECT * FROM "alert";
$$;

-- SELECT BY ID
CREATE OR REPLACE FUNCTION get_alert_by_id(p_idAlert INT)
RETURNS SETOF "alert"
LANGUAGE sql AS $$
    SELECT * FROM "alert" WHERE idAlert = p_idAlert;
$$;

-- GENERIC UPDATE
CREATE OR REPLACE FUNCTION update_alert_generic(
    p_idAlert INT,
    p_type TEXT DEFAULT NULL,
    p_level TEXT DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_issued_date TIMESTAMP DEFAULT NULL,
    p_idMeasurement INT DEFAULT NULL
)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "alert"
    SET
        alert_type = COALESCE(p_type, alert_type),
        level = COALESCE(p_level, level),
        description = COALESCE(p_description, description),
        issued_date = COALESCE(p_issued_date, issued_date),
        idMeasurement = COALESCE(p_idMeasurement, idMeasurement)
    WHERE idAlert = p_idAlert;
END;
$$;

-- SPECIAL UPDATE: Mark as resolved
CREATE OR REPLACE FUNCTION resolve_alert(p_idAlert INT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "alert"
    SET level = 'resolved'
    WHERE idAlert = p_idAlert;
END;
$$;

-- DELETE
CREATE OR REPLACE FUNCTION delete_alert(p_idAlert INT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM "alert" WHERE idAlert = p_idAlert;
END;
$$;

-- ============================================================
