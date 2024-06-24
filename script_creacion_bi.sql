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

CREATE TABLE REDIS.BI_Ubicacion
(
	ubicacion_id INT IDENTITY PRIMARY KEY,
	localidad_nombre NVARCHAR(255),
	provincia_nombre NVARCHAR(255)
)

CREATE TABLE REDIS.BI_Rango_Etario
(
	rango_etario_id INT IDENTITY PRIMARY KEY,
	rango_descripcion NVARCHAR(255)
)

CREATE TABLE REDIS.BI_Medio_De_Pago
(
	medio_de_pago_id INT IDENTITY PRIMARY KEY,
	medio_de_pago_descripcion NVARCHAR(255)
)

CREATE TABLE REDIS.BI_Turno
(
	turno_id INT IDENTITY PRIMARY KEY,
	turno_descripcion NVARCHAR(255)
)

--CREATE TABLE REDIS.BI_Hechos_Venta
--(
--	venta_id INT IDENTITY PRIMARY KEY,
--	tiempo_id INT,
--	ubicacion_id INT,
--	rango_etario_cliente_id INT,
--	rango_etario_empleado_id INT,
--	turno_id INT,
--	medio_de_pago_id INT,
--	importe_venta DECIMAL(18, 2),
--	cantidad_unidades DECIMAL(18,0),
--	FOREIGN KEY (tiempo_id) REFERENCES BI_Tiempo(tiempo_id),
--	FOREIGN KEY (ubicacion_id) REFERENCES BI_Ubicacion(ubicacion_id),
--)