# Informe Final - Laboratorio 02: Cifrado y Credenciales

## 1. Introducción
El presente laboratorio aborda la problemática de la exposición de datos sensibles y credenciales en bases de datos PostgreSQL. El objetivo principal fue mitigar el riesgo de robo de identidad, fuga de información y accesos no autorizados mediante la implementación de técnicas de hashing, cifrado simétrico y verificación de seguridad en tránsito, garantizando la confidencialidad de la información.

## 2. Protección de credenciales
Es fundamental distinguir entre los diferentes mecanismos de manejo de datos:
* **Texto claro:** Los datos se almacenan tal cual se escriben. Es una práctica altamente insegura para contraseñas, ya que cualquiera con acceso a la tabla puede leerlas.
* **Cifrado:** Transforma los datos en un formato ilegible utilizando una clave. Permite recuperar el valor original descifrándolo (bidireccional), lo cual es útil para datos que el sistema necesita leer posteriormente en su formato original.
* **Hash:** Transforma los datos en una cadena de longitud fija de forma irreversible (unidireccional). Es el estándar para proteger contraseñas, ya que el sistema solo compara el hash ingresado con el almacenado, sin necesidad de conocer la contraseña real. Se complementó con el uso de *salt* (Blowfish) para evitar ataques de diccionario.

## 3. Protección de datos sensibles
Durante el laboratorio se protegió la información crítica de la tabla `clientes`, prestando especial atención a identificadores como el RFC. Estos datos se protegieron utilizando cifrado simétrico (`pgp_sym_encrypt` de la extensión `pgcrypto`) porque constituyen Información de Identificación Personal (PII) que, en caso de filtración, podría derivar en fraudes financieros o violaciones a normativas de privacidad.

## 4. TLS (Seguridad de la Capa de Transporte)
TLS resuelve el problema de la intercepción de datos en tránsito (ataques de intermediario o *Man-in-the-Middle*) al crear un túnel cifrado entre el cliente y el servidor. En PostgreSQL se verificó el estado de la conexión utilizando la vista `pg_stat_ssl`. Se comprobó que la conexión actual no utilizaba TLS (arrojando un valor `false`), lo cual es el comportamiento esperado al trabajar en un entorno de desarrollo local (`localhost`) donde el tráfico no sale a internet.

## 5. Gestión de claves
Las claves criptográficas nunca deben almacenarse en el mismo repositorio que contiene el código fuente, los scripts SQL o la propia base de datos. Si un atacante logra comprometer el repositorio o el servidor, obtendría simultáneamente la "caja fuerte" y la "llave" para abrirla, anulando por completo cualquier mecanismo de cifrado. Deben gestionarse mediante variables de entorno o bóvedas de secretos especializadas.

## 6. Resultados
* Se implementó con éxito el algoritmo de hashing unidireccional (`crypt`) para el almacenamiento seguro de contraseñas de usuarios.
* Se aplicó cifrado y descifrado simétrico para proteger columnas con información personal sensible.
* Se auditó el estado de la conexión SSL/TLS para comprender la protección de los datos en tránsito.
* Se documentó una política formal para el ciclo de vida y gestión de claves criptográficas, junto con un análisis de riesgos de seguridad.

## 7. Problemas encontrados
* **Reconocimiento de comandos en terminal:** Se presentó el error `El término 'psql' no se reconoce como nombre de un cmdlet` en la terminal de Windows. Esto ocurrió porque la ruta de las herramientas de PostgreSQL no estaba en las variables de entorno del sistema. La dificultad se superó rápidamente utilizando la herramienta integrada *PSQL Tool* desde pgAdmin, la cual permitió ejecutar los comandos directamente al servidor.
* **Dudas sobre la verificación SSL:** Al consultar `pg_stat_ssl`, el campo `ssl` devolvió el valor `f` (false). Inicialmente parecía un error de configuración, pero tras el análisis se comprendió que el motor desactiva el cifrado por defecto para conexiones locales (`localhost`) por considerarlas de bajo riesgo.

## 8. Conclusiones
Este laboratorio demostró que la seguridad en bases de datos requiere una estrategia de "defensa en profundidad". No basta con configurar usuarios; es necesario proteger los datos en reposo (hashing y cifrado) y en tránsito. En un entorno productivo real, aplicaría la configuración `sslmode=verify-full` para garantizar la máxima seguridad en las conexiones, aseguraría el uso de un gestor de secretos externo para las llaves criptográficas, y auditaría constantemente los permisos para cumplir con el principio de mínimos privilegios.

## 9. Preguntas de reflexión
1. ¿Por qué una contraseña no debe almacenarse como texto claro?
Porque cualquier persona con acceso a la base de datos (administradores, o un atacante que logre entrar) podrá leerlas directamente. Esto compromete totalmente la cuenta del usuario e incluso cuentas en otros servicios si tiene la costumbre de reciclar contraseñas.

2. ¿Por qué un hash no es equivalente a un cifrado?
El hash es un proceso matemático unidireccional (irreversible); no se puede obtener el dato original a partir del hash. El cifrado es un proceso bidireccional; permite transformar el dato y luego recuperar la información original usando la clave de descifrado.

3. ¿Por qué el cifrado de una columna no sustituye al control de acceso?
El cifrado protege los datos físicamente en el disco. Sin embargo, si no hay control de acceso y un usuario malintencionado logra conectarse, puede ejecutar la consulta de descifrado y la base de datos le entregará la información. El control de acceso es lo que dictamina quién tiene permiso para hacer esa consulta.

4. ¿Por qué TLS no sustituye a los mecanismos de autorización de PostgreSQL?
TLS asegura el canal de comunicación (la red) evitando que alguien intercepte los datos mientras viajan. No obstante, una vez que el usuario llega a la base de datos por ese canal seguro, PostgreSQL necesita sus propios mecanismos de autorización para saber qué tablas puede ver o alterar.

5. ¿Qué ocurriría si una organización pierde una clave utilizada para cifrar información?
La información cifrada con esa clave se volvería permanentemente inaccesible e irrecuperable. Los datos quedarían inutilizables.

6. ¿Qué ocurriría si una clave criptográfica se publica accidentalmente en GitLab?
La seguridad del cifrado se anula por completo. Cualquier desarrollador o bot que escanee el repositorio (incluso en el historial) tendría la llave para descifrar la base de datos. Se tendría que invalidar la llave inmediatamente, generar una nueva y volver a cifrar toda la información.

7. ¿Por qué un repositorio privado no debe considerarse un almacén de secretos?
El código fuente suele ser clonado en múltiples computadoras locales por diversos desarrolladores, herramientas y servidores de prueba. Al multiplicar las copias del repositorio, se multiplican los riesgos de que la llave se filtre, además de que el control de permisos en Git no está diseñado para gestionar secretos.

8. ¿Qué diferencia existe entre proteger información almacenada y proteger información durante su transmisión?
Proteger información almacenada (en reposo, mediante cifrado de columnas/discos) evita vulneraciones si roban los discos duros o los respaldos. Proteger en transmisión (en tránsito, mediante TLS) evita que la información sea leída o alterada mientras viaja por los cables o el WiFi de la red.

9. ¿Por qué la gestión de claves es tan importante como el algoritmo criptográfico?
El cifrado moderno es matemáticamente inquebrantable en la práctica. Los atacantes no intentan romper el algoritmo de grado militar, sino que buscan robar la llave. Si la llave está mal gestionada (guardada en un post-it, en texto claro en el código o compartida por correo), el mejor algoritmo del mundo no servirá de nada.

10. ¿Qué mecanismo adicional implementarías en una organización para proteger los respaldos de las bases de datos?
Cifraría el archivo del respaldo (.bak o .sql) y lo almacenaría en un servidor o servicio en la nube físicamente separado del origen, aplicando controles de acceso estrictos y utilizando llaves de cifrado totalmente distintas a las de la base de datos principal.