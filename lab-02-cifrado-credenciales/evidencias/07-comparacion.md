| Situación | Mecanismo apropiado | ¿Qué protege? |
| :--- | :--- | :--- |
| Contraseña de usuario | Hashing (ej. bcrypt / `crypt()`) | Información en reposo (Irreversible) |
| RFC almacenado en una tabla | Cifrado simétrico (ej. `pgp_sym_encrypt()`) | Información en reposo (Reversible con llave) |
| Consulta enviada desde un cliente al servidor | TLS (Transport Layer Security) | Información en tránsito (Evita intercepción en la red) |
| Respaldo de una base de datos | Cifrado de archivos / Cifrado simétrico | Información en reposo (Protege el archivo backup) |
| Clave criptográfica | Gestor de secretos (KMS, Vault) / No hardcoding | Información en reposo y en uso (Protege el acceso al cifrado) |