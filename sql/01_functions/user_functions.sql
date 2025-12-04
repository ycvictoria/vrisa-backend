-- ============================================================
-- USER FUNCTIONS (CRUD + GENERIC UPDATE + SPECIAL UPDATES)

-- INSERT
CREATE OR REPLACE FUNCTION insert_user(
    p_first_name TEXT,
    p_last_name TEXT,
    p_role TEXT,
    p_registration_date DATE,
    p_authorization_status TEXT,
    p_account_status TEXT
)
RETURNS TABLE (idUser INT)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    INSERT INTO "User" (
        first_name, last_name, role, registration_date,
        authorization_status, account_status
    )
    VALUES (
        p_first_name, p_last_name, p_role, p_registration_date,
        p_authorization_status, p_account_status
    ) RETURNING idUser;
END;
$$;

-- SELECT ALL
CREATE OR REPLACE FUNCTION get_users()
RETURNS SETOF "User"
LANGUAGE sql AS $$
    SELECT * FROM "User";
$$;

-- SELECT BY ID
CREATE OR REPLACE FUNCTION get_user_by_id(p_idUser INT)
RETURNS SETOF "User"
LANGUAGE sql AS $$
    SELECT * FROM "User" WHERE idUser = p_idUser;
$$;

-- GENERIC UPDATE
CREATE OR REPLACE FUNCTION update_user_generic(
    p_idUser INT,
    p_first_name TEXT DEFAULT NULL,
    p_last_name TEXT DEFAULT NULL,
    p_role TEXT DEFAULT NULL,
    p_registration_date DATE DEFAULT NULL,
    p_authorization_status TEXT DEFAULT NULL,
    p_account_status TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "User"
    SET
        first_name = COALESCE(p_first_name, first_name),
        last_name = COALESCE(p_last_name, last_name),
        role = COALESCE(p_role, role),
        registration_date = COALESCE(p_registration_date, registration_date),
        authorization_status = COALESCE(p_authorization_status, authorization_status),
        account_status = COALESCE(p_account_status, account_status)
    WHERE idUser = p_idUser;
END;
$$;

-- SPECIAL UPDATES
CREATE OR REPLACE FUNCTION activate_user(p_idUser INT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "User" SET account_status = 'active'
    WHERE idUser = p_idUser;
END;
$$;

CREATE OR REPLACE FUNCTION deactivate_user(p_idUser INT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "User" SET account_status = 'inactive'
    WHERE idUser = p_idUser;
END;
$$;

CREATE OR REPLACE FUNCTION authorize_user(p_idUser INT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "User" SET authorization_status = 'authorized'
    WHERE idUser = p_idUser;
END;
$$;

-- DELETE
CREATE OR REPLACE FUNCTION delete_user(p_idUser INT)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM "User" WHERE idUser = p_idUser;
END;
$$;

-- ============================================================
