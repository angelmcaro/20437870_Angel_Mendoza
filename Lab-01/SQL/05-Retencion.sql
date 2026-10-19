--retencion de datos
SELECT *
FROM clientes
WHERE fecha_alta < CURRENT_DATE - INTERVAL '5 years';

--VERIFICACION FINAL
SET ROLE soporte_angel_mendoza;
SELECT * FROM v_clientes_soporte; 
SELECT * FROM clientes;          
RESET ROLE;


SET ROLE analista_angel_mendoza;
SELECT * FROM analitica.clientes; 
SELECT * FROM pii.mapa_cliente;   
SELECT * FROM public.clientes;    
RESET ROLE;