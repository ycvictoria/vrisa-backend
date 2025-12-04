-- Índices para mejorar consultas en measurement
CREATE INDEX idx_measurement_timestamp ON measurement(timestamp_measure);
CREATE INDEX idx_measurement_variable ON measurement(idParameter);
CREATE INDEX idx_measurement_sensor ON measurement(idSensor);

-- Índice compuesto para acelerar búsquedas por sensor + fecha
CREATE INDEX idx_measurement_sensor_date 
ON measurement(idSensor, timestamp_measure);

-- Índices para alertas
CREATE INDEX idx_alert_level ON alert(level);

-- Índice en station.status si buscas estaciones activas
CREATE INDEX idx_station_status ON station(status);

-- Índice en sensor.status si buscas sensores de que estacion
CREATE INDEX idx_sensor_station ON sensor(idStation);

-- Índice para buscar usuarios por rol
CREATE INDEX idx_user_role ON "user"(role);

-- Índice para búsquedas rápidas por institución
CREATE INDEX idx_institution_user ON institution(idUser);
