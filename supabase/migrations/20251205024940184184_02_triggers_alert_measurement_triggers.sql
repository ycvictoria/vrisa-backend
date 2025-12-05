-- ============================================================
-- TRIGGER DE ALERTAS AUTOMÁTICAS POR MEDICIONES FUERA DE RANGO
-- ============================================================

CREATE OR REPLACE FUNCTION trigger_measurement_alert()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    v_min FLOAT;
    v_max FLOAT;
    v_param_name TEXT;
    v_level TEXT;
    v_description TEXT;
BEGIN
    -- Obtener los rangos de la variable asociada
    SELECT range_min, range_max, name
    INTO v_min, v_max, v_param_name
    FROM "variable"
    WHERE idVariable = NEW.idParameter;

    -- Si no existe la variable, no crear alerta
    IF v_min IS NULL OR v_max IS NULL THEN
        RETURN NEW;
    END IF;


    ----------------------------------------------------------------
    -- 1. DETERMINAR SI EL VALOR ESTÁ FUERA DE RANGO
    ----------------------------------------------------------------
    IF NEW.value < v_min THEN
        
        v_level := 'warning';
        v_description := format(
            'Valor por debajo del mínimo permitido (%s < %s) en parámetro: %s',
            NEW.value, v_min, v_param_name
        );

        -- Insertar alerta
        INSERT INTO "alert"(
            alert_type,
            level,
            description,
            issued_date,
            idMeasurement
        ) VALUES (
            'BAJA CONCENTRACIÓN',
            v_level,
            v_description,
            NOW(),
            NEW.idMeasurement
        );

    ELSIF NEW.value > v_max THEN
        
        v_level := 'critical';
        v_description := format(
            'Valor por encima del máximo permitido (%s > %s) en parámetro: %s',
            NEW.value, v_max, v_param_name
        );

        INSERT INTO "alert"(
            alert_type,
            level,
            description,
            issued_date,
            idMeasurement
        ) VALUES (
            'ALTA CONCENTRACIÓN',
            v_level,
            v_description,
            NOW(),
            NEW.idMeasurement
        );

    END IF;


    RETURN NEW;
END;
$$;



DROP TRIGGER IF EXISTS trg_measurement_alert ON "measurement";

CREATE TRIGGER trg_measurement_alert
AFTER INSERT
ON "measurement"
FOR EACH ROW
EXECUTE FUNCTION trigger_measurement_alert();

-- ============================================================