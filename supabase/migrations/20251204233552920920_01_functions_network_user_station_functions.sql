-- ============================================================
-- NETWORK USER STATION FUNCTIONS (CRUD + GENERIC UPDATE)
-- INSERT
CREATE OR REPLACE FUNCTION insert_network_user_station(
    p_idUser INT,
    p_idStation INT,
    p_date_issue DATE,
    p_date_registration DATE,
    p_status TEXT
)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO "network_user_station"(idUser, idStation, date_issue, date_registration, status)
    VALUES (p_idUser, p_idStation, p_date_issue, p_date_registration, p_status);
END;
$$;

-- SELECT ALL
CREATE OR REPLACE FUNCTION get_network_user_station()
RETURNS SETOF "network_user_station"
LANGUAGE sql AS $$
    SELECT * FROM "network_user_station";
$$;

-- GENERIC UPDATE
CREATE OR REPLACE FUNCTION update_network_user_station_generic(
    p_idUser INT,
    p_idStation INT,
    p_date_issue DATE DEFAULT NULL,
    p_date_registration DATE DEFAULT NULL,
    p_status TEXT DEFAULT NULL
)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "network_user_station"
    SET
        date_issue = COALESCE(p_date_issue, date_issue),
        date_registration = COALESCE(p_date_registration, date_registration),
        status = COALESCE(p_status, status)
    WHERE idUser = p_idUser AND idStation = p_idStation;
END;
$$;

-- DELETE
CREATE OR REPLACE FUNCTION delete_network_user_station(
    p_idUser INT,
    p_idStation INT
)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM "network_user_station"
    WHERE idUser = p_idUser AND idStation = p_idStation;
END;
$$;

-- ============================================================
