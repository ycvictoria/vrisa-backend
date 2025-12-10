-- ============================================================
--  SCHEMA  VRISA (todas las tablas)
-- ============================================================

CREATE TYPE authorization_status_enum AS ENUM (
    'pendiente',
    'aprobado',
    'rechazado'
);

CREATE TYPE account_status_enum AS ENUM (
    'activo',
    'inactivo',
    'suspendido'
);

CREATE TYPE role_enum AS ENUM (
    'admin',
    'researcher',
    'institution',
    'station',
    'citizen',
    'technician'
);

CREATE TABLE "user" (
    idUser SERIAL,
    auth_id UUID UNIQUE,  -- opcional, no FK para mock
    email TEXT UNIQUE NOT NULL,

    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    role role_enum NOT NULL,
    registration_date DATE NOT NULL DEFAULT NOW(),
    authorization_status authorization_status_enum NOT NULL,
    account_status account_status_enum NOT NULL,

    CONSTRAINT user_pk PRIMARY KEY (idUser),
    CONSTRAINT user_email_ck CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT user_firstname_ck CHECK (first_name <> ''),
    CONSTRAINT user_lastname_ck CHECK (last_name <> '')
);


DROP TABLE IF EXISTS login;

CREATE TABLE login (
    idLogin SERIAL PRIMARY KEY,
    idUser INT NOT NULL REFERENCES "user"(idUser),
    session_id UUID NOT NULL,
    login_time TIMESTAMP NOT NULL DEFAULT NOW(),
    logout_time TIMESTAMP,
    ip_address TEXT,
    user_agent TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT login_session_unique UNIQUE (session_id)
);


CREATE TABLE "institution" (
    idInstitution SERIAL,
    name TEXT NOT NULL,
    logo TEXT NOT NULL,
    idUser INT NOT NULL,
    address TEXT NOT NULL,
    CONSTRAINT institution_pk PRIMARY KEY (idInstitution),
    CONSTRAINT institution_user_fk FOREIGN KEY (idUser) REFERENCES "user"(idUser),
    CONSTRAINT institution_name_ck CHECK (name <> ''),
    CONSTRAINT institution_logo_ck CHECK (logo <> ''),
    CONSTRAINT institution_address_ck CHECK (address <> '')
);
--attribute for institution's color.
CREATE TABLE "color" (
    idInstitution INT,
    color_1 TEXT NOT NULL,
    color_2 TEXT NOT NULL,
    color_3 TEXT NOT NULL,
    CONSTRAINT color_pk PRIMARY KEY (idInstitution),
    CONSTRAINT color_institution_fk FOREIGN KEY (idInstitution) REFERENCES "institution"(idInstitution),
    CONSTRAINT color_1_ck CHECK (color_1 <> ''),
    CONSTRAINT color_2_ck CHECK (color_2 <> ''),
    CONSTRAINT color_3_ck CHECK (color_3 <> '')
);
--N:N which research belong to which institution
CREATE TABLE "research_from_institution" (
    idInstitution INT NOT NULL,
    idUser INT NOT NULL,
    state TEXT NOT NULL,
    date_issue VARCHAR NOT NULL,
    CONSTRAINT research_from_institution_pk PRIMARY KEY (idInstitution, idUser),
    CONSTRAINT rfi_institution_fk FOREIGN KEY (idInstitution) REFERENCES "institution"(idInstitution),
    CONSTRAINT rfi_user_fk FOREIGN KEY (idUser) REFERENCES "user"(idUser),
    CONSTRAINT rfi_state_ck CHECK (state <> '')
);

CREATE TABLE "document_id" (
    idUser INT,
    document_type TEXT NOT NULL,
    document_number TEXT NOT NULL,
    CONSTRAINT document_id_pk PRIMARY KEY (idUser),
    CONSTRAINT document_id_user_fk FOREIGN KEY (idUser) REFERENCES "user"(idUser),
    CONSTRAINT document_id_type_ck CHECK (document_type <> ''),
    CONSTRAINT document_id_number_ck CHECK (document_number <> '')
);

CREATE TABLE "station" (
    idStation SERIAL,
    name TEXT NOT NULL,
    status TEXT NOT NULL,
    opening_date DATE NOT NULL,
    closing_date DATE,
    idTechnician INT NOT NULL,
    CONSTRAINT station_pk PRIMARY KEY (idStation),
    CONSTRAINT station_user_fk FOREIGN KEY (idTechnician) REFERENCES "user"(idUser),
    CONSTRAINT station_name_ck CHECK (name <> ''),
    CONSTRAINT station_status_ck CHECK (status <> ''),
    CONSTRAINT station_dates_ck CHECK (closing_date IS NULL OR closing_date > opening_date)
);

--attribute ubication of the institution
CREATE TABLE "ubication" (
    idStation INT,
    latitude FLOAT NOT NULL,
    longitude FLOAT NOT NULL,
    address TEXT NOT NULL,
    CONSTRAINT ubication_pk PRIMARY KEY (idStation),
    CONSTRAINT ubication_station_fk FOREIGN KEY (idStation) REFERENCES "station"(idStation),
    CONSTRAINT ubication_latitude_ck CHECK (latitude BETWEEN -90 AND 90),
    CONSTRAINT ubication_longitude_ck CHECK (longitude BETWEEN -180 AND 180),
    CONSTRAINT ubication_address_ck CHECK (address <> '')
);

CREATE TABLE "sensor" (
    idSensor SERIAL,
    brand TEXT NOT NULL,
    model TEXT NOT NULL,
    type TEXT NOT NULL,
    status TEXT NOT NULL,
    installation_date DATE NOT NULL,
    idStation INT NOT NULL,
    CONSTRAINT sensor_pk PRIMARY KEY (idSensor),
    CONSTRAINT sensor_station_fk FOREIGN KEY (idStation) REFERENCES "station"(idStation),
    CONSTRAINT sensor_brand_ck CHECK (brand <> ''),
    CONSTRAINT sensor_model_ck CHECK (model <> ''),
    CONSTRAINT sensor_type_ck CHECK (type <> ''),
    CONSTRAINT sensor_status_ck CHECK (status <> ''),
    CONSTRAINT sensor_installation_date_ck CHECK (installation_date <= NOW())
);

CREATE TABLE "variable" (
    idVariable SERIAL,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    description TEXT NOT NULL,
    measurement_unit TEXT NOT NULL,
    range_min FLOAT NOT NULL,
    range_max FLOAT NOT NULL,
    CONSTRAINT variable_pk PRIMARY KEY (idVariable),
    CONSTRAINT variable_range_ck CHECK (range_min < range_max),
    CONSTRAINT variable_name_ck CHECK (name <> ''),
    CONSTRAINT variable_category_ck CHECK (category <> ''),
    CONSTRAINT variable_unit_ck CHECK (measurement_unit <> '')
);

 --SENSOR-VARIABLE (N:N) 
CREATE TABLE "measurement" (
    idMeasurement SERIAL,
    value FLOAT NOT NULL,
    timestamp_measure TIMESTAMP NOT NULL,
    idSensor INT NOT NULL,
    idParameter INT NOT NULL,
    CONSTRAINT measurement_pk PRIMARY KEY (idMeasurement),
    CONSTRAINT measurement_sensor_fk FOREIGN KEY (idSensor) REFERENCES "sensor"(idSensor),
    CONSTRAINT measurement_variable_fk FOREIGN KEY (idParameter) REFERENCES "variable"(idVariable),
    CONSTRAINT measurement_timestamp_ck CHECK (timestamp_measure <= NOW())
);

CREATE TABLE "maintenance" (
    idMaintenance SERIAL,
    maintenance_date DATE NOT NULL,
    type_maintenance TEXT NOT NULL,
    description TEXT NOT NULL,
    certificated_documents_url TEXT NOT NULL,
    technician_in_charge INT NOT NULL,
    idSensor INT NOT NULL,
    CONSTRAINT maintenance_pk PRIMARY KEY (idMaintenance),
    CONSTRAINT maintenance_user_fk FOREIGN KEY (technician_in_charge) REFERENCES "user"(idUser),
    CONSTRAINT maintenance_sensor_fk FOREIGN KEY (idSensor) REFERENCES "sensor"(idSensor),
    CONSTRAINT maintenance_type_ck CHECK (type_maintenance <> ''),
    CONSTRAINT maintenance_description_ck CHECK (description <> ''),
    CONSTRAINT maintenance_url_ck CHECK (certificated_documents_url <> '')
);

CREATE TABLE "alert" (
    idAlert SERIAL,
    alert_type TEXT NOT NULL,
    level TEXT NOT NULL,
    description TEXT NOT NULL,
    issued_date TIMESTAMP NOT NULL,
    idMeasurement INT NOT NULL,
    CONSTRAINT alert_pk PRIMARY KEY (idAlert),
    CONSTRAINT alert_measurement_fk FOREIGN KEY (idMeasurement) REFERENCES "measurement"(idMeasurement),
    CONSTRAINT alert_type_ck CHECK (alert_type <> ''),
    CONSTRAINT alert_level_ck CHECK (level <> ''),
    CONSTRAINT alert_description_ck CHECK (description <> '')
);

--network ->  user - station (N:N)
CREATE TABLE "network_user_station" (
    idUser INT NOT NULL,
    idStation INT NOT NULL,
    date_issue DATE NOT NULL,
    date_registration DATE NOT NULL,
    status TEXT NOT NULL,
    CONSTRAINT network_user_station_pk PRIMARY KEY (idUser, idStation),
    CONSTRAINT nus_user_fk FOREIGN KEY (idUser) REFERENCES "user"(idUser),
    CONSTRAINT nus_station_fk FOREIGN KEY (idStation) REFERENCES "station"(idStation),
    CONSTRAINT nus_dates_ck CHECK (date_registration >= date_issue),
    CONSTRAINT nus_status_ck CHECK (status <> '')
);

--for triggers to log information 

CREATE TABLE "audit_users_log" (
    idAudit SERIAL,
    type_action TEXT NOT NULL,
    date_issue TIMESTAMP NOT NULL DEFAULT NOW(),
    idAdmin INT NOT NULL REFERENCES "user"(idUser),
    idUser INT NOT NULL REFERENCES "user"(idUser),
    notes TEXT NOT NULL,
    CONSTRAINT audit_users_log_pk PRIMARY KEY (idAudit)
);

CREATE TABLE "audit_researcher_institution_log" (
    idInstitution INT NOT NULL REFERENCES "institution"(idInstitution),
    idUser INT NOT NULL REFERENCES "user"(idUser),
    type_action TEXT NOT NULL,
    date_issue VARCHAR NOT NULL,
    notes TEXT NOT NULL,
    CONSTRAINT audit_researcher_institution_log_pk PRIMARY KEY (idInstitution, idUser)
);

CREATE TABLE "audit_network_log" (
    idAuditNetwork SERIAL,
    idUser INT NOT NULL REFERENCES "user"(idUser),
    idStation INT NOT NULL REFERENCES "station"(idStation),
    date_issue DATE NOT NULL,
    type_action TEXT NOT NULL,
    notes TEXT NOT NULL,
    CONSTRAINT audit_network_log_pk PRIMARY KEY (idAuditNetwork)
);

CREATE TABLE "audit_userdata_changes_log" (
    idUserChange SERIAL,
    idUser INT NOT NULL REFERENCES "user"(idUser),
    type_action TEXT NOT NULL,
    date_issue VARCHAR NOT NULL,
    notes TEXT NOT NULL,
    CONSTRAINT audit_userdata_changes_log_pk PRIMARY KEY (idUserChange)
);
