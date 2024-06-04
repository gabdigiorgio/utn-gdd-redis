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
--------------- TABLES ---------------
--------------------------------------

CREATE TABLE REDIS.Provincia (
	provincia_id DECIMAL(18, 0) IDENTITY PRIMARY KEY,
	provincia_nombre NVARCHAR(255) NOT NULL
)
GO

CREATE TABLE REDIS.Localidad (
	localidad_id DECIMAL(18, 0) IDENTITY PRIMARY KEY,
	localidad_nombre NVARCHAR(255) NOT NULL,
	localidad_provincia DECIMAL(18, 0) NOT NULL -- FK
)
GO

CREATE TABLE REDIS.Super (
	super_nombre NVARCHAR(255) NOT NULL,
	super_razon_soc NVARCHAR(255) PRIMARY KEY,
	super_cuit NVARCHAR(255) NOT NULL,
	super_ibb NVARCHAR(255) NOT NULL,
	super_domicilio NVARCHAR(255) NOT NULL,
	super_fecha_ini_actividad DATETIME NOT NULL,
	super_localidad DECIMAL(18, 0) NOT NULL -- FK,
	super_condicion_fiscal NVARCHAR(255) NOT NULL 
)
GO

CREATE TABLE REDIS.Sucursal (
	sucursal_id DECIMAL(18,0) IDENTITY PRIMARY KEY,
	sucursal_nombre NVARCHAR(255) NOT NULL,
	sucursal_direccion NVARCHAR(255) NOT NULL,
	sucursal_localidad DECIMAL(18, 0) NOT NULL -- FK
)
GO

CREATE TABLE REDIS.Producto (
	producto_id DECIMAL(18, 0) PRIMARY KEY IDENTITY,
	producto_codigo NVARCHAR(255),
	producto_descripcion NVARCHAR(255) NOT NULL,
	producto_precio DECIMAL(18, 2) NOT NULL,
	producto_marca NVARCHAR(255) NOT NULL, -- FK,
	producto_subcategoria DECIMAL(18, 0) NOT NULL -- FK
)
GO

CREATE TABLE REDIS.Subcategoria_Producto (
	subcategoria_producto_id DECIMAL(18, 0) IDENTITY PRIMARY KEY,
	subcategoria_producto_nombre NVARCHAR(255),
categoria_producto NVARCHAR(255) NOT NULL -- FK
)
GO

CREATE TABLE REDIS.Categoria_Producto (
	categoria_producto_nombre NVARCHAR(255) PRIMARY KEY
)
GO

CREATE TABLE REDIS.Marca_Producto (
	marca_producto_nombre NVARCHAR(255) PRIMARY KEY
)
GO

CREATE TABLE REDIS.Promocion_Por_Producto (
    producto_id DECIMAL(18,0), --FK,
    promocion_codigo NVARCHAR(255), --FK
    promo_aplicada_descuento DECIMAL(18,2),
    promocion_fecha_inicio DATETIME,
    promocion_fecha_fin DATETIME,
    PRIMARY KEY (producto_id, promocion_codigo)
)
GO

CREATE TABLE REDIS.Promocion (
	promocion_codigo NVARCHAR(255) PRIMARY KEY,
	promocion_descripcion NVARCHAR(255) NOT NULL,
	promocion_regla_codigo DECIMAL(18, 0) NOT NULL --FK
)
GO

CREATE TABLE REDIS.Regla (
	regla_codigo DECIMAL(18, 0) IDENTITY PRIMARY KEY,
	regla_aplica_misma_marca DECIMAL(18, 0) NOT NULL,
	regla_aplica_mismo_prod DECIMAL(18, 0) NOT NULL,
	regla_cant_aplica_descuento DECIMAL(18, 0) NOT NULL,
	regla_cant_aplicable_regla DECIMAL(18, 0) NOT NULL,
	regla_cant_max_prod DECIMAL(18, 0) NOT NULl,
	regla_descripcion NVARCHAR(255) NOT NULL,
	regla_descuento_aplicable_prod DECIMAL(18, 2) NOT NULL
)
GO

CREATE TABLE REDIS.Empleado (
	empleado_legajo DECIMAL(18, 0) IDENTITY PRIMARY KEY,
	empleado_nombre NVARCHAR(255) NOT NULL,
	empleado_apellido NVARCHAR(255) NOT NULL,
	empleado_dni DECIMAL(18, 0) NOT NULL,
	empleado_fecha_registro DATETIME NOT NULL,
	empleado_fecha_nacimiento DATE NOT NULL,
	empleado_telefono DECIMAL(18, 0) NOT NULL,
	empleado_mail NVARCHAR(255) NOT NULL,
	empleado_sucursal_id DECIMAL(18, 0) NOT NULL --FK,
)	
GO

CREATE TABLE REDIS.Pago (
	pago_nro DECIMAL(18,0) IDENTITY PRIMARY KEY,
	pago_fecha DATETIME,
	pago_importe DECIMAL(18,2),
	pago_descuento_aplicado DECIMAL(18,2), --FK
	pago_ticket_numero DECIMAL(18,0), --FK
	pago_detalle_de_pago_id  DECIMAL(18,0),--FK
	pago_medio_pago NVARCHAR(255) --FK,
)
GO

CREATE TABLE REDIS.Medio_Pago (
	medio_pago NVARCHAR(255) PRIMARY KEY,
	tipo_medio_pago NVARCHAR(255) NOT NULL
)
GO


CREATE TABLE REDIS.Descuento (
	descuento_codigo DECIMAL(18,0) PRIMARY KEY,
	descuento_medio_de_pago NVARCHAR(255) NOT NULL, -- FK
	descuento_descripcion NVARCHAR(255),
	descuento_fecha_inicio DATETIME,
	descuento_fecha_fin DATETIME,
	descuento_procentaje_desc DECIMAL(18,2),
	descuento_tope DECIMAL(18,0),
)
GO


CREATE TABLE REDIS.Detalle_De_Pago (
	detalle_de_pago_id DECIMAL(18,0) IDENTITY PRIMARY KEY,
	detalle_de_pago_nro_tarjeta NVARCHAR(255),
	detalle_de_pago_fecha_venc_tarjeta DATETIME,
	cuotas DECIMAL(18,0),
	detalle_de_pago_cliente_dni DECIMAL(18,0), --FK
)
GO


CREATE TABLE REDIS.Cliente (
	cliente_dni DECIMAL(18,0) PRIMARY KEY,
	cliente_nombre NVARCHAR(255) NOT NULL,
	cliente_apellido NVARCHAR(255) NOT NULL,
	cliente_fecha_registro DATETIME NOT NULL,
	cliente_telefono DECIMAL(18,0),
	cliente_mail NVARCHAR(255),
	cliente_fecha_nacimiento DATE NOT NULL,
	cliente_domicilio NVARCHAR(255) NOT NULL,
	cliente_localidad DECIMAL(18,0) NOT NULL --FK
)
GO

CREATE TABLE REDIS.Envio (
	envio_numero DECIMAL(18,0) IDENTITY PRIMARY KEY,
	envio_costo DECIMAL(18,2),
	envio_fecha_programada DATETIME,
	envio_hora_inicio DECIMAL(18,0),
	envio_hora_fin DECIMAL(18,0),
	envio_fecha_entrega DATETIME,
	envio_estado NVARCHAR(255),
	envio_ticket_numero DECIMAL(18,0), --FK,
	envio_cliente_dni DECIMAL(18,0) --FK
)
GO

CREATE TABLE REDIS.Ticket (
	ticket_id DECIMAL (18, 0) IDENTITY PRIMARY KEY,
	ticket_numero DECIMAL(18,0) NOT NULL,
	ticket_fecha_hora DATETIME NOT NULL,
	ticket_tipo_comprobante NVARCHAR(255) NOT NULL,
	ticket_subtotal_productos DECIMAL(18,2) NOT NULL,
	ticket_total_descuento_aplicado DECIMAL(18,2) NOT NULL,
	ticket_total_descuento_aplicado_mp DECIMAL(18,2) NOT NULL,
	ticket_total_envio DECIMAL(18,2) NOT NULL,
	ticket_total_venta DECIMAL(18,2) NOT NULL,
	ticket_sucursal_id DECIMAL(18,0) NOT NULL, --FK,
	ticket_caja_numero DECIMAL(18,0) NOT NULL, --FK,
	ticket_empleado_legajo DECIMAL(18,0) NOT NULL --FK
)
GO

CREATE TABLE REDIS.Ticket_Detalle (
	ticket_detalle_id DECIMAL(18,0) PRIMARY KEY IDENTITY,
	producto_id DECIMAL(18,0), --FK,
	ticket_numero DECIMAL(18, 0), --FK,
	cantidad DECIMAL(18,0),
	precio_unitario DECIMAL(18,2),
	total_producto DECIMAL(18,2)
)
GO


CREATE TABLE REDIS.Caja (
	caja_numero DECIMAL(18,0) NOT NULL,
	caja_tipo NVARCHAR(255) NOT NULL,
	caja_sucursal_id DECIMAL(18,0) NOT NULL --FK
	PRIMARY KEY (caja_numero, caja_sucursal_id)
)
GO

--------------------------------------
------------ PROCEDURES --------------
--------------------------------------

CREATE PROCEDURE REDIS.migrar_Provincia AS
BEGIN
	INSERT INTO REDIS.Provincia 
	SELECT provincia_nombre
		FROM (
	SELECT CLIENTE_PROVINCIA AS provincia_nombre
	FROM gd_esquema.Maestra
	UNION
	SELECT SUCURSAL_PROVINCIA
	FROM gd_esquema.Maestra
	UNION
	SELECT SUPER_PROVINCIA
	FROM gd_esquema.Maestra
) AS Placeholder
WHERE provincia_nombre IS NOT NULL
END
GO

CREATE PROCEDURE REDIS.migrar_Localidad AS
BEGIN
	INSERT INTO REDIS.Localidad 
	SELECT DISTINCT localidad_nombre, localidad_provincia 
FROM (
SELECT 
			p.provincia_nombre,
			m.CLIENTE_LOCALIDAD AS localidad_nombre,
			p.provincia_id AS localidad_provincia
FROM 
gd_esquema.Maestra m,
REDIS.Provincia p
UNION
SELECT 
p.provincia_nombre, 
m.SUCURSAL_LOCALIDAD,
p.provincia_id
FROM 
gd_esquema.Maestra m,
REDIS.Provincia p
UNION
SELECT 
p.provincia_nombre, 
m.SUPER_LOCALIDAD,
p.provincia_id
FROM 
gd_esquema.Maestra m,
REDIS.Provincia p
) AS Placeholder
WHERE localidad_nombre IS NOT NULL AND localidad_provincia IS NOT NULL
END
GO

CREATE PROCEDURE REDIS.migrar_Super AS 
BEGIN
	INSERT INTO REDIS.Super
	SELECT DISTINCT
	m.SUPER_NOMBRE,
	m.SUPER_RAZON_SOC,
	m.SUPER_CUIT,
	m.SUPER_IIBB,
	m.SUPER_DOMICILIO,
	m.SUPER_FECHA_INI_ACTIVIDAD,
	l.localidad_id,
	m.SUPER_CONDICION_FISCAL
FROM 
	gd_esquema.Maestra m,
	REDIS.Localidad l,
	REDIS.Provincia p
WHERE m.SUPER_LOCALIDAD = l.localidad_nombre AND p.provincia_id = l.localidad_provincia AND p.provincia_nombre = m.SUPER_PROVINCIA
END
GO
		
CREATE PROCEDURE REDIS.migrar_Sucursal AS
BEGIN
	INSERT INTO REDIS.Sucursal
	SELECT DISTINCT
	m.SUCURSAL_NOMBRE,
	m.SUCURSAL_DIRECCION,
	l.localidad_id
FROM 
	gd_esquema.Maestra m,
	REDIS.Localidad l,
	REDIS.Provincia p
WHERE m.SUCURSAL_LOCALIDAD = l.localidad_nombre 
AND p.provincia_id = l.localidad_provincia AND p.provincia_nombre = m.SUCURSAL_PROVINCIA
END
GO


CREATE PROCEDURE REDIS.migrar_Caja AS
BEGIN
	INSERT INTO REDIS.Caja (caja_numero, caja_tipo, caja_sucursal_id)
	SELECT DISTINCT
		CAJA_NUMERO,
		CAJA_TIPO,
		s.sucursal_id
	FROM 
		gd_esquema.Maestra m,
		REDIS.Sucursal s
	WHERE 
		m.SUCURSAL_NOMBRE = s.sucursal_nombre 
		AND CAJA_NUMERO IS NOT NULL
	ORDER BY CAJA_NUMERO ASC
END
GO

CREATE PROCEDURE REDIS.migrar_Empleado AS
BEGIN
	INSERT INTO REDIS.Empleado (
        empleado_nombre,
        empleado_apellido,
        empleado_dni,
        empleado_fecha_registro,
        empleado_fecha_nacimiento,
        empleado_telefono,
        empleado_mail,
        empleado_sucursal_id
    )
	SELECT DISTINCT
		EMPLEADO_NOMBRE,
		EMPLEADO_APELLIDO,
		EMPLEADO_DNI,
		EMPLEADO_FECHA_REGISTRO,
		EMPLEADO_FECHA_NACIMIENTO,
		EMPLEADO_TELEFONO,
		EMPLEADO_MAIL,
		s.sucursal_id
	FROM 
		gd_esquema.Maestra m,
		REDIS.Sucursal s
	WHERE 
	EMPLEADO_NOMBRE IS NOT NULL
	AND s.sucursal_nombre = m.SUCURSAL_NOMBRE
	ORDER BY EMPLEADO_NOMBRE ASC
END
GO
CREATE PROCEDURE REDIS.migrar_Categoria_Producto AS
BEGIN
	INSERT INTO REDIS.Categoria_Producto
	SELECT DISTINCT 
    REPLACE(PRODUCTO_CATEGORIA, 'Categoria N�', '')
	FROM gd_esquema.Maestra
	WHERE PRODUCTO_CATEGORIA IS NOT NULL
END
GO

CREATE PROCEDURE REDIS.migrar_Subcategoria_Producto AS
BEGIN
	INSERT INTO REDIS.Subcategoria_Producto(
		subcategoria_producto_nombre,
        categoria_producto
		)
	SELECT DISTINCT 
		REPLACE(m.PRODUCTO_SUB_CATEGORIA, 'SubCategoria N�', '') PRODUCTO_SUBCATEGORIA,
		REPLACE(m.PRODUCTO_CATEGORIA, 'Categoria N�', '') PRODUCTO_CATEGORIA
	FROM 
		gd_esquema.Maestra m
	WHERE 
		m.PRODUCTO_SUB_CATEGORIA IS NOT NULL
		AND REPLACE(m.PRODUCTO_CATEGORIA, 'Categoria N�', '') 
		IN (SELECT categoria_producto_nombre FROM REDIS.Categoria_Producto)
END
GO

CREATE PROCEDURE REDIS.migrar_Ticket AS
BEGIN
	INSERT INTO REDIS.Ticket
	SELECT DISTINCT 
		TICKET_NUMERO,
		TICKET_FECHA_HORA,
		TICKET_TIPO_COMPROBANTE,
		TICKET_SUBTOTAL_PRODUCTOS,
		TICKET_TOTAL_DESCUENTO_APLICADO,
		TICKET_TOTAL_DESCUENTO_APLICADO_MP,
		TICKET_TOTAL_ENVIO,
		TICKET_TOTAL_TICKET,
		s.sucursal_id,
		c.caja_numero,
		e.empleado_legajo
	FROM 
		gd_esquema.Maestra m,
		REDIS.Sucursal s,
		REDIS.Caja c,
		REDIS.Empleado e
	WHERE 
		m.CAJA_NUMERO IS NOT NULL
		AND s.sucursal_nombre = m.SUCURSAL_NOMBRE
		AND c.caja_numero = m.CAJA_NUMERO
		AND e.empleado_dni = m.EMPLEADO_DNI
END
GO

CREATE PROCEDURE REDIS.migrar_Cliente AS 
BEGIN
	INSERT INTO REDIS.Cliente
	SELECT DISTINCT
		m.CLIENTE_DNI,
		m.CLIENTE_NOMBRE,
		m.CLIENTE_APELLIDO,
		m.CLIENTE_FECHA_REGISTRO,
		m.CLIENTE_TELEFONO,
		m.CLIENTE_MAIL,
		m.CLIENTE_FECHA_NACIMIENTO,
		m.CLIENTE_DOMICILIO,
		l.localidad_id
	FROM 
		gd_esquema.Maestra m,
		REDIS.Localidad l,
		REDIS.Provincia p
	WHERE 
		CLIENTE_DNI IS NOT NULL 
		AND m.CLIENTE_LOCALIDAD = l.localidad_nombre 
		AND p.provincia_id = l.localidad_provincia 
		AND p.provincia_nombre = m.CLIENTE_PROVINCIA
END
GO

CREATE PROCEDURE REDIS.migrar_Medio_Pago AS
BEGIN
	INSERT INTO REDIS.Medio_Pago
	SELECT DISTINCT
		PAGO_MEDIO_PAGO, 
		PAGO_TIPO_MEDIO_PAGO
	FROM 
		gd_esquema.Maestra m
	WHERE 
	PAGO_MEDIO_PAGO IS NOT NULL
END
GO


CREATE PROCEDURE REDIS.migrar_Detalle_De_Pago AS
BEGIN
	INSERT INTO REDIS.Detalle_De_Pago(
        detalle_de_pago_nro_tarjeta,
        detalle_de_pago_fecha_venc_tarjeta,
        cuotas,
        detalle_de_pago_cliente_dni
    )
	SELECT DISTINCT
    (SELECT TOP 1 PAGO_TARJETA_NRO 
     FROM gd_esquema.Maestra sub1 
     WHERE sub1.TICKET_NUMERO = main.TICKET_NUMERO AND sub1.PAGO_TARJETA_NRO IS NOT NULL) AS PAGO_TARJETA_NRO,
     PAGO_TARJETA_FECHA_VENC,
	 PAGO_TARJETA_CUOTAS,
	(SELECT TOP 1 CLIENTE_DNI 
    FROM gd_esquema.Maestra sub2 
    WHERE sub2.TICKET_NUMERO = main.TICKET_NUMERO AND sub2.CLIENTE_DNI IS NOT NULL) AS CLIENTE_DNI
FROM gd_esquema.Maestra main
WHERE PAGO_IMPORTE IS NOT NULL AND PAGO_TARJETA_NRO IS NOT NULL
END
GO


CREATE PROCEDURE REDIS.migrar_Descuento AS
BEGIN
	INSERT INTO REDIS.Descuento 
	SELECT DISTINCT
		DESCUENTO_CODIGO,
		mp.medio_pago,
		DESCUENTO_DESCRIPCION,
		DESCUENTO_FECHA_INICIO,
		DESCUENTO_FECHA_FIN,
		DESCUENTO_PORCENTAJE_DESC,
		DESCUENTO_TOPE
	FROM 
		gd_esquema.Maestra m,
		REDIS.Medio_Pago mp
	WHERE 
		DESCUENTO_CODIGO IS NOT NULL
		AND mp.medio_pago = m.PAGO_MEDIO_PAGO
END
GO


CREATE PROCEDURE REDIS.migrar_Envio AS
BEGIN
	INSERT INTO REDIS.Envio 
	SELECT 
	ENVIO_COSTO,
	ENVIO_FECHA_PROGRAMADA,
	ENVIO_HORA_INICIO,
	ENVIO_HORA_FIN,
	ENVIO_FECHA_ENTREGA,
	ENVIO_ESTADO,
	TICKET_NUMERO,
	c.cliente_dni
FROM 
	gd_esquema.Maestra m,
	REDIS.Cliente c
WHERE ENVIO_COSTO IS NOT NULL
AND c.cliente_dni = m.CLIENTE_DNI
ORDER BY TICKET_NUMERO
END
GO


CREATE PROCEDURE REDIS.migrar_Pago AS
BEGIN
	INSERT INTO REDIS.Pago 
	SELECT
	PAGO_FECHA,
	PAGO_IMPORTE,
	PAGO_DESCUENTO_APLICADO,
    t.ticket_numero, 
    CASE 
        WHEN m.PAGO_MEDIO_PAGO = 'Efectivo' THEN NULL
        ELSE dp.detalle_de_pago_id 
    END AS detalle_de_pago_id,
	PAGO_MEDIO_PAGO
FROM 
	REDIS.Ticket t,
    gd_esquema.Maestra m
LEFT JOIN 
    REDIS.Detalle_De_Pago dp ON dp.detalle_de_pago_nro_tarjeta = m.PAGO_TARJETA_NRO
WHERE 
    PAGO_MEDIO_PAGO IS NOT NULL
	AND t.ticket_numero = m.TICKET_NUMERO
END
GO


CREATE PROCEDURE REDIS.migrar_Promocion AS
BEGIN
	INSERT INTO REDIS.Promocion 
	SELECT DISTINCT
	PROMO_CODIGO,
	PROMOCION_DESCRIPCION,
	r.regla_codigo
FROM gd_esquema.Maestra m,
REDIS.Regla r
WHERE r.regla_descripcion = m.REGLA_DESCRIPCION
END
GO

CREATE PROCEDURE REDIS.migrar_Producto AS
BEGIN
	INSERT INTO REDIS.Producto 
	SELECT DISTINCT
	REPLACE(PRODUCTO_NOMBRE, 'Codigo:', '') AS PRODUCTO_CODIGO,
	PRODUCTO_DESCRIPCION,
	PRODUCTO_PRECIO,
	REPLACE(PRODUCTO_MARCA, 'Marca N�', '') AS MARCA, 
	sp.subcategoria_producto_id AS SUBCATEGORIA
FROM 
	gd_esquema.Maestra m,
	REDIS.Marca_Producto mp,
	REDIS.Subcategoria_Producto sp
WHERE PRODUCTO_DESCRIPCION IS NOT NULL
AND mp.marca_producto_nombre = REPLACE(PRODUCTO_MARCA, 'Marca N�', '')
AND sp.subcategoria_producto_nombre = REPLACE(PRODUCTO_SUB_CATEGORIA, 'SubCategoria N�', '')
ORDER BY PRODUCTO_CODIGO
END
GO

CREATE PROCEDURE REDIS.migrar_Promocion_Por_Producto AS
BEGIN
    WITH CTE AS (
        SELECT 
            p.producto_id,
            PROMO_CODIGO,
            PROMO_APLICADA_DESCUENTO,
            PROMOCION_FECHA_INICIO,
            PROMOCION_FECHA_FIN,
            ROW_NUMBER() OVER (PARTITION BY p.producto_id, PROMO_CODIGO ORDER BY PROMO_APLICADA_DESCUENTO DESC) AS rn
        FROM 
            gd_esquema.Maestra m
            JOIN REDIS.Producto p ON REPLACE(m.PRODUCTO_NOMBRE, 'Codigo:', '') = p.producto_codigo
                                 AND REPLACE(m.PRODUCTO_MARCA, 'Marca N�', '') = p.producto_marca
        WHERE
            PROMO_CODIGO IS NOT NULL
    )
    INSERT INTO REDIS.Promocion_Por_Producto 
    SELECT
        producto_id,
        PROMO_CODIGO,
        PROMO_APLICADA_DESCUENTO,
        PROMOCION_FECHA_INICIO,
        PROMOCION_FECHA_FIN
    FROM CTE
    WHERE rn = 1
END
GO

CREATE PROCEDURE REDIS.migrar_Ticket_Detalle AS
BEGIN
	INSERT INTO REDIS.Ticket_Detalle 
	SELECT DISTINCT
	p.producto_id,
	t.ticket_numero,
	TICKET_DET_CANTIDAD,
	TICKET_DET_PRECIO,
	TICKET_DET_TOTAL
FROM 
	gd_esquema.Maestra m,
	REDIS.Producto p,
	REDIS.Ticket t
WHERE 
	REPLACE(m.PRODUCTO_NOMBRE, 'Codigo:', '') = p.producto_codigo
	AND REPLACE(m.PRODUCTO_MARCA, 'Marca N�', '') = p.producto_marca
	AND t.ticket_numero = m.TICKET_NUMERO
ORDER BY ticket_numero
END
GO

--------------------------------------
---------- DATA MIGRATION ------------
--------------------------------------

BEGIN TRANSACTION 
	EXECUTE REDIS.migrar_Provincia
	EXECUTE REDIS.migrar_Localidad
	EXECUTE REDIS.migrar_Localidad
	EXECUTE REDIS.migrar_Super
	EXECUTE REDIS.migrar_Sucursal
	EXECUTE REDIS.migrar_Caja
	EXECUTE REDIS.migrar_Empleado
	EXECUTE REDIS.migrar_Categoria_Producto
	EXECUTE REDIS.migrar_Subcategoria_Producto
	EXECUTE REDIS.migrar_Ticket
	EXECUTE REDIS.migrar_Cliente
	EXECUTE REDIS.migrar_Medio_Pago
	EXECUTE REDIS.migrar_Detalle_De_Pago
	EXECUTE REDIS.migrar_Descuento
	EXECUTE REDIS.migrar_Envio
	EXECUTE REDIS.migrar_Pago
	EXECUTE REDIS.migrar_Promocion
	EXECUTE REDIS.migrar_Producto
	EXECUTE REDIS.migrar_Promocion_Por_Producto
	EXECUTE REDIS.migrar_Ticket_Detalle
COMMIT TRANSACTION

--------------------------------------
------------ FOREING KEYS ------------
--------------------------------------

ALTER TABLE REDIS.Localidad
ADD FOREIGN KEY (localidad_provincia) REFERENCES REDIS.Provincia(provincia_id)

ALTER TABLE REDIS.Super
ADD FOREIGN KEY (super_localidad) REFERENCES REDIS.Localidad(localidad_id)

ALTER TABLE REDIS.Sucursal
ADD FOREIGN KEY (sucursal_localidad) REFERENCES REDIS.Localidad(localidad_id)

ALTER TABLE REDIS.Producto
ADD FOREIGN KEY (producto_subcategoria) REFERENCES REDIS.Subcategoria_producto(subcategoria_producto_id)

ALTER TABLE REDIS.Producto
ADD FOREIGN KEY (producto_marca) REFERENCES REDIS.Marca_Producto(marca_producto_nombre)

ALTER TABLE REDIS.Subcategoria_Producto
ADD FOREIGN KEY (categoria_producto) REFERENCES REDIS.Categoria_Producto(categoria_producto_nombre)

ALTER TABLE REDIS.Promocion_Por_Producto
ADD FOREIGN KEY (producto_id) REFERENCES REDIS.Producto(producto_id)

ALTER TABLE REDIS.Promocion_Por_Producto
ADD FOREIGN KEY (promocion_codigo) REFERENCES REDIS.Promocion(promocion_codigo)

ALTER TABLE REDIS.Promocion
ADD FOREIGN KEY (promocion_regla_codigo) REFERENCES REDIS.Regla(regla_codigo)

ALTER TABLE REDIS.Empleado
ADD FOREIGN KEY (empleado_sucursal_id) REFERENCES REDIS.Sucursal(sucursal_id)

ALTER TABLE REDIS.Pago
ADD FOREIGN KEY (pago_ticket_numero) REFERENCES REDIS.Ticket (ticket_numero)
-- ARREGLAR

ALTER TABLE REDIS.Descuento
ADD FOREIGN KEY (descuento_medio_de_pago) REFERENCES REDIS.Medio_Pago (medio_pago)

ALTER TABLE REDIS.Detalle_De_Pago
ADD FOREIGN KEY (detalle_de_pago_cliente_dni) REFERENCES REDIS.Cliente (cliente_dni)

ALTER TABLE REDIS.Cliente
ADD FOREIGN KEY (cliente_localidad) REFERENCES REDIS.Localidad (localidad_id)

--ALTER TABLE REDIS.Envio
--ADD FOREIGN KEY (envio_ticket_numero) REFERENCES REDIS.Ticket (ticket_numero)
-- ARREGLAR

ALTER TABLE REDIS.Envio
ADD FOREIGN KEY (envio_cliente_dni) REFERENCES REDIS.Cliente (cliente_dni)

ALTER TABLE REDIS.Ticket
ADD FOREIGN KEY (ticket_sucursal_id) REFERENCES REDIS.Sucursal (sucursal_id)

ALTER TABLE REDIS.Ticket
ADD FOREIGN KEY (ticket_caja_numero, ticket_sucursal_id) REFERENCES REDIS.Caja (caja_numero, caja_sucursal_id)

ALTER TABLE REDIS.Ticket
ADD FOREIGN KEY (ticket_empleado_legajo) REFERENCES REDIS.Empleado (empleado_legajo)

--ALTER TABLE REDIS.Ticket_Detalle
--ADD FOREIGN KEY (ticket_numero) REFERENCES REDIS.Ticket (ticket_numero)
-- ARREGLAR

ALTER TABLE REDIS.Ticket_Detalle
ADD FOREIGN KEY (producto_id) REFERENCES REDIS.Producto (producto_id)

ALTER TABLE REDIS.Caja
ADD FOREIGN KEY (caja_sucursal_id) REFERENCES REDIS.Sucursal (sucursal_id)