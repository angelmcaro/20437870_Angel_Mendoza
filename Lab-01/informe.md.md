# Informe de Laboratorio 1: Protección y Privacidad de Datos
**Materia:** Gestión de Seguridad y Desempeño de Bases de Datos  
**Autor:** Ángel Mendoza  

---

## 19.1 Clasificación

**Qué datos requieren protección y por qué:**
Todos los atributos de la tabla `clientes` son considerados datos personales o cuasi-identificadores, y requieren protección según su nivel de riesgo:

*   **Identificadores directos (`nombre`, `correo`, `telefono`, `rfc`):** Requieren el nivel más alto de protección. Permiten señalar a una persona concreta sin requerir información de contexto adicional. Su exposición no autorizada puede derivar en fraude, suplantación de identidad o extorsión.
*   **Cuasi-identificadores (`edad`, `ciudad`, `codigo_postal`, `fecha_alta`):** Requieren protección moderada. Por sí solos no identifican a la persona, pero combinados (ej. edad + código postal) pueden aislar a un individuo dentro de un grupo, facilitando su reidentificación.
*   **Identificadores internos (`id`):** Aunque es un seudónimo técnico, requiere protección porque permite vincular y cruzar registros del cliente entre múltiples sistemas o tablas.

---

## 19.2 Enmascaramiento

*   **Qué se ocultó:** Se aplicó un enmascaramiento parcial a los campos sensibles. Del `correo` solo se muestran los primeros 2 caracteres y el dominio; del `telefono` solo los últimos 4 dígitos; y del `rfc` solo los últimos 4 caracteres. Atributos demográficos como `edad`, `ciudad` y `codigo_postal` fueron excluidos por completo.
*   **Para quién:** Para el área de atención a clientes, a través del rol de base de datos `soporte`.
*   **Por qué:** Para cumplir con el *principio de mínimo privilegio*. El área de soporte solo necesita confirmar la identidad del cliente (verificando terminaciones de teléfono o correo), pero no requiere exportar ni visualizar la base de datos de manera explícita, reduciendo así el riesgo de fuga de información interna.
*   **Qué mecanismo se utilizó:** Se implementó *Enmascaramiento Dinámico* mediante una vista (`CREATE VIEW`) utilizando funciones de manipulación de cadenas de PostgreSQL (`CONCAT`, `LEFT`, `RIGHT`, `SUBSTRING`). El control se aseguró revocando el acceso a la tabla base (`REVOKE ALL ON clientes`) y otorgándolo exclusivamente a la vista (`GRANT SELECT ON v_clientes_soporte`).

---

## 19.3 Seudonimización

*   **Cómo se generaron los tokens:** Utilizando la extensión `pgcrypto` de PostgreSQL para invocar la función `gen_random_uuid()`, la cual genera un identificador único universal (UUID) aleatorio y no secuencial por cada cliente.
*   **Dónde se encuentra el mapa de correspondencia:** En un esquema aislado llamado `pii` (Personally Identifiable Information), dentro de la tabla `mapa_cliente`.
*   **Quién debería poder acceder a él:** Exclusivamente administradores de bases de datos (DBA) altamente privilegiados, o bien, sistemas de auditoría automatizados bajo la autorización estricta del Oficial de Privacidad de Datos (DPO).
*   **Por qué se separaron los permisos:** Para aplicar el principio de *Separación de funciones (Separation of Duties)*. Al aislar el esquema `analitica` del esquema `pii`, garantizamos que el analista pueda hacer su trabajo estadístico sin posibilidad de cruzar tablas (`JOIN`) para reidentificar a los clientes originales.

---

## 19.4 Anonimización

*   **Qué identificadores fueron eliminados:** Se suprimieron totalmente los identificadores directos: `nombre`, `correo`, `telefono` y `rfc`.
*   **Qué atributos fueron generalizados:** La `edad` se agrupó en bloques demográficos o rangos (ej. 18-30, 31-45, 46+). El `codigo_postal` se truncó a sus primeros 2 dígitos para representar regiones amplias en lugar de zonas específicas.
*   **Qué grupos fueron suprimidos:** Siguiendo el concepto de *k-anonimato*, se aplicó un umbral didáctico de `k=5` mediante la cláusula `HAVING COUNT(*) >= 5`. Cualquier cruce de edad y región que diera como resultado menos de 5 personas, fue suprimido del reporte final.
*   **Qué riesgo de reidentificación permanece:** Permanece un riesgo residual de reidentificación por medio de *ataques de vinculación*. Dado que el anonimato absoluto es imposible, si un atacante cruza estos datos agregados con fuentes de información externas (información de contexto), los individuos en grupos pequeños podrían seguir siendo vulnerables.

---

## 19.5 Retención

*   **Qué criterio se utilizó:** Un periodo de retención basado en el tiempo, específicamente registros cuya `fecha_alta` sea superior a 5 años en el pasado (`CURRENT_DATE - INTERVAL '5 years'`).
*   **Qué información debería conservarse:** Los datos de clientes activos o cuyas interacciones recientes sean necesarias para fines operativos, contables, fiscales o legales obligatorios.
*   **Qué información podría eliminarse:** Aquellos registros obsoletos o de clientes inactivos que ya han superado el umbral legal de retención de 5 años. Desechar esta información obedece al principio de *minimización de datos*.
*   **Qué controles deberían existir antes de eliminarla:** 
    1. Aprobación formal (mediante tickets y revisión de las áreas de Cumplimiento/Legal).
    2. Generación de un respaldo físico o lógico inmutable previo a la depuración (Cold Backup).
    3. Retención de bitácoras y logs de auditoría demostrando quién, cuándo y cuántos registros fueron depurados.
    4. Plan de recuperación (PITR) probado ante borrados accidentales.

---

## 19.6 Conclusiones

*   **¿Qué técnica utilizarías para un área de soporte?**
    Enmascaramiento (Masking) dinámico. Permite validar a los usuarios viendo una pequeña fracción de la información, manteniendo la tabla real intacta y oculta.

*   **¿Qué técnica utilizarías para un área de analítica?**
    Seudonimización (Pseudonymization). Sustituyendo llaves primarias por tokens. Mantiene la granularidad a nivel de registro para cruzar eventos analíticos, pero oculta la identidad real.

*   **¿Qué técnica utilizarías para publicar estadísticas?**
    Anonimización (Anonymization). Utilizando técnicas de agregación (COUNT/GROUP BY), generalización (rangos) y supresión (k-anonimato) para que sea imposible aislar e identificar a una sola persona de manera razonable.

*   **¿Por qué ninguna de estas técnicas sustituye al control de acceso?**
    Porque la seguridad debe implementarse bajo el paradigma de *Defensa en Profundidad*. Vistas enmascaradas, UUIDs y agrupaciones son transformaciones que ocurren a nivel de consulta. Si no existen controles de acceso estrictos a nivel motor (gestión de roles, esquemas, `GRANT` y `REVOKE`), un usuario o atacante podría simplemente evadir la vista o esquema seguro y ejecutar un `SELECT *` directamente sobre la tabla base, exponiendo toda la información confidencial.