-- ============================================================
-- AUDITORÍA INVESTIGADOR - INSTITUTO
-- El instituto hace los cambios, no un administrador
-- ============================================================

CREATE OR REPLACE FUNCTION audit_researcher_institution_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    change_note TEXT;
BEGIN
    ----------------------------------------------------------------
    -- 1. INSERT → creación del vínculo
    ----------------------------------------------------------------
    IF TG_OP = 'INSERT' THEN

        INSERT INTO "audit_researcher_institution_log"(
            type_action,
            date_issue,
            idInstitution,
            idUser,
            notes
        )
        VALUES (
            'AGREGACION_INVESTIGADOR',
            NOW(),
            NEW.idInstitution,
            NEW.idUser,
            'Institución hace solicitud y agrega a investigador'
        );

        RETURN NEW;
    END IF;


    ----------------------------------------------------------------
    -- 2. CAMBIO DE STATUS
    ----------------------------------------------------------------
    IF NEW.status IS DISTINCT FROM OLD.status THEN
        
        change_note := format(
            'status: "%s" → "%s"',
            OLD.status,
            NEW.status
        );

        -- ACTIVADO
        IF NEW.status = 'activo' THEN
            INSERT INTO "audit_researcher_institution_log"(
                type_action, date_issue, idInstitution, idUser, notes
            )
            VALUES (
                'ACTIVACION',
                NOW(),
                NEW.idInstitution,
                NEW.idUser,
                change_note
            );

        -- DESACTIVADO
        ELSIF NEW.status = 'inactivo' THEN
            INSERT INTO "audit_researcher_institution_log"(
                type_action, date_issue, idInstitution, idUser, notes
            )
            VALUES (
                'DESACTIVACION',
                NOW(),
                NEW.idInstitution,
                NEW.idUser,
                change_note
            );

        -- ELIMINADO / EXPULSADO / REVOCADO
        ELSE
            INSERT INTO "audit_researcher_institution_log"(
                type_action, date_issue, idInstitution, idUser, notes
            )
            VALUES (
                'ELIMINACION',
                NOW(),
                NEW.idInstitution,
                NEW.idUser,
                change_note
            );
        END IF;

    END IF;

    RETURN NEW;
END;
$$;


-- ============================================================
-- TRIGGER FINAL
-- ============================================================

DROP TRIGGER IF EXISTS trg_research_institution_audit ON "research_from_institution";

CREATE TRIGGER trg_research_institution_audit
AFTER INSERT OR UPDATE
ON "research_from_institution"
FOR EACH ROW
EXECUTE FUNCTION audit_researcher_institution_trigger();
