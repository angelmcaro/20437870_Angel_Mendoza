-- seudonimizacion
-- 9.1 Crear los esquemas
CREATE SCHEMA pii;
CREATE SCHEMA analitica;

-- 9.2 Crear la tabla de correspondencia
CREATE TABLE pii.mapa_cliente (
    token UUID PRIMARY KEY,
    cliente_id BIGINT UNIQUE REFERENCES public.clientes(id)
);

-- 9.3 Generar los tokens
CREATE EXTENSION IF NOT EXISTS pgcrypto;

INSERT INTO pii.mapa_cliente (token, cliente_id)
SELECT gen_random_uuid(), id FROM clientes;

-- 10. Crear el conjunto de datos para analítica 
CREATE TABLE analitica.clientes AS
SELECT
    m.token AS cliente_token,
    c.edad,
    c.ciudad,
    c.codigo_postal,
    c.fecha_alta
FROM pii.mapa_cliente m
JOIN clientes c ON c.id = m.cliente_id;

-- 11. Crear el rol 
CREATE ROLE analista_angel_mendoza NOLOGIN;

-- 11.1 Conceder acceso SOLO al conjunto analítico
GRANT USAGE ON SCHEMA analitica TO analista_angel_mendoza;
GRANT SELECT ON analitica.clientes TO analista_angel_mendoza;


SELECT * FROM analitica.clientes;

SELECT * FROM pii.mapa_cliente;

SELECT * FROM public.clientes;