USE RepuestosWebDWH
GO

--Creamos tabla para log de fact batches
CREATE TABLE FactLog
(
	ID_Batch UNIQUEIDENTIFIER DEFAULT(NEWID()),
	FechaEjecucion DATETIME DEFAULT(GETDATE()),
	NuevosRegistros INT,
	CONSTRAINT [PK_FactLog] PRIMARY KEY
	(
		ID_Batch
	)
)
GO

--Agregamos FK
ALTER TABLE Fact.Orden ADD CONSTRAINT [FK_IDBatch] FOREIGN KEY (ID_Batch) 
REFERENCES Factlog(ID_Batch)
go

--alter table Fact.Orden add ID_Batch UNIQUEIDENTIFIER NULL



/****** Object:  Table [staging].[Examen]    Script Date: 8/31/2020 6:34:39 PM ******/
create schema [staging]
go

DROP TABLE IF EXISTS [staging].Orden
GO

CREATE TABLE [staging].[Orden](
	[ID_Orden] [int] NOT NULL,
	[ID_Cliente] [int] not null,
	[ID_Ciudad] [int] not null,
	[ID_StatusOrden] [int] NULL,
	[ID_Parte] [int] null,
	[Total_Orden] [decimal](12, 2) NULL,
	[Fecha_Orden] datetime null,
	[FechaModificacion] DATETIME NULL,

) ON [PRIMARY]
GO

--Query para llenar datos en Staging
SELECT o.ID_Orden, 
c.ID_Cliente,
o.ID_Ciudad,
       o.ID_StatusOrden,
	   do.ID_Partes,
       o.Total_Orden,
	   o.Fecha_Orden,
       o.FechaModificacion 
FROM dbo.Orden o
inner join dbo.Clientes c on (c.ID_Cliente = o.ID_Cliente)
inner join dbo.Detalle_orden do on (do.ID_Orden = o.ID_Orden)
WHERE ((Fecha_Orden>?) OR (FechaModificacion>?))
go

SELECT o.ID_Orden, 
c.ID_Cliente,
o.ID_Ciudad,
       o.ID_StatusOrden,
	   do.ID_Partes,
       o.Total_Orden,
	   o.Fecha_Orden,
       o.FechaModificacion 
FROM RepuestosWeb.dbo.Orden o
inner join RepuestosWeb.dbo.Clientes c on (c.ID_Cliente = o.ID_Cliente)
inner join RepuestosWeb.dbo.Detalle_orden do on (do.ID_Orden = o.ID_Orden)
--WHERE ((Fecha_Orden>?) OR (FechaModificacion>?))
WHERE ((Fecha_Orden>'2021-09-19') OR (FechaModificacion>'2021-09-19'))
go

select * from staging.Orden

select * from Dimension.Partes



