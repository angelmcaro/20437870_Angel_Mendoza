-- 8. Actividad 2 — Enmascaramiento (masking)
-- 8.1 Crear el rol
CREATE ROLE soporte_angel_mendoza NOLOGIN;

-- 8.2 Crear una vista de acceso restringido
CREATE VIEW v_clientes_soporte AS
SELECT
    id,
    nombre,

    CONCAT(
        LEFT(correo, 2),
        '*****',
        SUBSTRING(correo FROM POSITION('@' IN correo))
    ) AS correo,

    CONCAT(
        '******',
        RIGHT(telefono, 4)
    ) AS telefono,

    CONCAT(
        '*********',
        RIGHT(rfc, 4)
    ) AS rfc

FROM clientes;

-- Consultar la vista:
SELECT * FROM v_clientes_soporte;

-- 8.3 Conceder acceso a la vista
GRANT USAGE ON SCHEMA public TO soporte_angel_mendoza;

GRANT SELECT ON v_clientes_soporte TO soporte_angel_mendoza;

-- Revocar el acceso directo a la tabla:
REVOKE ALL ON clientes FROM soporte_angel_mendoza;

-- 8.4 Verificar el resultado
-- La consulta a la vista debe mostrar los datos protegidos

SELECT * FROM v_clientes_soporte;

-- El acceso directo a la tabla debe estar restringido para el rol soporte:

SELECT * FROM clientes;
