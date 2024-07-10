--------------------------------------
---------------- INIT ----------------
--------------------------------------

USE GD1C2024
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'REDIS')
BEGIN 
	EXEC ('CREATE SCHEMA REDIS')
END
GO

-- Vistas
IF OBJECT_ID('REDIS.V_Ticket_Promedio_Mensual', 'V') IS NOT NULL DROP VIEW REDIS.V_Ticket_Promedio_Mensual;
IF OBJECT_ID('REDIS.V_Cantidad_Unidades_Promedio', 'V') IS NOT NULL DROP VIEW REDIS.V_Cantidad_Unidades_Promedio;
IF OBJECT_ID('REDIS.V_Porcentaje_Anual_De_Ventas', 'V') IS NOT NULL DROP VIEW REDIS.V_Porcentaje_Anual_De_Ventas;
IF OBJECT_ID('REDIS.V_Cantidad_De_Ventas_Por_Turno', 'V') IS NOT NULL DROP VIEW REDIS.V_Cantidad_De_Ventas_Por_Turno;
IF OBJECT_ID('REDIS.V_Porcentaje_Descuento_Tickets', 'V') IS NOT NULL DROP VIEW REDIS.V_Porcentaje_Descuento_Tickets;

IF OBJECT_ID('REDIS.V_Top3_Categorias_Promociones', 'V') IS NOT NULL DROP VIEW REDIS.V_Top3_Categorias_Promociones;

IF OBJECT_ID('REDIS.V_Porcentaje_Cumplimiento_Envios', 'V') IS NOT NULL DROP VIEW REDIS.V_Porcentaje_Cumplimiento_Envios;
IF OBJECT_ID('REDIS.V_Cantidad_Envios_Rango_Etario_Clientes', 'V') IS NOT NULL DROP VIEW REDIS.V_Cantidad_Envios_Rango_Etario_Clientes;
IF OBJECT_ID('REDIS.V_Top5_Localidades_Mayor_Costo_Envio', 'V') IS NOT NULL DROP VIEW REDIS.V_Top5_Localidades_Mayor_Costo_Envio;

IF OBJECT_ID('REDIS.V_Top3_Sucursales_Pagos_Cuotas', 'V') IS NOT NULL DROP VIEW REDIS.V_Top3_Sucursales_Pagos_Cuotas;
IF OBJECT_ID('REDIS.V_Promedio_Importe_Cuota_Rango_Etario', 'V') IS NOT NULL DROP VIEW REDIS.V_Promedio_Importe_Cuota_Rango_Etario;
IF OBJECT_ID('REDIS.V_Porcentaje_Descuento_Medio_Pago', 'V') IS NOT NULL DROP VIEW REDIS.V_Porcentaje_Descuento_Medio_Pago;

-- Hechos
IF OBJECT_ID('REDIS.BI_Hechos_Venta', 'U') IS NOT NULL DROP TABLE REDIS.BI_Hechos_Venta;
IF OBJECT_ID('REDIS.BI_Hechos_Promocion', 'U') IS NOT NULL DROP TABLE REDIS.BI_Hechos_Promocion;
IF OBJECT_ID('REDIS.BI_Hechos_Envio', 'U') IS NOT NULL DROP TABLE REDIS.BI_Hechos_Envio;
IF OBJECT_ID('REDIS.BI_Hechos_Pago_Cuotas', 'U') IS NOT NULL DROP TABLE REDIS.BI_Hechos_Pago_Cuotas;
IF OBJECT_ID('REDIS.BI_Hechos_Pago', 'U') IS NOT NULL DROP TABLE REDIS.BI_Hechos_Pago;

-- Dimensiones
IF OBJECT_ID('REDIS.BI_Tiempo', 'U') IS NOT NULL DROP TABLE REDIS.BI_Tiempo;
IF OBJECT_ID('REDIS.BI_Ubicacion', 'U') IS NOT NULL DROP TABLE REDIS.BI_Ubicacion;
IF OBJECT_ID('REDIS.BI_Rango_Etario', 'U') IS NOT NULL DROP TABLE REDIS.BI_Rango_Etario;
IF OBJECT_ID('REDIS.BI_Medio_De_Pago', 'U') IS NOT NULL DROP TABLE REDIS.BI_Medio_De_Pago;
IF OBJECT_ID('REDIS.BI_Turno', 'U') IS NOT NULL DROP TABLE REDIS.BI_Turno;
IF OBJECT_ID('REDIS.BI_Tipo_Caja', 'U') IS NOT NULL DROP TABLE REDIS.BI_Tipo_Caja;
IF OBJECT_ID('REDIS.BI_Categoria_Producto', 'U') IS NOT NULL DROP TABLE REDIS.BI_Categoria_Producto;
IF OBJECT_ID('REDIS.BI_Sucursal', 'U') IS NOT NULL DROP TABLE REDIS.BI_Sucursal;

--------------------------------------
------------ DINMENSIONS -------------
--------------------------------------

CREATE TABLE REDIS.BI_Tiempo
(
	tiempo_id INT IDENTITY PRIMARY KEY,
	anio INT,
	mes INT,
	cuatrimestre INT
)
GO

CREATE TABLE REDIS.BI_Ubicacion
(
	ubicacion_id INT IDENTITY PRIMARY KEY,
	localidad_nombre NVARCHAR(255),
	provincia_nombre NVARCHAR(255)
)
GO

CREATE TABLE REDIS.BI_Rango_Etario
(
	rango_etario_id INT IDENTITY PRIMARY KEY,
	rango_descripcion NVARCHAR(255)
)
GO

CREATE TABLE REDIS.BI_Medio_De_Pago
(
	medio_de_pago_id INT IDENTITY PRIMARY KEY,
	medio_de_pago_descripcion NVARCHAR(255)
)
GO

CREATE TABLE REDIS.BI_Turno
(
	turno_id INT IDENTITY PRIMARY KEY,
	turno_descripcion NVARCHAR(255)
)
GO

CREATE TABLE REDIS.BI_Tipo_Caja
(
	tipo_caja_id INT IDENTITY PRIMARY KEY,
	tipo_caja_descripcion NVARCHAR(255)
)
GO

CREATE TABLE REDIS.BI_Categoria_Producto (
    categoria_producto_id INT IDENTITY PRIMARY KEY,
    categoria_nombre NVARCHAR(255)
)
GO

CREATE TABLE REDIS.BI_Sucursal (
    sucursal_id INT IDENTITY PRIMARY KEY,
	sucursal_nombre NVARCHAR(255),
	sucursal_direccion NVARCHAR(255)
)
GO

--------------------------------------
--------- INSERT DATA ----------------
--------- DIMENSIONS -----------------
--------------------------------------

INSERT INTO REDIS.BI_Tiempo(anio, cuatrimestre, mes)
SELECT
    YEAR(t.ticket_fecha_hora) AS anio,
    CASE 
        WHEN DATEPART(MONTH, t.ticket_fecha_hora) BETWEEN 1 AND 4 THEN 1
        WHEN DATEPART(MONTH, t.ticket_fecha_hora) BETWEEN 5 AND 8 THEN 2
        WHEN DATEPART(MONTH, t.ticket_fecha_hora) BETWEEN 9 AND 12 THEN 3
    END AS cuatrimestre,
    DATEPART(MONTH, t.ticket_fecha_hora) AS mes
FROM REDIS.Ticket t
GROUP BY 
    YEAR(t.ticket_fecha_hora), 
    CASE 
        WHEN DATEPART(MONTH, t.ticket_fecha_hora) BETWEEN 1 AND 4 THEN 1
        WHEN DATEPART(MONTH, t.ticket_fecha_hora) BETWEEN 5 AND 8 THEN 2
        WHEN DATEPART(MONTH, t.ticket_fecha_hora) BETWEEN 9 AND 12 THEN 3
    END, 
    DATEPART(MONTH, t.ticket_fecha_hora)
ORDER BY 
    anio, cuatrimestre, mes
GO

INSERT INTO REDIS.BI_Ubicacion(localidad_nombre, provincia_nombre)
SELECT DISTINCT
    l.localidad_nombre,
    p.provincia_nombre
FROM
    REDIS.Sucursal s
JOIN
    REDIS.Localidad l ON s.sucursal_localidad = l.localidad_id
JOIN
    REDIS.Provincia p ON l.localidad_provincia = p.provincia_id

UNION

SELECT DISTINCT
    l.localidad_nombre,
    p.provincia_nombre
FROM
    REDIS.Cliente c
JOIN
    REDIS.Localidad l ON c.cliente_localidad = l.localidad_id
JOIN
    REDIS.Provincia p ON l.localidad_provincia = p.provincia_id
GO

INSERT INTO REDIS.BI_Rango_Etario(rango_descripcion)
SELECT DISTINCT
    CASE 
        WHEN DATEDIFF(YEAR, empleado_fecha_nacimiento, GETDATE()) < 25 THEN '< 25'
        WHEN DATEDIFF(YEAR, empleado_fecha_nacimiento, GETDATE()) BETWEEN 25 AND 35 THEN '25 - 35'
        WHEN DATEDIFF(YEAR, empleado_fecha_nacimiento, GETDATE()) BETWEEN 35 AND 50 THEN '35 - 50'
		WHEN DATEDIFF(YEAR, empleado_fecha_nacimiento, GETDATE()) > 50 THEN '> 50'
    END AS rango_etario
FROM REDIS.Empleado
UNION
SELECT DISTINCT
    CASE 
        WHEN DATEDIFF(YEAR, cliente_fecha_nacimiento, GETDATE()) < 25 THEN '< 25'
        WHEN DATEDIFF(YEAR, cliente_fecha_nacimiento, GETDATE()) BETWEEN 25 AND 35 THEN '25 - 35'
        WHEN DATEDIFF(YEAR, cliente_fecha_nacimiento, GETDATE()) BETWEEN 35 AND 50 THEN '35 - 50'
        WHEN DATEDIFF(YEAR, cliente_fecha_nacimiento, GETDATE()) > 50 THEN '> 50'
    END AS rango_etario
FROM REDIS.Cliente
GO

INSERT INTO REDIS.BI_Medio_De_Pago(medio_de_pago_descripcion)
SELECT DISTINCT medio_pago
FROM REDIS.Medio_Pago
GO

INSERT INTO REDIS.BI_Turno (turno_descripcion)
SELECT DISTINCT
    CASE
        WHEN DATEPART(HOUR, ticket_fecha_hora) >= 8 AND DATEPART(HOUR, ticket_fecha_hora) < 12 THEN '08:00 - 12:00'
        WHEN DATEPART(HOUR, ticket_fecha_hora) >= 12 AND DATEPART(HOUR, ticket_fecha_hora) < 16 THEN '12:00 - 16:00'
        WHEN DATEPART(HOUR, ticket_fecha_hora) >= 16 AND DATEPART(HOUR, ticket_fecha_hora) < 20 THEN '16:00 - 20:00'
        ELSE 'Otros'
    END AS turno
FROM REDIS.Ticket
GO

INSERT INTO REDIS.BI_Tipo_Caja(tipo_caja_descripcion)
SELECT
    c.caja_tipo
FROM REDIS.Ticket t JOIN REDIS.Caja c ON c.caja_numero + c.caja_sucursal_id = t.ticket_caja_numero + t.ticket_sucursal_id
GROUP BY c.caja_tipo
GO

INSERT INTO REDIS.BI_Categoria_Producto(categoria_nombre)
SELECT DISTINCT
	c.categoria_producto_nombre
FROM REDIS.Categoria_Producto c
GO

INSERT INTO REDIS.BI_Sucursal(sucursal_nombre, sucursal_direccion)
SELECT DISTINCT
	s.sucursal_nombre,
	s.sucursal_direccion
FROM REDIS.Sucursal s
GO

--------------------------------------
--------- FACTS TABLES  --------------
--------------------------------------

CREATE TABLE REDIS.BI_Hechos_Venta
(
	tiempo_id INT, -- FK
	ubicacion_id INT, -- FK
	rango_etario_empleado_id INT, -- FK
	turno_id INT, -- FK
	tipo_caja_id INT, --FK
	importe_venta DECIMAL(18, 2),
	cantidad_unidades DECIMAL(18,0),
	ticket_total_descuento_aplicado_prod DECIMAL(18, 2),
	ticket_total_descuento_aplicado_mp DECIMAL(18, 2),
	ticket_total_descuento_aplicado_total DECIMAL(18, 2),
	FOREIGN KEY (tiempo_id) REFERENCES REDIS.BI_Tiempo(tiempo_id),
	FOREIGN KEY (ubicacion_id) REFERENCES REDIS.BI_Ubicacion(ubicacion_id),
	FOREIGN KEY (rango_etario_empleado_id) REFERENCES REDIS.BI_Rango_Etario(rango_etario_id),
	FOREIGN KEY (turno_id) REFERENCES REDIS.BI_Turno(turno_id),
	FOREIGN KEY (tipo_caja_id) REFERENCES REDIS.BI_Tipo_Caja(tipo_caja_id),
	PRIMARY KEY (tiempo_id, ubicacion_id, rango_etario_empleado_id, turno_id, tipo_caja_id)
)
GO

INSERT INTO REDIS.BI_Hechos_Venta (
    tiempo_id, ubicacion_id, turno_id, importe_venta, cantidad_unidades, rango_etario_empleado_id,
	tipo_caja_id, ticket_total_descuento_aplicado_prod, ticket_total_descuento_aplicado_mp,
	ticket_total_descuento_aplicado_total
)
SELECT
    bt.tiempo_id,
    bu.ubicacion_id,
	bturno.turno_id AS ticket_turno,
    SUM(t.ticket_total_venta) AS importe_venta,
	SUM(td.cantidad) AS cantidad_unidades,
	brango.rango_etario_id AS rango_etario_empleado_id,
	tc.tipo_caja_id,
	SUM(t.ticket_total_descuento_aplicado),
	SUM(t.ticket_total_descuento_aplicado_mp),
	SUM(t.ticket_total_descuento_aplicado + t.ticket_total_descuento_aplicado_mp)
FROM 
	REDIS.Ticket t
	JOIN REDIS.Sucursal s ON t.ticket_sucursal_id = s.sucursal_id
	JOIN REDIS.Localidad l ON s.sucursal_localidad = l.localidad_id
	JOIN REDIS.Provincia p ON l.localidad_provincia = p.provincia_id
	JOIN REDIS.BI_Tiempo bt ON YEAR(t.ticket_fecha_hora) = bt.anio
		AND MONTH(t.ticket_fecha_hora) = bt.mes
	JOIN REDIS.BI_Turno bturno ON bturno.turno_descripcion =
		CASE
			WHEN DATEPART(HOUR, t.ticket_fecha_hora) BETWEEN 8 AND 12 THEN '08:00 - 12:00'
			WHEN DATEPART(HOUR, t.ticket_fecha_hora) BETWEEN 12 AND 16 THEN '12:00 - 16:00'
			WHEN DATEPART(HOUR, t.ticket_fecha_hora) BETWEEN 16 AND 20 THEN '16:00 - 20:00'
			ELSE 'Otros'
		END
	JOIN REDIS.BI_Ubicacion bu ON l.localidad_nombre = bu.localidad_nombre
		AND p.provincia_nombre = bu.provincia_nombre
	JOIN REDIS.Ticket_Detalle td ON td.ticket_numero = t.ticket_id
	JOIN REDIS.Empleado e ON t.ticket_empleado_legajo = e.empleado_legajo
	JOIN REDIS.Caja c ON c.caja_numero = t.ticket_caja_numero AND c.caja_sucursal_id = t.ticket_sucursal_id
	JOIN REDIS.BI_Tipo_Caja tc ON tc.tipo_caja_descripcion = c.caja_tipo
	JOIN REDIS.BI_Rango_Etario brango ON brango.rango_etario_id =
		CASE 
		    WHEN DATEDIFF(YEAR, e.empleado_fecha_nacimiento, GETDATE()) < 25 THEN (SELECT rango_etario_id FROM REDIS.BI_Rango_Etario WHERE rango_descripcion = '< 25')
		    WHEN DATEDIFF(YEAR, e.empleado_fecha_nacimiento, GETDATE()) BETWEEN 25 AND 35 THEN (SELECT rango_etario_id FROM REDIS.BI_Rango_Etario WHERE rango_descripcion = '25 - 35')
		    WHEN DATEDIFF(YEAR, e.empleado_fecha_nacimiento, GETDATE()) BETWEEN 35 AND 50 THEN (SELECT rango_etario_id FROM REDIS.BI_Rango_Etario WHERE rango_descripcion = '35 - 50')
		    ELSE (SELECT rango_etario_id FROM REDIS.BI_Rango_Etario WHERE rango_descripcion = '> 50')
		END
GROUP BY
    bt.tiempo_id,
    bu.ubicacion_id,
	bturno.turno_id,
	brango.rango_etario_id,
	tc.tipo_caja_id
GO

CREATE TABLE REDIS.BI_Hechos_Promocion (
    tiempo_id INT, -- FK
    categoria_id INT, -- FK
    promo_aplicada_descuento DECIMAL(18, 2),
    FOREIGN KEY (tiempo_id) REFERENCES REDIS.BI_Tiempo(tiempo_id),
    FOREIGN KEY (categoria_id) REFERENCES REDIS.BI_Categoria_Producto(categoria_producto_id),
	PRIMARY KEY (tiempo_id, categoria_id)
)
GO

INSERT INTO REDIS.BI_Hechos_Promocion (tiempo_id, categoria_id, promo_aplicada_descuento)
SELECT
    bt.tiempo_id,
    bicp.categoria_producto_id,
    SUM(ppt.promo_aplicada_descuento)
FROM
    REDIS.Promocion_Por_Ticket ppt
    JOIN REDIS.Ticket_Detalle td ON ppt.ticket_detalle_id = td.ticket_detalle_id
    JOIN REDIS.Ticket t ON t.ticket_id = td.ticket_numero
    JOIN REDIS.Producto p ON p.producto_id = td.producto_id
    JOIN REDIS.Subcategoria_Producto sc ON sc.subcategoria_producto_id = p.producto_subcategoria
    JOIN REDIS.Categoria_Producto c ON c.categoria_producto_nombre = sc.categoria_producto
    JOIN REDIS.BI_Tiempo bt ON bt.anio = YEAR(t.ticket_fecha_hora)
                            AND bt.mes = DATEPART(MONTH, t.ticket_fecha_hora)
                            AND bt.cuatrimestre = 
                                CASE 
                                    WHEN DATEPART(MONTH, t.ticket_fecha_hora) BETWEEN 1 AND 4 THEN 1
                                    WHEN DATEPART(MONTH, t.ticket_fecha_hora) BETWEEN 5 AND 8 THEN 2
                                    WHEN DATEPART(MONTH, t.ticket_fecha_hora) BETWEEN 9 AND 12 THEN 3
                                END
    JOIN REDIS.BI_Categoria_Producto bicp ON bicp.categoria_nombre = c.categoria_producto_nombre
GROUP BY
	bt.tiempo_id,
	bicp.categoria_producto_id
GO

CREATE TABLE REDIS.BI_Hechos_Envio (
	tiempo_id INT, -- FK
	sucursal_id INT, --FK
	rango_etario_cliente_id INT, --FK
	cliente_ubicacion_id INT, --FK
	maximo_costo_envio DECIMAL(18,2),
	entregados_a_tiempo INT,
	entregados_fuera_de_tiempo INT,
	FOREIGN KEY (tiempo_id) REFERENCES REDIS.BI_Tiempo(tiempo_id),
	FOREIGN KEY (sucursal_id) REFERENCES REDIS.BI_Sucursal(sucursal_id),
	FOREIGN KEY (rango_etario_cliente_id) REFERENCES REDIS.BI_Rango_Etario(rango_etario_id),
	FOREIGN KEY (cliente_ubicacion_id) REFERENCES REDIS.BI_Ubicacion(ubicacion_id),
	PRIMARY KEY (tiempo_id, sucursal_id, rango_etario_cliente_id, cliente_ubicacion_id)
)
GO

INSERT INTO REDIS.BI_Hechos_Envio (tiempo_id, sucursal_id, rango_etario_cliente_id, cliente_ubicacion_id,
maximo_costo_envio, entregados_a_tiempo,  entregados_fuera_de_tiempo)
SELECT
	bt.tiempo_id,
	bs.sucursal_id,
	brango.rango_etario_id AS rango_etario,
	bu.ubicacion_id,
	MAX(e.envio_costo),
	SUM(CASE WHEN e.envio_fecha_entrega BETWEEN DATEADD(HOUR, CAST(e.envio_hora_inicio AS INT), e.envio_fecha_programada) 
	AND DATEADD(HOUR, CAST(e.envio_hora_fin AS INT), e.envio_fecha_programada) THEN 1 ELSE 0 END) AS entregados_a_tiempo,
	SUM(CASE WHEN e.envio_fecha_entrega NOT BETWEEN DATEADD(HOUR, CAST(e.envio_hora_inicio AS INT), e.envio_fecha_programada) 
	AND DATEADD(HOUR, CAST(e.envio_hora_fin AS INT), e.envio_fecha_programada) THEN 1 ELSE 0 END) AS entregados_fuera_de_tiempo
FROM 
	REDIS.Envio e
	JOIN REDIS.BI_Tiempo bt ON bt.anio = YEAR(e.envio_fecha_entrega)
                            AND bt.mes = DATEPART(MONTH, e.envio_fecha_entrega)
                            AND bt.cuatrimestre = 
                                CASE 
                                    WHEN DATEPART(MONTH, e.envio_fecha_entrega) BETWEEN 1 AND 4 THEN 1
                                    WHEN DATEPART(MONTH, e.envio_fecha_entrega) BETWEEN 5 AND 8 THEN 2
                                    WHEN DATEPART(MONTH, e.envio_fecha_entrega) BETWEEN 9 AND 12 THEN 3
                                END
	JOIN REDIS.Ticket t ON t.ticket_id = e.envio_ticket_numero
	JOIN REDIS.Sucursal s ON s.sucursal_id = t.ticket_sucursal_id
	JOIN REDIS.BI_Sucursal bs ON bs.sucursal_nombre = s.sucursal_nombre
	JOIN REDIS.Cliente c ON c.cliente_dni = e.envio_cliente_dni
	JOIN REDIS.Localidad l ON l.localidad_id = c.cliente_localidad
	JOIN REDIS.Provincia p ON p.provincia_id = l.localidad_provincia
	JOIN REDIS.BI_Ubicacion bu ON l.localidad_nombre = bu.localidad_nombre
		AND p.provincia_nombre = bu.provincia_nombre
	JOIN REDIS.BI_Rango_Etario brango ON brango.rango_etario_id =
		CASE 
		    WHEN DATEDIFF(YEAR, c.cliente_fecha_nacimiento, GETDATE()) < 25 THEN (SELECT rango_etario_id FROM REDIS.BI_Rango_Etario WHERE rango_descripcion = '< 25')
		    WHEN DATEDIFF(YEAR, c.cliente_fecha_nacimiento, GETDATE()) BETWEEN 25 AND 35 THEN (SELECT rango_etario_id FROM REDIS.BI_Rango_Etario WHERE rango_descripcion = '25 - 35')
		    WHEN DATEDIFF(YEAR, c.cliente_fecha_nacimiento, GETDATE()) BETWEEN 35 AND 50 THEN (SELECT rango_etario_id FROM REDIS.BI_Rango_Etario WHERE rango_descripcion = '35 - 50')
		    ELSE (SELECT rango_etario_id FROM REDIS.BI_Rango_Etario WHERE rango_descripcion = '> 50')
		END
GROUP BY
	bt.tiempo_id,
	bs.sucursal_id,
	brango.rango_etario_id,
	bu.ubicacion_id
GO

CREATE TABLE REDIS.BI_Hechos_Pago_Cuotas(
	tiempo_id INT, -- FK
	sucursal_id INT, -- FK
	medio_de_pago_id INT, --FK
	rango_etario_cliente_id INT, --FK
	pago_importe DECIMAL(18, 2),
	cantidad_de_cuotas DECIMAL(18, 0)
	FOREIGN KEY (tiempo_id) REFERENCES REDIS.BI_Tiempo(tiempo_id),
	FOREIGN KEY (sucursal_id) REFERENCES REDIS.BI_Sucursal(sucursal_id),
	FOREIGN KEY (medio_de_pago_id) REFERENCES REDIS.BI_Medio_De_Pago(medio_de_pago_id),
	FOREIGN KEY (rango_etario_cliente_id) REFERENCES REDIS.BI_Rango_Etario(rango_etario_id),
	PRIMARY KEY (tiempo_id, sucursal_id, medio_de_pago_id, rango_etario_cliente_id)
)
GO

INSERT INTO REDIS.BI_Hechos_Pago_Cuotas (tiempo_id, sucursal_id, medio_de_pago_id, rango_etario_cliente_id,
pago_importe, cantidad_de_cuotas)
SELECT
	bt.tiempo_id,
	bs.sucursal_id,
	bmp.medio_de_pago_id,
	brango.rango_etario_id,
	SUM(p.pago_importe),
	SUM(dp.cuotas)
FROM
	REDIS.Pago p
	JOIN REDIS.BI_Tiempo bt ON bt.anio = YEAR(p.pago_fecha)
                            AND bt.mes = DATEPART(MONTH, p.pago_fecha)
                            AND bt.cuatrimestre = 
                                CASE 
                                    WHEN DATEPART(MONTH, p.pago_fecha) BETWEEN 1 AND 4 THEN 1
                                    WHEN DATEPART(MONTH, p.pago_fecha) BETWEEN 5 AND 8 THEN 2
                                    WHEN DATEPART(MONTH, p.pago_fecha) BETWEEN 9 AND 12 THEN 3
                                END
	JOIN REDIS.Ticket t ON p.pago_ticket_numero = t.ticket_id
	JOIN REDIS.Sucursal s ON s.sucursal_id = t.ticket_sucursal_id
	JOIN REDIS.BI_Sucursal bs ON bs.sucursal_nombre = s.sucursal_nombre
	JOIN REDIS.Medio_Pago mp ON p.pago_medio_pago = mp.medio_pago
	JOIN REDIS.BI_Medio_De_Pago bmp ON bmp.medio_de_pago_descripcion = mp.medio_pago
	JOIN REDIS.Detalle_De_Pago dp ON p.pago_detalle_de_pago_id = dp.detalle_de_pago_id
	JOIN REDIS.Cliente c ON c.cliente_dni = dp.detalle_de_pago_cliente_dni
	JOIN REDIS.BI_Rango_Etario brango ON brango.rango_etario_id =
		CASE 
		    WHEN DATEDIFF(YEAR, c.cliente_fecha_nacimiento, GETDATE()) < 25 THEN (SELECT rango_etario_id FROM REDIS.BI_Rango_Etario WHERE rango_descripcion = '< 25')
		    WHEN DATEDIFF(YEAR, c.cliente_fecha_nacimiento, GETDATE()) BETWEEN 25 AND 35 THEN (SELECT rango_etario_id FROM REDIS.BI_Rango_Etario WHERE rango_descripcion = '25 - 35')
		    WHEN DATEDIFF(YEAR, c.cliente_fecha_nacimiento, GETDATE()) BETWEEN 35 AND 50 THEN (SELECT rango_etario_id FROM REDIS.BI_Rango_Etario WHERE rango_descripcion = '35 - 50')
			WHEN DATEDIFF(YEAR, c.cliente_fecha_nacimiento, GETDATE()) > 50 THEN (SELECT rango_etario_id FROM REDIS.BI_Rango_Etario WHERE rango_descripcion = '> 50')
		END
GROUP BY
	bt.tiempo_id,
	brango.rango_etario_id,
	bs.sucursal_id,
	bmp.medio_de_pago_id
GO

CREATE TABLE REDIS.BI_Hechos_Pago(
	tiempo_id INT, -- FK
	medio_de_pago_id INT, --FK
	pago_importe DECIMAL(18, 2),
	pago_descuento_aplicado DECIMAL(18, 2),
	FOREIGN KEY (tiempo_id) REFERENCES REDIS.BI_Tiempo(tiempo_id),
	FOREIGN KEY (medio_de_pago_id) REFERENCES REDIS.BI_Medio_De_Pago(medio_de_pago_id),
	PRIMARY KEY (tiempo_id, medio_de_pago_id)
)
GO

INSERT INTO REDIS.BI_Hechos_Pago (tiempo_id, medio_de_pago_id, pago_importe, pago_descuento_aplicado)
SELECT
	bt.tiempo_id,
	bmp.medio_de_pago_id,
	SUM(p.pago_importe),
	SUM(p.pago_descuento_aplicado)
FROM
	REDIS.Pago p
	JOIN REDIS.BI_Tiempo bt ON bt.anio = YEAR(p.pago_fecha)
                            AND bt.mes = DATEPART(MONTH, p.pago_fecha)
                            AND bt.cuatrimestre = 
                                CASE 
                                    WHEN DATEPART(MONTH, p.pago_fecha) BETWEEN 1 AND 4 THEN 1
                                    WHEN DATEPART(MONTH, p.pago_fecha) BETWEEN 5 AND 8 THEN 2
                                    WHEN DATEPART(MONTH, p.pago_fecha) BETWEEN 9 AND 12 THEN 3
                                END
	JOIN REDIS.Medio_Pago mp ON p.pago_medio_pago = mp.medio_pago
	JOIN REDIS.BI_Medio_De_Pago bmp ON bmp.medio_de_pago_descripcion = mp.medio_pago
GROUP BY
	bt.tiempo_id,
	bmp.medio_de_pago_id
GO

--------------------------------------
--------- VIEWS  ---------------------
--------------------------------------

CREATE VIEW REDIS.V_Ticket_Promedio_Mensual AS
SELECT
    bu.localidad_nombre AS Localidad,
    bt.anio AS Anio,
    bt.mes AS Mes,
    AVG(hv.importe_venta) AS Ticket_Promedio
FROM
    REDIS.BI_Hechos_Venta hv
JOIN
    REDIS.BI_Tiempo bt ON hv.tiempo_id = bt.tiempo_id
JOIN
    REDIS.BI_Ubicacion bu ON hv.ubicacion_id = bu.ubicacion_id
GROUP BY
    bu.localidad_nombre,
    bt.anio,
    bt.mes
GO

CREATE VIEW REDIS.V_Cantidad_Unidades_Promedio AS
SELECT
    bt.anio AS Anio,
    bt.cuatrimestre AS Cuatrimestre,
    bt.mes AS Mes,
    btu.turno_descripcion AS Turno,
    AVG(hv.cantidad_unidades) AS Cantidad_Unidades_Promedio
FROM
    REDIS.BI_Hechos_Venta hv
JOIN
    REDIS.BI_Tiempo bt ON hv.tiempo_id = bt.tiempo_id
JOIN
    REDIS.BI_Turno btu ON hv.turno_id = btu.turno_id
GROUP BY
    bt.anio,
    bt.cuatrimestre,
    bt.mes,
    btu.turno_descripcion
GO

CREATE VIEW REDIS.V_Porcentaje_Anual_De_Ventas AS
SELECT
    bt.anio AS Anio,
    bt.cuatrimestre AS Cuatrimestre,
    re.rango_descripcion AS Rango_Etario_Empleado,
    tc.tipo_caja_descripcion AS Tipo_Caja,
    SUM(hv.importe_venta) AS Ventas_Acumuladas,
    SUM(SUM(hv.importe_venta)) OVER (PARTITION BY bt.anio, re.rango_descripcion, tc.tipo_caja_descripcion) AS Total_Ventas_Annio,
    CAST((SUM(hv.importe_venta) * 100.0 / SUM(SUM(hv.importe_venta)) 
	OVER (PARTITION BY bt.anio, re.rango_descripcion, tc.tipo_caja_descripcion)) AS DECIMAL(18,2)) AS Porcentaje_Ventas
FROM
    REDIS.BI_Hechos_Venta hv
JOIN
    REDIS.BI_Tiempo bt ON hv.tiempo_id = bt.tiempo_id
JOIN
    REDIS.BI_Rango_Etario re ON hv.rango_etario_empleado_id = re.rango_etario_id
JOIN
    REDIS.BI_Tipo_Caja tc ON hv.tipo_caja_id = tc.tipo_caja_id
GROUP BY
    bt.anio,
    bt.cuatrimestre,
    re.rango_descripcion,
    tc.tipo_caja_descripcion
GO

CREATE VIEW REDIS.V_Cantidad_De_Ventas_Por_Turno AS
SELECT
    bt.anio,
    bt.mes,
    bu.localidad_nombre,
    bturno.turno_descripcion AS turno,
    COUNT(*) AS cantidad_ventas
FROM 
    REDIS.BI_Hechos_Venta hv
	JOIN REDIS.BI_Tiempo bt ON bt.tiempo_id = hv.tiempo_id
	JOIN REDIS.BI_Ubicacion bu ON bu.ubicacion_id = hv.ubicacion_id
	JOIN REDIS.BI_Turno bturno ON bturno.turno_id = hv.turno_id
GROUP BY
    bt.anio,
    bt.mes,
    bu.localidad_nombre,
    bturno.turno_descripcion
GO

CREATE VIEW REDIS.V_Porcentaje_Descuento_Tickets AS
SELECT
    bt.anio AS Anio,
    bt.mes AS Mes,
    SUM(hv.ticket_total_descuento_aplicado_total) AS Descuentos_Totales,
    SUM(hv.importe_venta) AS Total_Ventas,
    CAST((SUM(hv.ticket_total_descuento_aplicado_total) * 100.0 / SUM(hv.importe_venta)) AS DECIMAL(18,2)) AS Porcentaje_Descuento
FROM
    REDIS.BI_Hechos_Venta hv
JOIN
    REDIS.BI_Tiempo bt ON hv.tiempo_id = bt.tiempo_id
GROUP BY
    bt.anio,
    bt.mes
GO

CREATE VIEW REDIS.V_Top3_Categorias_Promociones AS
SELECT TOP 3
	bt.anio,
	bt.cuatrimestre,
	bcp.categoria_nombre
FROM
	REDIS.BI_Hechos_Promocion hp
	JOIN REDIS.BI_Tiempo bt ON bt.tiempo_id = hp.tiempo_id
	JOIN REDIS.BI_Categoria_Producto bcp ON bcp.categoria_producto_id = hp.categoria_id
GROUP BY
	bt.cuatrimestre,
	bt.anio,
	bcp.categoria_nombre
ORDER BY
	SUM(hp.promo_aplicada_descuento) DESC
GO

CREATE VIEW REDIS.V_Porcentaje_Cumplimiento_Envios AS
SELECT
    bs.sucursal_nombre,
    bt.anio,
    bt.mes,
    COUNT(he.maximo_costo_envio) AS total_envios,
    SUM(he.entregados_a_tiempo) AS envios_a_tiempo,
    SUM(he.entregados_fuera_de_tiempo) AS envios_fuera_de_tiempo,
    (SUM(he.entregados_a_tiempo) * 1.0 / COUNT(he.maximo_costo_envio)) * 100 AS porcentaje_cumplimiento
FROM
    REDIS.BI_Hechos_Envio he
    JOIN REDIS.BI_Sucursal bs ON he.sucursal_id = bs.sucursal_id
    JOIN REDIS.BI_Tiempo bt ON he.tiempo_id = bt.tiempo_id
GROUP BY
    bs.sucursal_nombre,
    bt.anio,
    bt.mes
GO

CREATE VIEW REDIS.V_Cantidad_Envios_Rango_Etario_Clientes AS
SELECT
    brango.rango_descripcion,
    bt.anio,
    bt.cuatrimestre,
    COUNT(he.maximo_costo_envio) AS cantidad_envios
FROM
    REDIS.BI_Hechos_Envio he
    JOIN REDIS.BI_Rango_Etario brango ON he.rango_etario_cliente_id = brango.rango_etario_id
    JOIN REDIS.BI_Tiempo bt ON he.tiempo_id = bt.tiempo_id
GROUP BY
    brango.rango_descripcion,
    bt.anio,
    bt.cuatrimestre
GO

CREATE VIEW REDIS.V_Top5_Localidades_Mayor_Costo_Envio AS
SELECT TOP 5
    bu.localidad_nombre,
    bu.provincia_nombre,
    MAX(be.maximo_costo_envio) AS costo_de_envio
FROM
    REDIS.BI_Hechos_Envio be
JOIN
    REDIS.BI_Ubicacion bu ON be.cliente_ubicacion_id = bu.ubicacion_id
GROUP BY
    bu.localidad_nombre,
    bu.provincia_nombre
ORDER BY
    costo_de_envio DESC
GO

CREATE VIEW REDIS.V_Top3_Sucursales_Pagos_Cuotas AS
SELECT TOP 3
	bt.anio,
	bt.mes,
	mp.medio_de_pago_descripcion,
	SUM(hp.pago_importe) AS importe
FROM
	REDIS.BI_Hechos_Pago_Cuotas hp
	JOIN REDIS.BI_Medio_De_Pago mp ON mp.medio_de_pago_id = hp.medio_de_pago_id
	JOIN REDIS.BI_Tiempo bt ON bt.tiempo_id = hp.tiempo_id
GROUP BY
	bt.anio,
	bt.mes,
	mp.medio_de_pago_descripcion
ORDER BY
	SUM(hp.pago_importe) DESC
GO

CREATE VIEW REDIS.V_Promedio_Importe_Cuota_Rango_Etario AS
SELECT
    re.rango_descripcion AS rango_etario_cliente,
	SUM(hp.pago_importe) / SUM(hp.cantidad_de_cuotas) AS promedio_importe_cuota
FROM
    REDIS.BI_Hechos_Pago_Cuotas hp
    JOIN REDIS.BI_Rango_Etario re ON hp.rango_etario_cliente_id = re.rango_etario_id
GROUP BY
    re.rango_descripcion
GO

CREATE VIEW REDIS.V_Porcentaje_Descuento_Medio_Pago AS
SELECT
	bt.anio,
	bt.cuatrimestre,
	bmp.medio_de_pago_descripcion,
	(SUM(hp.pago_descuento_aplicado) / SUM(hp.pago_importe + hp.pago_descuento_aplicado)) * 100 AS 'Porcentaje de descuento aplicado'
FROM
	REDIS.BI_Hechos_Pago hp
	JOIN REDIS.BI_Tiempo bt ON bt.tiempo_id = hp.tiempo_id
	JOIN REDIS.BI_Medio_De_Pago bmp ON bmp.medio_de_pago_id = hp.medio_de_pago_id
GROUP BY
	bt.anio,
	bt.cuatrimestre,
	bmp.medio_de_pago_descripcion
GO

--WITH TotalPagos AS (
--    SELECT
--        bt.cuatrimestre,
--        mp.medio_de_pago_descripcion,
--        SUM(p.pago_importe) AS total_pagos_sin_descuento,
--        SUM(p.pago_descuento_aplicado) AS total_descuentos_aplicados
--    FROM
--        REDIS.BI_Hechos_Pago p
--        JOIN REDIS.BI_Tiempo bt ON p.tiempo_id = bt.tiempo_id
--        JOIN REDIS.BI_Medio_De_Pago mp ON p.medio_de_pago_id = mp.medio_de_pago_id
--    GROUP BY
--        bt.cuatrimestre,
--        mp.medio_de_pago_descripcion
--)
--SELECT
--    cuatrimestre,
--    medio_de_pago_descripcion,
--    total_descuentos_aplicados AS total_descuentos_aplicados,
--    CASE
--        WHEN total_pagos_sin_descuento > 0 THEN
--            (total_descuentos_aplicados / total_pagos_sin_descuento) * 100
--        ELSE
--            0
--    END AS porcentaje_descuento_aplicado
--FROM
--    TotalPagos