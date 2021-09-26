USE master
GO


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


CREATE DATABASE RepuestosWebDWH
GO

USE RepuestosWebDWH
GO

--Enteros
 --User Defined Type _ Surrogate Key
	--Tipo para SK entero: Surrogate Key
	CREATE TYPE [UDT_SK] FROM INT
	GO

	--Tipo para PK entero
	CREATE TYPE [UDT_PK] FROM INT
	GO

--Cadenas

	--Tipo para cadenas cortas
	CREATE TYPE [UDT_VarcharCorto] FROM VARCHAR(100)
	GO

	--Tipo para cadenas cortas
	CREATE TYPE [UDT_UnCaracter] FROM CHAR(1)
	GO

--Decimal

	--Tipo Decimal 12,2
	CREATE TYPE [UDT_Decimal12.2] FROM DECIMAL(12,2)
	GO

--Int
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

/****** Object:  Table [Dimension].[Partes]  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dimension].[Partes](
	[SK_Partes] [dbo].[UDT_SK] IDENTITY(1,1) NOT NULL,
	[ID_Parte] [dbo].[UDT_PK] NULL,
	[ID_Categoria] [dbo].[UDT_PK] NULL,
	[NombreParte] [dbo].[UDT_VarcharCorto] NULL,
	[NombreCategoria] [dbo].[UDT_VarcharCorto] NULL,
	--Columnas SCD Tipo 2
	[FechaInicioValidez] DATETIME NOT NULL DEFAULT(GETDATE()),
	[FechaFinValidez] DATETIME NULL,
	--Columnas Auditoria
	FechaCreacion DATETIME NULL DEFAULT(GETDATE()),
	UsuarioCreacion NVARCHAR(100) NULL DEFAULT(SUSER_NAME()),
	FechaModificacion DATETIME NULL,
	UsuarioModificacion NVARCHAR(100) NULL,
	--Columnas Linaje
	--ID_Batch UNIQUEIDENTIFIER NULL,
	--ID_SourceSystem VARCHAR(20)	
PRIMARY KEY CLUSTERED 
(
	[SK_Partes] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [Dimension].[Geografia]  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dimension].[Geografia](
	[SK_Geografia] [dbo].[UDT_SK] IDENTITY(1,1) NOT NULL,
	[ID_Pais] [dbo].[UDT_PK] NULL,
	[ID_Region] [dbo].[UDT_PK] NULL,
	[ID_Ciudad] [dbo].[UDT_PK] NULL,
	[NombrePais] [dbo].[UDT_VarcharCorto] NULL,
	[NombreRegion] [dbo].[UDT_VarcharCorto] NULL,
	[NombreCiudad] [dbo].[UDT_VarcharCorto] NULL,
	[CodigoPostal] [dbo].[UDT_Int] NULL,
	--Columnas SCD Tipo 2
	[FechaInicioValidez] DATETIME NOT NULL DEFAULT(GETDATE()),
	[FechaFinValidez] DATETIME NULL,
	--Columnas Auditoria
	FechaCreacion DATETIME NOT NULL DEFAULT(GETDATE()),
	UsuarioCreacion NVARCHAR(100) NOT NULL DEFAULT(SUSER_NAME()),
	FechaModificacion DATETIME NULL,
	UsuarioModificacion NVARCHAR(100) NULL,
	--Columnas Linaje
	--ID_Batch UNIQUEIDENTIFIER NULL,
	--ID_SourceSystem VARCHAR(50)
	
PRIMARY KEY CLUSTERED 
(
	[SK_Geografia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [Dimension].[Clientes]  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dimension].[Clientes](
	[SK_Clientes] [dbo].[UDT_SK] IDENTITY(1,1) NOT NULL,
	[ID_Cliente] [dbo].[UDT_PK] NULL,
	[PrimerNombre] [dbo].[UDT_VarcharCorto] NULL,
	[SegundoNombre] [dbo].[UDT_VarcharCorto] NULL,
	[PrimerApellido] [dbo].[UDT_VarcharCorto] NULL,
	[SegundoApellido] [dbo].[UDT_VarcharCorto] NULL,
	[Genero] [dbo].[UDT_UnCaracter] NULL,
	[Correo_Electronico] [dbo].[UDT_VarcharCorto] NULL,
	[Fecha_Nacimiento] [dbo].[UDT_DateTime] NULL,
	--Columnas SCD Tipo 2
	[FechaInicioValidez] DATETIME NOT NULL DEFAULT(GETDATE()),
	[FechaFinValidez] DATETIME NULL,
	--Columnas Auditoria
	FechaCreacion DATETIME NOT NULL DEFAULT(GETDATE()),
	UsuarioCreacion NVARCHAR(100) NOT NULL DEFAULT(SUSER_NAME()),
	FechaModificacion DATETIME NULL,
	UsuarioModificacion NVARCHAR(100) NULL,
	--Columnas Linaje
	--ID_Batch UNIQUEIDENTIFIER NULL,
	--ID_SourceSystem VARCHAR(50)
	
PRIMARY KEY CLUSTERED 
(
	[SK_Clientes] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [Dimension].[Fecha] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dimension].[Fecha](
	[DateKey] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[Day] [tinyint] NOT NULL,
	[DaySuffix] [char](2) NOT NULL,
	[Weekday] [tinyint] NOT NULL,
	[WeekDayName] [varchar](10) NOT NULL,
	[WeekDayName_Short] [char](3) NOT NULL,
	[WeekDayName_FirstLetter] [char](1) NOT NULL,
	[DOWInMonth] [tinyint] NOT NULL,
	[DayOfYear] [smallint] NOT NULL,
	[WeekOfMonth] [tinyint] NOT NULL,
	[WeekOfYear] [tinyint] NOT NULL,
	[Month] [tinyint] NOT NULL,
	[MonthName] [varchar](10) NOT NULL,
	[MonthName_Short] [char](3) NOT NULL,
	[MonthName_FirstLetter] [char](1) NOT NULL,
	[Quarter] [tinyint] NOT NULL,
	[QuarterName] [varchar](6) NOT NULL,
	[Year] [int] NOT NULL,
	[MMYYYY] [char](6) NOT NULL,
	[MonthYear] [char](7) NOT NULL,
	[IsWeekend] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [Fact].[Orden]  ******/
DROP TABLE IF EXISTS FACT.Orden 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Fact].[Orden](
	[SK_Orden] [dbo].[UDT_SK] IDENTITY(1,1) NOT NULL,
	[SK_Partes] [dbo].[UDT_SK] NULL,
	[SK_Geografia] [dbo].[UDT_SK] NULL,
	[SK_Clientes] [dbo].[UDT_SK] NULL,
	[DateKey] [int] NULL,
	[ID_Orden] [dbo].[UDT_PK] NULL,
	[ID_StatusOrden] [dbo].[UDT_PK] NULL,
	[Total_Orden] [dbo].[UDT_Decimal12.2] NULL,
	[Fecha_Orden] DATETIME NOT NULL,
	--Columnas Auditoria
	FechaCreacion DATETIME NOT NULL DEFAULT(GETDATE()),
	UsuarioCreacion VARCHAR(100) NOT NULL DEFAULT(SUSER_NAME()),
	FechaModificacion DATETIME NULL,
	UsuarioModificacion VARCHAR(100) NULL,
	--Columnas Linaje
	ID_Batch UNIQUEIDENTIFIER NULL,
	ID_SourceSystem VARCHAR(50)
PRIMARY KEY CLUSTERED 
(
	[SK_Orden] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [Fact].[Orden]  WITH CHECK ADD FOREIGN KEY([DateKey])
REFERENCES [Dimension].[Fecha] ([DateKey])
GO
ALTER TABLE [Fact].[Orden]  WITH CHECK ADD FOREIGN KEY([SK_Partes])
REFERENCES [Dimension].[Partes] ([SK_Partes])
GO
ALTER TABLE [Fact].[Orden]  WITH CHECK ADD FOREIGN KEY([SK_Geografia])
REFERENCES [Dimension].[Geografia] ([SK_Geografia])
GO
ALTER TABLE [Fact].[Orden]  WITH CHECK ADD FOREIGN KEY([SK_Clientes])
REFERENCES [Dimension].[Clientes] ([SK_Clientes])
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

--DimPartes
INSERT INTO Dimension.Partes
	(ID_Parte, 
	 ID_Categoria, 
	 NombreParte, 
	 NombreCategoria,
	 [FechaInicioValidez],
	 [FechaFinValidez],
	 FechaCreacion,
	 UsuarioCreacion,
	 FechaModificacion,
	 UsuarioModificacion,
	 ID_Batch,
	 ID_SourceSystem
	)
	SELECT p.ID_Partes, 
			p.ID_Categoria, 
			p.Nombre as NombreParte, 
			c.Nombre as NombreCategoria
			  --Columnas Auditoria
			  ,GETDATE() AS FechaCreacion
			  ,CAST(SUSER_NAME() AS nvarchar(100)) AS UsuarioCreacion
			  ,GETDATE() AS FechaModificacion
			  ,CAST(SUSER_NAME() AS nvarchar(100)) AS UsuarioModificacion
			  ,CAST('2020-01-01' AS DATETIME) as FechaInicioValidez

	FROM RepuestosWeb.dbo.Partes p
		INNER JOIN RepuestosWeb.dbo.Categoria c ON(c.ID_Categoria = p.ID_Categoria);
		
--DimGeografia
INSERT INTO Dimension.Geografia
([ID_Candidato], 
	[ID_Colegio], 
	[ID_Diversificado], 
	[NombreCandidato], 
	[ApellidoCandidato], 
	[Genero], 
	[FechaNacimiento], 
	[NombreColegio], 
	[NombreDiversificado],
	[FechaInicioValidez],
	[FechaFinValidez],
	FechaCreacion,
	UsuarioCreacion,
	FechaModificacion,
	UsuarioModificacion,
	ID_Batch,
	ID_SourceSystem
)
SELECT p.ID_Pais, 
		r.ID_Region, 
		c.ID_Ciudad, 
		p.Nombre as NombrePais, 
		r.Nombre as NombreRegion,
		c.Nombre as NombreCiudad,
		c.CodigoPostal
			--Columnas Auditoria
			,GETDATE() AS FechaCreacion
			,CAST(SUSER_NAME() AS nvarchar(100)) AS UsuarioCreacion
			,GETDATE() AS FechaModificacion
			,CAST(SUSER_NAME() AS nvarchar(100)) AS UsuarioModificacion
			,CAST('2020-01-01' AS DATETIME) as FechaInicioValidez
FROM RepuestosWeb.DBO.Pais p
	INNER JOIN RepuestosWeb.DBO.Region r ON(r.ID_Pais = p.ID_Pais)
	INNER JOIN RepuestosWeb.DBO.Ciudad c ON(C.ID_Region = r.ID_Region);
GO

--DimClientes
INSERT INTO Dimension.Candidato
([ID_Candidato], 
	[ID_Colegio], 
	[ID_Diversificado], 
	[NombreCandidato], 
	[ApellidoCandidato], 
	[Genero], 
	[FechaNacimiento], 
	[NombreColegio], 
	[NombreDiversificado],
	[FechaInicioValidez],
	[FechaFinValidez],
	FechaCreacion,
	UsuarioCreacion,
	FechaModificacion,
	UsuarioModificacion,
	ID_Batch,
	ID_SourceSystem
)
SELECT c.ID_Cliente,
			c.PrimerNombre,
			c.SegundoNombre,
			c.PrimerApellido,
			c.SegundoApellido,
			c.Genero,
			c.Correo_Electronico,
			c.FechaNacimiento
			--Columnas Auditoria
			,GETDATE() AS FechaCreacion
			,CAST(SUSER_NAME() AS nvarchar(100)) AS UsuarioCreacion
			,GETDATE() AS FechaModificacion
			,CAST(SUSER_NAME() AS nvarchar(100)) AS UsuarioModificacion
			,CAST('2020-01-01' AS DATETIME) as FechaInicioValidez
FROM RepuestosWeb.DBO.Clientes c
GO

--Dimension Fecha (SP que llena la dimension)
	
CREATE PROCEDURE USP_FillDimDate @CurrentDate DATE = '2016-01-01', 
									@EndDate     DATE = '2022-12-31'
AS
	BEGIN
		SET NOCOUNT ON;
		WHILE @CurrentDate < @EndDate
			BEGIN
				IF NOT EXISTS (SELECT 1 FROM Dimension.Fecha WHERE DATE = @CurrentDate)
				INSERT INTO Dimension.Fecha
				([DateKey], 
					[Date], 
					[Day], 
					[DaySuffix], 
					[Weekday], 
					[WeekDayName], 
					[WeekDayName_Short], 
					[WeekDayName_FirstLetter], 
					[DOWInMonth], 
					[DayOfYear], 
					[WeekOfMonth], 
					[WeekOfYear], 
					[Month], 
					[MonthName], 
					[MonthName_Short], 
					[MonthName_FirstLetter], 
					[Quarter], 
					[QuarterName], 
					[Year], 
					[MMYYYY], 
					[MonthYear], 
					[IsWeekend]
				)
						SELECT DateKey = YEAR(@CurrentDate) * 10000 + MONTH(@CurrentDate) * 100 + DAY(@CurrentDate), 
								DATE = @CurrentDate, 
								Day = DAY(@CurrentDate), 
								[DaySuffix] = CASE
												WHEN DAY(@CurrentDate) = 1
														OR DAY(@CurrentDate) = 21
														OR DAY(@CurrentDate) = 31
												THEN 'st'
												WHEN DAY(@CurrentDate) = 2
														OR DAY(@CurrentDate) = 22
												THEN 'nd'
												WHEN DAY(@CurrentDate) = 3
														OR DAY(@CurrentDate) = 23
												THEN 'rd'
												ELSE 'th'
											END, 
								WEEKDAY = DATEPART(dw, @CurrentDate), 
								WeekDayName = DATENAME(dw, @CurrentDate), 
								WeekDayName_Short = UPPER(LEFT(DATENAME(dw, @CurrentDate), 3)), 
								WeekDayName_FirstLetter = LEFT(DATENAME(dw, @CurrentDate), 1), 
								[DOWInMonth] = DAY(@CurrentDate), 
								[DayOfYear] = DATENAME(dy, @CurrentDate), 
								[WeekOfMonth] = DATEPART(WEEK, @CurrentDate) - DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM, 0, @CurrentDate), 0)) + 1, 
								[WeekOfYear] = DATEPART(wk, @CurrentDate), 
								[Month] = MONTH(@CurrentDate), 
								[MonthName] = DATENAME(mm, @CurrentDate), 
								[MonthName_Short] = UPPER(LEFT(DATENAME(mm, @CurrentDate), 3)), 
								[MonthName_FirstLetter] = LEFT(DATENAME(mm, @CurrentDate), 1), 
								[Quarter] = DATEPART(q, @CurrentDate), 
								[QuarterName] = CASE
													WHEN DATENAME(qq, @CurrentDate) = 1
													THEN 'First'
													WHEN DATENAME(qq, @CurrentDate) = 2
													THEN 'second'
													WHEN DATENAME(qq, @CurrentDate) = 3
													THEN 'third'
													WHEN DATENAME(qq, @CurrentDate) = 4
													THEN 'fourth'
												END, 
								[Year] = YEAR(@CurrentDate), 
								[MMYYYY] = RIGHT('0' + CAST(MONTH(@CurrentDate) AS VARCHAR(2)), 2) + CAST(YEAR(@CurrentDate) AS VARCHAR(4)), 
								[MonthYear] = CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + UPPER(LEFT(DATENAME(mm, @CurrentDate), 3)), 
								[IsWeekend] = CASE
												WHEN DATENAME(dw, @CurrentDate) = 'Sunday'
														OR DATENAME(dw, @CurrentDate) = 'Saturday'
												THEN 1
												ELSE 0
											END     ;
				SET @CurrentDate = DATEADD(DD, 1, @CurrentDate);
			END;
	END;
go

exec USP_FillDimDate @CurrentDate = '2016-01-01', 
						@EndDate     = '2022-12-31'

