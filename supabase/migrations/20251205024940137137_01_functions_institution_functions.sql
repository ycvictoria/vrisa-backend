CREATE OR REPLACE FUNCTION insert_institution(
    p_name TEXT,
    p_logo TEXT,
    p_address TEXT,
    p_idUser INT
)
RETURNS TABLE (idInstitution INT)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    INSERT INTO "institution" (name, logo, address, idUser)
    VALUES (p_name, p_logo, p_address, p_idUser)
    RETURNING idInstitution;
END;
$$;

CREATE OR REPLACE FUNCTION get_institutions()
RETURNS SETOF "institution"
LANGUAGE sql AS $$
    SELECT * FROM "institution";
$$;

CREATE OR REPLACE FUNCTION update_institution_generic(
    p_idInstitution INT,
    p_name TEXT DEFAULT NULL,
    p_logo TEXT DEFAULT NULL,
    p_address TEXT DEFAULT NULL,
    p_idUser INT DEFAULT NULL
)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "institution"
    SET
        name = COALESCE(p_name, name),
        logo = COALESCE(p_logo, logo),
        address = COALESCE(p_address, address),
        idUser = COALESCE(p_idUser, idUser)
    WHERE idInstitution = p_idInstitution;
END;
$$;

CREATE OR REPLACE FUNCTION delete_institution(p_idInstitution INT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM "institution" WHERE idInstitution = p_idInstitution;
END;
$$;


CREATE OR REPLACE FUNCTION insert_color(
    p_idInstitution INT,
    p_color1 TEXT,
    p_color2 TEXT,
    p_color3 TEXT
)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO "color"
    VALUES (p_idInstitution, p_color1, p_color2, p_color3);
END;
$$;
