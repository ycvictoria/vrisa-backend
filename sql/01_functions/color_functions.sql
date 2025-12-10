
---COLORS OF THE INSTITUTION
CREATE OR REPLACE FUNCTION update_color_generic(
    p_idInstitution INT,
    p_color1 TEXT DEFAULT NULL,
    p_color2 TEXT DEFAULT NULL,
    p_color3 TEXT DEFAULT NULL
)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "color"
    SET
        color_1 = COALESCE(p_color1, color_1),
        color_2 = COALESCE(p_color2, color_2),
        color_3 = COALESCE(p_color3, color_3)
    WHERE idInstitution = p_idInstitution;
END;
$$;
-- SELECT ALL
CREATE OR REPLACE FUNCTION get_colors()
RETURNS SETOF "color"
LANGUAGE sql AS $$
    SELECT * FROM "color";
$$;
