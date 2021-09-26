--------------------------------------------------------------------------------------------
----------------------------------- CREATION -----------------------------------------------
--------------------------------------------------------------------------------------------
use master
go

DECLARE @EliminarDB BIT = 1;
--Eliminar BDD si ya existe y si @EliminarDB = 1
if (((select COUNT(1) from sys.databases where name = 'RepuestosWebDWH')>0) AND (@EliminarDB = 1))
begin
	EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'RepuestosWebDWH'
	
	
	use [master];
	ALTER DATABASE RepuestosWebDWH SET  SINGLE_USER WITH ROLLBACK IMMEDIATE;
		
	DROP DATABASE RepuestosWebDWH
	print 'RepuestosWebDWH ha sido eliminada'
end


create database RepuestosWebDWH
go

use RepuestosWebDWH
go

--Enteros
 --User Defined Type _ Surrogate Key
	--Tipo para SK entero: Surrogate Key
	CREATE TYPE [UDT_SK] FROM INT
	GO

	--Tipo para PK entero
	CREATE TYPE [UDT_PK] FROM INT
	GO

--Cadenas

	--Tipo para cadenas largas
	CREATE TYPE [UDT_VarcharLargo] FROM VARCHAR(600)
	GO

	--Tipo para cadenas medianas
	CREATE TYPE [UDT_VarcharMediano] FROM VARCHAR(300)
	GO

	--Tipo para cadenas cortas
	CREATE TYPE [UDT_VarcharCorto] FROM VARCHAR(100)
	GO

	--Tipo para cadenas cortas
	CREATE TYPE [UDT_UnCaracter] FROM CHAR(1)
	GO

--Decimal

	--Tipo Decimal 6,2
	CREATE TYPE [UDT_Decimal6.2] FROM DECIMAL(6,2)
	GO

	--Tipo Decimal 5,2
	CREATE TYPE [UDT_Decimal5.2] FROM DECIMAL(5,2)
	GO

	--Tipo Decimal 5,2
	CREATE TYPE [UDT_Decimal12.2] FROM DECIMAL(12,2)
	GO


--Int

	--Integer type
	create type [UDT_Int] from int
	go

--Fechas
	CREATE TYPE [UDT_DateTime] FROM DATETIME
	GO

--Schemas para separar objetos
	CREATE SCHEMA Fact
	GO

	CREATE SCHEMA Dimension
	GO


--------------------------------------------------------------------------------------------
-------------------------------MODELADO CONCEPTUAL------------------------------------------
--------------------------------------------------------------------------------------------
--Tablas Dimensiones

	CREATE TABLE Dimension.Fecha
	(
		DateKey INT PRIMARY KEY
	)
	GO

	CREATE TABLE Dimension.Partes
	(
		SK_Partes [UDT_SK] PRIMARY KEY IDENTITY
	)
	GO

	CREATE TABLE Dimension.Geografia
	(
		SK_Geografia [UDT_SK] PRIMARY KEY IDENTITY
	)
	GO

	CREATE TABLE Dimension.Clientes
	(
		SK_Clientes [UDT_SK] PRIMARY KEY IDENTITY
	)
	GO

--Tablas Fact

	CREATE TABLE Fact.Orden
	(
		SK_Orden [UDT_SK] PRIMARY KEY IDENTITY,
		SK_Partes [UDT_SK] REFERENCES Dimension.Partes(SK_Partes),
		SK_Geografia [UDT_SK] REFERENCES Dimension.Geografia(SK_Geografia),
		SK_Clientes [UDT_SK] REFERENCES Dimension.Clientes(SK_Clientes),
		DateKey INT REFERENCES Dimension.Fecha(DateKey)
	)
	GO

--Metadata

	EXEC sys.sp_addextendedproperty 
     @name = N'Desnormalizacion', 
     @value = N'La dimension partes provee una vista desnormalizada de las tablas origen Partes, Linea y Categoria en una única dimensión para un modelo estrella', 
     @level0type = N'SCHEMA', 
     @level0name = N'Dimension', 
     @level1type = N'TABLE', 
     @level1name = N'Partes';
	GO

	EXEC sys.sp_addextendedproperty 
     @name = N'Desnormalizacion', 
     @value = N'La dimension geografia provee una vista desnormalizada de las tablas origen Pais, Region y Ciudad en una sola dimensión para un modelo estrella', 
     @level0type = N'SCHEMA', 
     @level0name = N'Dimension', 
     @level1type = N'TABLE', 
     @level1name = N'Geografia';
	GO

	EXEC sys.sp_addextendedproperty 
     @name = N'Desnormalizacion', 
     @value = N'La dimension clientes provee una vista desnormalizada de la tabla origen Clientes en una sola dimensión para un modelo estrella', 
     @level0type = N'SCHEMA', 
     @level0name = N'Dimension', 
     @level1type = N'TABLE', 
     @level1name = N'Clientes';
	GO

	EXEC sys.sp_addextendedproperty 
     @name = N'Desnormalizacion', 
     @value = N'La dimension fecha es generada de forma automatica y no tiene datos origen, se puede regenerar enviando un rango de fechas al stored procedure USP_FillDimDate', 
     @level0type = N'SCHEMA', 
     @level0name = N'Dimension', 
     @level1type = N'TABLE', 
     @level1name = N'Fecha';
	GO

	EXEC sys.sp_addextendedproperty 
     @name = N'Desnormalizacion', 
     @value = N'La tabla de orden es una union proveniente de las tablas de Orden, Detalle_Orden, Descuento y StatusOrden', 
     @level0type = N'SCHEMA', 
     @level0name = N'Fact', 
     @level1type = N'TABLE', 
     @level1name = N'Orden';
	GO

--------------------------------------------------------------------------------------------
---------------------------------MODELADO LOGICO--------------------------------------------
--------------------------------------------------------------------------------------------
--Transformación en modelo lógico

	--Fact
	ALTER TABLE Fact.Orden ADD ID_Orden [UDT_PK]
	ALTER TABLE Fact.Orden ADD Total_Orden [UDT_Decimal12.2]
	ALTER TABLE Fact.Orden ADD Cantidad [UDT_Int]
	ALTER TABLE Fact.Orden ADD NombreStatus [UDT_VarcharCorto]

	--DimFecha	
	ALTER TABLE Dimension.Fecha ADD [Date] DATE NOT NULL
    ALTER TABLE Dimension.Fecha ADD [Day] TINYINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [DaySuffix] CHAR(2) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [Weekday] TINYINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [WeekDayName] VARCHAR(10) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [WeekDayName_Short] CHAR(3) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [WeekDayName_FirstLetter] CHAR(1) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [DOWInMonth] TINYINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [DayOfYear] SMALLINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [WeekOfMonth] TINYINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [WeekOfYear] TINYINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [Month] TINYINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [MonthName] VARCHAR(10) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [MonthName_Short] CHAR(3) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [MonthName_FirstLetter] CHAR(1) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [Quarter] TINYINT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [QuarterName] VARCHAR(6) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [Year] INT NOT NULL
	ALTER TABLE Dimension.Fecha ADD [MMYYYY] CHAR(6) NOT NULL
	ALTER TABLE Dimension.Fecha ADD [MonthYear] CHAR(7) NOT NULL
    ALTER TABLE Dimension.Fecha ADD IsWeekend BIT NOT NULL
  
	--DimPartes
	ALTER TABLE Dimension.Partes ADD ID_Partes [UDT_PK]
	ALTER TABLE Dimension.Partes ADD ID_Categoria [UDT_PK]
	ALTER TABLE Dimension.Partes ADD NombreParte [UDT_VarcharCorto]
	ALTER TABLE Dimension.Partes ADD NombreCategoria [UDT_VarcharCorto]
	
	--DimGeografia
	ALTER TABLE Dimension.Geografia ADD ID_Pais [UDT_PK]
	ALTER TABLE Dimension.Geografia ADD ID_Region [UDT_PK]
	ALTER TABLE Dimension.Geografia ADD ID_Ciudad [UDT_PK]
	ALTER TABLE Dimension.Geografia ADD NombrePais [UDT_VarcharCorto]
	ALTER TABLE Dimension.Geografia ADD NombreRegion [UDT_VarcharCorto]
	ALTER TABLE Dimension.Geografia ADD NombreCiudad [UDT_VarcharCorto]
	ALTER TABLE Dimension.Geografia ADD CodigoPostal [UDT_Int]

	--DimClientes
	ALTER TABLE Dimension.Clientes ADD ID_Cliente [UDT_PK]	
	ALTER TABLE Dimension.Clientes ADD PrimerNombre [UDT_VarcharCorto]
	ALTER TABLE Dimension.Clientes ADD SegundoNombre [UDT_VarcharCorto]
	ALTER TABLE Dimension.Clientes ADD PrimerApellido [UDT_VarcharCorto]
	ALTER TABLE Dimension.Clientes ADD SegundoApellido [UDT_VarcharCorto]
	ALTER TABLE Dimension.Clientes ADD Genero [UDT_UnCaracter]
	ALTER TABLE Dimension.Clientes ADD Correo_Electronico [UDT_VarcharCorto]


--Indices Columnares
	CREATE NONCLUSTERED COLUMNSTORE INDEX [NCCS-Precio] ON [Fact].[Orden]
	(
	   [Total_Orden],
	   [Cantidad]
	)WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0)
	GO

--Queries to fill data

--Dimensiones

	--DimPartes
	INSERT INTO Dimension.Partes
	(ID_Partes, 
	 ID_Categoria, 
	 NombreParte, 
	 NombreCategoria
	)
	SELECT p.ID_Partes, 
			c.ID_Categoria, 
			p.Nombre as NombreParte, 
			c.Nombre as NombreCategoria
	FROM RepuestosWeb.dbo.Partes p
		INNER JOIN RepuestosWeb.dbo.Categoria c ON(c.ID_Categoria = p.ID_Categoria);
	
	SELECT * FROM Dimension.Partes

	--DimGeografia
	INSERT INTO Dimension.Geografia
	(ID_Pais, 
	 ID_Region, 
	 ID_Ciudad, 
	 NombrePais, 
	 NombreRegion, 
	 NombreCiudad, 
	 CodigoPostal
	)
	SELECT p.ID_Pais, 
			r.ID_Region, 
			c.ID_Ciudad,
			p.Nombre as NombrePais,
			r.Nombre as NombreRegion,
			c.Nombre as NombreCiudad,
			c.CodigoPostal
	FROM RepuestosWeb.dbo.Pais p
		INNER JOIN RepuestosWeb.dbo.Region r ON(r.ID_Pais = p.ID_Pais)
		INNER JOIN RepuestosWeb.dbo.Ciudad c ON(c.ID_Region = r.ID_Region);

		SELECT * FROM Dimension.Geografia

	--DimClientes
	INSERT INTO Dimension.Clientes
	(ID_Cliente,
	 PrimerNombre,
	 SegundoNombre,
	 PrimerApellido,
	 SegundoApellido,
	 Genero,
	 Correo_Electronico
	)
	SELECT c.ID_Cliente,
			c.PrimerNombre,
			c.SegundoNombre,
			c.PrimerApellido,
			c.SegundoApellido,
			c.Genero,
			c.Correo_Electronico
	FROM RepuestosWeb.DBO.Clientes c

		SELECT * FROM Dimension.Clientes




	DECLARE @FechaMaxima DATETIME=DATEADD(YEAR,2,GETDATE())
	--Fecha
	IF ISNULL((SELECT MAX(Date) FROM Dimension.Fecha),'1900-01-01')<@FechaMaxima
	begin
		EXEC USP_FillDimDate @CurrentDate = '2016-01-01', 
							 @EndDate     = @FechaMaxima
	end

SELECT * FROM Dimension.Fecha


----Fact
--INSERT INTO [Fact].Orden
--	(SK_Partes,
--	 SK_Geografia,
--	 SK_Clientes,
--	 [DateKey], 
--	 ID_Orden,  
--	 Total_Orden, 
--	 Cantidad, 
--	 NombreStatus
--	)
--	SELECT  --Columnas de mis dimensiones en DWH
--			SK_Partes,
--			SK_Geografia,
--			SK_Clientes,
--			F.DateKey, 
--			o.ID_Orden,
--			o.Total_Orden,
--			do.Cantidad,
--			so.NombreStatus				 
--	FROM RepuestosWeb.DBO.Orden o
--		INNER JOIN RepuestosWeb.DBO.Detalle_orden do ON(do.ID_Orden = o.ID_Orden)
--		inner join RepuestosWeb.DBO.StatusOrden so on(so.ID_StatusOrden = o.ID_StatusOrden)
--		--Referencias a DWH
--		INNER JOIN Dimension.Partes p ON(p.ID_Partes = o.ID_StatusOrden)
--		INNER JOIN Dimension.Geografia g ON(g.ID_Ciudad = o.ID_Ciudad)
--		inner join Dimension.Clientes c on(c.ID_Cliente = o.ID_Cliente)
--		INNER JOIN Dimension.Fecha F ON(CAST((CAST(YEAR(o.Fecha_Orden) AS VARCHAR(4)))+left('0'+CAST(MONTH(o.Fecha_Orden) AS VARCHAR(4)),2)+left('0'+(CAST(DAY(o.Fecha_Orden) AS VARCHAR(4))),2) AS INT)  = F.DateKey);

--------------------------------------------------------------------------------------------
------------------------------------Resultado Final-----------------------------------------
--------------------------------------------------------------------------------------------	

	--SELECT *
	--FROM	Fact.Orden AS o INNER JOIN
	--		Dimension.Partes as p on p.SK_Partes = o.SK_Partes inner join
	--		Dimension.Geografia as g on g.SK_Geografia = o.SK_Geografia inner join
	--		Dimension.Clientes as c on c.SK_Clientes = o.SK_Clientes inner join
	--		Dimension.Fecha AS f ON o.DateKey = f.DateKey


