USE master
GO


DECLARE @EliminarDB BIT = 1;
--Eliminar BDD si ya existe y si @EliminarDB = 1
if (((select COUNT(1) from sys.databases where name = 'RepuestosWeb_DWH')>0) AND (@EliminarDB = 1))
begin
	EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'RepuestosWeb_DWH'
	
	
	use [master];
	ALTER DATABASE [RepuestosWeb_DWH] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE;
		
	DROP DATABASE [RepuestosWeb_DWH]
	print 'RepuestosWeb_DWH ha sido eliminada'
end


CREATE DATABASE [RepuestosWeb_DWH]
GO

USE [RepuestosWeb_DWH]
GO

--Enteros
 --User Defined Type _ Surrogate Key
	--Tipo para SK entero: Surrogate Key
	CREATE TYPE [UDT_SK] FROM INT
	GO

	--Tipo para PK entero
	CREATE TYPE [UDT_PK] FROM INT
	GO


--cadenas

	--cadenas largas
	create type [UDT_VarcharLargo] from varchar(1000)
	go
	--cadenas medianaas
	create type [UDT_VarcharMediano] from varchar (200)
	go

	--cadenas cortas
	create type [UDT_VarcharCorto] from varchar (100)
	go

	--un caracter
	create type [UDT_UnCaracter] from char(1)
	go

--decimales

	--decimal 12,2
	create type [UDT_Decimal12.2] from decimal(12,2)
	go

	--decimal 2,2
	create type [UDT_Decimal2.2] from decimal (2,2)
	go

--fechas

	create type [UDT_DateTime] from datetime
	go

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

	CREATE TABLE Dimension.Geografia
	(
		SK_Geografia [UDT_SK] PRIMARY KEY IDENTITY
	)
	GO

	CREATE TABLE Dimension.Parte
	(
		SK_Parte [UDT_SK] PRIMARY KEY IDENTITY
	)
	GO

	CREATE TABLE Dimension.Cliente
	(
		SK_Cliente [UDT_SK] PRIMARY KEY IDENTITY
	)
	GO

	CREATE TABLE Dimension.Cotizacion
	(
		SK_Cotizacion [UDT_SK] PRIMARY KEY IDENTITY
	)
	GO

	CREATE TABLE Dimension.Vehiculo
	(
		SK_Vehiculo [UDT_SK] PRIMARY KEY IDENTITY
	)
	GO

	CREATE TABLE Dimension.Descuento
	(
		SK_Descuento [UDT_SK] PRIMARY KEY IDENTITY
	)
	GO

	CREATE TABLE Dimension.StatusOrden
	(
		SK_StatusOrden [UDT_SK] PRIMARY KEY IDENTITY
	)
	GO


--Tablas Fact

	CREATE TABLE Fact.Orden
	(
		SK_Orden [UDT_SK] PRIMARY KEY IDENTITY,
		SK_Geografia [UDT_SK] REFERENCES Dimension.Geografia(SK_Geografia),
		SK_Parte [UDT_SK] REFERENCES Dimension.Parte(SK_Parte),
		SK_Cliente [UDT_SK] REFERENCES Dimension.Cliente(SK_Cliente),
		SK_Cotizacion [UDT_SK] REFERENCES Dimension.Cotizacion(SK_Cotizacion),
		SK_Vehiculo [UDT_SK] REFERENCES Dimension.Vehiculo(SK_Vehiculo),
		SK_Descuento [UDT_SK] REFERENCES Dimension.Descuento(SK_Descuento),
		SK_StatusOrden [UDT_SK] REFERENCES Dimension.StatusOrden(SK_StatusOrden),
		DateKey INT REFERENCES Dimension.Fecha(DateKey)
	)
	GO

--Metadata

	EXEC sys.sp_addextendedproperty 
     @name = N'Desnormalizacion', 
     @value = N'La dimension Fecha es generada de forma automatica y no tiene datos origen, se puede regenerar enviando un rango de fechas al stored procedure USP_FillDimDate', 
     @level0type = N'SCHEMA', 
     @level0name = N'Dimension', 
     @level1type = N'TABLE', 
     @level1name = N'Fecha';
	GO


	EXEC sys.sp_addextendedproperty 
     @name = N'Desnormalizacion', 
     @value = N'La dimension Geofrafia provee una vista desnormalizada de las tablas origen Pais, Region y Ciudad, dejando todo en una unica dimension para un modelo estrella', 
     @level0type = N'SCHEMA', 
     @level0name = N'Dimension', 
     @level1type = N'TABLE', 
     @level1name = N'Geografia';
	GO


	EXEC sys.sp_addextendedproperty 
     @name = N'Desnormalizacion', 
     @value = N'La dimension Parte provee una vista desnormalizada de las tablas origen Clientes en una sola dimension para un modelo estrella', 
     @level0type = N'SCHEMA', 
     @level0name = N'Dimension', 
     @level1type = N'TABLE', 
     @level1name = N'Parte';
	GO


	EXEC sys.sp_addextendedproperty 
     @name = N'Desnormalizacion', 
     @value = N'La dimension Cliente provee una vista desnormalizada de las tablas origen Clientes en una sola dimension para un modelo estrella', 
     @level0type = N'SCHEMA', 
     @level0name = N'Dimension', 
     @level1type = N'TABLE', 
     @level1name = N'Cliente';
	GO


	EXEC sys.sp_addextendedproperty 
     @name = N'Desnormalizacion', 
     @value = N'La dimension Cotizacion provee una vista desnormalizada de las tablas origen Cotizaciones, Detalle_Cotizaciones, Aseguradoras, PlantaRepacion en una sola dimension para un modelo estrella', 
     @level0type = N'SCHEMA', 
     @level0name = N'Dimension', 
     @level1type = N'TABLE', 
     @level1name = N'Cotizacion';
	GO


	EXEC sys.sp_addextendedproperty 
     @name = N'Desnormalizacion', 
     @value = N'La dimension Vehiculo provee una vista desnormalizada de las tablas origen Vehiculos en una sola dimension para un modelo estrella', 
     @level0type = N'SCHEMA', 
     @level0name = N'Dimension', 
     @level1type = N'TABLE', 
     @level1name = N'Vehiculo';
	GO


	EXEC sys.sp_addextendedproperty 
     @name = N'Desnormalizacion', 
     @value = N'La dimension Descuento provee una vista desnormalizada de las tablas origen Descuento en una sola dimension para un modelo estrella', 
     @level0type = N'SCHEMA', 
     @level0name = N'Dimension', 
     @level1type = N'TABLE', 
     @level1name = N'Descuento';
	GO


	EXEC sys.sp_addextendedproperty 
     @name = N'Desnormalizacion', 
     @value = N'La dimension StatusOrden provee una vista desnormalizada de las tablas origen StatusOrden en una sola dimension para un modelo estrella', 
     @level0type = N'SCHEMA', 
     @level0name = N'Dimension', 
     @level1type = N'TABLE', 
     @level1name = N'StatusOrden';
	GO


	EXEC sys.sp_addextendedproperty 
     @name = N'Desnormalizacion', 
     @value = N'La tabla de hechos es una union proveniente de las tablas de Orden y Detalle_Orden', 
     @level0type = N'SCHEMA', 
     @level0name = N'Fact', 
     @level1type = N'TABLE', 
     @level1name = N'Orden';
	GO

--------------------------------------------------------------------------------------------
---------------------------------MODELADO LOGICO--------------------------------------------
--------------------------------------------------------------------------------------------
--Transformacion en modelo logico (mas detalles)

	--Fact
	ALTER TABLE Fact.Orden ADD ID_Orden [UDT_PK]
	ALTER TABLE Fact.Examen ADD ID_Cliente [UDT_PK]
	ALTER TABLE Fact.Examen ADD ID_Ciudad [UDT_PK]
	ALTER TABLE Fact.Examen ADD ID_StatusOrden [UDT_PK]
	ALTER TABLE Fact.Orden ADD ID_DetalleOrden [UDT_PK]
	ALTER TABLE Fact.Examen ADD ID_Parte [UDT_PK]
	ALTER TABLE Fact.Examen ADD ID_Descuento [UDT_PK]
	ALTER TABLE Fact.Examen ADD VehiculoID [UDT_PK]
	ALTER TABLE Fact.Examen ADD Total_Orden [UDT_Decimal12.2]
	ALTER TABLE Fact.Examen ADD Fecha_Orden [UDT_DateTime]
	ALTER TABLE Fact.Examen ADD NumeroOrden [UDT_VarcharCorto]
	ALTER TABLE Fact.Examen ADD Cantidad int not null
	go

	--DimFecha	
	alter table Dimension.Fecha add [Date] DATE NOT NULL
	alter table Dimension.Fecha add [Day] TINYINT NOT NULL
	alter table Dimension.Fecha add [DaySuffix] CHAR(2) NOT NULL
	alter table Dimension.Fecha add [Weekday] TINYINT NOT NULL
	alter table Dimension.Fecha add [WeekDayName] VARCHAR(10) NOT NULL
	alter table Dimension.Fecha add [WeekDayName_Short] CHAR(3) NOT NULL
	alter table Dimension.Fecha add [WeekDayName_FirstLetter] CHAR(1) NOT NULL
	alter table Dimension.Fecha add [DOWInMonth] TINYINT NOT NULL
	alter table Dimension.Fecha add [DayOfYear] SMALLINT NOT NULL
	alter table Dimension.Fecha add [WeekOfMonth] TINYINT NOT NULL
	alter table Dimension.Fecha add [WeekOfYear] TINYINT NOT NULL
	alter table Dimension.Fecha add [Month] TINYINT NOT NULL
	alter table Dimension.Fecha add [MonthName] VARCHAR(10) NOT NULL
	alter table Dimension.Fecha add [MonthName_Short] CHAR(3) NOT NULL
	alter table Dimension.Fecha add [MonthName_FirstLetter] CHAR(1) NOT NULL
	alter table Dimension.Fecha add [Quarter] TINYINT NOT NULL
	alter table Dimension.Fecha add [QuarterName] VARCHAR(6) NOT NULL
	alter table Dimension.Fecha add [Year] INT NOT NULL
	alter table Dimension.Fecha add [MMYYYY] CHAR(6) NOT NULL
	alter table Dimension.Fecha add [MonthYear] CHAR(7) NOT NULL
	alter table Dimension.Fecha add IsWeekend BIT NOT NULL
	go

	--DimGeografia
	alter table Dimension.Geografia add ID_Ciudad [UDT_PK]
	alter table Dimension.Geografia add ID_Region [UDT_PK]
	alter table Dimension.Geografia add ID_Pais [UDT_PK]
	alter table Dimension.Geografia add NombrePais [UDT_VarcharCorto]
	alter table Dimension.Geografia add NombreRegion [UDT_VarcharCorto]
	alter table Dimension.Geografia add NombreCiudad [UDT_VarcharCorto]
	alter table Dimension.Geografia add CodigoPostal  [UDT_VarcharCorto]
	--columnas scd tipo 2
	alter table Dimension.Geografia add FechaInicioValidez [UDT_DateTime] not null default (getdate())
	alter table Dimension.Geografia add FechaFinValidez [UDT_DateTime] null
	--columnas de auditoria
	alter table Dimension.Geografia add FechaCreacion [UDT_DateTime] not null default(getdate())
	alter table Dimension.Geografia add UsuarioCreacion nvarchar(100) not null default(suser_name())
	alter table Dimension.Geografia add FechaModificacion [UDT_DateTime]
	alter table Dimension.Geografia add UsuarioModificacion nvarchar(100) null
	go

	--DimParte
	alter table Dimension.Partes add ID_Partes [UDT_PK]
	alter table Dimension.Partes add ID_Linea [UDT_PK]
	alter table Dimension.Partes add ID_Categoria [UDT_PK]
	alter table Dimension.Partes add NombreParte [UDT_VarcharCorto]
	alter table Dimension.Partes add DescripcionParte [UDT_VarcharLargo]
	alter table Dimension.Partes add PrecioParte [UDT_Decimal12.2]
	alter table Dimension.Partes add NombreCategoria [UDT_VarcharCorto]
	alter table Dimension.Partes add DescripcionCategoria [UDT_VarcharLargo]
	alter table Dimension.Partes add NombreLinea [UDT_VarcharCorto]
	alter table Dimension.Partes add DescripcionLinea [UDT_VarcharLargo]
	----Columnas SCD Tipo 2
	--    [FechaInicioValidez] DATETIME NOT NULL DEFAULT(GETDATE()),
	--    [FechaFinValidez] DATETIME NULL,
	--columnas scd tipo 2
	alter table Dimension.Partes add FechaInicioValidez [UDT_DateTime] not null default (getdate())
	alter table Dimension.Partes add FechaFinValidez [UDT_DateTime] null
	--columnas de auditoria
	alter table Dimension.Partes add FechaCreacion [UDT_DateTime] not null default(getdate())
	alter table Dimension.Partes add UsuarioCreacion nvarchar(100) not null default(suser_name())
	alter table Dimension.Partes add FechaModificacion [UDT_DateTime]
	alter table Dimension.Partes add UsuarioModificacion nvarchar(100) null 
	go

	--DimCliente
	alter table Dimension.Clientes add ID_Cliente [UDT_PK]
	alter table Dimension.Clientes add PrimerNombre [UDT_VarcharCorto]
	alter table Dimension.Clientes add SegundoNombre [UDT_VarcharCorto]
	alter table Dimension.Clientes add PrimerApellido [UDT_VarcharCorto]
	alter table Dimension.Clientes add SegundoApellido [UDT_VarcharCorto]
	alter table Dimension.Clientes add Genero [UDT_UnCaracter]
	alter table Dimension.Clientes add Correo_Electronico [UDT_VarcharCorto]
	alter table Dimension.Clientes add FechaNacimiento [UDT_DateTime]
	alter table Dimension.Clientes add Direccion [UDT_VarcharLargo]
	--columnas scd tipo 2
	alter table Dimension.Clientes add FechaInicioValidez [UDT_DateTime] not null default (getdate())
	alter table Dimension.Clientes add FechaFinValidez [UDT_DateTime] null
	--columnas de auditoria
	alter table Dimension.Clientes add FechaCreacion [UDT_DateTime] not null default(getdate())
	alter table Dimension.Clientes add UsuarioCreacion nvarchar(100) not null default(suser_name())
	alter table Dimension.Clientes add FechaModificacion [UDT_DateTime]
	alter table Dimension.Clientes add UsuarioModificacion nvarchar(100) null
	go

	--DimCotizacion
	alter table Dimension.Cotizacion add IDPlantaReparacion [UDT_PK]
	alter table Dimension.Cotizacion add CompanyNombre [UDT_VarcharCorto]
	alter table Dimension.Cotizacion add Direccion [UDT_VarcharCorto]
	alter table Dimension.Cotizacion add Direccion2 [UDT_VarcharCorto]
	alter table Dimension.Cotizacion add Ciudad [UDT_VarcharCorto]
	alter table Dimension.Cotizacion add Estado [UDT_VarcharCorto]
	alter table Dimension.Cotizacion add CodigoPostal [UDT_VarcharCorto]
	alter table Dimension.Cotizacion add Pais [UDT_VarcharCorto]
	alter table Dimension.Cotizacion add TelefonoAlmacen [UDT_VarcharCorto]
	alter table Dimension.Cotizacion add FaxAlmacen [UDT_VarcharCorto]
	alter table Dimension.Cotizacion add CorreoContacto [UDT_VarcharCorto]
	alter table Dimension.Cotizacion add NombreContacto [UDT_VarcharMediano]--100
	alter table Dimension.Cotizacion add TelefonoContacto [UDT_VarcharCorto]
	alter table Dimension.Cotizacion add TituloTrabajo [UDT_VarcharCorto]
	alter table Dimension.Cotizacion add AlmacenKeystone [UDT_VarcharCorto]
	alter table Dimension.Cotizacion add IDPredido [UDT_VarcharCorto]
	alter table Dimension.Cotizacion add LocalizadorCotizacion [UDT_VarcharCorto]
	alter table Dimension.Cotizacion add FechaAgregado [UDT_DateTime]
	alter table Dimension.Cotizacion add IDEmpresa [UDT_VarcharCorto]
	alter table Dimension.Cotizacion add ValidacionSeguro [UDT_BIT]
	alter table Dimension.Cotizacion add Activo [UDT_BIT]
	alter table Dimension.Cotizacion add CreadoPor [UDT_VarcharCorto]
	alter table Dimension.Cotizacion add ActualizadoPor [UDT_VarcharCorto]
	alter table Dimension.Cotizacion add UltimaFechaActualizacion [UDT_BIT]
	alter table Dimension.Cotizacion add IDAseguradora [UDT_PK]
	alter table Dimension.Cotizacion add NombreAseguradora [UDT_VarcharMediano]--80
	alter table Dimension.Cotizacion add RowCreatedDate [UDT_DateTime]
	alter table Dimension.Cotizacion add Activa [UDT_BIT]
	--columnas de auditoria
	alter table Dimension.Descuento add FechaCreacion [UDT_DateTime] not null default(getdate())
	alter table Dimension.Descuento add UsuarioCreacion nvarchar(100) not null default(suser_name())
	alter table Dimension.Descuento add FechaModificacion [UDT_DateTime]
	alter table Dimension.Descuento add UsuarioModificacion nvarchar(100) null
	go

	--DimVehiculo
	alter table Dimension.Vehiculo add VehiculoID [UDT_PK]
	alter table Dimension.Vehiculo add VIN_Patron varchar(10)
	alter table Dimension.Vehiculo add Anio smallint
	alter table Dimension.Vehiculo add Marca [UDT_VarcharCorto]
	alter table Dimension.Vehiculo add Modelo [UDT_VarcharCorto]
	alter table Dimension.Vehiculo add SubModelo [UDT_UnCaracter]
	alter table Dimension.Vehiculo add Estilo [UDT_VarcharMediano]
	alter table Dimension.Vehiculo add FechaCreacion [UDT_DateTime]
	--columnas scd tipo 2
	alter table Dimension.Vehiculo add FechaInicioValidez [UDT_DateTime] not null default (getdate())
	alter table Dimension.Vehiculo add FechaFinValidez [UDT_DateTime] null
	--columnas de auditoria
	alter table Dimension.Vehiculo add FechaCreacion [UDT_DateTime] not null default(getdate())
	alter table Dimension.Vehiculo add UsuarioCreacion nvarchar(100) not null default(suser_name())
	alter table Dimension.Vehiculo add FechaModificacion [UDT_DateTime]
	alter table Dimension.Vehiculo add UsuarioModificacion nvarchar(100) null
	go

	--DimDescuento
	alter table Dimension.Descuento add ID_Descuento [UDT_PK]
	alter table Dimension.Descuento add NombreDescuento [UDT_VarcharMediano]
	alter table Dimension.Descuento add PorcentajeDescuento [UDT_Decimal2.2]
	--columnas scd tipo 2
	alter table Dimension.Descuento add FechaInicioValidez [UDT_DateTime] not null default (getdate())
	alter table Dimension.Descuento add FechaFinValidez [UDT_DateTime] null
	--columnas de auditoria
	alter table Dimension.Descuento add FechaCreacion [UDT_DateTime] not null default(getdate())
	alter table Dimension.Descuento add UsuarioCreacion nvarchar(100) not null default(suser_name())
	alter table Dimension.Descuento add FechaModificacion [UDT_DateTime]
	alter table Dimension.Descuento add UsuarioModificacion nvarchar(100) null
	go

	--DimStatusOrden
	alter table Dimension.StatusOrden add ID_StatusOrden  [UDT_PK]
	alter table Dimension.StatusOrden add ID_NombreStatus [UDT_VarcharLargo]
	--columnas de auditoria
	alter table Dimension.StatusOrden add FechaCreacion [UDT_DateTime] not null default(getdate())
	alter table Dimension.StatusOrden  add UsuarioCreacion nvarchar(100) not null default(suser_name())
	alter table Dimension.StatusOrden add FechaModificacion [UDT_DateTime]
	alter table Dimension.StatusOrden  add UsuarioModificacion nvarchar(100) null
	go

