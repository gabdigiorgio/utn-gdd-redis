USE GD1C2024;
GO

-- Verificar si las tablas contienen datos
DECLARE @TableName NVARCHAR(128);
DECLARE @SQL NVARCHAR(MAX);
DECLARE @Result INT;
DECLARE @AllTablesHaveData BIT = 1;

DECLARE TableCursor CURSOR FOR
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'REDIS';

OPEN TableCursor;
FETCH NEXT FROM TableCursor INTO @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = 'SELECT @Result = COUNT(*) FROM REDIS.' + QUOTENAME(@TableName);
    EXEC sp_executesql @SQL, N'@Result INT OUTPUT', @Result OUTPUT;

    IF @Result = 0
    BEGIN
        PRINT 'La tabla ' + @TableName + ' no tiene datos.';
        SET @AllTablesHaveData = 0;
    END

    FETCH NEXT FROM TableCursor INTO @TableName;
END

CLOSE TableCursor;
DEALLOCATE TableCursor;

IF @AllTablesHaveData = 1
BEGIN
    PRINT 'Todas las tablas tienen datos.';
END