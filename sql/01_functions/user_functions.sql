-- ============================================================
-- USER FUNCTIONS (CRUD + GENERIC UPDATE + SPECIAL UPDATES)

-- INSERT

CREATE OR REPLACE FUNCTION create_user(
  _email TEXT,
  _first_name TEXT,
  _last_name TEXT,
  _role role_enum,
  _authorization_status authorization_status_enum DEFAULT 'pendiente',
  _account_status account_status_enum DEFAULT 'inactivo'
)
RETURNS TABLE (
  idUser INT,
  email TEXT,
  first_name TEXT,
  last_name TEXT,
  role role_enum,
  authorization_status authorization_status_enum,
  account_status account_status_enum
)
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO "user" (
    auth_id,
    email,
    first_name,
    last_name,
    role,
    authorization_status,
    account_status
  )
  VALUES (
    NULL,
    _email,
    _first_name,
    _last_name,
    _role,
    _authorization_status,
    _account_status
  )
  RETURNING
    "idUser",
    email,
    first_name,
    last_name,
    role,
    authorization_status,
    account_status
  INTO idUser, email, first_name, last_name, role, authorization_status, account_status;

  RETURN;
END;
$$;

-- SELECT ALL
CREATE OR REPLACE FUNCTION get_users()
RETURNS SETOF "user"
LANGUAGE sql AS $$
    SELECT * FROM "user";
$$;

-- SELECT BY ID
CREATE OR REPLACE FUNCTION get_user_by_id(p_idUser INT)
RETURNS SETOF "user"
LANGUAGE sql AS $$
    SELECT * FROM "user" WHERE idUser = p_idUser;
$$;

--CURRENT USER AUTH ID
CREATE OR REPLACE FUNCTION get_current_user()
RETURNS TABLE (
    idUser INT,
    first_name TEXT,
    last_name TEXT,
    role role_enum,
    authorization_status authorization_status_enum,
    account_status account_status_enum
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT 
        u.idUser,
        u.first_name,
        u.last_name,
        u.role,
        u.authorization_status,
        u.account_status
    FROM "user" u
    WHERE u.auth_id = auth.uid();
$$;
--SELECT user with institution or station view

CREATE OR REPLACE FUNCTION get_profile_()
RETURNS TABLE (
    idUser INT,
    first_name TEXT,
    last_name TEXT,
    role role_enum,
    institution_name TEXT,
    authorization_status authorization_status_enum,
    account_status account_status_enum
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT 
        u.idUser,
        u.first_name,
        u.last_name,
        u.role,
        i.name AS institution_name,
        u.authorization_status,
        u.account_status
    FROM "user" u
    LEFT JOIN institution i ON u.idUser = i.idUser
    JOIN network_user_station n on n.idUser= i.idUser
    WHERE u.auth_id = auth.uid();
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
    UPDATE "user"
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

--activar cuenta si estuvo inactiva , ya autorizado el registro
CREATE OR REPLACE FUNCTION activate_user(p_idUser INT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "user" SET account_status = 'activo'
    WHERE idUser = p_idUser;
END;
$$;

--inactivar cuenta usuario ya autorizaddo el registro
CREATE OR REPLACE FUNCTION deactivate_user(p_idUser INT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "user" SET account_status = 'inactivo'
    WHERE idUser = p_idUser;
END;
$$;

CREATE OR REPLACE FUNCTION authorize_user(p_idUser INT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "user" SET authorization_status = 'aprobado'
    WHERE idUser = p_idUser;
END;
$$;

-- DELETE
CREATE OR REPLACE FUNCTION delete_user(p_idUser INT)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM "user" WHERE idUser = p_idUser;
END;
$$;


--autorizar el registro de un usuario
CREATE OR REPLACE FUNCTION authorize_user_registration(_id INTEGER)
RETURNS VOID AS $$
BEGIN
  UPDATE user
  SET authorization_status = 'aprobado'
  SET account_status= 'activo'
  WHERE iduser = _id;
END;
$$ LANGUAGE plpgsql;

--rechazar el registro de un usuario
CREATE OR REPLACE FUNCTION reject_user_registration(_id INTEGER)
RETURNS VOID AS $$
BEGIN
  UPDATE user
  SET authorization_status = 'rechazado'

  WHERE iduser = _id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
