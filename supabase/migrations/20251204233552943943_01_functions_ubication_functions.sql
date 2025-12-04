-- ============================================================
-- UBICATION FUNCTIONS (CRUD + GENERIC UPDATE)
-- INSERT
CREATE OR REPLACE FUNCTION insert_ubication(
    p_idStation INT,
    p_latitude FLOAT,
    p_longitude FLOAT,
    p_address TEXT
)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO "ubication"(idStation, latitude, longitude, address)
    VALUES (p_idStation, p_latitude, p_longitude, p_address);
END;
$$;

-- SELECT ALL
CREATE OR REPLACE FUNCTION get_ubications()
RETURNS SETOF "ubication"
LANGUAGE sql AS $$
    SELECT * FROM "ubication";
$$;

-- SELECT BY ID
CREATE OR REPLACE FUNCTION get_ubication_by_id(p_idStation INT)
RETURNS SETOF "ubication"
LANGUAGE sql AS $$
    SELECT * FROM "ubication" WHERE idStation = p_idStation;
$$;

-- GENERIC UPDATE
CREATE OR REPLACE FUNCTION update_ubication_generic(
    p_idStation INT,
    p_latitude FLOAT DEFAULT NULL,
    p_longitude FLOAT DEFAULT NULL,
    p_address TEXT DEFAULT NULL
)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "ubication"
    SET
        latitude = COALESCE(p_latitude, latitude),
        longitude = COALESCE(p_longitude, longitude),
        address = COALESCE(p_address, address)
    WHERE idStation = p_idStation;
END;
$$;

-- DELETE
CREATE OR REPLACE FUNCTION delete_ubication(p_idStation INT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM "ubication" WHERE idStation = p_idStation;
END;
$$;

-- ============================================================
