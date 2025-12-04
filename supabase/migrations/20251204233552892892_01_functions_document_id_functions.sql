-- ============================================================
-- DOCUMENT ID FUNCTIONS (CRUD + GENERIC UPDATE)

-- INSERT
CREATE OR REPLACE FUNCTION insert_document_id(
    p_idUser INT,
    p_document_type TEXT,
    p_document_number TEXT
)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO "document_id"(idUser, document_type, document_number)
    VALUES (p_idUser, p_document_type, p_document_number);
END;
$$;

-- SELECT ALL
CREATE OR REPLACE FUNCTION get_document_ids()
RETURNS SETOF "document_id"
LANGUAGE sql AS $$
    SELECT * FROM "document_id";
$$;

-- SELECT BY ID
CREATE OR REPLACE FUNCTION get_document_id_by_user(p_idUser INT)
RETURNS SETOF "document_id"
LANGUAGE sql AS $$
    SELECT * FROM "document_id" WHERE idUser = p_idUser;
$$;

-- GENERIC UPDATE
CREATE OR REPLACE FUNCTION update_document_id_generic(
    p_idUser INT,
    p_document_type TEXT DEFAULT NULL,
    p_document_number TEXT DEFAULT NULL
)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE "document_id"
    SET
        document_type = COALESCE(p_document_type, document_type),
        document_number = COALESCE(p_document_number, document_number)
    WHERE idUser = p_idUser;
END;
$$;

-- DELETE
CREATE OR REPLACE FUNCTION delete_document_id(p_idUser INT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM "document_id" WHERE idUser = p_idUser;
END;
$$;

-- ============================================================
