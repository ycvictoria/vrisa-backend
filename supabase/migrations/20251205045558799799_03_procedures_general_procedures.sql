--En Supabase, las actualizaciones UPDATE se deben hacer como FUNCTION, NO PROCEDURE , 
--para poder llamarse con supabase.rpc("nombre_function") desde el frontend. Por ello, CRUD esta en archivos
-- de funciones.

--Entonces… ¿para qué sirven las PROCEDURE en Supabase PostgreSQL?
--Para Ejecutar lógica con CALL, Transacciones explícitas , Sin necesidad de retornar datos
--Scripts administrativos internos. 
--Aqui irán procedures si aplican.