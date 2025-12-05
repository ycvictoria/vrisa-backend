BEGIN;

-- ============================================================
-- USERS (20)
-- ============================================================

--adicionando el primer admin
INSERT INTO "user" (
    auth_id, email, first_name, last_name, role, authorization_status, account_status
) VALUES (
    
    gen_random_uuid(),
    'admin@vrisa.com',
    'System',
    'Administrator',
    'admin',
    'aprobado',
    'activo'
);


--ahora los usuarios
INSERT INTO "user" (
    auth_id, email, first_name, last_name, role, authorization_status, account_status
)
VALUES
--(NULL,'admin@vrisa.com','Santiago','Valencia','admin','aprobado','activo'),          -- 1
(NULL,'carlos@vrisa.com','Carlos','Mosquera','technician','aprobado','activo'),      -- 2
(NULL,'luisa@vrisa.com','Luisa','Patiño','technician','aprobado','activo'),          -- 3
(NULL,'valeria@vrisa.com','Valeria','Rodríguez','researcher','aprobado','activo'),   -- 4
(NULL,'julian@vrisa.com','Julián','Castro','researcher','aprobado','activo'),         -- 5
(NULL,'lopera@univalle.edu','María','Lopera','institution','aprobado','activo'),      -- 6
(NULL,'emora@cvc.gov','Esteban','Mora','institution','aprobado','activo'),            -- 7
(NULL,'mgomez@mail.com','María','Gómez','citizen','aprobado','activo'),               -- 8
(NULL,'andres.bolanos@mail.com','Andrés','Bolaños','citizen','aprobado','activo'),    -- 9
(NULL,'daniela.barona@mail.com','Daniela','Barona','citizen','aprobado','activo'),    -- 10
(NULL,'jorge.salazar@vrisa.com','Jorge','Salazar','technician','aprobado','activo'),  -- 11
(NULL,'cmejia@univalle.edu','Carolina','Mejía','researcher','aprobado','activo'),     -- 12
(NULL,'felipearis@mail.com','Felipe','Aristizábal','citizen','aprobado','activo'),    -- 13
(NULL,'paola.v@vrisa.com','Paola','Villarreal','technician','aprobado','activo'),     -- 14
(NULL,'rbelalcazar@cvc.gov','Ricardo','Belalcázar','institution','aprobado','activo'),-- 15
(NULL,'ananavarro@mail.com','Ana','Navarro','citizen','aprobado','activo'),           -- 16
(NULL,'camilo.rivas@univalle.edu','Camilo','Rivas','researcher','aprobado','activo'), -- 17
(NULL,'susana.perico@mail.com','Susana','Perico','citizen','aprobado','activo'),      -- 18
(NULL,'oscar.t@vrisa.com','Oscar','Trejos','technician','aprobado','activo'),         -- 19
(NULL,'mateo.torres@univalle.edu','Mateo','Torres','researcher','aprobado','activo'); -- 20


-- ============================================================
-- SESSION LOGIN HISTORY
-- ============================================================
INSERT INTO login (idUser, session_id, ip_address, user_agent)
VALUES
(1, gen_random_uuid(), '181.55.100.21', 'Chrome / Windows'),
(2, gen_random_uuid(), '186.80.210.12', 'Chrome / Android'),
(3, gen_random_uuid(), '190.0.43.15', 'Firefox / Ubuntu'),
(4, gen_random_uuid(), '45.233.110.9', 'Safari / iPhone'),
(5, gen_random_uuid(), '186.28.17.4', 'Chrome / macOS');


-- ============================================================
-- DOCUMENT ID
-- ============================================================
INSERT INTO document_id(idUser, document_type, document_number)
VALUES
(1,'CC','1145893021'),
(2,'CC','1145899988'),
(4,'CC','1154872201'),
(5,'CC','1105892201'),
(6,'NIT','900123456'),
(7,'NIT','901456789');


-- ============================================================
-- INSTITUTIONS
-- ============================================================
INSERT INTO institution(name, logo, address, idUser)
VALUES
('Universidad del Valle','logo_univalle.png','Calle 13 #100-00, Meléndez, Cali',6),
('CVC – Regional Sur','logo_cvc.png','Av 2 Norte #23N-30, Santa Mónica, Cali',7);


-- ============================================================
-- INSTITUTION COLORS
-- ============================================================
INSERT INTO color(idInstitution, color_1, color_2, color_3)
VALUES
(1,'#cc0000','#ffffff','#000000'),
(2,'#008000','#ffffff','#004000');


-- ============================================================
-- RESEARCHER ↔ INSTITUTION (N:N)
-- ============================================================
INSERT INTO research_from_institution(idInstitution, idUser, state, date_issue)
VALUES
(1,4,'activo','2024-11-15'),
(1,5,'activo','2024-12-02'),
(2,12,'activo','2024-12-10'),
(2,17,'activo','2024-12-15');


-- ============================================================
-- STATIONS (10 barrios de Cali)
-- ============================================================
INSERT INTO station(name, status, opening_date, idTechnician)
VALUES
('San Antonio','active','2023-01-01',2),
('Ciudad Jardín','active','2023-03-15',3),
('Aguablanca','active','2023-02-10',11),
('La Flora','active','2023-04-20',14),
('Pance','active','2023-06-01',2),
('Siloé','active','2023-07-10',3),
('Valle del Lili','active','2023-08-05',11),
('Alfonso López','active','2023-09-01',14),
('El Ingenio','active','2023-10-20',19),
('Salomia','active','2023-11-15',3);


-- ============================================================
-- UBICATIONS
-- ============================================================
INSERT INTO ubication(idStation, latitude, longitude, address)
VALUES
(1,3.4516,-76.5320,'Cerro San Antonio'),
(2,3.3418,-76.5290,'Av Cañasgordas, Ciudad Jardín'),
(3,3.4172,-76.4857,'Calle 72W, Aguablanca'),
(4,3.4728,-76.5296,'Av 3N #36-00, La Flora'),
(5,3.3050,-76.6290,'Vía a Pance'),
(6,3.4405,-76.5533,'Barrio Siloé'),
(7,3.3725,-76.5312,'Valle del Lili'),
(8,3.4501,-76.4940,'Alfonso López'),
(9,3.3692,-76.5318,'El Ingenio'),
(10,3.4441,-76.5032,'Salomia');


-- ============================================================
-- VARIABLES (meteorológicas + contaminantes)
-- ============================================================
INSERT INTO variable(name, category, description, measurement_unit, range_min, range_max)
VALUES
('temperatura','meteorologica','Temperatura ambiente','°C',-10,50),
('humedad','meteorologica','Humedad relativa','%',0,100),
('presion_atmosferica','meteorologica','Presión atmosférica','hPa',900,1100),
('direccion_viento','meteorologica','Dirección del viento','°',0,360),
('velocidad_viento','meteorologica','Velocidad del viento','m/s',0,50),
('aqi','meteorologica','Índice calidad del aire','AQI',0,500),

('pm25','contaminante','Partículas finas PM2.5','µg/m³',0,500),
('pm10','contaminante','Partículas PM10','µg/m³',0,600),
('co','contaminante','Monóxido de carbono','ppm',0,50),
('so2','contaminante','Dióxido de azufre','ppb',0,500),
('o3','contaminante','Ozono','ppb',0,300),
('no2','contaminante','Dióxido de nitrógeno','ppb',0,500);


-- ============================================================
-- SENSORS (consistentes con estaciones y variables)
-- ============================================================
INSERT INTO sensor(brand, model, type, status, installation_date, idStation)
VALUES
-- San Antonio (1)
('Davis','VP2','temperatura','active','2023-01-02',1),
('Davis','VP2','humedad','active','2023-01-02',1),
('Davis','VP2','presion_atmosferica','active','2023-01-02',1),
('Gill','WindSonic','direccion_viento','active','2023-01-02',1),
('Gill','WindSonic','velocidad_viento','active','2023-01-02',1),

-- Ciudad Jardín (2)
('Honeywell','HPMA115','pm25','active','2023-03-16',2),
('Honeywell','HPMA115','pm10','active','2023-03-16',2),
('Bosch','AirPro','co','active','2023-03-16',2),
('Bosch','AirPro','so2','active','2023-03-16',2),
('EnviroTech','WX300','aqi','active','2023-03-16',2),

-- Aguablanca (3)
('Davis','Vue','temperatura','active','2023-02-12',3),
('Davis','Vue','humedad','active','2023-02-12',3),
('Honeywell','HPMA','pm25','active','2023-02-12',3),
('Bosch','AirPro','no2','active','2023-02-12',3),

-- La Flora (4)
('Philips','AirSense','o3','active','2023-04-25',4),
('EnviroTech','WX300','aqi','active','2023-04-25',4),

-- Pance (5)
('Davis','Vue','temperatura','active','2023-06-02',5),
('Davis','Vue','humedad','active','2023-06-02',5),
('Davis','Vue','precipitacion','active','2023-06-02',5);


-- ============================================================
-- N:N USER ↔ STATION
-- ============================================================
INSERT INTO network_user_station(idUser,idStation,date_issue,date_registration,status)
VALUES
(2,1,'2024-01-01','2024-01-05','activo'),
(3,2,'2024-01-10','2024-01-12','activo'),
(4,3,'2024-02-10','2024-02-12','activo'),
(5,4,'2024-03-05','2024-03-07','activo'),
(8,5,'2024-04-01','2024-04-02','activo');


-- ============================================================
-- AUDIT USERS LOG
-- ============================================================
INSERT INTO audit_users_log(type_action, idAdmin, idUser, notes)
VALUES
('CREACION','1','2','Cuenta creada por administrador'),
('CREACION','1','3','Cuenta creada por administrador'),
('ACTUALIZACION','1','4','Actualización de datos del usuario');

COMMIT;
