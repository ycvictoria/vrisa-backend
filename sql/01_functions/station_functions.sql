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

-- ============================================================
