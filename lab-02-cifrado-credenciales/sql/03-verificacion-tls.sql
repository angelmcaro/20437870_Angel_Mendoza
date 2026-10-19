-- Verificar configuración general
SHOW ssl;
SHOW ssl_min_protocol_version;
SHOW port;
SHOW listen_addresses;

-- Verificar la IP desde donde te conectas
SELECT inet_client_addr(), inet_client_port();

-- Verificar el estado de TLS de tu sesión actual 
SELECT
    ssl,
    version,
    cipher
FROM pg_stat_ssl
WHERE pid = pg_backend_pid();