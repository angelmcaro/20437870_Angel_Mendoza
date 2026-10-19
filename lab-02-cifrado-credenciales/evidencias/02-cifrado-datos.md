1. ¿Qué diferencia existe entre crypt() y pgp_sym_encrypt()?
La diferencia fundamental es su propósito y reversibilidad:

crypt() es una función de hashing unidireccional. Transforma el texto en una huella digital irreversible. Se usa para verificar datos (como contraseñas) sin necesidad de conocer su contenido original.

pgp_sym_encrypt() es una función de cifrado simétrico bidireccional. "Esconde" la información utilizando una clave secreta con el propósito específico de que la información sí pueda ser leída posteriormente al aplicar el proceso inverso con la misma clave.

2. ¿Cuál de los dos mecanismos permite recuperar el dato original?
El mecanismo de cifrado simétrico: pgp_sym_encrypt() (utilizado en conjunto con su función hermana pgp_sym_decrypt()).

3. ¿Qué ocurre si se utiliza una clave incorrecta?
El proceso de descifrado falla. PostgreSQL arroja un error crítico (generalmente ERROR: Wrong key or corrupt data) y aborta la consulta, impidiendo por completo la visualización de la información en texto plano.

4. ¿Qué problema de seguridad representa colocar la clave directamente en una consulta?
Es una vulnerabilidad crítica conocida como "Hardcoding de secretos". Si la clave secreta se escribe en texto plano directamente en la consulta SQL:

Quedará registrada en los logs del servidor de la base de datos.

Quedará en el historial de comandos de la terminal del administrador.

Si la consulta viene de una aplicación, la clave estará visible en el código fuente de los desarrolladores.
Cualquier persona con acceso a esos logs o repositorios conocerá la clave, haciendo inútil el esfuerzo de cifrar la base de datos.