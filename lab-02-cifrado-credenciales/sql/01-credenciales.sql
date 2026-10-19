--  Verificar que tus 5 clientes del Lab 1 sigan ahí
SELECT * FROM clientes;

-- Habilitar la extensión de criptografía 
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Comprobar que la extensión ya está registrada en el sistema
SELECT extname 
FROM pg_extension 
WHERE extname = 'pgcrypto';

--Actividad 1 — Protección de credenciales

CREATE TABLE usuarios_insegura (
    id BIGSERIAL PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL
);


INSERT INTO usuarios_insegura (usuario, password)
VALUES ('juan', 'Password123');

SELECT *
FROM usuarios_insegura;




SELECT crypt('Password123', gen_salt('bf'));


-- 7.4 Crear tabla e insertar usuario
CREATE TABLE usuarios_segura (
    id BIGSERIAL PRIMARY KEY,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL
);

INSERT INTO usuarios_segura (usuario, password_hash)
VALUES (
    'juan',
    crypt('Password123', gen_salt('bf'))
);

-- Consultamos para ver cómo quedó guardada
SELECT * FROM usuarios_segura;

-- 7.5 Verificación de contraseña correcta
SELECT
    usuario,
    password_hash = crypt('Password123', password_hash) AS contraseña_correcta
FROM usuarios_segura
WHERE usuario = 'juan';

-- 7.5 Verificación de contraseña INCORRECTA
SELECT
    usuario,
    password_hash = crypt('OtraPassword', password_hash) AS contraseña_correcta
FROM usuarios_segura
WHERE usuario = 'juan';

