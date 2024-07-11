USE GD1C2024;
GO

-- Verificar si las tablas y vistas contienen datos
DECLARE @ObjectName NVARCHAR(128);
DECLARE @ObjectType NVARCHAR(1);
DECLARE @SQL NVARCHAR(MAX);
DECLARE @Result INT;
DECLARE @AllObjectsHaveData BIT = 1;

-- Listado de tablas y vistas a verificar
DECLARE ObjectCursor CURSOR FOR
SELECT TABLE_NAME, TABLE_TYPE 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'REDIS'
AND (TABLE_NAME IN ('BI_Hechos_Venta', 'BI_Hechos_Promocion', 'BI_Hechos_Envio', 'BI_Hechos_Pago_Cuotas', 'BI_Hechos_Pago', 
                    'BI_Tiempo', 'BI_Ubicacion', 'BI_Rango_Etario', 'BI_Medio_De_Pago', 'BI_Turno', 'BI_Tipo_Caja', 
                    'BI_Categoria_Producto', 'BI_Sucursal') 
     OR TABLE_NAME IN ('V_Ticket_Promedio_Mensual', 'V_Cantidad_Unidades_Promedio', 'V_Porcentaje_Anual_De_Ventas', 
                       'V_Cantidad_De_Ventas_Por_Turno', 'V_Porcentaje_Descuento_Tickets', 'V_Top3_Categorias_Promociones', 
                       'V_Porcentaje_Cumplimiento_Envios', 'V_Cantidad_Envios_Rango_Etario_Clientes', 
                       'V_Top5_Localidades_Mayor_Costo_Envio', 'V_Top3_Sucursales_Pagos_Cuotas', 
                       'V_Promedio_Importe_Cuota_Rango_Etario', 'V_Porcentaje_Descuento_Medio_Pago'));

OPEN ObjectCursor;
FETCH NEXT FROM ObjectCursor INTO @ObjectName, @ObjectType;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @ObjectType = 'BASE TABLE'
    BEGIN
        SET @SQL = 'SELECT @Result = COUNT(*) FROM REDIS.' + QUOTENAME(@ObjectName);
    END
    ELSE IF @ObjectType = 'VIEW'
    BEGIN
        SET @SQL = 'SELECT @Result = COUNT(*) FROM REDIS.' + QUOTENAME(@ObjectName);
    END
    
    EXEC sp_executesql @SQL, N'@Result INT OUTPUT', @Result OUTPUT;

    IF @Result = 0
    BEGIN
        PRINT 'La tabla o vista ' + @ObjectName + ' no tiene datos.';
        SET @AllObjectsHaveData = 0;
    END

    FETCH NEXT FROM ObjectCursor INTO @ObjectName, @ObjectType;
END

CLOSE ObjectCursor;
DEALLOCATE ObjectCursor;

IF @AllObjectsHaveData = 1
BEGIN
    PRINT 'Todas las tablas y vistas tienen datos.';
END
