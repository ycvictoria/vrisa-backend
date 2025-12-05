-- ============================================================
-- MAINTENANCE FUNCTIONS (CRUD + GENERIC UPDATE)

-- INSERT
CREATE OR REPLACE FUNCTION insert_maintenance(
    p_date DATE,
    p_type TEXT,
    p_description TEXT,
    p_docs TEXT,
    p_technician INT,
    p_idSensor INT
)
RETURNS TABLE(idMaintenance INT)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    INSERT INTO "maintenance"(maintenance_date, type_maintenance, description, certificated_documents_url, technician_in_charge, idSensor)
    VALUES (p_date, p_type, p_description, p_docs, p_technician, p_idSensor)
    RETURNING idMaintenance;
END;
$$;

-- SELECT ALL
CREATE OR REPLACE FUNCTION get_maintenances()
RETURNS SETOF "maintenance"
LANGUAGE sql AS $$
    SELECT * FROM "maintenance";
$$;

-- SELECT BY ID
CREATE OR REPLACE FUNCTION get_maintenance_by_id(p_idMaintenance INT)
RETURNS SETOF "maintenance"
LANGUAGE sql AS $$
    SELECT * FROM "maintenance" WHERE idMaintenance = p_idMaintenance;
$$;

-- GENERIC UPDATE
CREATE OR REPLACE FUNCTION update_maintenance_generic(
    p_idMaintenance INT,
    p_date DATE DEFAULT NULL,
    p_type TEXT DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_docs TEXT DEFAULT NULL,
    p_technician INT DEFAULT NULL,
    p_idSensor INT DEFAULT NULL
)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "maintenance"
    SET
        maintenance_date = COALESCE(p_date, maintenance_date),
        type_maintenance = COALESCE(p_type, type_maintenance),
        description = COALESCE(p_description, description),
        certificated_documents_url = COALESCE(p_docs, certificated_documents_url),
        technician_in_charge = COALESCE(p_technician, technician_in_charge),
        idSensor = COALESCE(p_idSensor, idSensor)
    WHERE idMaintenance = p_idMaintenance;
END;
$$;

-- DELETE
CREATE OR REPLACE FUNCTION delete_maintenance(p_idMaintenance INT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM "maintenance" WHERE idMaintenance = p_idMaintenance;
END;
$$;

-- ============================================================
