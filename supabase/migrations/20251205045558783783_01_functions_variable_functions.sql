-- ============================================================
-- VARIABLE FUNCTIONS (CRUD + GENERIC UPDATE)
-- INSERT
CREATE OR REPLACE FUNCTION insert_variable(
    p_name TEXT,
    p_category TEXT,
    p_description TEXT,
    p_measurement_unit TEXT,
    p_range_min FLOAT,
    p_range_max FLOAT
)
RETURNS TABLE(idVariable INT)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    INSERT INTO "variable"(name, category, description, measurement_unit, range_min, range_max)
    VALUES (p_name, p_category, p_description, p_measurement_unit, p_range_min, p_range_max)
    RETURNING idVariable;
END;
$$;

-- SELECT ALL
CREATE OR REPLACE FUNCTION get_variables()
RETURNS SETOF "variable"
LANGUAGE sql AS $$
    SELECT * FROM "variable";
$$;

-- SELECT BY ID
CREATE OR REPLACE FUNCTION get_variable_by_id(p_idVariable INT)
RETURNS SETOF "variable"
LANGUAGE sql AS $$
    SELECT * FROM "variable" WHERE idVariable = p_idVariable;
$$;

-- GENERIC UPDATE
CREATE OR REPLACE FUNCTION update_variable_generic(
    p_idVariable INT,
    p_name TEXT DEFAULT NULL,
    p_category TEXT DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_measurement_unit TEXT DEFAULT NULL,
    p_range_min FLOAT DEFAULT NULL,
    p_range_max FLOAT DEFAULT NULL
)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "variable"
    SET
        name = COALESCE(p_name, name),
        category = COALESCE(p_category, category),
        description = COALESCE(p_description, description),
        measurement_unit = COALESCE(p_measurement_unit, measurement_unit),
        range_min = COALESCE(p_range_min, range_min),
        range_max = COALESCE(p_range_max, range_max)
    WHERE idVariable = p_idVariable;
END;
$$;

-- DELETE
CREATE OR REPLACE FUNCTION delete_variable(p_idVariable INT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM "variable" WHERE idVariable = p_idVariable;
END;
$$;

-- ============================================================
