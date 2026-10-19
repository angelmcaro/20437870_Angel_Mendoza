7.1 El problema

Pregunta: ¿Qué ocurriría si una persona obtiene acceso de lectura a esta tabla usuarios_insegura?

Si un atacante, empleado interno o auditor obtiene acceso de lectura a esta tabla, verá todas las contraseñas en texto plano. Esto provoca vulnerabilidades críticas de seguridad:

Suplantación de identidad inmediata: El intruso puede iniciar sesión en la aplicación evadiendo los controles de autenticación, actuando en nombre de los usuarios legítimos con total libertad.

Efecto dominó (Credential Stuffing): Dado que una gran cantidad de personas reutiliza la misma contraseña para múltiples servicios, el atacante utilizará estas credenciales descubiertas para intentar acceder a las cuentas de correo, redes sociales o servicios bancarios de esos usuarios, comprometiendo su seguridad personal mucho más allá de este sistema original.

7.3 Generar una representación no reversible

1. ¿Son iguales?
No, los resultados obtenidos son cadenas de texto completamente diferentes.

2. Si no son iguales, ¿por qué?
Porque cada vez que se ejecuta la consulta, se genera una "sal" (salt) aleatoria nueva. El resultado final es la combinación matemática de la contraseña y esa sal aleatoria, por lo que el hash resultante siempre será distinto, incluso si la contraseña original es idéntica.

3. ¿Qué función cumple gen_salt()?
Genera una cadena aleatoria de caracteres (conocida como salt o "sal"). En este caso, el parámetro 'bf' le indica que use el algoritmo Blowfish (bcrypt). Su función principal es evitar que dos contraseñas iguales generen el mismo hash, protegiendo el sistema contra ataques de diccionario y el uso de "Rainbow Tables" (tablas precalculadas de contraseñas).

4. ¿Qué función cumple crypt()?
Es la función de hashing. Toma dos valores de entrada: la contraseña en texto plano y la sal generada. Aplica el algoritmo criptográfico y devuelve un hash complejo y único que ya contiene la información de la sal incrustada en él.

5. ¿Esto es cifrado reversible?
No, no es cifrado, es hashing unidireccional (one-way hash). Es matemáticamente imposible tomar el resultado generado por crypt() y aplicar una función inversa para volver a obtener el texto 'Password123'.

7.5 Verificar una contraseña

1. ¿Qué resultado obtuviste con la contraseña correcta?
Se obtuvo el valor booleano true (verdadero) en la columna contraseña_correcta, lo que indica que la contraseña ingresada coincide criptográficamente con el hash almacenado.

2. ¿Qué resultado obtuviste con la contraseña incorrecta?
Se obtuvo el valor booleano false (falso).

3. ¿Por qué no es necesario recuperar la contraseña original?
Porque el proceso de autenticación no requiere saber cuál es la contraseña, solo necesita comprobar que el usuario la sabe. Para validarlo, basta con tomar la contraseña que el usuario escribe en el login, aplicarle la misma función de hash (usando la "sal" que ya viene incluida en el registro guardado) y comparar si el nuevo hash resultante es idéntico al hash que está guardado en la base de datos.

4. ¿Por qué un hash no debe confundirse con cifrado?
Porque tienen propósitos matemáticos y operativos diferentes:

Cifrado (Encryption): Es bidireccional. Se usa una llave para ocultar la información, y se usa una llave para volver a recuperar la información original (ej. cifrar un mensaje de WhatsApp para que el receptor lo lea).

Hash (Hashing): Es unidireccional y destructivo. Es una huella digital matemática. No existe ninguna llave ni mecanismo para recuperar la información original a partir del hash. Su único propósito es la validación de integridad o la autenticación segura.