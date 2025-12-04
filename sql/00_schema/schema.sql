-- ============================================================
--  SCHEMA COMPLETO VRISA (todas las tablas)
-- ============================================================

-- ============================
-- TABLE: User

CREATE TABLE User (
    idUser SERIAL PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    role TEXT,
    registration_date DATE,
    authorization_status TEXT,
    account_status TEXT
);

-- ============================
-- TABLE: Login (1:1 User)
CREATE TABLE Login (
    idUser INT PRIMARY KEY REFERENCES "User"(idUser),
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    token TEXT,
    last_access DATE,
    is_active BOOLEAN DEFAULT TRUE
);

-- ============================
-- TABLE: Institution

CREATE TABLE Institution (
    idInstitution SERIAL PRIMARY KEY,
    name TEXT,
    logo TEXT,
    address TEXT,
    idUser INT REFERENCES "User"(idUser)
);

-- ============================
-- TABLE: Color (1:1 Institution) Attribute

CREATE TABLE Color (
    idInstitution INT PRIMARY KEY REFERENCES "Institution"(idInstitution),
    color_1 TEXT,
    color_2 TEXT,
    color_3 TEXT
);

-- ============================
-- TABLE: Research_From_Institution (N:N)

CREATE TABLE Research_From_Institution (
    idInstitution INT REFERENCES "Institution"(idInstitution),
    idUser INT REFERENCES "User"(idUser),
    state TEXT,
    date_issue VARCHAR,
    PRIMARY KEY (idInstitution, idUser)
);

-- ============================
-- TABLE: document_id (1:1 User)

CREATE TABLE document_id (
    idUser INT PRIMARY KEY REFERENCES "User"(idUser),
    document_type TEXT,
    document_number TEXT
);

-- ============================
-- TABLE: Station
CREATE TABLE Station (
    idStation SERIAL PRIMARY KEY,
    name TEXT,
    status TEXT,
    opening_date DATE,
    closing_date DATE,
    idTechnician INT REFERENCES "User"(idUser)
);

-- ============================
-- TABLE: Ubication (1:1 Station)

CREATE TABLE Ubication (
    idStation INT PRIMARY KEY REFERENCES "Station"(idStation),
    latitude FLOAT,
    longitude FLOAT,
    address TEXT
);

-- ============================
-- TABLE: Sensor

CREATE TABLE Sensor (
    idSensor SERIAL PRIMARY KEY,
    brand TEXT,
    model TEXT,
    type TEXT,
    status TEXT,
    installation_date DATE,
    idStation INT REFERENCES "Station"(idStation)
);

-- ============================
-- TABLE: Variable

CREATE TABLE Variable (
    idVariable SERIAL PRIMARY KEY,
    name TEXT,
    category TEXT,
    description TEXT,
    measurement_unit TEXT,
    range_min FLOAT,
    range_max FLOAT
);

-- ============================
-- TABLE: Measurement N:N
CREATE TABLE Measurement (
    idMeasurement SERIAL PRIMARY KEY,
    value FLOAT,
    timestamp_measure TIMESTAMP,
    idSensor INT REFERENCES "Sensor"(idSensor),
    idParameter INT REFERENCES "Variable"(idVariable)
);

-- ============================
-- TABLE: Maintenance

CREATE TABLE Maintenance (
    idMaintenance SERIAL PRIMARY KEY,
    maintenance_date DATE,
    type_maintenance TEXT,
    description TEXT,
    certificated_documents_url TEXT,
    technician_in_charge INT REFERENCES "User"(idUser),
    idSensor INT REFERENCES "Sensor"(idSensor)
);

-- ============================
-- TABLE: Alert

CREATE TABLE Alert (
    idAlert SERIAL PRIMARY KEY,
    alert_type TEXT,
    level TEXT,
    description TEXT,
    issued_date TIMESTAMP,
    idMeasurement INT REFERENCES "Measurement"(idMeasurement)
);

-- ============================
-- TABLE: Network_User_Station (N:N)

CREATE TABLE Network_User_Station (
    idUser INT REFERENCES "User"(idUser),
    idStation INT REFERENCES "Station"(idStation),
    date_issue DATE,
    date_registration DATE,
    status TEXT,
    PRIMARY KEY (idUser, idStation)
);

-- ============================
-- AUDIT TABLES


CREATE TABLE "Audit_users_log" (
    idAudit SERIAL PRIMARY KEY,
    type_action TEXT,
    date_issue TIMESTAMP DEFAULT NOW(),
    idAdmin INT REFERENCES "User"(idUser),
    idUser INT REFERENCES "User"(idUser),
    notes TEXT
);

CREATE TABLE Audit_researcher_institution_log (
    idInstitution INT REFERENCES "Institution"(idInstitution),
    idUser INT REFERENCES "User"(idUser),
    type_action TEXT,
    date_issue VARCHAR,
    notes TEXT,
    PRIMARY KEY (idInstitution, idUser)
);

CREATE TABLE Audit_network_log (
    idAuditNetwork SERIAL PRIMARY KEY,
    idUser INT REFERENCES "User"(idUser),
    idStation INT REFERENCES "Station"(idStation),
    date_issue DATE,
    type_action TEXT,
    notes TEXT
);

CREATE TABLE Audit_userdata_changes_log (
    idUserChange SERIAL PRIMARY KEY,
    idUser INT REFERENCES "User"(idUser),
    type_action TEXT,
    date_issue VARCHAR,
    notes TEXT
);
