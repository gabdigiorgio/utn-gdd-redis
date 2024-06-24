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

-- Hechos
IF OBJECT_ID('REDIS.BI_Hechos_Venta', 'U') IS NOT NULL DROP TABLE REDIS.BI_Hechos_Venta;

-- Dimensiones
IF OBJECT_ID('REDIS.BI_Tiempo', 'U') IS NOT NULL DROP TABLE REDIS.BI_Tiempo;
IF OBJECT_ID('REDIS.BI_Ubicacion', 'U') IS NOT NULL DROP TABLE REDIS.BI_Ubicacion;
IF OBJECT_ID('REDIS.BI_Rango_Etario', 'U') IS NOT NULL DROP TABLE REDIS.BI_Rango_Etario;
IF OBJECT_ID('REDIS.BI_Medio_De_Pago', 'U') IS NOT NULL DROP TABLE REDIS.BI_Medio_De_Pago;
IF OBJECT_ID('REDIS.BI_Turno', 'U') IS NOT NULL DROP TABLE REDIS.BI_Turno;

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

--------------------------------------
--------- INSERT DATA ----------------
--------- DIMENSIONS -----------------
--------------------------------------

INSERT INTO REDIS.BI_Tiempo(anio, cuatrimestre, mes)
SELECT
    YEAR(t.ticket_fecha_hora) AS anio,
    DATEPART(QUARTER, t.ticket_fecha_hora) AS cuatrimestre,
    DATEPART(MONTH, t.ticket_fecha_hora) AS mes
FROM REDIS.Ticket t
GROUP BY 
    YEAR(t.ticket_fecha_hora), 
    DATEPART(QUARTER, t.ticket_fecha_hora), 
    DATEPART(MONTH, t.ticket_fecha_hora)
ORDER BY mes
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
GO

INSERT INTO REDIS.BI_Rango_Etario(rango_descripcion)
SELECT DISTINCT
    CASE 
        WHEN DATEDIFF(YEAR, empleado_fecha_nacimiento, GETDATE()) < 25 THEN '< 25'
        WHEN DATEDIFF(YEAR, empleado_fecha_nacimiento, GETDATE()) BETWEEN 25 AND 35 THEN '25 - 35'
        WHEN DATEDIFF(YEAR, empleado_fecha_nacimiento, GETDATE()) BETWEEN 35 AND 50 THEN '35 - 50'
        ELSE '> 50'
    END AS rango_etario
FROM REDIS.Empleado
UNION
SELECT DISTINCT
    CASE 
        WHEN DATEDIFF(YEAR, cliente_fecha_nacimiento, GETDATE()) < 25 THEN '< 25'
        WHEN DATEDIFF(YEAR, cliente_fecha_nacimiento, GETDATE()) BETWEEN 25 AND 35 THEN '25 - 35'
        WHEN DATEDIFF(YEAR, cliente_fecha_nacimiento, GETDATE()) BETWEEN 35 AND 50 THEN '35 - 50'
        ELSE '> 50'
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

--------------------------------------
--------- FACTS TABLES  --------------
--------------------------------------

CREATE TABLE REDIS.BI_Hechos_Venta
(
	venta_id INT IDENTITY PRIMARY KEY,
	tiempo_id INT, -- FK
	ubicacion_id INT, -- FK
	rango_etario_cliente_id INT, -- FK
	rango_etario_empleado_id INT, -- FK
	turno_id INT, -- FK
	medio_de_pago_id INT, -- FK
	importe_venta DECIMAL(18, 2),
	cantidad_unidades DECIMAL(18,0),
	FOREIGN KEY (tiempo_id) REFERENCES REDIS.BI_Tiempo(tiempo_id),
	FOREIGN KEY (ubicacion_id) REFERENCES REDIS.BI_Ubicacion(ubicacion_id),
	FOREIGN KEY (rango_etario_cliente_id) REFERENCES REDIS.BI_Rango_Etario(rango_etario_id),
	FOREIGN KEY (rango_etario_empleado_id) REFERENCES REDIS.BI_Rango_Etario(rango_etario_id),
	FOREIGN KEY (turno_id) REFERENCES REDIS.BI_Turno(turno_id),
	FOREIGN KEY (medio_de_pago_id) REFERENCES REDIS.BI_Medio_De_Pago(medio_de_pago_id),
)
GO

INSERT INTO REDIS.BI_Hechos_Venta (
    tiempo_id, ubicacion_id, importe_venta, cantidad_unidades
)
SELECT
    bt.tiempo_id,
    bu.ubicacion_id,
    t.ticket_total_venta AS importe_venta,
	SUM(td.cantidad) AS cantidad_unidades
FROM 
	REDIS.Ticket t
	JOIN REDIS.Sucursal s ON t.ticket_sucursal_id = s.sucursal_id
	JOIN REDIS.Localidad l ON s.sucursal_localidad = l.localidad_id
	JOIN REDIS.Provincia p ON l.localidad_provincia = p.provincia_id
	JOIN REDIS.BI_Tiempo bt ON YEAR(t.ticket_fecha_hora) = bt.anio
		AND MONTH(t.ticket_fecha_hora) = bt.mes
	JOIN REDIS.BI_Ubicacion bu ON l.localidad_nombre = bu.localidad_nombre
		AND p.provincia_nombre = bu.provincia_nombre
	JOIN REDIS.Ticket_Detalle td ON td.ticket_numero = t.ticket_id
GROUP BY
    bt.tiempo_id,
    bu.ubicacion_id,
    t.ticket_total_venta
GO

--------------------------------------
--------- VIEWS  ---------------------
--------------------------------------

CREATE VIEW REDIS.V_Ticket_Promedio_Mensual AS
SELECT
    BU.localidad_nombre AS Localidad,
    bt.anio AS Anio,
    bt.mes AS Mes,
    AVG(hv.importe_venta) AS Ticket_Promedio
FROM
    REDIS.BI_Hechos_Venta hv
JOIN
    REDIS.BI_Tiempo bt ON hv.tiempo_id = bt.tiempo_id
JOIN
    REDIS.BI_Ubicacion BU ON hv.ubicacion_id = BU.ubicacion_id
GROUP BY
    bu.localidad_nombre,
    bt.anio,
    bt.mes
GO
