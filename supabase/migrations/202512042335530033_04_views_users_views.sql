-- ============================================================
-- 1) USERS QUE SON RESEARCHERS Y PERTENECEN A UNA INSTITUCIÓN
-- ============================================================

CREATE OR REPLACE VIEW users_researcher_institution AS
SELECT 
    u.idUser,
    u.first_name,
    u.last_name,
    u.role,
    u.authorization_status,
    u.account_status,
    rfi.idInstitution,
    i.name AS institution_name,
    i.address AS institution_address
FROM "user" u
JOIN research_from_institution rfi ON u.idUser = rfi.idUser
JOIN institution i ON rfi.idInstitution = i.idInstitution
WHERE u.role = 'researcher';


-- USER ↔ STATION
-- ============================================================

CREATE OR REPLACE VIEW user_stations AS
SELECT 
    u.idUser,
    u.first_name,
    u.last_name,
    u.role,
    st.idStation,
    st.name AS station_name,
    st.status AS station_status,
    nus.date_issue,
    nus.date_registration,
    nus.status AS relation_status
FROM network_user_station nus
JOIN "user" u ON nus.idUser = u.idUser
JOIN station st ON nus.idStation = st.idStation
ORDER BY u.idUser, st.idStation;

-- ============================================================
-- 2) USERS EN ESTADO "PENDIENTE"
-- ============================================================

CREATE OR REPLACE VIEW users_pendientes AS
SELECT 
    idUser,
    first_name,
    last_name,
    role,
    registration_date,
    authorization_status,
    account_status
FROM "user"
WHERE authorization_status = 'pendiente';

-- 2) USERS EN ESTADO "PENDIENTE"
-- ============================================================

CREATE OR REPLACE VIEW all_users AS
SELECT 
    idUser,
    first_name,
    last_name,
    role,
    registration_date,
    authorization_status,
    account_status
FROM "user";