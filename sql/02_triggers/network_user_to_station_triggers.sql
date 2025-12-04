-- ============================================================
-- AUDITORÍA DE ACCESO A ESTACIONES (Network_User_Station)
-- Registra: solicitud, aprobación y eliminación de acceso
-- ============================================================

CREATE OR REPLACE FUNCTION audit_network_user_station_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    change_note TEXT;
BEGIN
    ----------------------------------------------------------------
    -- 1. INSERT → solicitud de acceso
    ----------------------------------------------------------------
    IF TG_OP = 'INSERT' THEN

        INSERT INTO "Audit_network_log"(
            idUser,
            idStation,
            date_issue,
            type_action,
            notes
        )
        VALUES (
            NEW.idUser,
            NEW.idStation,
            NOW(),
            'SOLICITUD',
            'Usuario o institución solicitó acceso a la estación'
        );

        RETURN NEW;
    END IF;


    ----------------------------------------------------------------
    -- 2. CAMBIO EN STATUS → aprobación o eliminación
    ----------------------------------------------------------------
    IF NEW.status IS DISTINCT FROM OLD.status THEN
        
        change_note := format(
            'status: "%s" → "%s"',
            OLD.status,
            NEW.status
        );

        -- APROBACIÓN
        IF NEW.status = 'aprobado' THEN
            INSERT INTO "Audit_network_log"(
                idUser, idStation, date_issue, type_action, notes
            )
            VALUES (
                NEW.idUser,
                NEW.idStation,
                NOW(),
                'APROBACION',
                change_note
            );

-- SUSPENSIÓN
        ELSIF NEW.status = 'suspendido' THEN
            INSERT INTO "Audit_network_log"(
                idUser, idStation, date_issue, type_action, notes
            )
            VALUES (
                NEW.idUser,
                NEW.idStation,
                NOW(),
                'SUSPENSION',
                change_note
            );

        -- ELIMINACIÓN / REVOCACIÓN / CANCELACIÓN
        ELSIF NEW.status IN ('eliminado', 'revocado', 'inactivo') THEN
            INSERT INTO "Audit_network_log"(
                idUser, idStation, date_issue, type_action, notes
            )
            VALUES (
                NEW.idUser,
                NEW.idStation,
                NOW(),
                'INACTIVACION',
                change_note
            );

        END IF;

    END IF;


    RETURN NEW;
END;
$$;


CREATE TRIGGER trg_network_access_audit
AFTER INSERT OR UPDATE
ON "Network_User_Station"
FOR EACH ROW
EXECUTE FUNCTION audit_network_user_station_trigger();

-- ============================================================