-- ============================================================
--TRIGGERS FOR USER



-- ============================================================
-- Crear auth id fot the new user
-- ============================================================
CREATE OR REPLACE FUNCTION create_profile_from_auth()
RETURNS trigger AS $$
BEGIN
  INSERT INTO "user" (
      auth_id, first_name, last_name, role,
      authorization_status, account_status
  )
  VALUES (
      NEW.id, '', '', 'citizen',
      'pendiente', 'activo'
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_auth_signup
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION create_profile_from_auth();

-- ============================================================
-- AUDITORÍA DE CAMBIOS DE ESTADOS DEL USUARIO POR ADMIN
-- ============================================================
CREATE OR REPLACE FUNCTION user_admin_audit_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    v_admin_id INT;
    change_note TEXT;
BEGIN
    -- Obtener ID del administrador desde variable de sesión
    BEGIN
        v_admin_id := current_setting('vr.admin_id', true)::INT;
    EXCEPTION WHEN others THEN
        v_admin_id := NULL;
    END;

    ----------------------------------------------------------------
    -- 0. INSERT: CREACION DE CUENTA
    ----------------------------------------------------------------
    IF TG_OP = 'INSERT' THEN
        
        INSERT INTO audit_users_log(
            type_action,
            date_issue,
            idAdmin,
            idUser,
            notes
        ) VALUES (
            'CREACION_CUENTA',
            NOW(),
            COALESCE(v_admin_id, 1),   
            NEW.idUser,
            'Se creó una nueva cuenta'
        );

        RETURN NEW;
    END IF;


    ----------------------------------------------------------------
    -- 1. CAMBIO EN authorization_status
    ----------------------------------------------------------------
    IF NEW.authorization_status IS DISTINCT FROM OLD.authorization_status THEN
        change_note := format(
            'authorization_status: "%s" → "%s"',
            OLD.authorization_status,
            NEW.authorization_status
        );

        INSERT INTO audit_users_log(
            type_action, date_issue, idAdmin, idUser, notes
        ) VALUES (
            'CAMBIO_REGISTRO',
            NOW(),
            COALESCE(v_admin_id, 1),  
            NEW.idUser,
            change_note
        );
    END IF;


    ----------------------------------------------------------------
    -- 2. CAMBIO EN account_status
    ----------------------------------------------------------------
    IF NEW.account_status IS DISTINCT FROM OLD.account_status THEN
        change_note := format(
            'account_status: "%s" → "%s"',
            OLD.account_status,
            NEW.account_status
        );

        INSERT INTO audit_users_log(
            type_action, date_issue, idAdmin, idUser, notes
        ) VALUES (
            'CAMBIO_ESTADO',
            NOW(),
            COALESCE(v_admin_id, 1),  -- 👈 FIX
            NEW.idUser,
            change_note
        );
    END IF;


    RETURN NEW;
END;
$$;

--nombre trigger
CREATE TRIGGER user_admin_audit_trigger
AFTER UPDATE ON "user"
FOR EACH ROW
EXECUTE FUNCTION user_admin_audit_trigger();
-- ============================================================
-- AUDITORÍA DE CAMBIOS DE DATOS PERSONALES DEL USUARIO
-- ============================================================

CREATE OR REPLACE FUNCTION audit_userdata_changes_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    changes TEXT := '';
BEGIN
 
    ----------------------------------------------------------------
    -- 1. CAMBIOS EN DATOS PERSONALES
    ----------------------------------------------------------------
    IF NEW.first_name IS DISTINCT FROM OLD.first_name THEN
        changes := changes || format('first_name: "%s" → "%s"; ', OLD.first_name, NEW.first_name);
    END IF;

    IF NEW.last_name IS DISTINCT FROM OLD.last_name THEN
        changes := changes || format('last_name: "%s" → "%s"; ', OLD.last_name, NEW.last_name);
    END IF;

    IF NEW.email IS DISTINCT FROM OLD.email THEN
        changes := changes || format('email: "%s" → "%s"; ', OLD.email, NEW.email);
    END IF;


    ----------------------------------------------------------------
    -- 1. Registrar los cambios de datos personales (si existieron)
    ----------------------------------------------------------------
    IF changes <> '' THEN
        
        INSERT INTO "audit_userdata_changes_log"(
            idUser,
            type_action,
            date_issue,
            notes
        )
        VALUES (
            NEW.idUser,
            'CAMBIO_DATOS',
            NOW()::TEXT,
            changes
        );

    END IF;

    RETURN NEW;
END;
$$;


CREATE TRIGGER trg_userdata_changes
AFTER UPDATE
ON "user"
FOR EACH ROW
EXECUTE FUNCTION audit_userdata_changes_trigger();

-- ============================================================

-- ============================================================
-- AUDITORÍA DE CAMBIOS EN DOCUMENTO DE IDENTIDAD
-- ============================================================

CREATE OR REPLACE FUNCTION audit_document_id_changes_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    changes TEXT := '';
BEGIN
    ----------------------------------------------------------------
    -- 1. CAMBIO EN TIPO DE DOCUMENTO
    ----------------------------------------------------------------
    IF NEW.document_type IS DISTINCT FROM OLD.document_type THEN
        changes := changes || format(
            'document_type: "%s" → "%s"; ',
            OLD.document_type,
            NEW.document_type
        );
    END IF;

    ----------------------------------------------------------------
    -- 2. CAMBIO EN NÚMERO DE DOCUMENTO
    ----------------------------------------------------------------
    IF NEW.document_number IS DISTINCT FROM OLD.document_number THEN
        changes := changes || format(
            'document_number: "%s" → "%s"; ',
            OLD.document_number,
            NEW.document_number
        );
    END IF;


    ----------------------------------------------------------------
    -- 3. REGISTRAR CAMBIOS (si existieron)
    ----------------------------------------------------------------
    IF changes <> '' THEN

        INSERT INTO "audit_userdata_changes_log"(
            idUser,
            type_action,
            date_issue,
            notes
        )
        VALUES (
            NEW.idUser,
            'CAMBIO_DOCUMENTO',
            NOW()::TEXT,
            changes
        );

    END IF;

    RETURN NEW;
END;
$$;



DROP TRIGGER IF EXISTS trg_document_id_changes ON "document_id";

CREATE TRIGGER trg_document_id_changes
AFTER UPDATE
ON "document_id"
FOR EACH ROW
EXECUTE FUNCTION audit_document_id_changes_trigger();

-- ============================================================