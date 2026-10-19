-- 8.1 Crear tabla e insertar registro cifrado
CREATE TABLE clientes_protegidos (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    rfc_cifrado BYTEA NOT NULL
);
INSERT INTO clientes_protegidos (nombre, rfc_cifrado)
VALUES (
    'Ana López',
    pgp_sym_encrypt('LOPA900101ABC', 'CLAVE-DE-PRUEBA')
);
-- Consultamos para ver cómo se guardó 
SELECT * FROM clientes_protegidos;
-- 8.2 Recuperar el dato 
SELECT
    id,
    nombre,
    pgp_sym_decrypt(rfc_cifrado, 'CLAVE-DE-PRUEBA') AS rfc
FROM clientes_protegidos;
-- Prueba intentando recuperar con una clave incorrecta
SELECT
    id,
    nombre,
    pgp_sym_decrypt(rfc_cifrado, 'CLAVE-FALSA') AS rfc
FROM clientes_protegidos;
