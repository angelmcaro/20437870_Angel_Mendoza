Pregunta 1: ¿Cuáles son los principales riesgos?

Exposición masiva de credenciales y datos fiscales por almacenamiento en texto plano.

Interceptación de tráfico en la red (Man-in-the-Middle) por falta de cifrado en tránsito.

Robo de llaves criptográficas expuestas en archivos de código fuente.

Acceso desatendido y filtración de información sensible a través de respaldos sin cifrar.

Pregunta 2: ¿Qué mecanismo utilizarías para cada elemento?

Nombre: Enmascaramiento dinámico (vistas) o control de acceso por roles.

Correo electrónico: Enmascaramiento parcial o cifrado simétrico.

Contraseña: Hashing unidireccional con salting (crypt() con Blowfish / pgcrypto).

RFC: Cifrado simétrico de datos en reposo (pgp_sym_encrypt).

Información financiera: Cifrado simétrico de datos en reposo y control estricto de mínimos privilegios.

Claves criptográficas: Almacenamiento externo seguro (Gestor de secretos / Key Vault) y exclusión absoluta del código fuente.

Pregunta 3: ¿Cuál de los problemas consideras más crítico y por qué?
Las contraseñas en texto claro y las claves expuestas en archivos SQL. Esto compromete de inmediato la autenticidad y el control total de los accesos, permitiendo que cualquier atacante suplante identidades o descifre el resto de la base de datos sin mayor esfuerzo.

Pregunta 4: ¿Tener correctamente configurados los usuarios y permisos elimina estos riesgos? Justifica tu respuesta.
No. Los permisos de base de datos controlan quién accede a los objetos, pero no protegen la información si un usuario con privilegios legítimos es vulnerado, si hay un ataque de escucha en la red, o si un atacante roba un archivo de respaldo o el código fuente donde están expuestas las llaves y contraseñas. Por eso se requiere el principio de Defensa en Profundidad (combinando permisos, cifrado y hashing).