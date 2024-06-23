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

-----------------------------------------
-------------- DROP TABLES --------------
-----------------------------------------

IF OBJECT_ID('REDIS.Detalle_De_Pago', 'U') IS NOT NULL DROP TABLE REDIS.Detalle_De_Pago;
IF OBJECT_ID('REDIS.Descuento_Por_Pago', 'U') IS NOT NULL DROP TABLE REDIS.Descuento_Por_Pago;
IF OBJECT_ID('REDIS.Pago', 'U') IS NOT NULL DROP TABLE REDIS.Pago;
IF OBJECT_ID('REDIS.Envio', 'U') IS NOT NULL DROP TABLE REDIS.Envio;
IF OBJECT_ID('REDIS.Promocion_Por_Ticket', 'U') IS NOT NULL DROP TABLE REDIS.Promocion_Por_Ticket;
IF OBJECT_ID('REDIS.Ticket', 'U') IS NOT NULL DROP TABLE REDIS.Ticket;
IF OBJECT_ID('REDIS.Super', 'U') IS NOT NULL DROP TABLE REDIS.Super;
IF OBJECT_ID('REDIS.Ticket_Detalle', 'U') IS NOT NULL DROP TABLE REDIS.Ticket_Detalle;
IF OBJECT_ID('REDIS.Promocion_Por_Producto', 'U') IS NOT NULL DROP TABLE REDIS.Promocion_Por_Producto;
IF OBJECT_ID('REDIS.Producto', 'U') IS NOT NULL DROP TABLE REDIS.Producto;
IF OBJECT_ID('REDIS.Subcategoria_Producto', 'U') IS NOT NULL DROP TABLE REDIS.Subcategoria_Producto;
IF OBJECT_ID('REDIS.Categoria_Producto', 'U') IS NOT NULL DROP TABLE REDIS.Categoria_Producto;
IF OBJECT_ID('REDIS.Marca_Producto', 'U') IS NOT NULL DROP TABLE REDIS.Marca_Producto;
IF OBJECT_ID('REDIS.Promocion', 'U') IS NOT NULL DROP TABLE REDIS.Promocion;
IF OBJECT_ID('REDIS.Regla', 'U') IS NOT NULL DROP TABLE REDIS.Regla;
IF OBJECT_ID('REDIS.Empleado', 'U') IS NOT NULL DROP TABLE REDIS.Empleado;
IF OBJECT_ID('REDIS.Medio_Pago', 'U') IS NOT NULL DROP TABLE REDIS.Medio_Pago;
IF OBJECT_ID('REDIS.Descuento', 'U') IS NOT NULL DROP TABLE REDIS.Descuento;
IF OBJECT_ID('REDIS.Cliente', 'U') IS NOT NULL DROP TABLE REDIS.Cliente;
IF OBJECT_ID('REDIS.Caja', 'U') IS NOT NULL DROP TABLE REDIS.Caja;
IF OBJECT_ID('REDIS.Sucursal', 'U') IS NOT NULL DROP TABLE REDIS.Sucursal;
IF OBJECT_ID('REDIS.Localidad', 'U') IS NOT NULL DROP TABLE REDIS.Localidad;
IF OBJECT_ID('REDIS.Provincia', 'U') IS NOT NULL DROP TABLE REDIS.Provincia;

-------------------------------------------
-------------- CREATE TABLES --------------
-------------------------------------------

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
	super_localidad DECIMAL(18, 0) NOT NULL, -- FK
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
	pago_descuento_aplicado DECIMAL(18,2),
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
	descuento_descripcion NVARCHAR(255),
	descuento_fecha_inicio DATETIME,
	descuento_fecha_fin DATETIME,
	descuento_procentaje_desc DECIMAL(18,2),
	descuento_tope DECIMAL(18,0),
)
GO

CREATE TABLE REDIS.Descuento_Por_pago (
	descuento_codigo DECIMAL(18,0) NOT NULL, --FK
	descuento_pago_nro DECIMAL(18,0) NOT NULL, -- FK
	PRIMARY KEY (descuento_codigo, descuento_pago_nro)
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

CREATE TABLE REDIS.Promocion_Por_Ticket (
	promocion_codigo NVARCHAR(255) NOT NULL,
	ticket_detalle_id DECIMAL(18,0) NOT NULL,
	promo_aplicada_descuento DECIMAL(18,2) NOT NULL
	PRIMARY KEY (promocion_codigo, ticket_detalle_id)
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
		SELECT 
			CLIENTE_PROVINCIA AS provincia_nombre
		FROM 
			gd_esquema.Maestra
		UNION
		SELECT 
			SUCURSAL_PROVINCIA
		FROM 
			gd_esquema.Maestra
		UNION
		SELECT 
			SUPER_PROVINCIA
		FROM 
			gd_esquema.Maestra
		) AS Placeholder
	WHERE 
		provincia_nombre IS NOT NULL
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
	WHERE 
		localidad_nombre IS NOT NULL 
		AND localidad_provincia IS NOT NULL
	ORDER BY localidad_nombre
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
	WHERE 
		m.SUPER_LOCALIDAD = l.localidad_nombre 
		AND p.provincia_id = l.localidad_provincia 
		AND p.provincia_nombre = m.SUPER_PROVINCIA
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
	WHERE 
		m.SUCURSAL_LOCALIDAD = l.localidad_nombre 
		AND p.provincia_id = l.localidad_provincia 
		AND p.provincia_nombre = m.SUCURSAL_PROVINCIA
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
		PRODUCTO_CATEGORIA
	FROM 
		gd_esquema.Maestra
	WHERE 
		PRODUCTO_CATEGORIA IS NOT NULL
END
GO

CREATE PROCEDURE REDIS.migrar_Subcategoria_Producto AS
BEGIN
	INSERT INTO REDIS.Subcategoria_Producto(
		subcategoria_producto_nombre,
        categoria_producto
		)
	SELECT DISTINCT 
		m.PRODUCTO_SUB_CATEGORIA PRODUCTO_SUBCATEGORIA,
		m.PRODUCTO_CATEGORIA PRODUCTO_CATEGORIA
	FROM 
		gd_esquema.Maestra m
	WHERE 
		m.PRODUCTO_SUB_CATEGORIA IS NOT NULL
		AND m.PRODUCTO_CATEGORIA IN (SELECT categoria_producto_nombre FROM REDIS.Categoria_Producto)
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
	SELECT 
		*
	FROM(
		SELECT 
		    MAX(PAGO_TARJETA_NRO) AS PAGO_TARJETA_NRO,
			MAX(PAGO_TARJETA_FECHA_VENC) AS PAGO_TARJETA_FECHA_VENC,
			MAX(PAGO_TARJETA_CUOTAS) AS CUOTAS,
			MAX(CLIENTE_DNI) AS CLIENTE_DNI
		FROM 
		    gd_esquema.Maestra M
		WHERE (CLIENTE_DNI IS NOT NULL OR PAGO_TARJETA_NRO IS NOT NULL
		OR PAGO_TARJETA_FECHA_VENC IS NOT NULL OR PAGO_TARJETA_CUOTAS IS NOT NULL)
		GROUP BY TICKET_NUMERO
			) AS subquery
	WHERE subquery.CLIENTE_DNI IS NOT NULL AND subquery.PAGO_TARJETA_NRO IS NOT NULL
	AND subquery.PAGO_TARJETA_NRO IS NOT NULL AND subquery.CUOTAS IS NOT NULL
END
GO

CREATE PROCEDURE REDIS.migrar_Descuento AS
BEGIN
	INSERT INTO REDIS.Descuento 
	SELECT DISTINCT
		m.DESCUENTO_CODIGO,
		m.DESCUENTO_DESCRIPCION,
		m.DESCUENTO_FECHA_INICIO,
		m.DESCUENTO_FECHA_FIN,
		m.DESCUENTO_PORCENTAJE_DESC,
		m.DESCUENTO_TOPE
	FROM 
		gd_esquema.Maestra m,
		REDIS.Pago p,
		REDIS.Medio_Pago mp
	WHERE 
		DESCUENTO_CODIGO IS NOT NULL
END
GO

CREATE PROCEDURE REDIS.migrar_Descuento_Por_Pago AS
BEGIN
	INSERT INTO REDIS.Descuento_Por_pago 
	SELECT DISTINCT
		d.descuento_codigo,
		p.pago_nro
	FROM
		gd_esquema.Maestra m,
		REDIS.Pago p,
		REDIS.Medio_Pago mp,
		REDIS.Descuento d
	WHERE 
		m.DESCUENTO_CODIGO IS NOT NULL
		AND p.pago_ticket_numero = m.TICKET_NUMERO
		AND p.pago_fecha BETWEEN m.DESCUENTO_FECHA_INICIO AND m.DESCUENTO_FECHA_FIN
		AND mp.medio_pago = m.PAGO_MEDIO_PAGO
		AND p.pago_medio_pago = mp.medio_pago
		AND m.DESCUENTO_CODIGO = d.descuento_codigo
	ORDER BY pago_nro
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
		t.ticket_id,
		c.cliente_dni
	FROM 
		gd_esquema.Maestra m,
		REDIS.Cliente c,
		REDIS.Ticket t
	WHERE 
		ENVIO_COSTO IS NOT NULL
		AND c.cliente_dni = m.CLIENTE_DNI
		AND t.ticket_numero = m.TICKET_NUMERO
	ORDER BY 
		m.TICKET_NUMERO
END
GO

CREATE PROCEDURE REDIS.migrar_Pago AS
BEGIN
	INSERT INTO REDIS.Pago 
	SELECT
		PAGO_FECHA,
		PAGO_IMPORTE,
		PAGO_DESCUENTO_APLICADO,
		t.ticket_id, 
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
	ORDER BY t.ticket_numero
END
GO

CREATE PROCEDURE REDIS.migrar_Regla AS
BEGIN
	INSERT INTO REDIS.Regla(
        regla_descripcion,
        regla_cant_max_prod,
        regla_aplica_misma_marca,
		regla_aplica_mismo_prod,
		regla_cant_aplica_descuento,
		regla_cant_aplicable_regla,
		regla_descuento_aplicable_prod
    )
	SELECT DISTINCT
		REGLA_DESCRIPCION,
		REGLA_CANT_MAX_PROD,
		REGLA_APLICA_MISMA_MARCA,
		REGLA_APLICA_MISMO_PROD,
		REGLA_CANT_APLICA_DESCUENTO,
		REGLA_CANT_APLICABLE_REGLA,
		REGLA_DESCUENTO_APLICABLE_PROD
	FROM 
		gd_esquema.Maestra
	WHERE REGLA_DESCRIPCION IS NOT NULL
END
GO

CREATE PROCEDURE REDIS.migrar_Promocion AS
BEGIN
	INSERT INTO REDIS.Promocion 
	SELECT DISTINCT
		PROMO_CODIGO,
		PROMOCION_DESCRIPCION,
		r.regla_codigo
	FROM 
		gd_esquema.Maestra m,
		REDIS.Regla r
	WHERE 
		r.regla_descripcion = m.REGLA_DESCRIPCION
END
GO

CREATE PROCEDURE REDIS.migrar_Marca_Producto AS
BEGIN
	INSERT INTO REDIS.Marca_Producto
	SELECT DISTINCT 
		PRODUCTO_MARCA 
	FROM 
		gd_esquema.Maestra 
	WHERE 
		PRODUCTO_MARCA IS NOT NULL
	ORDER BY 
		PRODUCTO_MARCA
END
GO

CREATE PROCEDURE REDIS.migrar_Producto AS
BEGIN
	INSERT INTO REDIS.Producto 
	SELECT DISTINCT
		PRODUCTO_NOMBRE,
		PRODUCTO_DESCRIPCION,
		PRODUCTO_PRECIO,
		mp.marca_producto_nombre,
		sp.subcategoria_producto_id
	FROM 
		gd_esquema.Maestra m,
		REDIS.Marca_Producto mp,
		REDIS.Subcategoria_Producto sp
	WHERE 
		PRODUCTO_NOMBRE IS NOT NULL
		AND mp.marca_producto_nombre = PRODUCTO_MARCA
		AND sp.subcategoria_producto_nombre = PRODUCTO_SUB_CATEGORIA
		AND sp.categoria_producto = PRODUCTO_CATEGORIA
END
GO

CREATE PROCEDURE REDIS.migrar_Promocion_Por_Producto AS
BEGIN
    WITH CTE AS (
        SELECT 
            p.producto_id,
            PROMO_CODIGO,
            PROMOCION_FECHA_INICIO,
            PROMOCION_FECHA_FIN,
            ROW_NUMBER() OVER (PARTITION BY p.producto_id, PROMO_CODIGO ORDER BY PROMO_APLICADA_DESCUENTO DESC) AS rn
        FROM 
            gd_esquema.Maestra m
            JOIN REDIS.Producto p ON 
				m.PRODUCTO_NOMBRE = p.producto_codigo                     
				AND m.PRODUCTO_MARCA = p.producto_marca
        WHERE
            PROMO_CODIGO IS NOT NULL
    )
    INSERT INTO REDIS.Promocion_Por_Producto 
    SELECT
        producto_id,
        PROMO_CODIGO,
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
		t.ticket_id,
		TICKET_DET_CANTIDAD,
		TICKET_DET_PRECIO,
		TICKET_DET_TOTAL
	FROM 
		gd_esquema.Maestra m,
		REDIS.Producto p,
		REDIS.Ticket t
	WHERE 
		m.PRODUCTO_NOMBRE = p.producto_codigo
		AND m.PRODUCTO_MARCA = p.producto_marca
		AND t.ticket_numero = m.TICKET_NUMERO
END
GO

CREATE PROCEDURE REDIS.migrar_Promocion_Por_Ticket AS
BEGIN
	INSERT INTO REDIS.Promocion_Por_Ticket 
	SELECT 
		td.ticket_detalle_id,
		p.promocion_codigo,
		SUM(m.PROMO_APLICADA_DESCUENTO)
	FROM 
		gd_esquema.Maestra m,
		REDIS.Ticket_Detalle td,
		REDIS.Ticket t,
		REDIS.Promocion p,
		REDIS.Producto prod
	WHERE 
		PROMO_APLICADA_DESCUENTO IS NOT NULL
		AND t.ticket_numero = m.TICKET_NUMERO
		AND td.ticket_numero = t.ticket_id
		AND m.PRODUCTO_NOMBRE = prod.producto_codigo
		AND td.producto_id = prod.producto_id
		AND p.promocion_codigo = m.PROMO_CODIGO
	GROUP BY 
		t.ticket_id,
		td.ticket_detalle_id, 
		p.promocion_codigo,
		t.ticket_numero
	ORDER BY td.ticket_detalle_id DESC
END
GO

--------------------------------------
---------- DATA MIGRATION ------------
--------------------------------------

BEGIN TRANSACTION 
	EXECUTE REDIS.migrar_Provincia
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
	EXECUTE REDIS.migrar_Envio
	EXECUTE REDIS.migrar_Pago
	EXECUTE REDIS.migrar_Descuento
	EXECUTE REDIS.migrar_Descuento_Por_Pago
	EXECUTE REDIS.migrar_Regla
	EXECUTE REDIS.migrar_Promocion
	EXECUTE REDIS.migrar_Marca_Producto
	EXECUTE REDIS.migrar_Producto
	EXECUTE REDIS.migrar_Promocion_Por_Producto
	EXECUTE REDIS.migrar_Ticket_Detalle
	EXECUTE REDIS.migrar_Promocion_Por_Ticket
COMMIT TRANSACTION

--------------------------------------
---------- PROCEDURE DROPS -----------
--------------------------------------

DROP PROCEDURE REDIS.migrar_Provincia;
DROP PROCEDURE REDIS.migrar_Localidad;
DROP PROCEDURE REDIS.migrar_Super;
DROP PROCEDURE REDIS.migrar_Sucursal;
DROP PROCEDURE REDIS.migrar_Caja;
DROP PROCEDURE REDIS.migrar_Empleado;
DROP PROCEDURE REDIS.migrar_Categoria_Producto;
DROP PROCEDURE REDIS.migrar_Subcategoria_Producto;
DROP PROCEDURE REDIS.migrar_Ticket;
DROP PROCEDURE REDIS.migrar_Cliente;
DROP PROCEDURE REDIS.migrar_Medio_Pago;
DROP PROCEDURE REDIS.migrar_Detalle_De_Pago;
DROP PROCEDURE REDIS.migrar_Descuento_Por_Pago;
DROP PROCEDURE REDIS.migrar_Descuento;
DROP PROCEDURE REDIS.migrar_Envio;
DROP PROCEDURE REDIS.migrar_Pago;
DROP PROCEDURE REDIS.migrar_Regla;
DROP PROCEDURE REDIS.migrar_Promocion;
DROP PROCEDURE REDIS.migrar_Marca_Producto;
DROP PROCEDURE REDIS.migrar_Producto;
DROP PROCEDURE REDIS.migrar_Promocion_Por_Producto;
DROP PROCEDURE REDIS.migrar_Ticket_Detalle;
DROP PROCEDURE REDIS.migrar_Promocion_Por_Ticket;

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
ADD FOREIGN KEY (pago_ticket_numero) REFERENCES REDIS.Ticket (ticket_id)

ALTER TABLE REDIS.Detalle_De_Pago
ADD FOREIGN KEY (detalle_de_pago_cliente_dni) REFERENCES REDIS.Cliente (cliente_dni)

ALTER TABLE REDIS.Cliente
ADD FOREIGN KEY (cliente_localidad) REFERENCES REDIS.Localidad (localidad_id)

ALTER TABLE REDIS.Envio
ADD FOREIGN KEY (envio_ticket_numero) REFERENCES REDIS.Ticket (ticket_id)

ALTER TABLE REDIS.Envio
ADD FOREIGN KEY (envio_cliente_dni) REFERENCES REDIS.Cliente (cliente_dni)

ALTER TABLE REDIS.Ticket
ADD FOREIGN KEY (ticket_sucursal_id) REFERENCES REDIS.Sucursal (sucursal_id)

ALTER TABLE REDIS.Ticket
ADD FOREIGN KEY (ticket_caja_numero, ticket_sucursal_id) REFERENCES REDIS.Caja (caja_numero, caja_sucursal_id)

ALTER TABLE REDIS.Ticket
ADD FOREIGN KEY (ticket_empleado_legajo) REFERENCES REDIS.Empleado (empleado_legajo)

ALTER TABLE REDIS.Ticket_Detalle
ADD FOREIGN KEY (ticket_numero) REFERENCES REDIS.Ticket (ticket_id)

ALTER TABLE REDIS.Ticket_Detalle
ADD FOREIGN KEY (producto_id) REFERENCES REDIS.Producto (producto_id)

ALTER TABLE REDIS.Caja
ADD FOREIGN KEY (caja_sucursal_id) REFERENCES REDIS.Sucursal (sucursal_id)